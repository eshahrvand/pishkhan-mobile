import 'package:flutter_bloc/flutter_bloc.dart';

import 'issuance_address_form.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import '../cubit/card_issuance_cubit.dart';

Future<void> showIssuanceAddressSheet(
  BuildContext context,
  CardIssuanceCubit cubit,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.surfaceSubtle,
  builder: (_) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocProvider.value(value: cubit, child: const IssuanceAddressForm()),
  ),
);
