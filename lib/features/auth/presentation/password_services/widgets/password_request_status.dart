import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:pishkhan_mobile/features/auth/domain/entities/password_data.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

class PasswordRecordSheet extends StatelessWidget {
  const PasswordRecordSheet({
    super.key,
    required this.record,
    required this.newlySubmitted,
    required this.operation,
  });
  final PasswordRequestRecord record;
  final bool newlySubmitted;
  final PasswordOperation operation;
  @override
  Widget build(BuildContext context) {
    final change = operation == PasswordOperation.changePassword;
    final approved = record.status == PasswordRequestStatus.approved || change;
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (approved) ...[
                Center(
                  child: SizedBox(
                    width: 57.0045,
                    height: 59.9961,
                    child: SvgPicture.asset(AppAssets.passwordApproved),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                approved
                    ? l.passwordApprovedTitle
                    : newlySubmitted
                    ? l.passwordSubmittedTitle
                    : l.passwordPendingTitle,
                textAlign: TextAlign.center,
                style: passwordBody(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Text(
                change
                    ? l.passwordChangeSuccessBody
                    : approved
                    ? l.passwordApprovedBody
                    : newlySubmitted
                    ? l.passwordSubmittedBody
                    : l.passwordPendingBody,
                textAlign: approved || newlySubmitted
                    ? TextAlign.center
                    : TextAlign.start,
                style: passwordBody(context),
              ),
              if (approved || newlySubmitted) ...[
                SizedBox(height: change ? 12 : 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.passwordTracking,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: context.colors.textTertiary,
                                height: 18 / 12,
                              ),
                        ),
                      ),
                      SelectableText(
                        record.trackingCode ?? '—',
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppPasswordServiceColors.body,
                          height: 18 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (record.isMock) ...[
                const SizedBox(height: 12),
                Text(
                  l.passwordMockReceipt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: context.colors.textTertiary,
                    height: 18 / 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
          child: AppButton(
            onPressed: () => context.pop(),
            label: l.passwordUnderstood,
            size: AppButtonSize.lg,
            constrainLabel: true,
          ),
        ),
      ],
    );
  }
}

/// Full-page content for a returning change-password request status check.
class PasswordStatusContent extends StatelessWidget {
  const PasswordStatusContent({super.key, required this.record});
  final PasswordRequestRecord record;
  @override
  Widget build(BuildContext context) {
    final approved = record.status == PasswordRequestStatus.approved;
    final l = context.l10n;
    return Column(
      children: [
        SizedBox(
          width: 95.0099,
          height: 99.9961,
          child: SvgPicture.asset(AppAssets.passwordStatusSuccess),
        ),
        const SizedBox(height: 40),
        Text(
          approved ? l.passwordApprovedTitle : l.passwordStatusRegisteredTitle,
          textAlign: TextAlign.center,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Text(
          approved ? l.passwordChangeSuccessBody : l.passwordSubmittedBody,
          textAlign: TextAlign.center,
          style: passwordBody(context),
        ),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.surfaceSubtle,
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.passwordTracking,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: context.colors.textTertiary,
                    height: 18 / 12,
                  ),
                ),
              ),
              SelectableText(
                record.trackingCode ?? '—',
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppPasswordServiceColors.body,
                  fontWeight: FontWeight.w500,
                  height: 18 / 12,
                ),
              ),
            ],
          ),
        ),
        if (record.isMock) ...[
          const SizedBox(height: 12),
          Text(
            l.passwordMockReceipt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall!
                .copyWith(color: context.colors.textTertiary, height: 18 / 12),
          ),
        ],
      ],
    );
  }
}
