import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

Future<T?> showDepositSheet<T>(BuildContext context, Widget panel) =>
    showAppServiceSheet<T>(context, panel);
