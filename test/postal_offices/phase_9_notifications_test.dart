import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/postal_offices/data/repositories/mock_postal_offices_repository.dart';
import 'package:pishkhan_mobile/features/postal_offices/domain/entities/postal_office.dart';
import 'package:pishkhan_mobile/features/postal_offices/domain/repositories/postal_offices_repository.dart';
import 'package:pishkhan_mobile/features/postal_offices/presentation/lookup/cubit/postal_offices_cubit.dart';
import 'package:pishkhan_mobile/features/postal_offices/presentation/lookup/widgets/postal_offices_sheet.dart';
import 'package:pishkhan_mobile/features/postal_offices/presentation/lookup/widgets/postal_offices_results.dart';

import '../deposits/certificate_test_support.dart';

class RetryingPostalRepository extends MockPostalOfficesRepository {
  bool failProvinces = true;
  bool failOffices = true;
  @override
  Future<Result<List<PostalProvince>>> fetchProvinces() => failProvinces
      ? Future.value(const Err(DataFailure('timeout')))
      : super.fetchProvinces();
  @override
  Future<Result<List<PostalOffice>>> fetchPostalOffices(String cityId) =>
      failOffices
      ? Future.value(const Err(DataFailure('timeout')))
      : super.fetchPostalOffices(cityId);
}

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('pishkhan/platform_share'),
          null,
        );
    await getIt.reset();
  });
  testWidgets(
    'postal failures repeat per operation; success can share twice with retained error text',
    (tester) async {
      final repository = RetryingPostalRepository();
      await getIt.unregister<PostalOfficesRepository>();
      getIt.registerSingleton<PostalOfficesRepository>(repository);
      final shares = <String>[];
      var failShare = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('pishkhan/platform_share'),
            (call) async {
              if (failShare) throw PlatformException(code: 'unavailable');
              shares.add(call.arguments as String);
              return null;
            },
          );
      await mountCertificate(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              return AppButton(
                label: 'Open postal',
                onPressed: () => showPostalOfficesSheet(context),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open postal'));
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(PostalOfficesSheet))
          .read<PostalOfficesCubit>();
      expect(find.byType(AvpSnackBar), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await cubit.fetchProvinces();
      await tester.pumpAndSettle();
      expect(find.byType(AvpSnackBar), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      repository.failProvinces = false;
      await cubit.fetchProvinces();
      await tester.pumpAndSettle();
      cubit.selectProvince(cubit.state.provinces.first);
      cubit.selectCity(cubit.state.cities.first);
      for (var attempt = 0; attempt < 2; attempt++) {
        await cubit.searchPostalOffices();
        await tester.pumpAndSettle();
        expect(find.byType(AvpSnackBar), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
      repository.failOffices = false;
      await cubit.searchPostalOffices();
      await tester.pumpAndSettle();
      expect(cubit.state.postalOfficesStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(find.byType(PostalOfficesResults), findsOneWidget);
      for (var attempt = 0; attempt < 2; attempt++) {
        cubit.requestPostalShare();
        await tester.pumpAndSettle();
      }
      expect(shares, hasLength(2));
      expect(shares.toSet(), {cubit.state.postalShareText});
      expect(shares.first, contains(cubit.state.postalOffices.first.address));
      expect(find.byType(AvpSnackBar), findsNothing);
      failShare = true;
      for (var attempt = 0; attempt < 2; attempt++) {
        cubit.requestPostalShare();
        await tester.pumpAndSettle();
        expect(cubit.state.shareStatus, RequestStatus.failure);
        expect(cubit.state.failure?.code, 'platform.share.unavailable');
        expect(find.byType(AvpSnackBar), findsOneWidget);
        expect(
          find.text('اشتراک‌گذاری در این دستگاه در دسترس نیست.'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
      failShare = false;
      cubit.requestPostalShare();
      await tester.pumpAndSettle();
      expect(cubit.state.shareStatus, RequestStatus.success);
      expect(cubit.state.message, 'اشتراک‌گذاری در این دستگاه در دسترس نیست.');
      expect(find.byType(AvpSnackBar), findsNothing);
      expect(shares, hasLength(3));
      expect(tester.takeException(), isNull);
    },
  );
}
