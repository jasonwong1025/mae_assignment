// Builds a repeatable history of completed orders (and customer reviews for
// most of them), so Sales, Reviews and the Dashboard have something to show.
//
// Everything is derived from a fixed random seed, so running the seed twice
// writes the same orders (same ids, same contents). Times are relative to
// the moment the seed runs: the last order of each day is never in the
// future, and the history always ends "today".
//
// Documents written (see DATABASE/FIRESTORE.md):
//   orders/hist-<branch>-<n>   completed orders, newest numbers last
//   reviews/hist-<branch>-<n>  one review for about 6 in 10 of them

/** Days of history before today. */
const DAYS = 35;

/** Orders per day on a weekday, per branch. Weekends are 30% busier. */
const ORDERS_PER_DAY = { ss15: 11, "bukit-jalil": 6, puchong: 3 };

/** Order numbers: far above the live counter, so they never clash. */
const FIRST_NUMBER = { ss15: 3000, "bukit-jalil": 4000, puchong: 5000 };

/** Hours of the day orders are placed, with how popular each is. */
const HOUR_WEIGHTS = [
  [8, 2], [9, 3], [10, 3], [11, 4], [12, 6], [13, 5], [14, 3], [15, 3],
  [16, 4], [17, 6], [18, 8], [19, 8], [20, 4],
];

const CUSTOMERS = [
  ["Farah Idris", "012-345 6789"], ["Wong Kar Yee", "016-221 4480"],
  ["Nur Aisyah", "013-778 9021"], ["Mei Ling Tan", "017-909 1123"],
  ["David Wong", "019-334 5567"], ["Siti Aminah", "011-2345 6780"],
  ["Ooi Hui Min", "012-618 3390"], ["Ahmad Fauzi", "019-870 2215"],
  ["Raj Kumar", "012-887 4410"], ["Lim Jia Hui", "014-330 8821"],
  ["Hannah Yusuf", "018-902 4417"], ["Chong Wei Ming", "016-774 2290"],
];

const COMMENTS = [
  "Everything arrived fresh. Thank you!",
  "Fast delivery and the driver was polite.",
  "One item was missing, but support sorted it out.",
  "Good prices and the packing was neat.",
  "Bread was a little squashed.",
  "Will order again.",
  "Substitution was not what I wanted.",
  "Quick and easy, as always.",
];

