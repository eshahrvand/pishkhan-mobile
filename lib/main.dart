import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pishkhan_mobile/shared/widgets/app_drawer.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_list.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';
import 'package:pishkhan_mobile/shared/widgets/app_arrow_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_confirmer_details_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_credit_card_mockup.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';
import 'package:pishkhan_mobile/shared/widgets/app_file_upload_base.dart';
import 'package:pishkhan_mobile/shared/widgets/app_loan_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_occupation_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_representative_cards.dart';
import 'package:pishkhan_mobile/shared/widgets/app_request_report_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_resalat_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_grid_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_transaction_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_transfer_destination_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_welcome_card.dart';

void main() => runApp(const MyApp());

/// Temporary fake UI for reviewing the shared component library.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'پیش‌نمایش کامپوننت‌ها',
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light(),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SharedComponentsPreview(),
    );
  }
}

class SharedComponentsPreview extends StatefulWidget {
  const SharedComponentsPreview({super.key});

  @override
  State<SharedComponentsPreview> createState() =>
      _SharedComponentsPreviewState();
}

class _SharedComponentsPreviewState extends State<SharedComponentsPreview> {
  final _searchController = TextEditingController();
  var _drawerOpen = true;
  String? _expandedItemId = 'personal-information';
  var _selectedItemId = 'personal-information';
  String? _selectedSubItemId;
  String _search = '';

