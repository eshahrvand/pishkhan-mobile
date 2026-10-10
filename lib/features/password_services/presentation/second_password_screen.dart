import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../data/mock_password_repository.dart';
import '../domain/password_data.dart';
import 'cubit/second_password_cubit.dart';
import 'password_sheets.dart';

class SecondPasswordScreen extends StatefulWidget {
  const SecondPasswordScreen({
    super.key,
    this.repository,
    this.initialCardNumber,
    this.selectOperation = false,
    this.instructionVideoUrl = demoVideoUrl,
    this.onTermsRequested,
    this.onSubmitted,
    this.videoController,
  });
  static const demoVideoUrl =
      'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4';
  final PasswordServicesRepository? repository;
  final bool selectOperation;
  final String? initialCardNumber, instructionVideoUrl;
  final VideoPlayerController? videoController;
  final VoidCallback? onTermsRequested;
  final ValueChanged<PasswordRequestRecord>? onSubmitted;
  @override
  State<SecondPasswordScreen> createState() => _SecondPasswordScreenState();
}

class _SecondPasswordScreenState extends State<SecondPasswordScreen> {
  late SecondPasswordCubit cubit;
  VideoPlayerController? video;
  bool _sheetOpen = false;
  @override
  void initState() {
    super.initState();
    _createCubit();
    _createVideo();
  }

