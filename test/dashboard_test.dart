import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/core/theme/app_theme.dart';
import 'package:midterm_cross_platform/screens/dashboard_screen.dart';
import 'package:midterm_cross_platform/services/cloudinary_service.dart';
import 'package:midterm_cross_platform/services/firestore_service.dart';
import 'widget_test.dart' show TestAuth;

void main() {
  for (final width in [375.0, 1440.0]) {
    testWidgets(
      'Dashboard at $width supports product search and confirmed delete',
      (tester) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = FakeFirebaseFirestore();
        await db.collection('product').doc('a').set({
          'name': 'Bút bi',
          'price': 12500.0,
          'soluong': 3,
          'image': '',
        });
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: DashboardScreen(
              auth: TestAuth(),
              firestore: FirestoreService(db),
              cloudinary: CloudinaryService(),
              adminEmail: 'admin@example.com',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Bút bi'), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'nobody');
        await tester.pumpAndSettle();
        expect(find.text('Không tìm thấy kết quả'), findsOneWidget);
        await tester.tap(find.byTooltip('Xóa tìm kiếm'));
        await tester.pumpAndSettle();
        expect(find.text('Bút bi'), findsOneWidget);
        expect(find.text('12500,00 ₫'), findsOneWidget);
        final delete = width >= 850
            ? find.byTooltip('Xóa Bút bi')
            : find.text('Xóa');
        await tester.ensureVisible(delete);
        await tester.tap(delete);
        await tester.pumpAndSettle();
        expect(find.text('Xóa sản phẩm?'), findsOneWidget);
        await tester.tap(find.text('Hủy'));
        await tester.pumpAndSettle();
        expect((await db.collection('product').get()).docs, hasLength(1));
        await tester.tap(delete);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Xóa sản phẩm'));
        await tester.pumpAndSettle();
        expect((await db.collection('product').get()).docs, isEmpty);
        expect(find.text('Chưa có sản phẩm'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
