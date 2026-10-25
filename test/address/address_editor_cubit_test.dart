import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/features/address/presentation/editor/cubit/address_editor_cubit.dart';

void main() {
  test(
    'address validation follows edits and clears the failed-submit message',
    () async {
      final cubit = AddressEditorCubit();
      addTearDown(cubit.close);
      cubit.submitAddress();
      expect(cubit.state.isInvalid, isTrue);
      expect(cubit.state.savedAddress, isNull);
      cubit.updateTitle(' دفتر ');
      expect(cubit.state.isTitleValid, isTrue);
      expect(cubit.state.isInvalid, isTrue);
      cubit.updateDetail(' تهران، خیابان نمونه ');
      cubit.updatePostalCode('۱۲۳۴۵۶۷۸۹۰');
      expect(cubit.state.isPostalCodeValid, isTrue);
      expect(cubit.state.isInvalid, isFalse);
      cubit.submitAddress();
      expect(cubit.state.savedAddress!.title, 'دفتر');
      expect(cubit.state.savedAddress!.postalCode, '1234567890');
    },
  );

  test(
    'correcting one field retains the other field validity outcomes',
    () async {
      final cubit = AddressEditorCubit();
      addTearDown(cubit.close);
      cubit.updateTitle('Home');
      cubit.updateDetail('Address');
      cubit.updatePostalCode('123');
      cubit.submitAddress();
      expect(cubit.state.isInvalid, isTrue);
      cubit.updateTitle('Updated home');
      expect(cubit.state.isDetailValid, isTrue);
      expect(cubit.state.isPostalCodeValid, isFalse);
      cubit.updatePostalCode('1234567890');
      expect(cubit.state.isInvalid, isFalse);
      cubit.submitAddress();
      expect(cubit.state.savedAddress!.title, 'Updated home');
    },
  );
  test('last-home restriction keeps the existing type and draft and can show the notice repeatedly', () async {
    const address = DeliveryAddress(
      id: 'home',
      title: 'Home',
      detail: 'old',
      postalCode: '1234567890',
      phoneNumber: '02112345678',
    );
    final cubit = AddressEditorCubit(
      initialAddress: address,
      includeContact: true,
      retainHomeAddress: true,
    );
    addTearDown(cubit.close);
    cubit.fetchAddress();
    cubit.updateDetail('new detail');
    cubit.selectType(DeliveryAddressType.work);
    expect(cubit.state.type, DeliveryAddressType.home);
    expect(cubit.state.detail, 'new detail');
    expect(cubit.state.effect, AddressEditorEffect.minimumHomeNotice);
    cubit.consumeAddressEditorInteraction();
    expect(cubit.state.effect, isNull);
    expect(cubit.state.savedAddress, isNull);
    cubit.selectType(DeliveryAddressType.work);
    expect(cubit.state.effect, AddressEditorEffect.minimumHomeNotice);
    cubit.submitAddress();
    expect(cubit.state.savedAddress!.type, DeliveryAddressType.home);
    expect(cubit.state.savedAddress!.detail, 'new detail');
  });
  test(
    'correcting the contact telephone clears a failed-submit error',
    () async {
      final cubit = AddressEditorCubit(includeContact: true);
      addTearDown(cubit.close);
      cubit.updateTitle('Home');
      cubit.updateDetail('Address');
      cubit.updatePostalCode('1234567890');
      cubit.updatePhoneNumber('021');
      cubit.submitAddress();
      expect(cubit.state.isInvalid, isTrue);
      cubit.updatePhoneNumber('۰۲۱۱۲۳۴۵۶۷۸');
      expect(cubit.state.isInvalid, isFalse);
      cubit.submitAddress();
      expect(cubit.state.savedAddress!.phoneNumber, '02112345678');
    },
  );
}