  void _createCubit() => cubit = SecondPasswordCubit(
    repository: widget.repository ?? MockPasswordServicesRepository(),
    initialCardNumber: widget.initialCardNumber,
    selectOperation: widget.selectOperation,
  )..load();
  void _createVideo() => video =
      widget.videoController ??
      (widget.instructionVideoUrl == null
          ? null
          : VideoPlayerController.networkUrl(
              Uri.parse(widget.instructionVideoUrl!),
            ));
  @override
  void didUpdateWidget(SecondPasswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.initialCardNumber != widget.initialCardNumber ||
        oldWidget.selectOperation != widget.selectOperation) {
      cubit.close();
      _createCubit();
    }
    if (oldWidget.instructionVideoUrl != widget.instructionVideoUrl ||
        oldWidget.videoController != widget.videoController) {
      if (oldWidget.videoController == null) video?.dispose();
      _createVideo();
    }
  }

  @override
  void dispose() {
    cubit.close();
    if (widget.videoController == null) video?.dispose();
    super.dispose();
  }

  Future<void> _back() async {
    if (cubit.state.status == SecondPasswordStatus.checking ||
        cubit.state.status == SecondPasswordStatus.submitting) {
      return;
    }
    if (_fullStatus(cubit.state)) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      return;
    }
    if (cubit.back()) return;
    if (cubit.state.status != SecondPasswordStatus.submitted &&
        cubit.state.selectionComplete) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.passwordExitTitle),
          content: Text(context.l10n.passwordExitBody),
          actions: [
            AppButton(
              onPressed: () => Navigator.of(context).pop(false),
              label: context.l10n.passwordStay,
              variant: AppButtonVariant.text,
              constrainLabel: true,
            ),
            AppButton(
              onPressed: () => Navigator.of(context).pop(true),
              label: context.l10n.passwordExit,
              isDestructive: true,
            ),
          ],
        ),
      );
      if (leave != true || !mounted) return;
    }
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  bool _fullStatus(SecondPasswordState state) =>
      state.isChange &&
      state.record != null &&
      state.status != SecondPasswordStatus.submitted;

  Future<void> _record(SecondPasswordState state) async {
    if (_fullStatus(state)) return;
    if (_sheetOpen || state.record == null || !mounted) return;
    _sheetOpen = true;
    final submitted = state.status == SecondPasswordStatus.submitted;
    if (submitted) widget.onSubmitted?.call(state.record!);
    await showPasswordRecord(
      context,
      state.record!,
      newlySubmitted: submitted,
      operation: state.operation!,
    );
    _sheetOpen = false;
    if (!mounted) return;
    if (submitted) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } else {
      cubit.dismissRecord();
    }
  }

  Widget _icon(String asset, {double size = 20}) => SizedBox.square(
    dimension: size,
    child: SvgPicture.asset(asset, fit: BoxFit.contain),
  );
  String _kind(BuildContext context, PasswordCardKind kind) => switch (kind) {
    PasswordCardKind.resalat => context.l10n.cardFeatureResalat,
    PasswordCardKind.coupon => context.l10n.cardFeatureCoupon,
    PasswordCardKind.gift => context.l10n.cardFeatureGift,
    PasswordCardKind.family => context.l10n.cardFeatureFamily,
  };
  Widget _select<T>(
    String key,
    String title,
    String hint,
    T? value,
    List<AppSelectOption<T>> options,
    ValueChanged<T> change,
  ) => AppSelect<T>(
    key: Key(key),
    label: title,
    hintText: hint,
    value: value,
    options: options,
    onChanged: change,
    labelSpacing: 8,
    labelStyle: AppTypography.bodySmall.copyWith(
      height: 18 / 12,
      fontWeight: FontWeight.w500,
      color: context.colors.textSecondary,
      letterSpacing: 0,
    ),
    textStyle: passwordBody(context).copyWith(
      fontWeight: FontWeight.w400,
      color: value == null
          ? AppPasswordServiceColors.hint
          : context.colors.textPrimary,
    ),
    trailing: _icon(
      value == null
          ? AppAssets.issuanceSelectEmpty
          : AppAssets.cardFeaturesChevron,
    ),
    menuBuilder: (context, options, selected) => showPasswordOptions(
      context,
      title,
      options,
      selected,
      scrimAsset: key == 'password_operation'
          ? AppAssets.passwordOperationScrim
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: cubit,
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<SecondPasswordCubit, SecondPasswordState>(
        listenWhen: (old, next) =>
            old.record != next.record && next.record != null,
        listener: (context, state) => _record(state),
        buildWhen: (old, next) =>
            old.step != next.step ||
            old.status != next.status ||
            old.catalog != next.catalog ||
            old.operation != next.operation ||
            old.kind != next.kind ||
            old.cardId != next.cardId ||
            old.secondPasswordSelected != next.secondPasswordSelected ||
            old.record != next.record ||
            old.failure != next.failure,
        builder: (context, state) => PopScope<void>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: Scaffold(
            backgroundColor:
                state.isChange ||
                    (widget.selectOperation &&
                        state.step == SecondPasswordStep.selection) ||
                    state.step.index >= SecondPasswordStep.instruction.index
                ? context.colors.surface
                : context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: context.l10n.passwordTitle,
                    showLeadingActions: false,
                    trailingIcon: _icon(AppAssets.cardFeaturesBack, size: 24),
                    trailingTooltip: context.l10n.backLabel,
                    onTrailingPressed: _back,
                  ),
                  Expanded(
                    child: _fullStatus(state)
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 36, 16, 20),
                            child: PasswordStatusContent(record: state.record!),
                          )
                        : state.record != null
                        ? const SizedBox.shrink()
                        : SingleChildScrollView(
                            key: ValueKey(state.step),
                            padding: EdgeInsets.fromLTRB(
                              16,
                              (state.step == SecondPasswordStep.password &&
                                          !state.isChange) ||
                                      state.step == SecondPasswordStep.serial
                                  ? 14
                                  : 16,
                              16,
                              20,
                            ),
                            child: _body(context, state),
                          ),
                  ),
                  if (_fullStatus(state))
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppButton(
                        key: const Key('password_status_dismiss'),
                        onPressed: _back,
                        label: context.l10n.passwordUnderstood,
                        size: AppButtonSize.lg,
                        constrainLabel: true,
                      ),
                    ),
                  if (state.record == null &&
                      state.status != SecondPasswordStatus.failed &&
                      state.status != SecondPasswordStatus.empty &&
                      state.status != SecondPasswordStatus.loading)
                    _footer(context),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _body(BuildContext context, SecondPasswordState state) {
    final l = context.l10n;
    if (state.status == SecondPasswordStatus.initial ||
        state.status == SecondPasswordStatus.loading) {
      return Center(
        child: AppButton(
          onPressed: null,
          isLoading: true,
          label: l.dashboardLoading,
        ),
      );
    }
    if (state.status == SecondPasswordStatus.empty ||
        state.status == SecondPasswordStatus.failed) {
      return Column(
        children: [
          Text(
            state.status == SecondPasswordStatus.empty
                ? l.cardsEmpty
                : l.dashboardLoadError,
          ),
          const SizedBox(height: 16),
          AppButton(
            key: const Key('password_retry'),
            onPressed: cubit.load,
            label: l.dashboardRetry,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.failure != null) ...[
          Text(
            l.dashboardLoadError,
            style: passwordBody(context).copyWith(color: context.colors.error),
          ),
          const SizedBox(height: 12),
        ],
        switch (state.step) {
          SecondPasswordStep.selection => _selection(context, state),
          SecondPasswordStep.password => const _PasswordForm(),
          SecondPasswordStep.serial => const _SerialForm(),
          SecondPasswordStep.instruction => _instruction(context),
          SecondPasswordStep.recording => _recording(context),
        },
      ],
    );
  }

  Widget _selection(BuildContext context, SecondPasswordState state) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.passwordSelectionPrompt,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        _select(
          'password_card_kind',
          l.passwordCardType,
          l.passwordCardTypeHint,
          state.kind,
          [
            for (final kind in PasswordCardKind.values)
              AppSelectOption(value: kind, label: _kind(context, kind)),
          ],
          cubit.selectKind,
        ),
        const SizedBox(height: 20),
        _select(
          'password_card_number',
          l.passwordCardNumber,
          l.passwordCardNumberHint,
          state.cardId,
          [
            for (final card in state.catalog!.cards.where(
              (c) => c.kind == (state.kind ?? PasswordCardKind.resalat),
            ))
              AppSelectOption(value: card.id, label: card.number),
          ],
          cubit.selectCard,
        ),
        const SizedBox(height: 20),
        _select(
          'password_type',
          state.card != null && state.secondPasswordSelected
              ? l.passwordOperation
              : l.passwordType,
          l.passwordTypeHint,
          state.secondPasswordSelected ? 'second' : null,
          [
            AppSelectOption(
              value: 'first',
              label: l.passwordFirst,
              supportingText: l.passwordFirstDescription,
            ),
            AppSelectOption(
              value: 'second',
              label: l.passwordSecond,
              supportingText: l.passwordSecondDescription,
            ),
          ],
          (value) {
            if (value == 'second') {
              cubit.selectSecondPassword();
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l.passwordUnsupported)));
            }
          },
        ),
        if (state.card != null && state.secondPasswordSelected) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 0,
            child: OverflowBox(
              minHeight: 1,
              maxHeight: 1,
              child: SvgPicture.asset(
                AppAssets.issuanceDivider,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.selectOperation)
            _select<PasswordOperation>(
              'password_operation',
              l.passwordOperation,
              l.passwordOperationHint,
              state.operation,
              [
                AppSelectOption(
                  value: PasswordOperation.changePassword,
                  label: l.passwordChange,
                ),
                AppSelectOption(
                  value: PasswordOperation.forgotPassword,
                  label: l.passwordForgot,
                ),
              ],
              cubit.chooseOperation,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.passwordOperation,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 18 / 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  hintText: l.passwordSetSecond,
                  hintColor: context.colors.textSecondary,
                  readOnly: true,
                  textStyle: passwordBody(context),
                ),
              ],
            ),
        ],
        if (state.selectionComplete && !state.isChange) ...[
          const SizedBox(height: 20),
          AppInvoice(
            totalAmount: CurrencyFormatter.format(state.catalog!.feeRial),
            walletBalance: CurrencyFormatter.format(
              state.catalog!.walletBalanceRial,
            ),
            lines: const [],
            isExpanded: false,
            onExpandedChanged: (_) {},
            showToggle: false,
            title: l.issuancePayable,
            walletLabel: l.walletBalanceTitle,
            backgroundColor: context.colors.surface,
            borderRadius: BorderRadius.zero,
            zeroHeightDividers: true,
            labelColor: context.colors.textTertiary,
            isWalletBalanceSufficient: state.walletSufficient,
            walletSufficientLabel: l.issuanceWalletSufficient,
            walletInsufficientLabel: l.issuanceWalletInsufficient,
          ),
        ],
        if (state.card != null &&
            state.operation != null &&
            !state.card!.supports(state.operation!)) ...[
          const SizedBox(height: 12),
          Text(l.passwordUnsupported),
        ],
      ],
    );
  }

  Widget _instruction(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.passwordInstructionPrompt,
        style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 20),
      AppVideoPlayer(
        key: const Key('password_instruction_video'),
        controller: video,
        poster: _InstructionPoster(),
        playLabel: context.l10n.passwordPlay,
        pauseLabel: context.l10n.passwordPause,
        unavailableLabel: context.l10n.passwordVideoUnavailable,
        retryLabel: context.l10n.dashboardRetry,
        seekLabel: context.l10n.passwordSeek,
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppPasswordServiceColors.cameraNotice,
          borderRadius: AppRadius.borderSm,
        ),
        child: Row(
          children: [
            _icon(AppAssets.passwordCameraInfo),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.passwordCameraNotice,
                style: AppTypography.bodySmall.copyWith(
                  height: 18 / 12,
                  fontWeight: FontWeight.w500,
                  color: AppPasswordServiceColors.body,
                ),
              ),
            ),
          ],
        ),
      ),
      if (widget.instructionVideoUrl == SecondPasswordScreen.demoVideoUrl) ...[
        const SizedBox(height: 12),
        Text(
          context.l10n.passwordDemoVideo,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textTertiary,
            height: 18 / 12,
          ),
        ),
      ],
    ],
  );
  Widget _recording(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.passwordRecordingPrompt,
        style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 20),
      AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: AppRadius.borderSm,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppAssets.passwordRecording, fit: BoxFit.cover),
              ColoredBox(
                color: AppPasswordServiceColors.recordingScrim.withValues(
                  alpha: .4,
                ),
              ),
              Center(
                child: IconButton(
                  key: const Key('password_mock_recording_play'),
                  tooltip: context.l10n.passwordConfirmMock,
                  onPressed: cubit.confirmMockRecording,
                  icon: _icon(AppAssets.passwordRecordPlay, size: 23),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Align(
        alignment: Alignment.centerLeft,
        child: IntrinsicWidth(
          child: AppButton(
            key: const Key('password_record_again'),
            onPressed: cubit.recordAgain,
            label: context.l10n.passwordRecordAgain,
            variant: AppButtonVariant.text,
            horizontalPadding: 4,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        context.l10n.passwordMockKyc,
        style: AppTypography.bodySmall.copyWith(
          color: context.colors.textTertiary,
          height: 18 / 12,
        ),
      ),
      BlocSelector<SecondPasswordCubit, SecondPasswordState, bool>(
        selector: (s) => s.recordingConfirmed,
        builder: (context, confirmed) => AppCheckbox(
          key: const Key('password_confirm_mock'),
          value: confirmed,
          label: context.l10n.passwordConfirmMock,
          onChanged: (v) {
            if (v == true) {
              cubit.confirmMockRecording();
            } else {
              cubit.recordAgain();
            }
          },
        ),
      ),
    ],
  );
  Widget _footer(
    BuildContext context,
  ) => BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
    buildWhen: (a, b) =>
        a.canContinue != b.canContinue ||
        a.status != b.status ||
        a.step != b.step ||
        a.terms != b.terms,
    builder: (context, state) => Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        state.step == SecondPasswordStep.password ? 0 : 16,
        16,
        16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.step == SecondPasswordStep.password) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              constraints: const BoxConstraints(minHeight: 44),
              decoration: BoxDecoration(
                color: state.isChange
                    ? context.colors.surfaceSubtle
                    : context.colors.surface,
                borderRadius: AppRadius.borderSm,
              ),
              child: Row(
                children: [
                  AppCheckbox(
                    key: const Key('password_terms'),
                    value: state.terms,
                    size: AppCheckboxSize.md,
                    onChanged: cubit.acceptTerms,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        InkWell(
                          onTap:
                              widget.onTermsRequested ??
                              () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.issuanceTermsUnavailable,
                                  ),
                                ),
                              ),
                          child: Text(
                            '${context.l10n.issuanceTerms} ',
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.primary,
                              decoration: TextDecoration.underline,
                              height: 18 / 12,
                            ),
                          ),
                        ),
                        Text(
                          context.l10n.issuanceTermsPrompt,
                          style: AppTypography.bodySmall.copyWith(
                            height: 18 / 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          AppButton(
            key: const Key('password_next'),
            onPressed: state.canContinue
                ? () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    cubit.next();
                  }
                : null,
            label:
                state.isChange &&
                    state.step == SecondPasswordStep.password &&
                    state.passwordComplete
                ? context.l10n.passwordChangeSubmit
                : state.step == SecondPasswordStep.instruction
                ? context.l10n.passwordStartKyc
                : state.step == SecondPasswordStep.recording
                ? context.l10n.passwordSubmit
                : context.l10n.issuanceNext,
            isLoading:
                state.status == SecondPasswordStatus.checking ||
                state.status == SecondPasswordStatus.submitting,
            size: AppButtonSize.lg,
            constrainLabel: true,
            disabledAppearance: AppButtonDisabledAppearance.service,
          ),
        ],
      ),
    ),
  );
}

