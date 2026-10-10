/// Canonical registry for application-owned image assets.
///
/// Keep asset paths here so renames and deduplication stay isolated from UI
/// code. Feature-specific facades may alias these constants, but must not
/// duplicate path strings.
abstract final class AppAssets {
  static const passwordRequestScrim =
      'assets/images/password_request_scrim.svg';
  static const passwordEyeSlash = 'assets/images/password_eye_slash.svg';
  static const passwordCheckInactive =
      'assets/images/password_check_inactive.svg';
  static const passwordCheckActive = 'assets/images/password_check_active.svg';
  static const passwordInfo = 'assets/images/password_info.svg';
  static const passwordInstruction = 'assets/images/password_instruction.png';
  static const passwordCameraInfo = 'assets/images/password_camera_info.svg';
  static const passwordRecording = 'assets/images/password_recording.png';
  static const passwordRecordPlay = 'assets/images/password_record_play.svg';
  static const passwordApproved = 'assets/images/password_approved.svg';
  static const passwordChangeScrim = 'assets/images/password_change_scrim.svg';
  static const passwordStatusSuccess =
      'assets/images/password_status_success.svg';
  static const passwordOperationScrim =
      'assets/images/password_operation_scrim.svg';
  static const passwordScrim = 'assets/images/password_scrim.svg';

  static const issuanceTrash = 'assets/images/issuance_trash.svg';
  static const issuanceSummaryDivider =
      'assets/images/issuance_summary_divider.svg';
  static const issuanceSummaryDividerOperation =
      'assets/images/issuance_summary_divider_operation.svg';
  static const issuanceSummaryChevron =
      'assets/images/issuance_summary_chevron.svg';
  static const issuanceSelectEmpty = 'assets/images/issuance_select_empty.svg';
  static const issuancePlus = 'assets/images/issuance_plus.svg';
  static const issuanceDivider = 'assets/images/issuance_divider.svg';
  static const issuanceCredit = 'assets/images/issuance_credit.svg';
  static const issuanceCardDivider = 'assets/images/issuance_card_divider.svg';
  static const issuanceCalendar = 'assets/images/issuance_calendar.svg';
  static const cardFeaturesResalat = "assets/images/card_features_resalat.svg";
  static const cardFeaturesGift = "assets/images/card_features_gift.svg";
  static const cardFeaturesVirtual = "assets/images/card_features_virtual.svg";
  static const cardFeaturesCoupon = "assets/images/card_features_coupon.svg";
  static const cardFeaturesFamily = "assets/images/card_features_family.svg";
  static const cardFeaturesScrim = 'assets/images/card_features_scrim.svg';
  static const cardFeaturesBack = "assets/images/card_features_back.svg";
  static const cardFeaturesFilter = "assets/images/card_features_filter.svg";
  static const cardFeaturesSearch = "assets/images/card_features_search.svg";
  static const cardFeaturesSeparator =
      "assets/images/card_features_separator.png";
  static const cardFeaturesInfo = "assets/images/card_features_info.svg";
  static const cardFeaturesReissue = "assets/images/card_features_reissue.svg";
  static const cardFeaturesChangeDeposit =
      "assets/images/card_features_change_deposit.svg";
  static const cardFeaturesBlock = "assets/images/card_features_block.svg";
  static const cardFeaturesDivider = "assets/images/card_features_divider.svg";
  static const cardFeaturesFilterHeader =
      "assets/images/card_features_filter_header.svg";
  static const cardFeaturesChevron = "assets/images/card_features_chevron.svg";
  static const cardFeaturesExpiredGift =
      "assets/images/card_features_expired_gift.svg";
  static const cardFeaturesPlus = "assets/images/card_features_plus.svg";
  static const _root = 'assets/images';

  static const loansChangeDeposit = '$_root/loans_change_deposit.svg';
  static const loansCorrectInstallments =
      '$_root/loans_correct_installments.svg';
  static const loansDefer = '$_root/loans_defer.svg';
  static const loansPatternUp = '$_root/loans_pattern_up.svg';
  static const loansPay = '$_root/loans_pay.svg';
  static const loansQuickConsolidate = '$_root/loans_quick_consolidate.svg';
  static const loansQuickRelationships = '$_root/loans_quick_relationships.svg';

