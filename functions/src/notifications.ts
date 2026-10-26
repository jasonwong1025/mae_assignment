import { DocumentData, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db, region } from "./firebase";

interface Message {
  /** Stable per event, so a retried trigger never notifies twice. */
  id: string;
  uid: string;
  title: string;
  body: string;
  orderId: string;
}

interface ShortageLine {
  lineId?: string;
  name?: string;
  packSize?: string;
}

type Shortages = Record<string, { status?: string; replacement?: ShortageLine }>;

/** "Fresh Milk 1L", or null when the line has no name. */
function lineName(line: ShortageLine | undefined): string | null {
  const name = line?.name?.trim();
  if (!name) return null;
  const size = line?.packSize?.trim();
  return size ? `${name} ${size}` : name;
}

/** What each status change tells the customer. */
function statusMessage(order: DocumentData, status: string): { title: string; body: string } | null {
  const number = order.number;
  const delivery = order.isDelivery === true;
  switch (status) {
    case "packing":
      return { title: `Packing started for order #${number}`, body: "The store is picking your items now." };
    case "ready":
      return delivery
        ? { title: `Order #${number} is packed`, body: "A driver will collect it shortly." }
        : {
          title: `Order #${number} is ready for pickup`,
          body: `Show your QR code at ${order.branchName ?? "the store"}.`,
        };
    case "outForDelivery":
      return { title: `Order #${number} is on the way`, body: "Follow your driver in the app." };
    case "completed":
      return {
        title: `Order #${number} ${delivery ? "delivered" : "collected"}`,
        body: "Thank you for shopping with Grocerly.",
      };
    case "cancelled":
      return { title: `Order #${number} was cancelled`, body: "Any payment is refunded to your wallet." };
    default:
      return null;
  }
}

/** Works out who to tell about this change. Pure, so it is easy to test. */
export function messagesFor(before: DocumentData, after: DocumentData, orderId: string): Message[] {
  const messages: Message[] = [];
  const number = after.number;

  if (before.status !== after.status) {
    const text = statusMessage(after, after.status as string);
    if (text && after.customerId) {
      messages.push({ id: `${orderId}-status-${after.status}`, uid: after.customerId, orderId, ...text });
    }
  }

  const beforeShortages = (before.shortages ?? {}) as Shortages;
  const afterShortages = (after.shortages ?? {}) as Shortages;
  const items = (after.items ?? []) as ShortageLine[];
  for (const [lineId, shortage] of Object.entries(afterShortages)) {
    if (!after.customerId) break;
    const previous = beforeShortages[lineId]?.status;
    const item = lineName(items.find((line) => line.lineId === lineId)) ?? "An item";
    if (shortage.status === "proposed" && previous !== "proposed") {
      const replacement = lineName(shortage.replacement);
      messages.push({
        id: `${orderId}-shortage-${lineId}`, uid: after.customerId, orderId,
        title: `Your reply is needed on order #${number}`,
        body: replacement
          ? `${item} is unavailable. We suggest ${replacement}. Accept it or remove the item.`
          : `${item} is unavailable. Choose a replacement or remove it.`,
      });
    } else if (shortage.status === "removed" && previous === undefined) {
      // Removed straight away because nothing could replace it. A removal
      // after a proposal is the customer's own choice, so it is not told.
      messages.push({
        id: `${orderId}-removed-${lineId}`, uid: after.customerId, orderId,
        title: `An item was removed from order #${number}`,
        body: `${item} is unavailable and has no replacement. ` +
          "You will be refunded for it when packing finishes.",
      });
    }
  }

  if (after.packerId && after.packerId !== before.packerId) {
    messages.push({
      id: `${orderId}-packer-${after.packerId}`, uid: after.packerId, orderId,
      title: "New order to pack", body: `Order #${number} was assigned to you.`,
    });
  }
  if (after.driverId && after.driverId !== before.driverId) {
    messages.push({
      id: `${orderId}-driver-${after.driverId}`, uid: after.driverId, orderId,
      title: "New delivery", body: `Order #${number} was assigned to you.`,
    });
  }
  return messages;
}

async function deliver(message: Message): Promise<void> {
  const inbox = db.doc(`users/${message.uid}/notifications/${message.id}`);
  try {
    await inbox.create({
      title: message.title, body: message.body, orderId: message.orderId,
      read: false, createdAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    // Already delivered for this event: a retried trigger.
    if ((error as { code?: number }).code === 6) return;
    throw error;
  }

  const devices = await db.collection(`users/${message.uid}/devices`).get();
  const tokens = devices.docs.map((doc) => doc.id);
  if (tokens.length === 0) return;
  try {
    const result = await getMessaging().sendEachForMulticast({
      tokens,
      notification: { title: message.title, body: message.body },
      data: { orderId: message.orderId },
      android: { priority: "high" },
    });
    // Forget phones that no longer accept messages (app removed, token rotated).
    await Promise.all(result.responses.map(async (response, index) => {
      const code = response.error?.code;
      if (code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token") {
        await devices.docs[index].ref.delete();
      }
    }));
  } catch (error) {
    // The inbox entry is saved; a push that fails (no network, emulator) must
    // not fail the order update that caused it.
    console.warn("Push notification failed", error);
  }
}

export const notifyOrderChanges = onDocumentUpdated(
  { document: "orders/{orderId}", region },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    await Promise.all(messagesFor(before, after, event.params.orderId).map(deliver));
  },
);
