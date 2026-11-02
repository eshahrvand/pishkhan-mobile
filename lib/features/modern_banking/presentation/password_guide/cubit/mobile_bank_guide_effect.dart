sealed class MobileBankGuideEffect {
  const MobileBankGuideEffect();
}

final class MobileBankGuidePageRequested extends MobileBankGuideEffect {
  const MobileBankGuidePageRequested(this.page);
  final int page;
}

final class MobileBankGuideBackRequested extends MobileBankGuideEffect {
  const MobileBankGuideBackRequested();
}

final class MobileBankGuideHomeRequested extends MobileBankGuideEffect {
  const MobileBankGuideHomeRequested();
}