  static const depositsBlock = '$_root/deposits_block.svg';
  static const depositsCards = '$_root/deposits_cards.svg';
  static const depositsCertificate = '$_root/deposits_certificate.svg';
  static const depositsChequeCancel = '$_root/deposits_cheque_cancel.svg';
  static const depositsChequeClear = '$_root/deposits_cheque_clear.svg';
  static const depositsChequeIssue = '$_root/deposits_cheque_issue.svg';
  static const depositsLoans = '$_root/deposits_loans.svg';
  static const depositsPatternUp = '$_root/deposits_pattern_up.svg';
  static const depositsQuickAccess = '$_root/deposits_quick_access.svg';
  static const depositsQuickEstimate = '$_root/deposits_quick_estimate.svg';
  static const depositsQuickInternet = '$_root/deposits_quick_internet.svg';
  static const depositsQuickIntroduce = '$_root/deposits_quick_introduce.svg';
  static const depositsQuickIssue = '$_root/deposits_quick_issue.svg';
  static const depositsQuickMobile = '$_root/deposits_quick_mobile.svg';
  static const depositsQuickPhone = '$_root/deposits_quick_phone.svg';
  static const depositsQuickProxy = '$_root/deposits_quick_proxy.svg';
  static const depositsQuickTransfer = '$_root/deposits_quick_transfer.svg';
  static const depositsRepresentative = '$_root/deposits_representative.svg';
  static const depositsSms = '$_root/deposits_sms.svg';
  static const depositsStatement = '$_root/deposits_statement.svg';
  static const depositsVirtual = '$_root/deposits_virtual.svg';

  static const addressCardAngleLeft = '$_root/address_card_angle_left.svg';
  static const addressCardBuildings = '$_root/address_card_buildings.svg';
  static const addressCardHomeHeart = '$_root/address_card_home_heart.svg';
  static const arrowButtonArrowLeft = '$_root/arrow_button_arrow_left.svg';
  static const arrowButtonArrowRight = '$_root/arrow_button_arrow_right.svg';
  static const authBackground = '$_root/auth_background.png';
  static const authHeaderDivider = '$_root/auth_header_divider.svg';
  static const authMenu = '$_root/auth_menu.svg';
  static const authSectionMark = '$_root/auth_section_mark.svg';
  static const authSheetClose = '$_root/auth_sheet_close.svg';
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
  static const dashboardHeaderBell = '$_root/dashboard_header_bell.svg';
  static const dashboardHeaderMenu = '$_root/dashboard_header_menu.svg';
  static const dashboardHeaderUser = '$_root/dashboard_header_user.svg';
  static const dashboardPatternDown = '$_root/dashboard_pattern_down.svg';
  static const dashboardPatternUp = '$_root/dashboard_pattern_up.svg';
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

