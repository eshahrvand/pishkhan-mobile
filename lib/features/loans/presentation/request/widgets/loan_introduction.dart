import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/loan_request_cubit.dart';
import 'loan_training_video.dart';
import 'loan_current_request_card.dart';
import 'loan_completed_request_card.dart';

class LoanIntroduction extends StatelessWidget {
  const LoanIntroduction({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoanTrainingVideo(url: state.catalog!.tutorialUrl),
        const SizedBox(height: 16),
        Text(
          S.current.loanRequestVideoHint,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: context.colors.textSecondary,
            letterSpacing: 0,
          ),
        ),
        if (state.catalog!.currentDraft != null) ...[
          const SizedBox(height: 20),
          LoanCurrentRequestCard(state: state),
        ],
        if (state.catalog!.latestRecord != null) ...[
          const SizedBox(height: 20),
          LoanCompletedRequestCard(state: state),
        ],
      ],
    );
  }
}