  static final _items = <AppDrawerItem>[
    AppDrawerItem(
      id: 'dashboard',
      label: 'داشبورد',
      icon: AppDrawerIcons.home(),
    ),
    AppDrawerItem(
      id: 'modern',
      label: 'بانکداری مدرن',
      icon: AppDrawerIcons.modernBanking(),
      children: [
        AppDrawerSubItem(id: 'signature', label: 'امضای دیجیتال'),
        AppDrawerSubItem(id: 'modern-services', label: 'خدمات بانکداری مدرن'),
      ],
    ),
    AppDrawerItem(
      id: 'cards',
      label: 'کارت',
      icon: AppDrawerIcons.card(),
      children: [
        AppDrawerSubItem(id: 'virtual-card', label: 'کارت مجازی'),
        AppDrawerSubItem(id: 'block-card', label: 'مسدودسازی کارت'),
        AppDrawerSubItem(id: 'card-tracking', label: 'پیگیری درخواست کارت'),
      ],
    ),
    AppDrawerItem(
      id: 'cheque',
      label: 'چک',
      icon: AppDrawerIcons.cheque(),
      children: [
        AppDrawerSubItem(id: 'cheque-book', label: 'درخواست دسته‌چک'),
        AppDrawerSubItem(id: 'cheque-inquiry', label: 'استعلام چک'),
      ],
    ),
    AppDrawerItem(
      id: 'money-transfer',
      label: 'انتقال وجه',
      icon: AppDrawerIcons.moneyTransfer(),
      children: [
        AppDrawerSubItem(id: 'transfer-history', label: 'تاریخچه انتقال وجه'),
      ],
    ),
    AppDrawerItem(
      id: 'loans',
      label: 'وام',
      icon: AppDrawerIcons.loan(),
      children: [
        AppDrawerSubItem(id: 'loan-request', label: 'درخواست تسهیلات'),
        AppDrawerSubItem(id: 'loan-tracking', label: 'پیگیری درخواست'),
      ],
    ),
    AppDrawerItem(
      id: 'deposits',
      label: 'سپرده',
      icon: AppDrawerIcons.deposit(),
      children: [AppDrawerSubItem(id: 'deposit-list', label: 'فهرست سپرده‌ها')],
    ),
    AppDrawerItem(
      id: 'wallet',
      label: 'کیف پول',
      icon: AppDrawerIcons.wallet(),
      children: [
        AppDrawerSubItem(id: 'wallet-balance', label: 'موجودی کیف پول'),
      ],
    ),
    AppDrawerItem(
      id: 'personal-information',
      label: 'اطلاعات فردی',
      icon: AppDrawerIcons.personalInformationDeselected(),
      selectedIcon: AppDrawerIcons.personalInformation(),
      children: [
        AppDrawerSubItem(id: 'change-phone', label: 'تغییر شماره تلفن همراه'),
        AppDrawerSubItem(id: 'manage-address', label: 'مدیریت آدرس'),
        AppDrawerSubItem(id: 'manage-job', label: 'مدیریت شغل'),
        AppDrawerSubItem(id: 'change-identity', label: 'تغییر مشخصات هویتی'),
      ],
    ),
    AppDrawerItem(
      id: 'requests',
      label: 'درخواست‌های من',
      icon: AppDrawerIcons.myRequests(),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppDrawerItem> get _visibleItems {
    if (_search.trim().isEmpty) return _items;
    return _items
        .where(
          (item) =>
              item.label.contains(_search) ||
              item.children.any((child) => child.label.contains(_search)),
        )
        .toList();
  }

  void _onItemSelected(AppDrawerItem item) {
    setState(() {
      _selectedItemId = item.id;
      _selectedSubItemId = null;
      _expandedItemId = item.hasChildren && _expandedItemId != item.id
          ? item.id
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceSubtle,
      body: Stack(
        children: [
          _FakeDashboard(
            drawerOpen: _drawerOpen,
            selectedItemId: _selectedItemId,
            selectedSubItemId: _selectedSubItemId,
            expandedItemId: _expandedItemId,
            onOpenDrawer: () => setState(() => _drawerOpen = true),
            onToggleCards: () => setState(
              () =>
                  _expandedItemId = _expandedItemId == 'cards' ? null : 'cards',
            ),
          ),
          AppDrawer(
            isOpen: _drawerOpen,
            items: _visibleItems,
            expandedItemId: _expandedItemId,
            selectedItemId: _selectedItemId,
            selectedSubItemId: _selectedSubItemId,
            searchController: _searchController,
            logo: AppDrawerIcons.resalat(),
            onSearchChanged: (value) => setState(() => _search = value),
            onOpenChanged: (value) => setState(() => _drawerOpen = value),
            onItemSelected: _onItemSelected,
            onSubItemSelected: (item) =>
                setState(() => _selectedSubItemId = item.id),
          ),
        ],
      ),
    );
  }
}

class _FakeDashboard extends StatelessWidget {
  const _FakeDashboard({
    required this.drawerOpen,
    required this.selectedItemId,
    required this.selectedSubItemId,
    required this.expandedItemId,
    required this.onOpenDrawer,
    required this.onToggleCards,
  });

  final bool drawerOpen;
  final String selectedItemId;
  final String? selectedSubItemId;
  final String? expandedItemId;
  final VoidCallback onOpenDrawer;
  final VoidCallback onToggleCards;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                IconButton(
                  key: const Key('preview_open_drawer'),
                  onPressed: onOpenDrawer,
                  tooltip: 'باز کردن منو',
                  icon: const Icon(Icons.menu),
                ),
                const Spacer(),
                Text(
                  'پیش‌نمایش کامپوننت‌ها',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'منوی کناری',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'داده‌ها ساختگی هستند و فقط برای بازبینی UX و حالت‌های کامپوننت استفاده می‌شوند.',
                  style: TextStyle(
                    color: AppColors.light.textTertiary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _PreviewCard(
                  drawerOpen: drawerOpen,
                  selectedItemId: selectedItemId,
                  selectedSubItemId: selectedSubItemId,
                  expandedItemId: expandedItemId,
                  onOpenDrawer: onOpenDrawer,
                  onToggleCards: onToggleCards,
                ),
                const SizedBox(height: 16),
                const _BalanceCard(),
                const SizedBox(height: 16),
                const _WalletCardPreview(),
                const SizedBox(height: 16),
                const _DepositListPreview(),
                const SizedBox(height: 16),
                const _CardsListPreview(),
                const SizedBox(height: 16),
                const _NewFigmaCardsPreview(),
                const SizedBox(height: 16),
                const _FinancialCardsPreview(),
                const SizedBox(height: 16),
                const _DetailComponentsPreview(),
                const SizedBox(height: 16),
                const _ServicesCard(),
                const SizedBox(height: 16),
                const _InvoicePreview(),
                const SizedBox(height: 16),
                const _ServiceGridPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.drawerOpen,
    required this.selectedItemId,
    required this.selectedSubItemId,
    required this.expandedItemId,
    required this.onOpenDrawer,
    required this.onToggleCards,
  });

  final bool drawerOpen;
  final String selectedItemId;
  final String? selectedSubItemId;
  final String? expandedItemId;
  final VoidCallback onOpenDrawer;
  final VoidCallback onToggleCards;

  @override
  Widget build(BuildContext context) {
    final subItem = selectedSubItemId ?? 'ندارد';
    final expandedItem = expandedItemId ?? 'ندارد';
    return Card(
      elevation: 0,
      color: AppColors.light.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.light.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'وضعیت فعلی',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(drawerOpen ? 'منو: باز' : 'منو: بسته'),
                _Chip('انتخاب‌شده: $selectedItemId'),
                _Chip('زیرمنو: $subItem'),
                _Chip('بازشده: $expandedItem'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onToggleCards,
                    child: const Text('تغییر زیرمنوی کارت'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onOpenDrawer,
                    child: const Text('باز کردن منو'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.light.primarySubtle,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(color: AppColors.light.primaryHover, fontSize: 12),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.light.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خوش آمدید، کاربر نمونه',
            style: TextStyle(
              color: AppColors.light.textOnPrimary.withValues(alpha: .7),
            ),
          ),
          SizedBox(height: 12),
          Text(
            '۱۲٬۴۵۰٬۰۰۰ ریال',
            style: TextStyle(
              color: AppColors.light.textOnPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'مانده قابل نمایش',
            style: TextStyle(
              color: AppColors.light.textOnPrimary.withValues(alpha: .7),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardsListPreview extends StatelessWidget {
  const _CardsListPreview();

  @override
  Widget build(BuildContext context) {
    const cardNumber = '۵۰۴۱۷۲۱۴۵۶۷۸۳۴۰۷';
    const linkedDeposit = '۱۰-۱۲۲-۱۲۳۴۵۶۷-۱';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('لیست کارت‌ها', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...AppCardsListType.values.expand(
          (type) => [
            AppCardsList(
              type: type,
              cardNumber: cardNumber,
              linkedDeposit: linkedDeposit,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }
}

class _NewFigmaCardsPreview extends StatelessWidget {
  const _NewFigmaCardsPreview();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'کارت‌ها و بارگذاری جدید',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      const Center(child: AppCreditCardMockup()),
      const SizedBox(height: 16),
      const Center(
        child: AppCreditCardMockup(
          state: AppCreditCardMockupState.active,
          channel: AppBankingChannel.web,
        ),
      ),
      const SizedBox(height: 16),
      const Center(
        child: AppCreditCardMockup(state: AppCreditCardMockupState.wallet),
      ),
      const SizedBox(height: 16),
      const Center(child: AppFileUploadBase()),
      const SizedBox(height: 16),
      const Center(
        child: AppFileUploadBase(state: AppFileUploadState.uploading),
      ),
      const SizedBox(height: 16),
      const Center(
        child: AppTransferDestinationCard(method: AppTransferMethod.internal),
      ),
      const SizedBox(height: 16),
      const Center(
        child: AppTransferDestinationCard(method: AppTransferMethod.paya),
      ),
      const SizedBox(height: 16),
      const Center(child: AppAddressCard()),
      const SizedBox(height: 16),
      const Center(child: AppAddressCard(type: AppAddressType.work)),
      const SizedBox(height: 16),
      const Center(child: AppOccupationCard()),
      const SizedBox(height: 16),
      const Center(child: AppRequestReportCard()),
      const SizedBox(height: 16),
      ...AppTransactionType.values.expand(
        (type) => [
          Center(child: AppTransactionCard(type: type)),
          const SizedBox(height: 16),
        ],
      ),
    ],
  );
}

class _FinancialCardsPreview extends StatefulWidget {
  const _FinancialCardsPreview();

  @override
  State<_FinancialCardsPreview> createState() => _FinancialCardsPreviewState();
}

class _FinancialCardsPreviewState extends State<_FinancialCardsPreview> {
  var _detailsVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('کارت‌های مالی', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Center(
          child: AppResalatCard(
            isVisible: _detailsVisible,
            onVisibilityChanged: (value) =>
                setState(() => _detailsVisible = value),
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: AppDepositCard()),
        const SizedBox(height: 20),
        Center(child: AppLoanCard(onArrowPressed: () {})),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppArrowButton(
              onPressed: () {},
              direction: AppArrowDirection.left,
              tooltip: 'قبلی',
            ),
            const SizedBox(width: 20),
            AppArrowButton(
              onPressed: () {},
              direction: AppArrowDirection.right,
              tooltip: 'بعدی',
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailComponentsPreview extends StatelessWidget {
  const _DetailComponentsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('جزئیات و شیت‌ها', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const Center(child: AppWelcomeCard()),
        const SizedBox(height: 20),
        const AppBottomSheetHeader(),
        const SizedBox(height: 20),
        Center(
          child: AppDeleteAddressSheet(
            address: 'تهران - خیابان شریعتی - روبروی خیابان یخچال - بن بست شریف - پلاک ۴ - واحد ۱',
            postalCode: '۱۹۴۴۶۲۹۱۲۳',
            onConfirm: () {},
            onCancel: () {},
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: AppConfirmerDetailsCard()),
        const SizedBox(height: 20),
        const Center(child: AppMeAsRepresentativeCard()),
        const SizedBox(height: 20),
        const Center(
          child: AppMyRepresentativeCard(
            status: AppRepresentativeStatus.waiting,
          ),
        ),
      ],
    );
  }
}

class _DepositListPreview extends StatelessWidget {
  const _DepositListPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('لیست سپرده‌ها', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const AppDepositList(
          title: 'پس انداز حقیقی',
          accountNumber: '۱۰-۱۲۲-۱۲۳۴۵۶۷-۱',
        ),
        const SizedBox(height: 16),
        const AppDepositList(
          title: 'جاری حقیقی',
          accountNumber: '۱۰-۱۲۲-۱۲۳۴۵۶۷-۲',
        ),
      ],
    );
  }
}

class _WalletCardPreview extends StatelessWidget {
  const _WalletCardPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('کارت کیف پول', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const AppWalletCard(balance: '۱٬۲۰۰٬۰۰۰'),
        const SizedBox(height: 16),
        const AppWalletCard(
          balance: '۱٬۲۰۰٬۰۰۰',
          type: AppWalletCardType.desktop,
        ),
      ],
    );
  }
}

class _ServiceGridPreview extends StatelessWidget {
  const _ServiceGridPreview();

  static const _labels = [
    'صورتحساب، معدل موجودی',
    'گردش حساب',
    'انتقال وجه',
    'مدیریت کارت',
  ];

  List<AppServiceGridItem> _items(
    Widget Function() icon, {
    Size iconSize = const Size.square(32),
  }) => [
    for (var index = 0; index < _labels.length; index++)
      AppServiceGridItem(
        id: 'service-$index',
        label: _labels[index],
        icon: icon(),
        iconSize: iconSize,
        onTap: () {},
      ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'کارت خدمات و دسترسی سریع',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        AppServiceGridCard(
          title: 'خدمات',
          headerAction: AppServiceGridIcons.angleLeft(),
          items: _items(AppServiceGridIcons.representativePurple),
        ),
        const SizedBox(height: 16),
        AppServiceGridCard(
          title: 'دسترسی سریع',
          type: AppServiceGridCardType.quick,
          headerAction: AppServiceGridIcons.quickAccess(),
          items: _items(
            AppServiceGridIcons.quickService,
            iconSize: const Size(70, 70.5),
          ),
        ),
      ],
    );
  }
}

class _InvoicePreview extends StatefulWidget {
  const _InvoicePreview();

  @override
  State<_InvoicePreview> createState() => _InvoicePreviewState();
}

class _InvoicePreviewState extends State<_InvoicePreview> {
  var _isExpanded = false;
  var _isSufficient = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'صورتحساب هزینه',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'کامپوننت مشترک با دو حالت باز/بسته و وضعیت موجودی کیف پول.',
          style: TextStyle(color: AppColors.light.textTertiary),
        ),
        const SizedBox(height: 12),
        AppInvoice(
          totalAmount: '۱٬۳۰۰٬۰۰۰',
          walletBalance: '۲٬۰۰۰٬۰۰۰',
          isExpanded: _isExpanded,
          isWalletBalanceSufficient: _isSufficient,
          onExpandedChanged: (value) => setState(() => _isExpanded = value),
          lines: [
            AppInvoiceLine(
              id: 'print',
              label: 'هزینه چاپ گزارش',
              amount: '۳۰۰٬۰۰۰',
              icon: AppInvoiceIcons.print(),
            ),
            AppInvoiceLine(
              id: 'identity',
              label: 'کارمزد احراز هویت',
              amount: '۳۰۰٬۰۰۰',
              icon: AppInvoiceIcons.identityVideo(),
            ),
            AppInvoiceLine(
              id: 'delivery',
              label: 'هزینه ارسال',
              amount: '۱٬۰۰۰٬۰۰۰',
              icon: AppInvoiceIcons.delivery(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => setState(() => _isSufficient = !_isSufficient),
            child: Text(
              _isSufficient ? 'نمایش وضعیت ناموجود' : 'نمایش وضعیت کافی',
            ),
          ),
        ),
      ],
    );
  }
}

class _ServicesCard extends StatelessWidget {
  const _ServicesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.light.surface,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خدمات پرکاربرد',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _Service(icon: Icons.credit_card_outlined, label: 'کارت مجازی'),
                _Service(icon: Icons.receipt_long_outlined, label: 'دسته‌چک'),
                _Service(icon: Icons.savings_outlined, label: 'تسهیلات'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Service extends StatelessWidget {
  const _Service({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.light.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: AppColors.light.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