  static const dashboardAssistantSpark = '$_root/dashboard_assistant_spark.svg';
  static const dashboardAssistantStar = '$_root/dashboard_assistant_star.svg';
  static const dashboardBlockEditTile = '$_root/dashboard_block_edit_tile.svg';
  static const dashboardBlockFullTile = '$_root/dashboard_block_full_tile.svg';
  static const dashboardBlockSelectedTile =
      '$_root/dashboard_block_selected_tile.svg';
  static const dashboardCardDivider = '$_root/dashboard_card_divider.svg';
  static const dashboardCatalogBlock = '$_root/dashboard_catalog_block.svg';
  static const dashboardCatalogCardDeposit =
      '$_root/dashboard_catalog_card_deposit.svg';
  static const dashboardCatalogCertificate =
      '$_root/dashboard_catalog_certificate.svg';
  static const dashboardCatalogConsolidation =
      '$_root/dashboard_catalog_consolidation.svg';
  static const dashboardCatalogEstimate =
      '$_root/dashboard_catalog_estimate.svg';
  static const dashboardCatalogIntroduce =
      '$_root/dashboard_catalog_introduce.svg';
  static const dashboardCatalogIssue = '$_root/dashboard_catalog_issue.svg';
  static const dashboardCatalogLoanDeposit =
      '$_root/dashboard_catalog_loan_deposit.svg';
  static const dashboardCatalogPassword =
      '$_root/dashboard_catalog_password.svg';
  static const dashboardCatalogRepresentative =
      '$_root/dashboard_catalog_representative.svg';
  static const dashboardCatalogStatement =
      '$_root/dashboard_catalog_statement.svg';
  static const dashboardDepositDivider = '$_root/dashboard_deposit_divider.svg';
  static const dashboardEditDivider = '$_root/dashboard_edit_divider.png';
  static const dashboardEstimateFullTile =
      '$_root/dashboard_estimate_full_tile.svg';
  static const dashboardEstimateSelectedTile =
      '$_root/dashboard_estimate_selected_tile.svg';
  static const dashboardEstimateTile = '$_root/dashboard_estimate_tile.svg';
  static const dashboardFabSpark = '$_root/dashboard_fab_spark.svg';
  static const dashboardFabStar = '$_root/dashboard_fab_star.svg';
  static const dashboardGlowLarge = '$_root/dashboard_glow_large.svg';
  static const dashboardGlowSmall = '$_root/dashboard_glow_small.svg';
  static const dashboardIssueEditTile = '$_root/dashboard_issue_edit_tile.svg';
  static const dashboardIssueSelectedTile =
      '$_root/dashboard_issue_selected_tile.svg';
  static const dashboardLoanDivider = '$_root/dashboard_loan_divider.svg';
  static const dashboardMinus = '$_root/dashboard_minus.svg';
  static const dashboardNavCard = '$_root/dashboard_nav_card.svg';
  static const dashboardNavDeposit = '$_root/dashboard_nav_deposit.svg';
  static const dashboardNavHome = '$_root/dashboard_nav_home.svg';
  static const dashboardNavLoan = '$_root/dashboard_nav_loan.svg';
  static const dashboardPasswordEditTile =
      '$_root/dashboard_password_edit_tile.svg';
  static const dashboardPasswordFullTile =
      '$_root/dashboard_password_full_tile.svg';
  static const dashboardPasswordSelectedTile =
      '$_root/dashboard_password_selected_tile.svg';
  static const dashboardPasswordTile = '$_root/dashboard_password_tile.svg';
  static const dashboardPlus = '$_root/dashboard_plus.svg';
  static const dashboardPromptArrow = '$_root/dashboard_prompt_arrow.svg';
  static const dashboardReset = '$_root/dashboard_reset.svg';
  static const dashboardReso = '$_root/dashboard_reso.png';
  static const dashboardSms = '$_root/dashboard_sms.svg';
  static const dashboardTexture = '$_root/dashboard_texture.png';
  static const dashboardTileWave = '$_root/dashboard_tile_wave.svg';

  static const dashboardCatalogSms = '$_root/dashboard_catalog_sms.svg';
  static const dashboardCatalogSearch = '$_root/dashboard_catalog_search.svg';

