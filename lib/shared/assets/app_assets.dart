/// Canonical registry for application-owned image assets.
///
/// Keep asset paths here so renames and deduplication stay isolated from UI
/// code. Feature-specific facades may alias these constants, but must not
/// duplicate path strings.
abstract final class AppAssets {
  static const _root = 'assets/images';

  static const addressCardAngleLeft = '$_root/address_card_angle_left.svg';
  static const addressCardBuildings = '$_root/address_card_buildings.svg';
  static const addressCardHomeHeart = '$_root/address_card_home_heart.svg';
  static const arrowButtonArrowLeft = '$_root/arrow_button_arrow_left.svg';
  static const arrowButtonArrowRight = '$_root/arrow_button_arrow_right.svg';
  static const authAssetReport = '$_root/auth_asset_report.svg';
  static const authCallCenter = '$_root/auth_call_center.svg';
  static const authCaptcha = '$_root/auth_captcha.png';
  static const authChangeMobile = '$_root/auth_change_mobile.svg';
  static const authClock = '$_root/auth_clock.svg';
  static const authClose = '$_root/auth_close.svg';
  static const authInfoCircle = '$_root/auth_info_circle.svg';
  static const authInheritance = '$_root/auth_inheritance.svg';
  static const authInternetBank = '$_root/auth_internet_bank.svg';
  static const authLock = '$_root/auth_lock.svg';
  static const authMobile = '$_root/auth_mobile.svg';
  static const authMobileBank = '$_root/auth_mobile_bank.svg';
  static const authRefresh = '$_root/auth_refresh.svg';
  static const authRequestStatus = '$_root/auth_request_status.svg';
  static const authResalatLogo = '$_root/auth_resalat_logo.svg';
  static const authResalatService = '$_root/auth_resalat_service.svg';
  static const authResalatWordmark = '$_root/auth_resalat_wordmark.svg';
  static const authSectionDivider1 = '$_root/auth_section_divider_1.svg';
  static const authSectionDivider2 = '$_root/auth_section_divider_2.svg';
  static const authSecurity = '$_root/auth_security.svg';
  static const authUpdateGuide = '$_root/auth_update_guide.svg';
  static const authUser = '$_root/auth_user.svg';
  static const bankingChannelCardAngleLeft =
      '$_root/banking_channel_card_angle_left.svg';
  static const bankingChannelCardBackground =
      '$_root/banking_channel_card_background.png';
  static const bankingChannelCardDivider =
      '$_root/banking_channel_card_divider.svg';
  static const bankingChannelCardGlobe =
      '$_root/banking_channel_card_globe.svg';
  static const bankingChannelCardMobile =
      '$_root/banking_channel_card_mobile.svg';
  static const bankingChannelCardPhone =
      '$_root/banking_channel_card_phone.svg';
  static const bankingChannelCardRefresh =
      '$_root/banking_channel_card_refresh.svg';
  static const bankingChannelCardWallet =
      '$_root/banking_channel_card_wallet.svg';
  static const bottomSheetHeaderWallet =
      '$_root/bottom_sheet_header_wallet.svg';
  static const cardsListCoupon = '$_root/cards_list_coupon.svg';
  static const cardsListCreditCard = '$_root/cards_list_credit_card.svg';
  static const cardsListFamily = '$_root/cards_list_family.svg';
  static const cardsListGiftCard = '$_root/cards_list_gift_card.svg';
  static const cardsListVirtualCard = '$_root/cards_list_virtual_card.svg';
  static const dashboardBannerBlue = '$_root/dashboard_banner_blue.png';
  static const dashboardBannerYellow = '$_root/dashboard_banner_yellow.png';
  static const dashboardCardBlock = '$_root/dashboard_card_block.svg';
  static const dashboardCardIssue = '$_root/dashboard_card_issue.svg';
  static const dashboardCardLinkedDeposit =
      '$_root/dashboard_card_linked_deposit.svg';
  static const dashboardCardPassword = '$_root/dashboard_card_password.svg';
  static const dashboardDepositCertificate =
      '$_root/dashboard_deposit_certificate.svg';
  static const dashboardDepositSms = '$_root/dashboard_deposit_sms.svg';
  static const dashboardDepositStatement =
      '$_root/dashboard_deposit_statement.svg';
  static const dashboardHeaderBell = '$_root/dashboard_header_bell.svg';
  static const dashboardHeaderMenu = '$_root/dashboard_header_menu.svg';
  static const dashboardHeaderUser = '$_root/dashboard_header_user.svg';
  static const dashboardLoanCalculator = '$_root/dashboard_loan_calculator.svg';
  static const dashboardLoanConsolidation =
      '$_root/dashboard_loan_consolidation.svg';
  static const dashboardLoanLinkedDeposit =
      '$_root/dashboard_loan_linked_deposit.svg';
  static const dashboardLoanTransfer = '$_root/dashboard_loan_transfer.svg';
  static const dashboardPatternDown = '$_root/dashboard_pattern_down.svg';
  static const dashboardPatternUp = '$_root/dashboard_pattern_up.svg';
  static const dashboardRequestDivider = '$_root/dashboard_request_divider.png';
  static const dashboardSectionDivider = '$_root/dashboard_section_divider.png';
  static const dashboardSelectedCheque = '$_root/dashboard_selected_cheque.svg';
  static const dashboardSelectedInternet =
      '$_root/dashboard_selected_internet.svg';
  static const dashboardSelectedMobile = '$_root/dashboard_selected_mobile.svg';
  static const dashboardSelectedProxy = '$_root/dashboard_selected_proxy.svg';
  static const depositCardResalatLogo = '$_root/deposit_card_resalat_logo.svg';
  static const depositListDeposit = '$_root/deposit_list_deposit.svg';
  static const dividerCardGray200 = '$_root/divider_card_gray200.svg';
  static const drawerCard = '$_root/drawer_card.svg';
  static const drawerCheque = '$_root/drawer_cheque.svg';
  static const drawerChevronDown = '$_root/drawer_chevron_down.svg';
  static const drawerChevronUp = '$_root/drawer_chevron_up.svg';
  static const drawerClose = '$_root/drawer_close.svg';
  static const drawerDeposit = '$_root/drawer_deposit.svg';
  static const drawerHome = '$_root/drawer_home.svg';
  static const drawerLoan = '$_root/drawer_loan.svg';
  static const drawerModernBanking = '$_root/drawer_modern_banking.svg';
  static const drawerMoneyTransfer = '$_root/drawer_money_transfer.svg';
  static const drawerMyRequests = '$_root/drawer_my_requests.svg';
  static const drawerMyRequestsDeselected =
      '$_root/drawer_my_requests_deselected.svg';
  static const drawerPersonalInformation =
      '$_root/drawer_personal_information.svg';
  static const drawerPersonalInformationDeselected =
      '$_root/drawer_personal_information_deselected.svg';
  static const drawerResalat = '$_root/drawer_resalat.svg';
  static const drawerSearch = '$_root/drawer_search.svg';
  static const drawerSubmenuLine = '$_root/drawer_submenu_line.svg';
  static const fileUploadFile = '$_root/file_upload_file.svg';
  static const fileUploadTrash = '$_root/file_upload_trash.svg';
  static const fileUploadUploadCloud = '$_root/file_upload_upload_cloud.svg';
  static const iconAngleLeft20Gray700 = '$_root/icon_angle_left_20_gray700.svg';
  static const iconClose24Gray700 = '$_root/icon_close_24_gray700.svg';
  static const iconCopy16White = '$_root/icon_copy_16_white.svg';
  static const iconMenuLeft24 = '$_root/icon_menu_left_24.svg';
  static const iconMoreVertical20Gray700 =
      '$_root/icon_more_vertical_20_gray700.svg';
  static const iconRepresentative32Gray600 =
      '$_root/icon_representative_32_gray600.svg';
  static const iconWallet20Gray600 = '$_root/icon_wallet_20_gray600.svg';
  static const invoiceChevronDown = '$_root/invoice_chevron_down.svg';
  static const invoiceChevronUp = '$_root/invoice_chevron_up.svg';
  static const invoiceCost = '$_root/invoice_cost.svg';
  static const invoiceCurrency = '$_root/invoice_currency.svg';
  static const invoiceCurrencyPrimary = '$_root/invoice_currency_primary.svg';
  static const invoiceDelivery = '$_root/invoice_delivery.svg';
  static const invoiceDivider = '$_root/invoice_divider.svg';
  static const invoiceIdentityVideo = '$_root/invoice_identity_video.svg';
  static const invoicePrint = '$_root/invoice_print.svg';
  static const loanCardCopy = '$_root/loan_card_copy.svg';
  static const loanCardDividerMulti = '$_root/loan_card_divider_multi.svg';
  static const loanCardDividerSingle = '$_root/loan_card_divider_single.svg';
  static const occupationCardBriefcase = '$_root/occupation_card_briefcase.svg';
  static const representativeCardMoreVertical =
      '$_root/representative_card_more_vertical.svg';
  static const resalatCardEye = '$_root/resalat_card_eye.svg';
  static const resalatCardEyeSlash = '$_root/resalat_card_eye_slash.svg';
  static const resalatCardMoreVertical =
      '$_root/resalat_card_more_vertical.svg';
  static const serviceGridQuickAccess = '$_root/service_grid_quick_access.svg';
  static const serviceGridQuickService =
      '$_root/service_grid_quick_service.svg';
  static const serviceGridQuickServiceBlueGray =
      '$_root/service_grid_quick_service_blue_gray.svg';
  static const serviceGridRepresentative =
      '$_root/service_grid_representative.svg';
  static const serviceGridRepresentativeBlue =
      '$_root/service_grid_representative_blue.svg';
  static const serviceGridRepresentativeBlueGray =
      '$_root/service_grid_representative_blue_gray.svg';
  static const serviceGridRepresentativeGreen =
      '$_root/service_grid_representative_green.svg';
  static const serviceGridRepresentativePurple =
      '$_root/service_grid_representative_purple.svg';
  static const serviceGridSetting = '$_root/service_grid_setting.svg';
  static const transactionCardReceived = '$_root/transaction_card_received.svg';
  static const transactionCardSend = '$_root/transaction_card_send.svg';
  static const transactionCardShoppingCartCheck =
      '$_root/transaction_card_shopping_cart_check.svg';
  static const transactionCardTransport =
      '$_root/transaction_card_transport.svg';
  static const transferDestinationCardDivider1 =
      '$_root/transfer_destination_card_divider_1.svg';
  static const transferDestinationCardDivider2 =
      '$_root/transfer_destination_card_divider_2.svg';
  static const transferDestinationCardDivider3 =
      '$_root/transfer_destination_card_divider_3.svg';
  static const transferDestinationCardDivider4 =
      '$_root/transfer_destination_card_divider_4.svg';
  static const transferDestinationCardDivider5 =
      '$_root/transfer_destination_card_divider_5.svg';
  static const transferDestinationCardDivider6 =
      '$_root/transfer_destination_card_divider_6.svg';
  static const transferDestinationCardDivider7 =
      '$_root/transfer_destination_card_divider_7.svg';
  static const transferDestinationCardDivider8 =
      '$_root/transfer_destination_card_divider_8.svg';
  static const transferDestinationCardTrash =
      '$_root/transfer_destination_card_trash.svg';
  static const walletCardWallet = '$_root/wallet_card_wallet.svg';
  static const welcomeCardTimerSeparator =
      '$_root/welcome_card_timer_separator.svg';

