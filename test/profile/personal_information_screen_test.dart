import 'dart:async';

import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/profile/presentation/addresses/cubit/addresses_cubit.dart';
import 'package:pishkhan_mobile/features/profile/presentation/change_phone/cubit/change_phone_cubit.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
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
import 'package:pishkhan_mobile/features/profile/presentation/job_information/cubit/job_information_cubit.dart';
import 'package:pishkhan_mobile/features/profile/presentation/job_information/screens/job_information_screen.dart';
import 'package:pishkhan_mobile/features/profile/domain/entities/personal_information.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';
import 'package:pishkhan_mobile/features/profile/presentation/job_information/widgets/job_information_list.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/shared/widgets/app_job_information_card.dart';

import '../deposits/certificate_test_support.dart';

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  Future<void> capture(WidgetTester tester, String name) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pumpAndSettle();
    await captureCertificate(tester, 'profile-$name');
  }

  testWidgets('both Back paths wait for every concurrent address review', (
    tester,
  ) async {
    final repository = PendingAddressReviewRepository();
    await getIt.unregister<PersonalInformationRepository>();
    getIt.registerSingleton<PersonalInformationRepository>(repository);
    await mountCertificate(
      tester,
      Builder(
        builder: (context) => AppButton(
          label: 'open addresses',
          onPressed: () =>
              ServiceRegistry.openCardService(context, 'identity-addresses'),
        ),
      ),
    );
    await tester.tap(find.text('open addresses'));
    await tester.pumpAndSettle();
    final cubit = tester.element(find.byType(AppTopBar)).read<AddressesCubit>();
    await tester.runAsync(
      () => cubit.applyAddressEditor(
        const DeliveryAddress(
          id: 'second-home',
          title: 'Second home',
          detail: 'Synthetic address',
          postalCode: '1234567890',
        ),
      ),
    );
    await tester.pumpAndSettle();
    final first = cubit.state.addresses[1];
    final second = cubit.state.addresses.last;
    final firstRequest = cubit.submitAddressReview(first);
    final secondRequest = cubit.submitAddressReview(second);
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<AppTopBar>(find.byType(AppTopBar)).onTrailingPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AddressesScreen), findsOneWidget);
    repository.reviews[first.address.id]!.complete(
      const Success(ResidenceStatus.valid),
    );
    await firstRequest;
    await tester.pump();
    expect(
      tester.widget<AppTopBar>(find.byType(AppTopBar)).onTrailingPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(AddressesScreen), findsOneWidget);
    repository.reviews[second.address.id]!.complete(
      const Err(DataFailure('review.failed')),
    );
    await secondRequest;
    await tester.pumpAndSettle();
    expect(
      cubit.state.reviewStatuses[second.address.id],
      RequestStatus.failure,
    );
    expect(
      tester.widget<AppTopBar>(find.byType(AppTopBar)).onTrailingPressed,
      isNotNull,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    cubit.requestAddressActions(first);
    await tester.pumpAndSettle();
    expect(find.text(S.current.profileEditAddress), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    Navigator.of(tester.element(find.text(S.current.profileEditAddress))).pop();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('open addresses'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'phone repeated failures do not block terms or successful submission',
    (tester) async {
      await mountCertificate(tester, const ChangePhoneScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<ChangePhoneCubit>();
      cubit.updatePhoneNumber('09123456789');
      final otpRequest = cubit.submitOtpRequest();
      await tester.pumpAndSettle();
      await otpRequest;
      cubit.updateOtp('0000');
      cubit.updateTerms(true);
      for (var attempt = 0; attempt < 2; attempt++) {
        final submission = cubit.submitPhoneChange();
        await tester.pumpAndSettle();
        await submission;
        expect(cubit.state.submissionStatus, RequestStatus.failure);
        expect(find.byType(SnackBar), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
      cubit.requestTerms();
      await tester.pumpAndSettle();
      expect(find.text(S.current.issuanceTermsUnavailable), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      cubit.updateOtp('2345');
      final submission = cubit.submitPhoneChange();
      await tester.pumpAndSettle();
      await submission;
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(cubit.state.otp, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'occupation retry retains identity and effects survive the last error',
    (tester) async {
      final repository = RetryingJobInformationRepository();
      await getIt.unregister<PersonalInformationRepository>();
      getIt.registerSingleton<PersonalInformationRepository>(repository);
      await mountCertificate(tester, const JobInformationScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<JobInformationCubit>();
      final jobInformation = cubit.state.jobInformation;
      cubit.requestNewJobInformation();
      cubit.selectKind(JobInformationKind.designer);
      cubit.updateDescription('Designer');
      cubit.updateTerms(true);
      for (var attempt = 0; attempt < 2; attempt++) {
        final submission = cubit.submitJobInformation();
        await tester.pumpAndSettle();
        await submission;
        expect(find.byType(SnackBar), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
      cubit.requestTerms();
      await tester.pumpAndSettle();
      expect(find.text(S.current.issuanceTermsUnavailable), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      repository.fail = false;
      final submission = cubit.submitJobInformation();
      await tester.pumpAndSettle();
      await submission;
      expect(repository.keys.toSet(), hasLength(1));
      expect(cubit.state.jobInformation, jobInformation);
      expect(cubit.state.failure, isNotNull);
      expect(find.text(S.current.profileJobInformationQueued), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(AppButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(cubit.state.step, JobInformationStep.list);
      expect(find.byType(AppJobInformationCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('each failed address review notifies again after retry', (
    tester,
  ) async {
    await getIt.unregister<PersonalInformationRepository>();
    getIt.registerSingleton<PersonalInformationRepository>(
      FailingAddressReviewRepository(),
    );
    await mountCertificate(tester, const AddressesScreen());
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.text(S.current.profileReview));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(S.current.profileReviewError), findsNothing);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });
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
              find.byType(JobInformationScreen).evaluate().length,
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
        AppRoutes.jobInformation,
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
                widget is AvpImage &&
                widget.image == '${AppConstants.baseImage}profile_lock.svg',
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
      await mountCertificate(tester, const JobInformationScreen());
      await capture(tester, 'occupations-list');
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppJobInformationCard).last,
              matching: find.byType(InkWell),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-actions');
      await tester.tap(find.text(S.current.profileEditJobInformation));
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-edit');
      final cubit = tester
          .element(find.byType(AppCheckbox))
          .read<JobInformationCubit>();
      cubit.selectKind(JobInformationKind.professor);
      cubit.updateDescription('مدرس مدیریت سیستم‌ها');
      cubit.updateTerms(true);
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-edit-filled');
      cubit.selectKind(JobInformationKind.homemaker);
      await tester.pumpAndSettle();
      expect(cubit.state.requiresOperatorReview, isTrue);
      await capture(tester, 'occupation-operator-review');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(S.current.flowExitTitle), findsOneWidget);
      await tester.tap(find.text(S.current.passwordExit));
      await tester.pumpAndSettle();
      expect(find.byType(AppJobInformationCard), findsNWidgets(2));
      await tester.tap(find.text(S.current.profileAddJobInformation));
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-new');
      cubit.selectKind(JobInformationKind.homemaker);
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
      cubit.selectKind(JobInformationKind.teacher);
      cubit.updateDescription('مدرس');
      cubit.updateTerms(true);
      await tester.pumpAndSettle();
      await capture(tester, 'occupation-new-filled');
      await tester.tap(find.text(S.current.profileSubmit));
      await tester.pumpAndSettle();
      expect(find.text(S.current.profileJobInformationQueued), findsOneWidget);
      await tester.tap(find.text(S.current.backLabel));
      await tester.pumpAndSettle();
      expect(find.byType(AppJobInformationCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'occupation confirmation supports dismissal and cancel; last occupation shows the required notice',
    (tester) async {
      await mountCertificate(tester, const JobInformationScreen());
      Future<void> requestDelete() async {
        await tester.tap(
          find
              .descendant(
                of: find.byType(AppJobInformationCard).first,
                matching: find.byType(InkWell),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.current.profileDeleteJobInformation));
        await tester.pumpAndSettle();
      }

      await requestDelete();
      expect(find.byType(AppDecisionSheet), findsOneWidget);
      expect(
        find.text(
          S.current.profileDeleteJobInformationPrompt(
            S.current.profileDesigner,
          ),
        ),
        findsOneWidget,
      );
      await capture(tester, 'occupation-delete-confirmation');
      await tester.tap(find.text(S.current.dashboardCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AppJobInformationCard), findsNWidgets(2));
      await requestDelete();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AppJobInformationCard), findsNWidgets(2));
      await requestDelete();
      await tester.tap(find.text(S.current.chequeCancelRemove));
      await tester.pumpAndSettle();
      expect(find.byType(AppJobInformationCard), findsOneWidget);
      await requestDelete();
      expect(find.text(S.current.profileMinimumJobInformation), findsOneWidget);
      expect(find.text(S.current.chequeCancelRemove), findsNothing);
      await capture(tester, 'occupation-minimum');
      await tester.tap(find.text(S.current.passwordUnderstood));
      await tester.pumpAndSettle();
      expect(find.byType(AppJobInformationCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'empty occupation response centers its message within the list area',
    (tester) async {
      await getIt.unregister<PersonalInformationRepository>();
      getIt.registerSingleton<PersonalInformationRepository>(
        EmptyJobInformationRepository(),
      );
      await mountCertificate(tester, const JobInformationScreen());
      final area = tester.getRect(find.byType(JobInformationList));
      expect(
        tester.getCenter(find.text(S.current.profileJobInformationEmpty)).dx,
        closeTo(area.center.dx, .5),
      );
      expect(
        tester.getCenter(find.text(S.current.profileJobInformationEmpty)).dy,
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
          const JobInformationScreen(),
          size: const Size(320, 640),
          locale: locale,
          scale: 1.1,
        );
        await tester.tap(find.text(S.current.profileAddJobInformation));
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 200);
        await tester.pumpAndSettle();
        expect(
          find.text(S.current.profileJobInformationDescription),
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

class FailingAddressReviewRepository extends MockPersonalInformationRepository {
  @override
  Future<Result<ResidenceStatus>> reviewAddress(DeliveryAddress address) {
    return Future.value(const Err(DataFailure('review.failed')));
  }
}

class EmptyJobInformationRepository extends MockPersonalInformationRepository {
  @override
  Future<Result<List<ProfileJobInformation>>> fetchJobInformation() =>
      Future.value(const Success([]));
}

class PendingAddressReviewRepository extends MockPersonalInformationRepository {
  final reviews = <String, Completer<Result<ResidenceStatus>>>{};
  @override
  Future<Result<ResidenceStatus>> reviewAddress(DeliveryAddress address) {
    final response = Completer<Result<ResidenceStatus>>();
    reviews[address.id] = response;
    return response.future;
  }
}

class RetryingJobInformationRepository
    extends MockPersonalInformationRepository {
  bool fail = true;
  final keys = <String>[];
  @override
  Future<Result<void>> saveJobInformation(
    ProfileJobInformation jobInformation, {
    required String idempotencyKey,
  }) {
    keys.add(idempotencyKey);
    if (fail) return Future.value(const Err(DataFailure('occupation.failed')));
    return super.saveJobInformation(
      jobInformation,
      idempotencyKey: idempotencyKey,
    );
  }
}