/** Small deterministic random number generator (mulberry32). */
function randomFrom(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function pick(random, list) {
  return list[Math.floor(random() * list.length)];
}

function pickWeighted(random, weighted) {
  const total = weighted.reduce((sum, [, weight]) => sum + weight, 0);
  let roll = random() * total;
  for (const [value, weight] of weighted) {
    roll -= weight;
    if (roll < 0) return value;
  }
  return weighted[weighted.length - 1][0];
}

/** 1 to 5 stars, mostly 4 and 5. */
function score(random) {
  return pickWeighted(random, [[5, 9], [4, 6], [3, 2], [2, 1], [1, 1]]);
}

/**
 * @param {object} options
 * @param {Date} options.now
 * @param {{id: string, name: string, brand: string, categoryId: string, packSize: string}[]} options.products
 * @param {{id: string, name: string}[]} options.categories
 * @param {Record<string, Record<string, {price: number}>>} options.inventory
 * @param {{id: string, name: string}[]} options.drivers  active drivers
 * @param {{id: string, name: string, location: [number, number], maxDeliveryKm: number}[]} options.branches
 * @returns {{orders: {id: string, data: object}[], reviews: {id: string, data: object}[]}}
 */
export function buildHistory({ now, products, categories, inventory, drivers, branches }) {
  const random = randomFrom(20260101);
  const categoryName = Object.fromEntries(categories.map((c) => [c.id, c.name]));
  const orders = [];
  const reviews = [];

  for (const branch of branches) {
    const perDay = ORDERS_PER_DAY[branch.id] ?? 3;
    // Branches without their own stock (Puchong) are priced like SS15.
    const prices = inventory[branch.id] ?? inventory.ss15;
    const sellable = products.filter((p) => prices[p.id]);
    let number = FIRST_NUMBER[branch.id] ?? 6000;

    for (let daysAgo = DAYS; daysAgo >= 0; daysAgo--) {
      const day = new Date(now);
      day.setDate(day.getDate() - daysAgo);
      const weekend = [0, 6].includes(day.getDay());
      const count = Math.round(perDay * (weekend ? 1.3 : 1) * (0.7 + random() * 0.6));

      for (let i = 0; i < count; i++) {
        const hour = pickWeighted(random, HOUR_WEIGHTS);
        const placed = new Date(day);
        placed.setHours(hour, Math.floor(random() * 60), 0, 0);
        // Nothing is placed in the future, and today's orders are done.
        if (placed > new Date(now.getTime() - 90 * 60000)) continue;

        number += 1;
        const id = `hist-${branch.id}-${number}`;
        const customer = pick(random, CUSTOMERS);
        const isDelivery = random() < 0.7;
        const lineCount = 1 + Math.floor(random() * 4);
        const chosen = new Set();
        while (chosen.size < Math.min(lineCount, sellable.length)) {
          chosen.add(pick(random, sellable));
        }
        const items = [...chosen].map((product, index) => ({
          lineId: `L${index + 1}`,
          productId: product.id,
          name: product.name,
          brand: product.brand,
          packSize: product.packSize,
          quantity: 1 + Math.floor(random() * 3),
          unitPrice: prices[product.id].price,
          categoryId: product.categoryId,
          category: categoryName[product.categoryId] ?? "",
        }));
        const subtotal = round2(items.reduce((sum, i) => sum + i.unitPrice * i.quantity, 0));
        const deliveryFee = isDelivery ? 4 : 0;
        const driver = isDelivery ? pick(random, drivers) : null;
        const minutes = (date) => Math.round((date.getTime() - now.getTime()) / 60000);
        const done = new Date(placed.getTime() + (35 + Math.floor(random() * 40)) * 60000);

        const data = {
          number,
          customerId: `sample-customer-${number}`,
          customerName: customer[0],
          customerPhone: customer[1],
          branchId: branch.id,
          branchName: branch.name,
          isDelivery,
          items,
          subtotal,
          deliveryFee,
          discount: 0,
          total: round2(subtotal + deliveryFee),
          status: "completed",
          placedAt: { $minutes: minutes(placed) },
          statusSince: { $minutes: minutes(done) },
          completedAt: { $minutes: minutes(done) },
          readyAt: { $minutes: minutes(new Date(placed.getTime() + 25 * 60000)) },
        };
        if (isDelivery) {
          data.address = `${1 + Math.floor(random() * 90)}, Jalan Sample ${1 + Math.floor(random() * 20)}`;
          data.driverId = driver.id;
          data.driverName = driver.name;
          data.deliveredBy = driver.id;
          data.deliveredByName = driver.name;
          data.addressLocation = { $geo: [branch.location[0] + (random() - 0.5) * 0.05, branch.location[1] + (random() - 0.5) * 0.05] };
        }
        orders.push({ id, data });

        const writesReview = random() < 0.6;
        const reviewDelay = (30 + Math.floor(random() * 120)) * 60000;
        // A review is written after the order is done, never in the future.
        if (writesReview && done.getTime() + reviewDelay <= now.getTime()) {
          const review = {
            orderNumber: number,
            branchId: branch.id,
            customerId: data.customerId,
            customerName: customer[0],
            shoppingScore: score(random),
            productScore: score(random),
            createdAt: { $minutes: minutes(new Date(done.getTime() + reviewDelay)) },
          };
          if (isDelivery) {
            review.deliveryScore = score(random);
            review.driverId = driver.id;
            review.driverName = driver.name;
          }
          if (random() < 0.4) review.comment = pick(random, COMMENTS);
          reviews.push({ id, data: review });
        }
      }
    }
  }
  return { orders, reviews };
}

function round2(value) {
  return Math.round(value * 100) / 100;
}
