import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/address/presentation/editor/cubit/address_editor_cubit.dart';
import 'package:pishkhan_mobile/features/profile/data/repositories/mock_personal_information_repository.dart';
import 'package:pishkhan_mobile/features/profile/domain/entities/personal_information.dart';
import 'package:pishkhan_mobile/features/profile/domain/repositories/personal_information_repository.dart';
import 'package:pishkhan_mobile/features/profile/presentation/addresses/cubit/addresses_cubit.dart';
import 'package:pishkhan_mobile/features/profile/presentation/change_phone/cubit/change_phone_cubit.dart';
import 'package:pishkhan_mobile/features/profile/presentation/occupations/cubit/occupations_cubit.dart';

void main() {
  late MockPersonalInformationRepository repository;
  setUp(() {
    repository = MockPersonalInformationRepository();
    getIt.registerSingleton<PersonalInformationRepository>(repository);
  });
  tearDown(() => getIt.reset());

  test('constructors preserve supplied state and do not fetch', () async {
    const phoneState = ChangePhoneState.initial(phoneNumber: '123');
    const addressesState = AddressesState.initial(
      effect: AddressEffect.minimumAddress,
    );
    const occupationsState = OccupationsState.initial(description: 'draft');
    final phone = ChangePhoneCubit(initialState: phoneState);
    final addresses = AddressesCubit(initialState: addressesState);
    final occupations = OccupationsCubit(initialState: occupationsState);
    expect(phone.state, phoneState);
    expect(addresses.state, addressesState);
    expect(occupations.state, occupationsState);
    await phone.close();
    await addresses.close();
    await occupations.close();
  });
  test('phone validates live, rejects unchanged number, and resets challenge on change', () async {
    final cubit = ChangePhoneCubit();
    addTearDown(cubit.close);
    await cubit.fetchSettings();
    cubit.updatePhoneNumber('۰');
    expect(cubit.state.isPhoneNumberError, isTrue);
    cubit.updatePhoneNumber(cubit.state.settings!.phoneNumber);
    expect(cubit.state.canRequestOtp, isFalse);
    cubit.updatePhoneNumber('۰۹۱۲۶۹۰۳۴۵۶');
    expect(cubit.state.phoneNumber, '09126903456');
    expect(cubit.state.canRequestOtp, isTrue);
    await cubit.submitOtpRequest();
    cubit.updateOtp('۲۳۴۵');
    cubit.updateTerms(true);
    expect(cubit.state.canSubmit, isTrue);
    cubit.updatePhoneNumber('09123456789');
    expect(cubit.state.challenge, isNull);
    expect(cubit.state.otp, isEmpty);
    expect(cubit.state.canSubmit, isFalse);
    expect(cubit.state.remainingSeconds, 0);
  });
  test('phone submission error is retryable; success clears secret and charges once', () async {
    final cubit = ChangePhoneCubit();
    addTearDown(cubit.close);
    await cubit.fetchSettings();
    cubit.updatePhoneNumber('09126903456');
    await cubit.submitOtpRequest();
    cubit.updateOtp('1111');
    cubit.updateTerms(true);
    await cubit.submitPhoneChange();
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    expect(cubit.state.failure!.code, 'profile.otp.invalid');
    final failedKey = cubit.state.idempotencyKey;
    await cubit.submitPhoneChange();
    expect(cubit.state.idempotencyKey, failedKey);
    cubit.updateOtp('2345');
    await cubit.submitPhoneChange();
    expect(cubit.state.submissionStatus, RequestStatus.success);
    expect(cubit.state.canSubmit, isFalse);
    expect(cubit.state.otp, isEmpty);
    final settings =
        await repository.fetchPhoneSettings() as Success<PhoneSettings>;
    expect(settings.data.phoneNumber, '09126903456');
    expect(settings.data.walletBalanceRial, 700000);
    await repository.changePhone(
      phoneNumber: '09126903456',
      otp: '2345',
      challengeId: cubit.state.challenge!.id,
      idempotencyKey: cubit.state.idempotencyKey!,
    );
    expect(
      (await repository.fetchPhoneSettings() as Success<PhoneSettings>)
          .data
          .walletBalanceRial,
      700000,
    );
  });
  test(
    'OTP expiry disables submit and allows resend without revalidating input',
    () async {
      await getIt.unregister<PersonalInformationRepository>();
      getIt.registerSingleton<PersonalInformationRepository>(
        ShortChallengeRepository(),
      );
      final cubit = ChangePhoneCubit(
        initialState: const ChangePhoneState.initial(
          phoneNumber: '09126903456',
          isPhoneNumberValid: true,
          termsAccepted: true,
          walletSufficient: true,
        ),
      );
      addTearDown(cubit.close);
      await cubit.submitOtpRequest();
      cubit.updateOtp('2345');
      expect(cubit.state.canSubmit, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      expect(cubit.state.canSubmit, isFalse);
      expect(cubit.state.canRequestOtp, isTrue);
    },
  );
  test('wallet balance and terms gate submission', () async {
    final cubit = ChangePhoneCubit(
      initialState: ChangePhoneState.initial(
        challenge: PhoneChallenge(
          id: 'test',
          expiresAt: DateTime.now().add(const Duration(seconds: 30)),
        ),
        isPhoneNumberValid: true,
        remainingSeconds: 30,
      ),
    );
    addTearDown(cubit.close);
    cubit.updateOtp('2345');
    cubit.updateTerms(true);
    expect(cubit.state.canSubmit, isFalse);
  });
  test(
    'address review is explicit and retains each independent result',
    () async {
      final cubit = AddressesCubit();
      addTearDown(cubit.close);
      await cubit.fetchAddresses();
      final home = cubit.state.addresses.last;
      expect(home.status, ResidenceStatus.unchecked);
      final pending = cubit.submitAddressReview(home);
      expect(cubit.state.addresses.last.status, ResidenceStatus.querying);
      await pending;
      expect(cubit.state.addresses.last.status, ResidenceStatus.valid);
      expect(cubit.state.addresses.first.status, ResidenceStatus.unchecked);
      await cubit.applyAddressEditor(
        const DeliveryAddress(
          id: 'missing',
          title: 'خانه',
          detail: 'test',
          postalCode: '1234567890',
          phoneNumber: '02112345678',
        ),
      );
      await cubit.submitAddressReview(cubit.state.addresses.last);
      expect(cubit.state.addresses.last.status, ResidenceStatus.missing);
    },
  );
  test('address edits preserve identity, reset inquiry; dismissed sheets do not mutate', () async {
    final cubit = AddressesCubit();
    addTearDown(cubit.close);
    await cubit.fetchAddresses();
    final address = cubit.state.addresses.last;
    cubit.requestAddressActions(address);
    cubit.applyAddressAction(null);
    await cubit.applyAddressEditor(null);
    expect(cubit.state.addresses, hasLength(2));
    await cubit.submitAddressReview(address);
    await cubit.applyAddressEditor(
      DeliveryAddress(
        id: address.address.id,
        title: 'جدید',
        detail: 'updated',
        postalCode: '1234567890',
        phoneNumber: '02112345678',
      ),
    );
    expect(cubit.state.addresses, hasLength(2));
    expect(cubit.state.addresses.last.status, ResidenceStatus.unchecked);
    expect(cubit.state.addresses.last.address.detail, 'updated');
    final work = cubit.state.addresses.first;
    cubit.requestAddressActions(work);
    cubit.applyAddressAction(AddressAction.delete);
    expect(cubit.state.effect, AddressEffect.confirmDeletion);
    expect(cubit.state.addresses, hasLength(2));
    await cubit.submitDeletion(work);
    expect(cubit.state.addresses, hasLength(1));
    expect(
      (await repository.fetchAddresses() as Success<List<ProfileAddress>>).data,
      hasLength(1),
    );
  });
  test('last occupation cannot be removed in the flow or repository', () async {
    final cubit = OccupationsCubit();
    addTearDown(cubit.close);
    await cubit.fetchOccupations();
    final first = cubit.state.occupations.first;
    cubit.requestOccupationActions(first);
    cubit.applyOccupationAction(OccupationAction.delete);
    expect(cubit.state.effect, OccupationEffect.confirmDeletion);
    expect(
      (await repository.fetchOccupations() as Success<List<ProfileOccupation>>)
          .data,
      hasLength(2),
    );
    await cubit.submitDeletion(first);
    final last = cubit.state.occupations.single;
    cubit.requestOccupationActions(last);
    cubit.applyOccupationAction(OccupationAction.delete);
    expect(cubit.state.effect, OccupationEffect.minimumOccupation);
    expect(cubit.state.occupations.single, last);
    expect(await repository.deleteOccupation(last.id), isA<Err<void>>());
    expect(
      (await repository.fetchOccupations() as Success<List<ProfileOccupation>>)
          .data
          .single,
      last,
    );
  });
  test('last home cannot be deleted or converted into work even when another work address exists', () async {
    final cubit = AddressesCubit();
    addTearDown(cubit.close);
    await cubit.fetchAddresses();
    final home = cubit.state.addresses.last;
    cubit.requestAddressActions(home);
    cubit.applyAddressAction(AddressAction.delete);
    expect(cubit.state.effect, AddressEffect.minimumAddress);
    expect(await repository.deleteAddress(home.address.id), isA<Err<void>>());
    final replacement = DeliveryAddress(
      id: home.address.id,
      title: 'work',
      detail: home.address.detail,
      postalCode: home.address.postalCode,
      phoneNumber: home.address.phoneNumber,
      type: DeliveryAddressType.work,
    );
    await cubit.applyAddressEditor(replacement);
    expect(cubit.state.effect, AddressEffect.minimumAddress);
    expect(cubit.state.addresses.last, home);
    expect(
      await repository.saveAddress(replacement),
      isA<Err<ProfileAddress>>(),
    );
    await cubit.submitDeletion(cubit.state.addresses.first);
    cubit.requestAddressActions(home);
    cubit.applyAddressAction(AddressAction.delete);
    expect(cubit.state.effect, AddressEffect.minimumAddress);
    expect(cubit.state.addresses, hasLength(1));
    // After adding another home, the old home may be confirmed for deletion.
    await cubit.applyAddressEditor(
      const DeliveryAddress(
        id: 'second-home',
        title: 'second',
        detail: 'new home',
        postalCode: '1234567890',
      ),
    );
    cubit.requestAddressActions(home);
    cubit.applyAddressAction(AddressAction.delete);
    expect(cubit.state.effect, AddressEffect.confirmDeletion);
    await cubit.submitDeletion(home);
    expect(cubit.state.addresses.single.address.id, 'second-home');
  });
  test(
    'shared editor restores and saves contact fields without changing ID',
    () async {
      const address = DeliveryAddress(
        id: 'work',
        title: 'دفتر',
        detail: 'Address',
        postalCode: '1234567890',
        phoneNumber: '02112345678',
        type: DeliveryAddressType.work,
      );
      final cubit = AddressEditorCubit(
        initialAddress: address,
        includeContact: true,
      );
      addTearDown(cubit.close);
      cubit.fetchAddress();
      expect(cubit.state.type, DeliveryAddressType.work);
      cubit.updatePhoneNumber('۰۲۱۸۸۲۶۱۹۱۴');
      cubit.updateDetail('Updated');
      cubit.submitAddress();
      expect(cubit.state.savedAddress!.id, 'work');
      expect(cubit.state.savedAddress!.phoneNumber, '02188261914');
      expect(cubit.state.savedAddress!.detail, 'Updated');
    },
  );
  test(
    'new occupation conflict blocks submit; editing homemaker requests review',
    () async {
      final cubit = OccupationsCubit();
      addTearDown(cubit.close);
      await cubit.fetchOccupations();
      cubit.requestNewOccupation();
      cubit.selectKind(OccupationKind.homemaker);
      cubit.updateDescription('test');
      cubit.updateTerms(true);
      expect(cubit.state.conflictingOccupation, isNotNull);
      expect(cubit.state.canSubmit, isFalse);
      cubit.selectKind(OccupationKind.professor);
      expect(cubit.state.conflictingOccupation, isNull);
      expect(cubit.state.canSubmit, isTrue);
      cubit.requestOccupationActions(cubit.state.occupations.last);
      cubit.applyOccupationAction(OccupationAction.edit);
      expect(cubit.state.description, 'مدرس تجربه کاربری');
      expect(cubit.state.canSubmit, isFalse);
      cubit.selectKind(OccupationKind.homemaker);
      cubit.updateTerms(true);
      expect(cubit.state.requiresOperatorReview, isTrue);
      expect(cubit.state.conflictingOccupation, isNull);
      expect(cubit.state.canSubmit, isTrue);
    },
  );
  test('occupation submission queues review and returns to list; delete removes selected record', () async {
    final cubit = OccupationsCubit();
    addTearDown(cubit.close);
    await cubit.fetchOccupations();
    cubit.requestNewOccupation();
    cubit.selectKind(OccupationKind.professor);
    cubit.updateDescription('استاد');
    cubit.updateTerms(true);
    await cubit.submitOccupation();
    expect(cubit.state.effect, OccupationEffect.submitted);
    expect(cubit.state.canSubmit, isFalse);
    expect(cubit.state.occupations, hasLength(2));
    cubit.applySubmissionDismissal();
    expect(cubit.state.step, OccupationStep.list);
    cubit.requestOccupationActions(cubit.state.occupations.first);
    cubit.applyOccupationAction(OccupationAction.delete);
    expect(cubit.state.effect, OccupationEffect.confirmDeletion);
    expect(cubit.state.occupations, hasLength(2));
    await cubit.submitDeletion(cubit.state.selectedOccupation!);
    expect(cubit.state.occupations.single.kind, OccupationKind.teacher);
  });
}

class ShortChallengeRepository extends MockPersonalInformationRepository {
  @override
  Future<Result<PhoneChallenge>> requestPhoneOtp(String phoneNumber) =>
      Future.value(
        Success(
          PhoneChallenge(
            id: 'short',
            expiresAt: DateTime.now().toUtc().add(
              const Duration(milliseconds: 300),
            ),
          ),
        ),
      );
}