  static const dashboardAllAngle = '$_root/dashboard_all_angle.svg';
  static const dashboardFixedSms = '$_root/dashboard_fixed_sms.svg';
  static const dashboardFixedEstimate = '$_root/dashboard_fixed_estimate.svg';
  static const dashboardFixedPassword = '$_root/dashboard_fixed_password.svg';
  static const dashboardFixedRepresentative =
      '$_root/dashboard_fixed_representative.svg';
  static const dashboardFixedCertificate =
      '$_root/dashboard_fixed_certificate.svg';
  static const dashboardFixedStatement = '$_root/dashboard_fixed_statement.svg';
  static const dashboardFixedBlock = '$_root/dashboard_fixed_block.svg';
  static const dashboardAddFavorites = '$_root/dashboard_add_favorites.svg';
  static const dashboardEdit = '$_root/dashboard_edit.svg';
  static const dashboardFavoriteCardDeposit =
      '$_root/dashboard_favorite_card_deposit.svg';
  static const dashboardFavoriteChequeIcon =
      '$_root/dashboard_favorite_cheque_icon.svg';
  static const dashboardFavoriteConsolidation =
      '$_root/dashboard_favorite_consolidation.svg';
  static const dashboardFavoriteIssue = '$_root/dashboard_favorite_issue.svg';
  static const dashboardFavoriteProxy = '$_root/dashboard_favorite_proxy.svg';
  static const dashboardFavoriteMobile = '$_root/dashboard_favorite_mobile.svg';
  static const dashboardFavoriteCardDepositEdit =
      '$_root/dashboard_favorite_card_deposit_edit.svg';
  static const dashboardFavoriteConsolidationEdit =
      '$_root/dashboard_favorite_consolidation_edit.svg';
  static const dashboardFavoriteIssueEdit =
      '$_root/dashboard_favorite_issue_edit.svg';
  static const dashboardFavoriteLoanDepositEdit =
      '$_root/dashboard_favorite_loan_deposit_edit.svg';
  static const dashboardFavoriteInternetEdit =
      '$_root/dashboard_favorite_internet_edit.svg';
  static const dashboardFavoriteProxyEdit =
      '$_root/dashboard_favorite_proxy_edit.svg';
  static const dashboardFavoriteMobileEdit =
      '$_root/dashboard_favorite_mobile_edit.svg';
  static const dashboardOptionMore = '$_root/dashboard_option_more.svg';
  static const dashboardCategoryModern = '$_root/dashboard_category_modern.svg';
  static const dashboardCategoryCardActive =
      '$_root/dashboard_category_card_active.svg';
  static const dashboardCategoryCheque = '$_root/dashboard_category_cheque.svg';
  static const dashboardCategoryCollapse =
      '$_root/dashboard_category_collapse.svg';
  static const dashboardOptionIssue = '$_root/dashboard_option_issue.svg';
  static const dashboardOptionPassword = '$_root/dashboard_option_password.svg';
  static const dashboardOptionCardDeposit =
      '$_root/dashboard_option_card_deposit.svg';
  static const dashboardOptionBlock = '$_root/dashboard_option_block.svg';
  static const dashboardCatalogMore = '$_root/dashboard_catalog_more.svg';
  static const dashboardCatalogRequests =
      '$_root/dashboard_catalog_requests.svg';
  static const dashboardCatalogCategoryModern =
      '$_root/dashboard_catalog_category_modern.svg';
  static const dashboardCatalogCategoryCard =
      '$_root/dashboard_catalog_category_card.svg';
  static const dashboardCatalogCategoryCheque =
      '$_root/dashboard_catalog_category_cheque.svg';
  static const dashboardCatalogCategoryTransfer =
      '$_root/dashboard_catalog_category_transfer.svg';
  static const dashboardCatalogCategoryLoan =
      '$_root/dashboard_catalog_category_loan.svg';
  static const dashboardCatalogCategoryDeposit =
      '$_root/dashboard_catalog_category_deposit.svg';
  static const dashboardCatalogCategoryWallet =
      '$_root/dashboard_catalog_category_wallet.svg';
  static const dashboardCatalogCategoryIdentity =
      '$_root/dashboard_catalog_category_identity.svg';
  static const dashboardCatalogCategoryRequests =
      '$_root/dashboard_catalog_category_requests.svg';
  static const dashboardSearchClear = '$_root/dashboard_search_clear.svg';
  static const dashboardGreenPlus = '$_root/dashboard_green_plus.svg';

  static const dashboardSearchCard = '$_root/dashboard_search_card.svg';
  static const dashboardSearchWallet = '$_root/dashboard_search_wallet.svg';
  static const dashboardSearchIdentity = '$_root/dashboard_search_identity.svg';

  static const dashboardCatalogBack = '$_root/dashboard_catalog_back.svg';

  static const dashboardDividerModern = '$_root/dashboard_divider_modern.svg';
  static const dashboardDividerCard = '$_root/dashboard_divider_card.svg';
  static const dashboardDividerCheque = '$_root/dashboard_divider_cheque.svg';
  static const dashboardDividerTransfer =
      '$_root/dashboard_divider_transfer.svg';
  static const dashboardDividerLoan = '$_root/dashboard_divider_loan.svg';
  static const dashboardDividerDeposit = '$_root/dashboard_divider_deposit.svg';
  static const dashboardDividerWallet = '$_root/dashboard_divider_wallet.svg';
  static const dashboardDividerIdentity =
      '$_root/dashboard_divider_identity.svg';
  static const dashboardDividerRequests =
      '$_root/dashboard_divider_requests.svg';
  static const dashboardDividerSheetModern =
      '$_root/dashboard_divider_sheet_modern.svg';
  static const dashboardDividerSheetCard =
      '$_root/dashboard_divider_sheet_card.svg';
  static const dashboardDividerSheetCheque =
      '$_root/dashboard_divider_sheet_cheque.svg';

