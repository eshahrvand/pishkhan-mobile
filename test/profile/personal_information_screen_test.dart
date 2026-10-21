import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/features/address/presentation/editor/widgets/address_editor_form.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/validated_return_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/features/profile/data/repositories/mock_personal_information_repository.dart';
import 'package:pishkhan_mobile/features/profile/domain/repositories/personal_information_repository.dart';
import 'package:pishkhan_mobile/features/profile/presentation/addresses/screens/addresses_screen.dart';
import 'package:pishkhan_mobile/features/profile/presentation/change_phone/screens/change_phone_screen.dart';
import 'package:pishkhan_mobile/features/profile/presentation/change_phone/widgets/phone_otp_field.dart';
import 'package:pishkhan_mobile/features/profile/presentation/occupations/cubit/occupations_cubit.dart';
import 'package:pishkhan_mobile/features/profile/presentation/occupations/screens/occupations_screen.dart';
import 'package:pishkhan_mobile/features/profile/domain/entities/personal_information.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';
import 'package:pishkhan_mobile/features/profile/presentation/occupations/widgets/occupations_list.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/shared/widgets/app_occupation_card.dart';

import '../deposits/certificate_test_support.dart';

void main() {
  setUpAll(loadCertificateFonts);
  setUp(() {
    getIt.registerSingleton<PersonalInformationRepository>(
      MockPersonalInformationRepository(),
    );
  });
  tearDown(() => getIt.reset());
  Future<void> capture(WidgetTester tester, String name) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pumpAndSettle();
    await captureCertificate(tester, 'profile-$name');
  }

  testWidgets(
    'all three services open through the registry and back returns to the caller',
    (tester) async {
      for (final service in [
        'identity-phone',
        'identity-addresses',
        'identity-occupation',
      ]) {
        await mountCertificate(
          tester,
          Builder(
            builder: (context) => AppButton(
              label: 'open service',
              onPressed: () {
                ServiceRegistry.openCardService(context, service);
              },
            ),
          ),
        );
        await tester.tap(find.text('open service'));
        await tester.pumpAndSettle();
        expect(find.text('open service'), findsNothing);
        expect(
          find.byType(ChangePhoneScreen).evaluate().length +
              find.byType(AddressesScreen).evaluate().length +
              find.byType(OccupationsScreen).evaluate().length,
          1,
        );
        await tester.tap(find.byTooltip(S.current.backLabel));
        await tester.pumpAndSettle();
        if (service == 'identity-phone') {
          await tester.tap(find.text(S.current.passwordExit));
          await tester.pumpAndSettle();
        }
        expect(find.text('open service'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
      for (final path in [
        AppRoutes.changePhone,
        AppRoutes.addresses,
        AppRoutes.occupations,
      ]) {
        expect(validatedReturnLocation(path), path);
      }
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'phone form has live validation, OTP request, countdown, consent and disabled repeat submit',
    (tester) async {
      await mountCertificate(tester, const ChangePhoneScreen());
      expect(
        tester.getSize(
          find.byWidgetPredicate(
            (widget) =>
                widget is AvpImage && widget.image == AppAssets.profileLock,
          ),
        ),
        const Size(20, 20),
      );
      await capture(tester, 'phone-empty');
      final number = find.byType(EditableText).at(1);
      await tester.enterText(number, '0');
      await tester.pump();
      expect(find.text(S.current.authInvalidPhone), findsOneWidget);
      await tester.enterText(number, '09126903456');
      await tester.pumpAndSettle();
      await capture(tester, 'phone-filled');
      await tester.tap(find.text(S.current.profileRequestOtp));
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileRequestOtp), findsNothing);
      await tester.enterText(
        find.descendant(
          of: find.byType(PhoneOtpField),
          matching: find.byType(EditableText),
        ),
        '2345',
      );
      await tester.tap(find.byType(AppCheckbox));
      await tester.pumpAndSettle();
      await capture(tester, 'phone-ready');
      final submit = find.widgetWithText(AppButton, S.current.issuanceSubmit);
      expect(tester.widget<AppButton>(submit).onPressed, isNotNull);
      await tester.tap(submit);
      await tester.pump();
      expect(
        tester
            .widgetList<AppButton>(find.byType(AppButton))
            .any((button) => button.isLoading),
        isTrue,
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.profilePhoneSubmitted), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'address list checks explicitly, then editor and deletion operate on chosen address',
    (tester) async {
      await mountCertificate(tester, const AddressesScreen());
      await capture(tester, 'addresses-list');
      expect(find.text(S.current.profileReview), findsOneWidget);
      await tester.tap(find.text(S.current.profileReview));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(S.current.profileQuerying), findsOneWidget);
      await captureCertificate(tester, 'profile-addresses-querying');
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileValid), findsOneWidget);
      await capture(tester, 'addresses-valid');
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppAddressCard).last,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await capture(tester, 'address-actions');
      await tester.tap(find.text(S.current.profileEditAddress));
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileEditAddress), findsOneWidget);
      expect(find.byType(EditableText), findsNWidgets(4));
      await tester.tap(find.text(S.current.issuanceSaveAddress));
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileReview), findsOneWidget);
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppAddressCard).last,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.profileEditAddress));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).last, '1234567890');
      await tester.tap(find.text(S.current.issuanceSaveAddress));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.profileReview));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileMissingResidence), findsOneWidget);
      await capture(tester, 'addresses-missing');
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppAddressCard).last,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.profileDeleteAddress));
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileMinimumAddress), findsOneWidget);
      await capture(tester, 'address-minimum-home');
      await tester.tap(find.text(S.current.passwordUnderstood));
      await tester.pumpAndSettle();
      expect(find.byType(AppAddressCard), findsNWidgets(2));
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppAddressCard).first,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.profileDeleteAddress));
      await tester.pumpAndSettle();
      expect(find.byType(AppDeleteAddressSheet), findsOneWidget);
      await capture(tester, 'address-delete-confirmation');
      // Outside dismissal does not delete.
      await tester.tapAt(const Offset(180, 200));
      await tester.pumpAndSettle();
      expect(find.byType(AppAddressCard), findsNWidgets(2));
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppAddressCard).first,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.profileDeleteAddress));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AppAddressCard), findsNWidgets(2));
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppAddressCard).first,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.profileDeleteAddress));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.chequeCancelRemove));
      await tester.pumpAndSettle();
      expect(find.byType(AppAddressCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'editing the last home warns inside the editor and preserves typed input',
    (tester) async {
      await mountCertificate(tester, const AddressesScreen());
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppAddressCard).last,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.profileEditAddress));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(1), 'عنوان حفظ‌شده');
      await tester.tap(find.byType(AppSelect<DeliveryAddressType>));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AppSelectSheet<DeliveryAddressType>),
          matching: find.text(S.current.profileWork),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileMinimumAddress), findsOneWidget);
      expect(find.byType(AddressEditorForm), findsOneWidget);
      await capture(tester, 'address-edit-minimum-home');
      await tester.tap(find.text(S.current.passwordUnderstood));
      await tester.pumpAndSettle();
      expect(find.text('عنوان حفظ‌شده'), findsOneWidget);
      expect(
        tester
            .widget<AppSelect<DeliveryAddressType>>(
              find.byType(AppSelect<DeliveryAddressType>),
            )
            .value,
        DeliveryAddressType.home,
      );
      await tester.tap(find.text(S.current.issuanceSaveAddress));
      await tester.pumpAndSettle();
      expect(find.text('عنوان حفظ‌شده'), findsOneWidget);
      expect(find.byType(AppAddressCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'occupation actions, editable fields, incompatible option and operator-review state',
    (tester) async {
      await mountCertificate(tester, const OccupationsScreen());
      await capture(tester, 'occupations-list');
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppOccupationCard).last,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-actions');
      await tester.tap(find.text(S.current.profileEditOccupation));
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-edit');
      final cubit = tester
          .element(find.byType(AppCheckbox))
          .read<OccupationsCubit>();
      cubit.selectKind(OccupationKind.professor);
      cubit.updateDescription('مدرس مدیریت سیستم‌ها');
      cubit.updateTerms(true);
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-edit-filled');
      cubit.selectKind(OccupationKind.homemaker);
      await tester.pumpAndSettle();
      expect(cubit.state.requiresOperatorReview, isTrue);
      await capture(tester, 'occupation-operator-review');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(S.current.flowExitTitle), findsOneWidget);
      await tester.tap(find.text(S.current.passwordExit));
      await tester.pumpAndSettle();
      expect(find.byType(AppOccupationCard), findsNWidgets(2));
      await tester.tap(find.text(S.current.profileAddOccupation));
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-new');
      cubit.selectKind(OccupationKind.homemaker);
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-conflict');
      expect(
        tester
            .widget<AppButton>(
              find.widgetWithText(AppButton, S.current.profileSubmit),
            )
            .onPressed,
        isNull,
      );
      cubit.selectKind(OccupationKind.teacher);
      cubit.updateDescription('مدرس');
      cubit.updateTerms(true);
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-new-filled');
      await tester.tap(find.text(S.current.profileSubmit));
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileOccupationQueued), findsOneWidget);
      await tester.tap(find.text(S.current.backLabel));
      await tester.pumpAndSettle();
      expect(find.byType(AppOccupationCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'occupation confirmation supports dismissal and cancel; last occupation shows the required notice',
    (tester) async {
      await mountCertificate(tester, const OccupationsScreen());
      Future<void> requestDelete() async {
        await tester.tap(
          find
              .descendant(
                of: find.byType(AppOccupationCard).first,
                matching: find.byType(InkWell),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.current.profileDeleteOccupation));
        await tester.pumpAndSettle();
      }

      await requestDelete();
      expect(find.byType(AppDecisionSheet), findsOneWidget);
      expect(
        find.text(
          S.current.profileDeleteOccupationPrompt(S.current.profileDesigner),
        ),
        findsOneWidget,
      );
      await capture(tester, 'occupation-delete-confirmation');
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AppOccupationCard), findsNWidgets(2));
      await requestDelete();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AppOccupationCard), findsNWidgets(2));
      await requestDelete();
      await tester.tap(find.text(S.current.chequeCancelRemove));
      await tester.pumpAndSettle();
      expect(find.byType(AppOccupationCard), findsOneWidget);
      await requestDelete();
      expect(find.text(S.current.profileMinimumOccupation), findsOneWidget);
      expect(find.text(S.current.chequeCancelRemove), findsNothing);
      await capture(tester, 'occupation-minimum');
      await tester.tap(find.text(S.current.passwordUnderstood));
      await tester.pumpAndSettle();
      expect(find.byType(AppOccupationCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'empty occupation response centers its message within the list area',
    (tester) async {
      await getIt.unregister<PersonalInformationRepository>();
      getIt.registerSingleton<PersonalInformationRepository>(
        EmptyOccupationsRepository(),
      );
      await mountCertificate(tester, const OccupationsScreen());
      final area = tester.getRect(find.byType(OccupationsList));
      expect(
        tester.getCenter(find.text(S.current.profileOccupationsEmpty)).dx,
        closeTo(area.center.dx, .5),
      );
      expect(
        tester.getCenter(find.text(S.current.profileOccupationsEmpty)).dy,
        closeTo(area.center.dy, .5),
      );
      await capture(tester, 'occupations-empty');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'new address uses the shared editor; cancel leaves list unchanged',
    (tester) async {
      await mountCertificate(tester, const AddressesScreen());
      await tester.tap(find.text(S.current.profileAddAddress));
      await tester.pumpAndSettle();
      await capture(tester, 'address-editor');
      expect(
        tester
            .getBottomRight(
              find.widgetWithText(AppButton, S.current.issuanceSaveAddress),
            )
            .dy,
        lessThanOrEqualTo(772),
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(S.current.issuanceSaveAddress));
      await tester.pumpAndSettle();
      expect(
        tester
            .getBottomRight(
              find.widgetWithText(AppButton, S.current.issuanceSaveAddress),
            )
            .dy,
        lessThanOrEqualTo(592),
      );
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AppAddressCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'forms remain usable with keyboard at narrow English and Arabic widths',
    (tester) async {
      for (final locale in ['en', 'ar']) {
        await mountCertificate(
          tester,
          const ChangePhoneScreen(),
          size: const Size(320, 640),
          locale: locale,
          scale: 1.1,
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 200);
        await tester.pumpAndSettle();
        expect(find.text(S.current.profileChangePhone), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = const FakeViewPadding();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await mountCertificate(
          tester,
          const OccupationsScreen(),
          size: const Size(320, 640),
          locale: locale,
          scale: 1.1,
        );
        await tester.tap(find.text(S.current.profileAddOccupation));
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 200);
        await tester.pumpAndSettle();
        expect(
          find.text(S.current.profileOccupationDescription),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = const FakeViewPadding();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
    },
  );
}

class EmptyOccupationsRepository extends MockPersonalInformationRepository {
  @override
  Future<Result<List<ProfileOccupation>>> fetchOccupations() =>
      Future.value(const Success([]));
}
