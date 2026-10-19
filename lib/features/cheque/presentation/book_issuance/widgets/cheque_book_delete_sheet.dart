import 'package:flutter/material.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

import '../cubit/cheque_book_cubit.dart';

Future<void> showChequeBookDeleteSheet(
  BuildContext context,
  DeliveryAddress address,
) {
  return showAppServiceSheet<void>(
    context,
    AppDeleteAddressSheet(
      variant: AppDeleteAddressSheetVariant.compact,
      title: '',
      address: address.detail,
      postalCode: address.postalCode,
      postalCodeLabel: S.current.issuancePostalCode,
      prompt: S.current.chequeBookDeletePrompt,
      confirmLabel: S.current.chequeBookDeleteContinue,
      cancelLabel: S.current.agentCancel,
      onConfirm: () {
        context.read<ChequeBookCubit>().deleteAddress(address);
        Navigator.of(context).pop();
      },
      onCancel: () => Navigator.of(context).pop(),
    ),
    scrimColor: AppDashboardColors.sheetScrim.withValues(alpha: .64),
  );
}
