import 'package:flutter_test/flutter_test.dart';
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
}
