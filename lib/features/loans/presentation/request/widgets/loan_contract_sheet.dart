import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../cubit/loan_request_cubit.dart';

class LoanContractSheet extends StatefulWidget {
  const LoanContractSheet({super.key});

  @override
  State<LoanContractSheet> createState() {
    return _LoanContractSheetState();
  }
}

class _LoanContractSheetState extends State<LoanContractSheet> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoanRequestCubit, LoanRequestState>(
      buildWhen: (previous, current) =>
          previous.termsAccepted != current.termsAccepted ||
          previous.catalog != current.catalog,
      builder: (context, state) {
        return SizedBox(
          height:
              MediaQuery.sizeOf(context).height -
              MediaQueryData.fromView(View.of(context)).viewPadding.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBottomSheetHeader(
                title: S.current.loanRequestContract,
                showRightIcon: false,
                showLeftAction: false,
              ),
              Expanded(
                child: ScrollbarTheme(
                  data: ScrollbarTheme.of(context).copyWith(
                    thumbColor: WidgetStatePropertyAll(
                      context.colors.borderSubtle,
                    ),
                    crossAxisMargin: 24,
                    mainAxisMargin: 20,
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        20,
                        48,
                        20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.catalog!.contractText == null) ...[
                            Text(
                              S.current.loanRequestMockContract,
                              style: AppTypography.bodySmall.copyWith(
                                color: context.colors.warning,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Text(
                            state.catalog!.contractText ??
                                S.current.loanRequestMockContractBody,
                            style: AppTypography.bodySmall.copyWith(
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              color: AppPalette.gray700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: context.colors.borderSubtle),
              Padding(
                padding: const EdgeInsets.all(20),
                child: MergeSemantics(
                  child: Row(
                    children: [
                      AppCheckbox(
                        value: state.termsAccepted,
                        onChanged: context
                            .read<LoanRequestCubit>()
                            .updateTermsAccepted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: context
                              .read<LoanRequestCubit>()
                              .toggleTermsAcceptance,
                          child: Text(
                            S.current.loanRequestTerms,
                            style: AppTypography.bodySmall.copyWith(
                              letterSpacing: 0,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: S.current.loanRequestDownloadContract,
                        size: AppButtonSize.lg,
                        horizontalPadding: 8,
                        constrainLabel: true,
                        variant: AppButtonVariant.secondaryGray,
                        onPressed: context
                            .read<LoanRequestCubit>()
                            .requestUnavailable,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: S.current.loanRequestContractAccept,
                        size: AppButtonSize.lg,
                        horizontalPadding: 8,
                        labelStyle: MediaQuery.sizeOf(context).width < 360
                            ? AppTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              )
                            : null,
                        constrainLabel: true,
                        isActive: state.termsAccepted,
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
