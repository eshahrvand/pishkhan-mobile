import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';

import '../cubit/mobile_bank_guide_cubit.dart';

class MobileBankGuideScreen extends StatefulWidget {
  const MobileBankGuideScreen({super.key});
  @override
  State<MobileBankGuideScreen> createState() => _MobileBankGuideScreenState();
}

class _MobileBankGuideScreenState extends State<MobileBankGuideScreen> {
  final _pages = PageController();
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MobileBankGuideCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: S.current.passwordChange,
                    showLeadingActions: false,
                    trailingIcon: SizedBox.square(
                      dimension: 24,
                      child: AvpImage(image: AppAssets.depositFeatureBack),
                    ),
                    trailingTooltip: S.current.backLabel,
                    onTrailingPressed: () {
                      NavigationActions.back(context);
                    },
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _pages,
                                itemCount: 4,
                                onPageChanged: (page) {
                                  context
                                      .read<MobileBankGuideCubit>()
                                      .selectPage(page);
                                },
                                itemBuilder: (pageContext, index) {
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      8,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: 44,
                                          child: Text(
                                            getModernBankGuideText(index),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  height: 20 / 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        AvpImage(
                                          image: getModernBankGuideImage(index),
                                          width: 250,
                                          height: 500,
                                          semanticsLabel:
                                              getModernBankGuideText(index),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            BlocBuilder<
                              MobileBankGuideCubit,
                              MobileBankGuideState
                            >(
                              buildWhen: (previous, current) =>
                                  previous.page != current.page,
                              builder: (context, state) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (var index = 0; index < 4; index++)
                                      Semantics(
                                        label: S.current.modernGuidePage(
                                          index + 1,
                                        ),
                                        selected: state.page == index,
                                        button: true,
                                        child: InkWell(
                                          onTap: () {
                                            _pages.animateToPage(
                                              index,
                                              duration: const Duration(
                                                milliseconds: 220,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                              vertical: 12,
                                            ),
                                            child: Container(
                                              width: state.page == index
                                                  ? 14
                                                  : 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: state.page == index
                                                    ? context.colors.primary
                                                    : context.colors.border,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 66),
                          ],
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: AppAssistantButton(
                            onPressed: () {
                              NavigationActions.returnHome(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String getModernBankGuideText(int page) => switch (page) {
  0 => S.current.modernGuideLogin,
  1 || 2 => S.current.modernGuideOther,
  _ => S.current.modernGuidePassword,
};
String getModernBankGuideImage(int page) => switch (page) {
  0 => AppAssets.modernGuide1,
  1 => AppAssets.modernGuide2,
  2 => AppAssets.modernGuide3,
  _ => AppAssets.modernGuide4,
};
