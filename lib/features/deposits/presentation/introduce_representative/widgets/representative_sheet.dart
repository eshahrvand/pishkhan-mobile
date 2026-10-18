import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../cubit/representative_cubit.dart';
import 'representative_form.dart';

Future<void> showRepresentativeSheet(
  BuildContext context,
  RepresentativeCubit cubit,
) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceSubtle,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: AppRadius.xl),
    ),
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const RepresentativeSheet()),
  );
}

class RepresentativeSheet extends StatelessWidget {
  const RepresentativeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RepresentativeCubit, RepresentativeState>(
      listenWhen: (previous, current) =>
          previous.draftSavedId != current.draftSavedId,
      listener: (context, state) => context.pop(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBottomSheetHeader(
                    title: S.current.representativeAddNext,
                    showLeftAction: false,
                    showRightIcon: false,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: RepresentativeForm(fieldSpacing: 12),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: S.current.representativeCancel,
                            variant: AppButtonVariant.secondaryGray,
                            size: AppButtonSize.lg,
                            onPressed: () => context.pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child:
                              BlocBuilder<
                                RepresentativeCubit,
                                RepresentativeState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.canSaveDraft !=
                                    current.canSaveDraft,
                                builder: (context, state) {
                                  return AppButton(
                                    label: S.current.representativeSave,
                                    size: AppButtonSize.lg,
                                    disabledAppearance:
                                        AppButtonDisabledAppearance.service,
                                    onPressed: state.canSaveDraft
                                        ? context
                                              .read<RepresentativeCubit>()
                                              .saveDraft
                                        : null,
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
