import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';

import '../../helpers/worker_test_app.dart';

// Every Store Worker screen at narrow-to-wide phone widths, with normal and
// enlarged system text. A layout overflow anywhere fails the test.

/// Phone widths to check, narrowest to widest common phones.
const _widths = [320.0, 360.0, 430.0];

/// Normal text and the larger system text many older users choose.
const _textScales = [1.0, 1.3];

/// Tall enough that most of each screen is built, so overflows further
/// down a list are caught too.
const _height = 2000.0;

/// Opens the app as [worker] at the given width and text size.
Future<(ProviderContainer, WorkerOrdersRepository)> _pump(
  WidgetTester tester, {
  required String worker,
  required double width,
  required double textScale,
}) async {
  final result = await pumpWorkerApp(
    tester,
    worker,
    location: AppRoutes.workerDevSelect,
  );
  tester.view.physicalSize = Size(width, _height);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpAndSettle();
  return result;
}

Future<void> _show(
  WidgetTester tester,
  ProviderContainer container,
  String location,
) async {
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  for (final width in _widths) {
    for (final textScale in _textScales) {
      final size = '${width.toInt()}dp, text x$textScale';

      testWidgets('Packing Staff screens fit at $size', (tester) async {
        final (container, repository) = await _pump(
          tester,
          worker: 'Daniel Lee',
          width: width,
          textScale: textScale,
        );

        // Selector, then the three packer tabs.
        expect(find.text('Store Worker preview'), findsOneWidget);
        await _show(tester, container, AppRoutes.workerPacking);
        expect(find.text('#2301'), findsOneWidget);
        await _show(tester, container, AppRoutes.workerPickup);
        await _show(tester, container, AppRoutes.workerAccount);

        // Packing screens: being packed, pending, cancelled.
        for (final id in ['ord-2302', 'ord-2301', 'ord-2311']) {
          await _show(tester, container, AppRoutes.workerPackingOrder(id));
        }

        // Review sheet and success screen for a fully packed order.
        await repository.setItemPacked(
          mockWorker('Daniel Lee'),
          'ord-2303',
          'L4',
          packed: true,
        );
        await _show(tester, container, AppRoutes.workerPackingOrder('ord-2303'));
        await _tap(tester, 'Review & mark ready');
        await _tap(tester, 'Mark as ready');
        expect(find.text('Order #2303 is ready'), findsOneWidget);

        // Handover screen, verified, with its confirmation sheet.
        await _show(tester, container, AppRoutes.workerPickupOrder('ord-2306'));
        await _tap(tester, 'Customer gave order number #2306');
        await _tap(tester, 'Name matches Kelvin Lim');
        await _tap(tester, 'Complete pickup');
        expect(find.text('Hand over order #2306?'), findsOneWidget);
        await _tap(tester, 'Cancel');

        // A handed-over record.
        await _show(tester, container, AppRoutes.workerPickupOrder('ord-2307'));
      });

      testWidgets('Delivery Driver screens fit at $size', (tester) async {
        final (container, _) = await _pump(
          tester,
          worker: 'Amir Hamzah',
          width: width,
          textScale: textScale,
        );

        await _show(tester, container, AppRoutes.workerDelivery);
        expect(find.text('READY TO COLLECT (1)'), findsOneWidget);
        await _show(tester, container, AppRoutes.workerAccount);

        // Being packed.
        await _show(tester, container, AppRoutes.workerDeliveryOrder('ord-2303'));

        // Ready, with the verify sheet showing an error.
        await _show(tester, container, AppRoutes.workerDeliveryOrder('ord-2308'));
        await _tap(tester, 'Verify order');
        await tester.enterText(find.byType(TextField), '1');
        await _tap(tester, 'Verify');
        expect(find.textContaining('does not match'), findsOneWidget);
        await _tap(tester, 'Cancel');

        // On the way, items opened, with the confirmation sheet.
        await _show(tester, container, AppRoutes.workerDeliveryOrder('ord-2309'));
        await _tap(tester, 'Order items (2 products · 3 items)');
        await _tap(tester, 'Mark as delivered');
        await _tap(tester, 'Cancel');

        // Delivered.
        await _show(tester, container, AppRoutes.workerDeliveryOrder('ord-2310'));
      });
    }
  }
}