class _InstructionPoster extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ClipRect(
      child: Stack(
        children: [
          Positioned(
            left: -constraints.maxWidth * .0016,
            top: -constraints.maxHeight * .1162,
            width: constraints.maxWidth,
            height: constraints.maxHeight * 1.4286,
            child: Image.asset(AppAssets.passwordInstruction, fit: BoxFit.fill),
          ),
        ],
      ),
    ),
  );
}

class _PasswordForm extends StatefulWidget {
  const _PasswordForm();
  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  late final TextEditingController password, confirmation, currentPassword;
  final focus = FocusNode();
  bool showPassword = false,
      showConfirmation = false,
      showCurrent = false,
      mismatch = false;
  @override
  void initState() {
    super.initState();
    final state = context.read<SecondPasswordCubit>().state;
    currentPassword = TextEditingController(text: state.currentPassword);
    password = TextEditingController(text: state.password);
    confirmation = TextEditingController(text: state.confirmation);
    focus.addListener(() {
      if (!focus.hasFocus && mounted) {
        setState(
          () => mismatch =
              confirmation.text.isNotEmpty &&
              password.text != confirmation.text,
        );
      }
    });
  }

  @override
  void dispose() {
    currentPassword.dispose();
    password.dispose();
    confirmation.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.read<SecondPasswordCubit>(), l = context.l10n;
    final change = c.state.isChange;
    Widget field(int type) {
      final confirm = type == 2, current = type == 0;
      final visible = current
          ? showCurrent
          : confirm
          ? showConfirmation
          : showPassword;
      return AppTextField(
        key: Key(
          current
              ? 'password_current'
              : confirm
              ? 'password_confirmation'
              : 'password_value',
        ),
        controller: current
            ? currentPassword
            : confirm
            ? confirmation
            : password,
        focusNode: confirm ? focus : null,
        hintText: current
            ? l.passwordCurrentHint
            : change
            ? (confirm ? l.passwordNewConfirmationHint : l.passwordNewHint)
            : (confirm ? l.passwordConfirmationHint : l.passwordValueHint),
        obscureText: !visible,
        obscuringCharacter: '*',
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        keyboardType: TextInputType.number,
        normalizeDigits: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        focusRing: AppTextFieldFocusRing.none,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        textStyle: passwordBody(context),
        errorText: confirm && mismatch ? l.passwordMismatch : null,
        suffixIcon: IconButton(
          tooltip: visible ? l.passwordHide : l.passwordShow,
          onPressed: () => setState(() {
            if (current) {
              showCurrent = !showCurrent;
            } else if (confirm) {
              showConfirmation = !showConfirmation;
            } else {
              showPassword = !showPassword;
            }
          }),
          icon: SizedBox.square(
            dimension: 20,
            child: visible
                ? SvgPicture.asset(AppAssets.resalatCardEye)
                : SvgPicture.asset(AppAssets.passwordEyeSlash),
          ),
        ),
        onChanged: (v) {
          setState(() => mismatch = false);
          if (current) {
            c.currentPasswordChanged(v);
          } else if (confirm) {
            c.confirmationChanged(v);
          } else {
            c.passwordChanged(v);
          }
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          change ? l.passwordChangePrompt : l.passwordPrompt,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        if (change) ...[
          field(0),
          const SizedBox(height: 20),
          SizedBox(
            height: 0,
            child: OverflowBox(
              minHeight: 1,
              maxHeight: 1,
              child: SvgPicture.asset(
                AppAssets.issuanceDivider,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        field(1),
        const SizedBox(height: 20),
        field(2),
        const SizedBox(height: 20),
        BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
          buildWhen: (a, b) => a.password != b.password,
          builder: (context, s) => Column(
            children: [
              for (final rule in [
                (l.passwordLengthRule, s.lengthValid),
                (l.passwordPatternRule, s.patternValid),
                (l.passwordDateRule, s.dateValid),
              ]) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox.square(
                      dimension: 20,
                      child: SvgPicture.asset(
                        rule.$2
                            ? AppAssets.passwordCheckActive
                            : AppAssets.passwordCheckInactive,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule.$1,
                        style: passwordBody(context).copyWith(
                          color: rule.$2
                              ? context.colors.textSecondary
                              : AppPasswordServiceColors.hint,
                        ),
                      ),
                    ),
                  ],
                ),
                if (rule.$1 != l.passwordDateRule) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SerialForm extends StatefulWidget {
  const _SerialForm();
  @override
  State<_SerialForm> createState() => _SerialFormState();
}

class _SerialFormState extends State<_SerialForm> {
  late final TextEditingController controller;
  final focus = FocusNode();
  bool error = false;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: context.read<SecondPasswordCubit>().state.serial,
    );
    focus.addListener(() {
      if (!focus.hasFocus && mounted) {
        setState(
          () => error =
              controller.text.isNotEmpty &&
              !context.read<SecondPasswordCubit>().state.serialComplete,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.passwordSerialPrompt,
        style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 20),
      AppTextField(
        key: const Key('password_serial'),
        controller: controller,
        focusNode: focus,
        hintText: context.l10n.passwordSerialHint,
        errorText: error ? context.l10n.passwordSerialError : null,
        textStyle: passwordBody(context),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        normalizeDigits: true,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(20),
        ],
        focusRing: AppTextFieldFocusRing.none,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        onChanged: (v) {
          setState(() => error = false);
          context.read<SecondPasswordCubit>().serialChanged(v);
        },
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          SizedBox.square(
            dimension: 14,
            child: SvgPicture.asset(AppAssets.passwordInfo),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.passwordSerialHelper,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
                height: 18 / 12,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