  static const cardsActionBlock = '$_root/cards_action_block.svg';
  static const cardsActionDeposit = '$_root/cards_action_deposit.svg';
  static const cardsActionReissue = '$_root/cards_action_reissue.svg';
  static const cardsActionForgotFirst = '$_root/cards_action_forgot_first.svg';
  static const cardsActionSetSecond = '$_root/cards_action_set_second.svg';
  static const cardsActionChangeFirst = '$_root/cards_action_change_first.svg';
  static const cardsQuickAccess = '$_root/cards_quick_access.svg';
  static const cardsQuickGiftBalance = '$_root/cards_quick_gift_balance.svg';
  static const cardsQuickGiftBuy = '$_root/cards_quick_gift_buy.svg';
  static const cardsQuickVirtual = '$_root/cards_quick_virtual.svg';
  static const cardsQuickIssue = '$_root/cards_quick_issue.svg';
  static const cardsNavActive = '$_root/cards_nav_active.svg';
  static const cardsNavHome = '$_root/cards_nav_home.svg';
  static const cardsPatternUp = '$_root/cards_pattern_up.svg';
  static const cardsActionForgotSecond =
      '$_root/cards_action_forgot_second.svg';

  /// Every registered file, used by the asset integrity test.
  static const notificationBack = '$_root/notification_back.svg';
  static const notificationDivider = '$_root/notification_divider.svg';
  static const notificationUnread = '$_root/notification_unread.svg';
  static const notificationReadAll = '$_root/notification_read_all.svg';
  static const notificationLogoGray = '$_root/notification_logo_gray.svg';
  static const notificationLogoBlue = '$_root/notification_logo_blue.svg';
  static const notificationSecurity = '$_root/notification_security.png';