  /// Every registered file, used by the asset integrity test.
  static const all = <String>[
    addressCardAngleLeft,
    addressCardBuildings,
    addressCardHomeHeart,
    arrowButtonArrowLeft,
    arrowButtonArrowRight,
    authAssetReport,
    authCallCenter,
    authCaptcha,
    authChangeMobile,
    authClock,
    authClose,
    authInfoCircle,
    authInheritance,
    authInternetBank,
    authLock,
    authMobile,
    authMobileBank,
    authRefresh,
    authRequestStatus,
    authResalatLogo,
    authResalatService,
    authResalatWordmark,
    authSectionDivider1,
    authSectionDivider2,
    authSecurity,
    authUpdateGuide,
    authUser,
    bankingChannelCardAngleLeft,
    bankingChannelCardBackground,
    bankingChannelCardDivider,
    bankingChannelCardGlobe,
    bankingChannelCardMobile,
    bankingChannelCardPhone,
    bankingChannelCardRefresh,
    bankingChannelCardWallet,
    bottomSheetHeaderWallet,
    cardsListCoupon,
    cardsListCreditCard,
    cardsListFamily,
    cardsListGiftCard,
    cardsListVirtualCard,
    dashboardBannerBlue,
    dashboardBannerYellow,
    dashboardCardBlock,
    dashboardCardIssue,
    dashboardCardLinkedDeposit,
    dashboardCardPassword,
    dashboardDepositCertificate,
    dashboardDepositSms,
    dashboardDepositStatement,
    dashboardHeaderBell,
    dashboardHeaderMenu,
    dashboardHeaderUser,
    dashboardLoanCalculator,
    dashboardLoanConsolidation,
    dashboardLoanLinkedDeposit,
    dashboardLoanTransfer,
    dashboardPatternDown,
    dashboardPatternUp,
    dashboardRequestDivider,
    dashboardSectionDivider,
    dashboardSelectedCheque,
    dashboardSelectedInternet,
    dashboardSelectedMobile,
    dashboardSelectedProxy,
    depositCardResalatLogo,
    depositListDeposit,
    dividerCardGray200,
    drawerCard,
    drawerCheque,
    drawerChevronDown,
    drawerChevronUp,
    drawerClose,
    drawerDeposit,
    drawerHome,
    drawerLoan,
    drawerModernBanking,
    drawerMoneyTransfer,
    drawerMyRequests,
    drawerMyRequestsDeselected,
    drawerPersonalInformation,
    drawerPersonalInformationDeselected,
    drawerResalat,
    drawerSearch,
    drawerSubmenuLine,
    fileUploadFile,
    fileUploadTrash,
    fileUploadUploadCloud,
    iconAngleLeft20Gray700,
    iconClose24Gray700,
    iconCopy16White,
    iconMenuLeft24,
    iconMoreVertical20Gray700,
    iconRepresentative32Gray600,
    iconWallet20Gray600,
    invoiceChevronDown,
    invoiceChevronUp,
    invoiceCost,
    invoiceCurrency,
    invoiceCurrencyPrimary,
    invoiceDelivery,
    invoiceDivider,
    invoiceIdentityVideo,
    invoicePrint,
    loanCardCopy,
    loanCardDividerMulti,
    loanCardDividerSingle,
    occupationCardBriefcase,
    representativeCardMoreVertical,
    resalatCardEye,
    resalatCardEyeSlash,
    resalatCardMoreVertical,
    serviceGridQuickAccess,
    serviceGridQuickService,
    serviceGridQuickServiceBlueGray,
    serviceGridRepresentative,
    serviceGridRepresentativeBlue,
    serviceGridRepresentativeBlueGray,
    serviceGridRepresentativeGreen,
    serviceGridRepresentativePurple,
    serviceGridSetting,
    transactionCardReceived,
    transactionCardSend,
    transactionCardShoppingCartCheck,
    transactionCardTransport,
    transferDestinationCardDivider1,
    transferDestinationCardDivider2,
    transferDestinationCardDivider3,
    transferDestinationCardDivider4,
    transferDestinationCardDivider5,
    transferDestinationCardDivider6,
    transferDestinationCardDivider7,
    transferDestinationCardDivider8,
    transferDestinationCardTrash,
    walletCardWallet,
    welcomeCardTimerSeparator,
  ];
}
