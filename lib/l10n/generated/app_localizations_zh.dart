// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Receipt Trail';

  @override
  String get language => '語言';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get english => 'English';

  @override
  String get languageSaveFailed => '無法儲存語言設定，請再試一次';

  @override
  String get welcomeTitle => '歡迎使用 Receipt Trail';

  @override
  String get welcomeDescription =>
      '登入可同步並在重新安裝後恢復資料；訪客資料只保存在這台裝置，刪除 App 後無法恢復。';

  @override
  String get loginOrRegister => '登入或註冊';

  @override
  String get continueAsGuest => '以訪客身分使用';

  @override
  String get guestMigrationNote => '之後登入時，裝置上的訪客紀錄會自動移入該帳號。';

  @override
  String get dataRepairTitle => '資料需要修復';

  @override
  String get dataRepairFallback => '資料尚未完成搬移，原始資料仍保留。';

  @override
  String get dataMigrationFailed => '資料遷移失敗，原始資料仍保留，可安全重試。';

  @override
  String get guestClaimFailed => '登入成功，但訪客資料認領失敗，請重試。';

  @override
  String get dataRepairFailed => '資料修復仍未完成，原始資料沒有被刪除。';

  @override
  String get retryDataRepair => '重試資料修復';

  @override
  String get navOverview => '總覽';

  @override
  String get navReceipts => '發票';

  @override
  String get navScan => '掃描';

  @override
  String get navMap => '地圖';

  @override
  String get navAccount => '我的';

  @override
  String get accountTitle => '我的帳號';

  @override
  String get guestInitial => '訪';

  @override
  String get guestName => '訪客';

  @override
  String get guestSyncPrompt => '登入後可跨裝置同步';

  @override
  String get securityTitle => '安全性';

  @override
  String get biometricLogin => '生物辨識快速登入';

  @override
  String get loginFirst => '請先登入帳號';

  @override
  String get secureTokenSaved => 'Token 已保存於系統安全儲存區';

  @override
  String get biometricComingSoon => '生物辨識將在下一階段接入系統驗證';

  @override
  String get changePassword => '變更密碼';

  @override
  String get changePasswordUnavailable => '變更密碼端點尚未啟用';

  @override
  String get dataAndSyncTitle => '資料與同步';

  @override
  String get syncStatus => '同步狀態';

  @override
  String get signInToSync => '登入後即可啟用雲端同步';

  @override
  String get syncingData => '正在同步資料…';

  @override
  String get dataSynced => '資料已與雲端同步';

  @override
  String pendingSyncCount(int count) {
    return '$count 筆資料等待同步';
  }

  @override
  String get syncNow => '立即同步';

  @override
  String get localData => '本機資料';

  @override
  String localDataSummary(int receiptCount, int storeCount) {
    return '$receiptCount 筆發票 · $storeCount 個店家 · 已永久保存';
  }

  @override
  String get localDataSaved => '資料已安全保存在這台裝置';

  @override
  String get exportData => '匯出資料';

  @override
  String get exportSubtitle => '匯出這台裝置目前可見的 CSV、JSON 快照';

  @override
  String get resetAll => '全部重置';

  @override
  String get resetGuestSubtitle => '永久刪除此裝置上的訪客紀錄';

  @override
  String get resetAccountSubtitle => '可選擇只清除此裝置，或刪除所有雲端紀錄';

  @override
  String get preferencesTitle => '偏好設定';

  @override
  String get syncNotifications => '同步通知';

  @override
  String get logout => '登出';

  @override
  String get exportDialogTitle => '匯出消費資料';

  @override
  String get exportDialogBody =>
      'ZIP 會包含這台裝置目前可見的消費、發票、地址與經緯度等個人資料，且未加密；目前 App 尚未提供匯入還原。OCR 原文可能含更多個資，建議不要一併匯出。';

  @override
  String get cancel => '取消';

  @override
  String get includeOcr => '包含 OCR 原文';

  @override
  String get exportWithoutOcr => '匯出（不含 OCR）';

  @override
  String get exportCompleted => '匯出檔已分享或儲存';

  @override
  String get exportDismissed => '已取消匯出，沒有確認檔案已保存';

  @override
  String get exportUnavailable => '系統無法確認是否已保存，請檢查你選擇的位置';

  @override
  String get exportFailed => '匯出失敗，請再試一次';

  @override
  String get exportShareTitle => '匯出 Receipt Trail 資料';

  @override
  String get exportShareSubject => 'Receipt Trail 資料匯出檔';

  @override
  String get resetCompleted => '資料已依照你的選擇清除';

  @override
  String get resetFailed => '無法清除資料，請再試一次';

  @override
  String get cloudDeleteUnconfirmed => '雲端刪除尚未確認，本機資料仍保留，可稍後安全重試。';

  @override
  String get noAuthenticatedAccount => '目前沒有登入帳號';

  @override
  String get clearGuestTitle => '清除訪客資料？';

  @override
  String get clearGuestBody => '訪客資料只存在這台裝置，刪除後無法從雲端復原。';

  @override
  String get continueAction => '繼續';

  @override
  String get chooseResetScope => '選擇清除範圍';

  @override
  String get chooseResetScopeBody => '只清除此裝置會同時登出，重新登入後仍可從雲端取回資料。';

  @override
  String get clearThisDevice => '只清除此裝置';

  @override
  String get clearDeviceAndCloud => '裝置與雲端全部刪除';

  @override
  String get finalConfirmation => '最後確認';

  @override
  String get cloudResetWarning => '這會永久刪除本機及雲端的全部消費紀錄。網路失敗時會保留刪除工作供你重試。';

  @override
  String get deviceResetWarning => '這項操作無法復原。匯出檔目前不能由 App 匯入還原，請先確認已另行保存。';

  @override
  String get deletePhrasePrompt => '請輸入「刪除我的資料」';

  @override
  String get deletePhrase => '刪除我的資料';

  @override
  String get deletePermanently => '永久刪除';

  @override
  String get authSuccess => '登入成功，歡迎回來';

  @override
  String get logoutTitle => '確定要登出？';

  @override
  String get logoutBody => '本機發票仍會保留，安全儲存的登入憑證將被清除。';

  @override
  String get tagline => '每張發票，都是一段生活足跡';

  @override
  String get createUser => '建立新使用者';

  @override
  String get welcomeBack => '歡迎回來';

  @override
  String get registerDescription => '建立帳號後會立即登入，密碼只會以安全雜湊保存。';

  @override
  String get loginDescription => '登入憑證會保存於 Android Keystore 或 iOS Keychain。';

  @override
  String get nameLabel => '姓名';

  @override
  String get enterName => '請輸入姓名';

  @override
  String get emailInvalid => '請輸入正確的 Email';

  @override
  String get passwordLabel => '密碼';

  @override
  String get passwordTooShort => '密碼至少需要 8 個字元';

  @override
  String get registerAndLogin => '註冊並登入';

  @override
  String get hasAccount => '已有帳號？返回登入';

  @override
  String get needsAccount => '還沒有帳號？立即註冊';

  @override
  String get authNetworkUnavailable => '目前無法連接登入服務，請檢查網路後再試一次。';

  @override
  String get authServiceUnavailable => '雲端服務可能正在喚醒，本機資料已安全保留，請稍後重試。';

  @override
  String get authInvalidCredentials => 'Email 或密碼不正確。';

  @override
  String get authEmailAlreadyRegistered => '這個 Email 已經註冊。';

  @override
  String get authSessionExpired => '登入狀態已失效，請重新登入。';

  @override
  String get authMalformedResponse => '登入服務回傳格式錯誤，請稍後重試。';

  @override
  String get authUnknownFailure => '登入失敗，請稍後重試。';

  @override
  String homeGreeting(String name) {
    return '你好，$name';
  }

  @override
  String homeDate(int month, int day, String weekday) {
    return '$month月$day日 星期$weekday';
  }

  @override
  String get weekdayMonday => '一';

  @override
  String get weekdayTuesday => '二';

  @override
  String get weekdayWednesday => '三';

  @override
  String get weekdayThursday => '四';

  @override
  String get weekdayFriday => '五';

  @override
  String get weekdaySaturday => '六';

  @override
  String get weekdaySunday => '日';

  @override
  String get scanReceipt => '掃描發票';

  @override
  String get scanAndBookkeep => '辨識並自動記帳';

  @override
  String get useCenterScanButton => '請按下方中央的掃描按鈕開始辨識發票';

  @override
  String get viewMap => '查看地圖';

  @override
  String get reviewSpendingTrail => '回顧最近消費足跡';

  @override
  String get prizeReminder => '兌獎提醒';

  @override
  String get learnMore => '了解更多';

  @override
  String get recentPurchases => '最近消費';

  @override
  String get viewAll => '查看全部';

  @override
  String get monthlySpending => '本月累積消費';

  @override
  String get localRecords => '本機紀錄';

  @override
  String get scannedReceipts => '已掃描發票';

  @override
  String receiptCountUnit(int count) {
    return '$count 張';
  }

  @override
  String get spendingTrail => '消費足跡';

  @override
  String placeCountUnit(int count) {
    return '$count 個地點';
  }

  @override
  String get generalPrizeEnabled => '一般發票對獎已啟用';

  @override
  String get prizeStatusHint => '點開消費紀錄，可查看獎別與領獎狀態。';

  @override
  String get available => '可查詢';

  @override
  String get noPurchases => '尚無消費紀錄，按下方掃描按鈕新增';

  @override
  String get purchaseRecords => '消費紀錄';

  @override
  String get purchaseRecordsSubtitle => '每一筆消費，都是生活的足跡';

  @override
  String get searchPurchases => '搜尋店家或消費';

  @override
  String get allCategories => '全部';

  @override
  String get categoryFood => '餐飲';

  @override
  String get categoryShopping => '購物';

  @override
  String get categoryTransport => '交通';

  @override
  String get categoryOther => '其他';

  @override
  String get noMatchingPurchases => '找不到符合的消費紀錄';

  @override
  String monthGroup(int year, int month) {
    return '$year 年 $month 月';
  }

  @override
  String get synced => '已同步';

  @override
  String get waitingToSync => '等待同步';

  @override
  String get receiptDetails => '發票詳細紀錄';

  @override
  String get invoicePeriod => '發票期別';

  @override
  String invoicePeriodValue(int rocYear, int startMonth, int endMonth) {
    return '$rocYear 年 $startMonth–$endMonth 月';
  }

  @override
  String get sellerTaxId => '賣方統編';

  @override
  String get itemsSubtotal => '商品小計';

  @override
  String get discount => '折扣';

  @override
  String get amountPaid => '實付金額';

  @override
  String get purchaseItems => '消費明細';

  @override
  String get rawOcrText => 'OCR 辨識原文';

  @override
  String get googleNavigation => 'Google 導航';

  @override
  String get deleteRecord => '刪除這筆紀錄';

  @override
  String get deleteRecordTitle => '刪除消費紀錄？';

  @override
  String deleteRecordBody(String merchant) {
    return '「$merchant」刪除後無法復原。';
  }

  @override
  String get delete => '刪除';

  @override
  String get noMapApp => '找不到可開啟的地圖 App';

  @override
  String get updatingPrizeNumbers => '正在更新對獎資料';

  @override
  String get offlinePrizeFallback => '若目前離線，將使用上次成功下載的獎號';

  @override
  String get prizeAwaitingDraw => '本期尚未開獎';

  @override
  String get prizeAwaitingNumbers => '尚未取得對獎資料';

  @override
  String get prizeNotWinning => '一般獎未中獎';

  @override
  String prizeWinningBeforeClaim(String tier) {
    return '中獎 · $tier（尚未開始領獎）';
  }

  @override
  String prizeClaimable(String tier) {
    return '恭喜中獎 · $tier';
  }

  @override
  String get prizeExpired => '中獎但已逾領獎期限';

  @override
  String get verifyReceiptNumber => '請確認發票號碼';

  @override
  String get prizeTierPending => '待確認';

  @override
  String get prizeTierSpecial => '特別獎';

  @override
  String get prizeTierGrand => '特獎';

  @override
  String get prizeTierFirst => '頭獎';

  @override
  String get prizeTierSecond => '二獎';

  @override
  String get prizeTierThird => '三獎';

  @override
  String get prizeTierFourth => '四獎';

  @override
  String get prizeTierFifth => '五獎';

  @override
  String get prizeTierSixth => '六獎';

  @override
  String get prizeTierAdditionalSixth => '增開六獎';

  @override
  String get prizeOfflineCache => '網路更新失敗，目前使用離線快取';

  @override
  String get prizeLocalCache => '目前使用本機快取';

  @override
  String updatedOn(String date) {
    return '更新：$date';
  }

  @override
  String dataSource(String source) {
    return '資料來源：$source';
  }

  @override
  String prizeAmount(String amount) {
    return '獎金 $amount';
  }

  @override
  String get prizeDisclaimer => '非財政部即時查詢，實際資格以財政部為準';

  @override
  String get exclusivePrizeDisclaimer => '一般獎資料不含雲端發票專屬獎，仍請至官方確認';

  @override
  String drawDate(String date) {
    return '開獎日 $date';
  }

  @override
  String get prizeSnapshotUnavailable => '後端尚無此期官方公告快照，請以財政部公告為準';

  @override
  String get openOfficialSource => '前往官方來源確認';

  @override
  String syncedUploadCount(int count) {
    return '已同步 $count 筆本機資料';
  }

  @override
  String get syncAuthenticationRequired => '請先登入後再同步';

  @override
  String get syncNetworkUnavailable => '目前無法連接雲端，請檢查網路後重試。';

  @override
  String get syncServiceUnavailable => '雲端服務可能正在喚醒，本機資料已安全保留，請稍後重試。';

  @override
  String get syncMissingLocalReceipt => '找不到等待同步的本機消費資料';

  @override
  String get syncInvalidResponse => '雲端回傳格式錯誤，請稍後重試。';

  @override
  String get syncUnknownFailure => '雲端同步失敗，請稍後重試。';

  @override
  String get mapLoadFailed => '底圖載入失敗，請確認網路連線';

  @override
  String get mapEmpty => '新增發票後，消費足跡會顯示在這裡';

  @override
  String get mapNoLocations => '目前的發票沒有可定位地址\n新增或掃描含地址的發票後會顯示圖釘';

  @override
  String get mySpendingTrail => '我的消費足跡';

  @override
  String get visitCount => '消費次數';

  @override
  String visitCountValue(int count) {
    return '$count 次';
  }

  @override
  String get totalSpending => '總消費';

  @override
  String get averageSpending => '平均消費';

  @override
  String get googleMaps => 'Google 地圖';

  @override
  String get startNavigation => '開始導航';

  @override
  String get viewPurchaseRecords => '查看消費紀錄';

  @override
  String get cannotOpenGoogleMaps => '無法開啟 Google Maps';

  @override
  String get scanFailureRecognition => 'OCR 辨識失敗，請重新拍攝或手動輸入';

  @override
  String get scanFailureNoText => '無法辨識圖片中的文字，請重新拍攝或手動輸入';

  @override
  String get scanFailureLocation => '無法取得店家位置';

  @override
  String get scanFailureUnknown => '辨識失敗，請重新拍攝或手動輸入';

  @override
  String get reviewData => '確認資料';

  @override
  String get saveComplete => '儲存完成';

  @override
  String get scanStepOne => '步驟 1 / 3';

  @override
  String get scanYourReceipt => '掃描你的發票';

  @override
  String get chooseReceiptType => '先選擇發票類型，我們會使用最合適的辨識方式。';

  @override
  String get electronicReceipt => '電子發票';

  @override
  String get scanLeftQr => '掃描左側 QR Code';

  @override
  String get traditionalReceipt => '傳統發票';

  @override
  String get photographFront => '拍攝發票正面';

  @override
  String get traditionalCaptureHint => '將發票號碼與日期完整放入畫面\n保持平整、光線充足並避免反光';

  @override
  String get electronicCaptureHint => '將電子發票 QR Code 完整放入框內\n辨識後可確認或補填內容';

  @override
  String get captureTraditional => '拍攝傳統發票';

  @override
  String get scanElectronic => '掃描電子發票';

  @override
  String get manualEntry => '改用手動輸入';

  @override
  String get enterReceiptContent => '輸入發票內容';

  @override
  String get receiptContentSubtitle => '儲存後，首頁、紀錄與消費地圖會立即同步';

  @override
  String get possibleSavedMerchant => '可能是已儲存的店家';

  @override
  String get merchantNameRequired => '店家名稱 *';

  @override
  String get enterMerchantName => '請輸入店家名稱';

  @override
  String get address => '地址';

  @override
  String get receiptNumber => '發票號碼';

  @override
  String get sellerTaxIdInvalid => '賣方統編需為 8 位數字';

  @override
  String purchaseDate(String date) {
    return '消費日期 $date';
  }

  @override
  String get totalAmountRequired => '總金額 *';

  @override
  String get enterValidAmount => '請輸入正確金額';

  @override
  String get enterValidSubtotal => '請輸入正確小計';

  @override
  String get enterValidDiscount => '請輸入正確折扣';

  @override
  String get spendingCategory => '消費分類';

  @override
  String get purchaseItemRows => '消費品項';

  @override
  String get itemsMayBeIncomplete => '辨識出的品項可能不完整，請核對發票並補上其餘品項。';

  @override
  String get itemName => '品名';

  @override
  String get enterItemName => '請輸入品名';

  @override
  String get removeItem => '移除品項';

  @override
  String get quantity => '數量';

  @override
  String get quantityAtLeastOne => '數量至少為 1';

  @override
  String get unitPrice => '單價';

  @override
  String get enterValidUnitPrice => '請輸入正確單價';

  @override
  String get addItem => '新增品項';

  @override
  String get confirmAndSave => '確認並儲存';

  @override
  String get goBack => '返回上一頁';

  @override
  String get receiptAdded => '發票已加入';

  @override
  String get receiptAddedBody => '這筆資料會立即顯示於首頁、紀錄與消費地圖。';

  @override
  String get backHome => '回到首頁';

  @override
  String get dateOutOfRange => '辨識出的消費日期不在可選範圍內，請重新選擇日期';

  @override
  String get amountMismatch => '商品小計扣除折扣後必須等於實付金額';

  @override
  String get saveFailedKeepData => '儲存失敗，請重試；輸入資料仍保留在畫面上';
}