  static const all = <String>[
    passwordRequestScrim,
    passwordEyeSlash,
    passwordCheckInactive,
    passwordCheckActive,
    passwordInfo,
    passwordInstruction,
    passwordCameraInfo,
    passwordRecording,
    passwordRecordPlay,
    passwordApproved,
    passwordScrim,
    passwordOperationScrim,
    passwordStatusSuccess,
    passwordChangeScrim,

    issuanceCalendar,
    issuanceCardDivider,
    issuanceCredit,
    issuanceDivider,
    issuancePlus,
    issuanceSelectEmpty,
    issuanceSummaryChevron,
    issuanceSummaryDividerOperation,
    issuanceSummaryDivider,
    issuanceTrash,
    loansChangeDeposit,
    loansCorrectInstallments,
    loansDefer,
    loansPatternUp,
    loansPay,
    loansQuickConsolidate,
    loansQuickRelationships,
    depositsBlock,
    depositsCards,
    depositsCertificate,
    depositsChequeCancel,
    depositsChequeClear,
    depositsChequeIssue,
    depositsLoans,
    depositsPatternUp,
    depositsQuickAccess,
    depositsQuickEstimate,
    depositsQuickInternet,
    depositsQuickIntroduce,
    depositsQuickIssue,
    depositsQuickMobile,
    depositsQuickPhone,
    depositsQuickProxy,
    depositsQuickTransfer,
    depositsRepresentative,
    depositsSms,
    depositsStatement,
    depositsVirtual,
    dashboardAllAngle,
    dashboardFixedSms,
    dashboardFixedEstimate,
    dashboardFixedPassword,
    dashboardFixedRepresentative,
    dashboardFixedCertificate,
    dashboardFixedStatement,
    dashboardFixedBlock,
    dashboardAddFavorites,
    dashboardEdit,
    dashboardFavoriteCardDeposit,
    dashboardFavoriteChequeIcon,
    dashboardFavoriteConsolidation,
    dashboardFavoriteIssue,
    dashboardFavoriteProxy,
    dashboardFavoriteMobile,
    dashboardFavoriteCardDepositEdit,
    dashboardFavoriteConsolidationEdit,
    dashboardFavoriteIssueEdit,
    dashboardFavoriteLoanDepositEdit,
    dashboardFavoriteInternetEdit,
    dashboardFavoriteProxyEdit,
    dashboardFavoriteMobileEdit,
    dashboardOptionMore,
    dashboardCategoryModern,
    dashboardCategoryCardActive,
    dashboardCategoryCheque,
    dashboardCategoryCollapse,
    dashboardOptionIssue,
    dashboardOptionPassword,
    dashboardOptionCardDeposit,
    dashboardOptionBlock,
    dashboardCatalogMore,
    dashboardCatalogRequests,
    dashboardCatalogCategoryModern,
    dashboardCatalogCategoryCard,
    dashboardCatalogCategoryCheque,
    dashboardCatalogCategoryTransfer,
    dashboardCatalogCategoryLoan,
    dashboardCatalogCategoryDeposit,
    dashboardCatalogCategoryWallet,
    dashboardCatalogCategoryIdentity,
    dashboardCatalogCategoryRequests,
    dashboardDividerModern,
    dashboardDividerCard,
    dashboardDividerCheque,
    dashboardDividerTransfer,
    dashboardDividerLoan,
    dashboardDividerDeposit,
    dashboardDividerWallet,
    dashboardDividerIdentity,
    dashboardDividerRequests,
    dashboardDividerSheetModern,
    dashboardDividerSheetCard,
    dashboardDividerSheetCheque,
    cardsActionBlock,
    cardsActionDeposit,
    cardsActionReissue,
    cardsActionForgotFirst,
    cardsActionSetSecond,
    cardsActionChangeFirst,
    cardsQuickAccess,
    cardsQuickGiftBalance,
    cardsQuickGiftBuy,
    cardsQuickVirtual,
    cardsQuickIssue,
    cardsNavActive,
    cardsNavHome,
    cardsPatternUp,
    cardsActionForgotSecond,
    dashboardCatalogBack,
    dashboardSearchClear,
    dashboardSearchCard,
    dashboardSearchWallet,
    dashboardSearchIdentity,
    dashboardGreenPlus,
    notificationBack,
    notificationDivider,
    notificationUnread,
    notificationReadAll,
    notificationLogoGray,
    notificationLogoBlue,
    notificationSecurity,

    dashboardCatalogSms,
    dashboardCatalogSearch,
    dashboardAssistantSpark,
    dashboardAssistantStar,
    dashboardBlockEditTile,
    dashboardBlockFullTile,
    dashboardBlockSelectedTile,
    dashboardCardDivider,
    dashboardCatalogBlock,
    dashboardCatalogCardDeposit,
    dashboardCatalogCertificate,
    dashboardCatalogConsolidation,
    dashboardCatalogEstimate,
    dashboardCatalogIntroduce,
    dashboardCatalogIssue,
    dashboardCatalogLoanDeposit,
    dashboardCatalogPassword,
    dashboardCatalogRepresentative,
    dashboardCatalogStatement,
    dashboardDepositDivider,
    dashboardEditDivider,
    dashboardEstimateFullTile,
    dashboardEstimateSelectedTile,
    dashboardEstimateTile,
    dashboardFabSpark,
    dashboardFabStar,
    dashboardGlowLarge,
    dashboardGlowSmall,
    dashboardIssueEditTile,
    dashboardIssueSelectedTile,
    dashboardLoanDivider,
    dashboardMinus,
    dashboardNavCard,
    dashboardNavDeposit,
    dashboardNavHome,
    dashboardNavLoan,
    dashboardPasswordEditTile,
    dashboardPasswordFullTile,
    dashboardPasswordSelectedTile,
    dashboardPasswordTile,
    dashboardPlus,
    dashboardPromptArrow,
    dashboardReset,
    dashboardReso,
    dashboardSms,
    dashboardTexture,
    dashboardTileWave,

    addressCardAngleLeft,
    addressCardBuildings,
    addressCardHomeHeart,
    arrowButtonArrowLeft,
    arrowButtonArrowRight,
    authBackground,
    authHeaderDivider,
    authMenu,
    authSectionMark,
    authSheetClose,
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
    dashboardHeaderBell,
    dashboardHeaderMenu,
    dashboardHeaderUser,
    dashboardPatternDown,
    dashboardPatternUp,
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
  ];
}
