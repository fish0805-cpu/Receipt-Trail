import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Receipt Trail'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'語言'**
  String get language;

  /// No description provided for @traditionalChinese.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get traditionalChinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @languageSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法儲存語言設定，請再試一次'**
  String get languageSaveFailed;

  /// No description provided for @welcomeTitle.
  ///
  /// In zh, this message translates to:
  /// **'歡迎使用 Receipt Trail'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In zh, this message translates to:
  /// **'登入可同步並在重新安裝後恢復資料；訪客資料只保存在這台裝置，刪除 App 後無法恢復。'**
  String get welcomeDescription;

  /// No description provided for @loginOrRegister.
  ///
  /// In zh, this message translates to:
  /// **'登入或註冊'**
  String get loginOrRegister;

  /// No description provided for @continueAsGuest.
  ///
  /// In zh, this message translates to:
  /// **'以訪客身分使用'**
  String get continueAsGuest;

  /// No description provided for @guestMigrationNote.
  ///
  /// In zh, this message translates to:
  /// **'之後登入時，裝置上的訪客紀錄會自動移入該帳號。'**
  String get guestMigrationNote;

  /// No description provided for @dataRepairTitle.
  ///
  /// In zh, this message translates to:
  /// **'資料需要修復'**
  String get dataRepairTitle;

  /// No description provided for @dataRepairFallback.
  ///
  /// In zh, this message translates to:
  /// **'資料尚未完成搬移，原始資料仍保留。'**
  String get dataRepairFallback;

  /// No description provided for @dataMigrationFailed.
  ///
  /// In zh, this message translates to:
  /// **'資料遷移失敗，原始資料仍保留，可安全重試。'**
  String get dataMigrationFailed;

  /// No description provided for @guestClaimFailed.
  ///
  /// In zh, this message translates to:
  /// **'登入成功，但訪客資料認領失敗，請重試。'**
  String get guestClaimFailed;

  /// No description provided for @dataRepairFailed.
  ///
  /// In zh, this message translates to:
  /// **'資料修復仍未完成，原始資料沒有被刪除。'**
  String get dataRepairFailed;

  /// No description provided for @retryDataRepair.
  ///
  /// In zh, this message translates to:
  /// **'重試資料修復'**
  String get retryDataRepair;

  /// No description provided for @navOverview.
  ///
  /// In zh, this message translates to:
  /// **'總覽'**
  String get navOverview;

  /// No description provided for @navReceipts.
  ///
  /// In zh, this message translates to:
  /// **'發票'**
  String get navReceipts;

  /// No description provided for @navScan.
  ///
  /// In zh, this message translates to:
  /// **'掃描'**
  String get navScan;

  /// No description provided for @navMap.
  ///
  /// In zh, this message translates to:
  /// **'地圖'**
  String get navMap;

  /// No description provided for @navAccount.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get navAccount;

  /// No description provided for @accountTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的帳號'**
  String get accountTitle;

  /// No description provided for @guestInitial.
  ///
  /// In zh, this message translates to:
  /// **'訪'**
  String get guestInitial;

  /// No description provided for @guestName.
  ///
  /// In zh, this message translates to:
  /// **'訪客'**
  String get guestName;

  /// No description provided for @guestSyncPrompt.
  ///
  /// In zh, this message translates to:
  /// **'登入後可跨裝置同步'**
  String get guestSyncPrompt;

  /// No description provided for @securityTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全性'**
  String get securityTitle;

  /// No description provided for @biometricLogin.
  ///
  /// In zh, this message translates to:
  /// **'生物辨識快速登入'**
  String get biometricLogin;

  /// No description provided for @loginFirst.
  ///
  /// In zh, this message translates to:
  /// **'請先登入帳號'**
  String get loginFirst;

  /// No description provided for @secureTokenSaved.
  ///
  /// In zh, this message translates to:
  /// **'Token 已保存於系統安全儲存區'**
  String get secureTokenSaved;

  /// No description provided for @biometricComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'生物辨識將在下一階段接入系統驗證'**
  String get biometricComingSoon;

  /// No description provided for @changePassword.
  ///
  /// In zh, this message translates to:
  /// **'變更密碼'**
  String get changePassword;

  /// No description provided for @changePasswordUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'變更密碼端點尚未啟用'**
  String get changePasswordUnavailable;

  /// No description provided for @dataAndSyncTitle.
  ///
  /// In zh, this message translates to:
  /// **'資料與同步'**
  String get dataAndSyncTitle;

  /// No description provided for @syncStatus.
  ///
  /// In zh, this message translates to:
  /// **'同步狀態'**
  String get syncStatus;

  /// No description provided for @signInToSync.
  ///
  /// In zh, this message translates to:
  /// **'登入後即可啟用雲端同步'**
  String get signInToSync;

  /// No description provided for @syncingData.
  ///
  /// In zh, this message translates to:
  /// **'正在同步資料…'**
  String get syncingData;

  /// No description provided for @dataSynced.
  ///
  /// In zh, this message translates to:
  /// **'資料已與雲端同步'**
  String get dataSynced;

  /// No description provided for @pendingSyncCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 筆資料等待同步'**
  String pendingSyncCount(int count);

  /// No description provided for @syncNow.
  ///
  /// In zh, this message translates to:
  /// **'立即同步'**
  String get syncNow;

  /// No description provided for @localData.
  ///
  /// In zh, this message translates to:
  /// **'本機資料'**
  String get localData;

  /// No description provided for @localDataSummary.
  ///
  /// In zh, this message translates to:
  /// **'{receiptCount} 筆發票 · {storeCount} 個店家 · 已永久保存'**
  String localDataSummary(int receiptCount, int storeCount);

  /// No description provided for @localDataSaved.
  ///
  /// In zh, this message translates to:
  /// **'資料已安全保存在這台裝置'**
  String get localDataSaved;

  /// No description provided for @exportData.
  ///
  /// In zh, this message translates to:
  /// **'匯出資料'**
  String get exportData;

  /// No description provided for @exportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'匯出這台裝置目前可見的 CSV、JSON 快照'**
  String get exportSubtitle;

  /// No description provided for @resetAll.
  ///
  /// In zh, this message translates to:
  /// **'全部重置'**
  String get resetAll;

  /// No description provided for @resetGuestSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'永久刪除此裝置上的訪客紀錄'**
  String get resetGuestSubtitle;

  /// No description provided for @resetAccountSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'可選擇只清除此裝置，或刪除所有雲端紀錄'**
  String get resetAccountSubtitle;

  /// No description provided for @preferencesTitle.
  ///
  /// In zh, this message translates to:
  /// **'偏好設定'**
  String get preferencesTitle;

  /// No description provided for @syncNotifications.
  ///
  /// In zh, this message translates to:
  /// **'同步通知'**
  String get syncNotifications;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'登出'**
  String get logout;

  /// No description provided for @exportDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'匯出消費資料'**
  String get exportDialogTitle;

  /// No description provided for @exportDialogBody.
  ///
  /// In zh, this message translates to:
  /// **'ZIP 會包含這台裝置目前可見的消費、發票、地址與經緯度等個人資料，且未加密；目前 App 尚未提供匯入還原。OCR 原文可能含更多個資，建議不要一併匯出。'**
  String get exportDialogBody;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @includeOcr.
  ///
  /// In zh, this message translates to:
  /// **'包含 OCR 原文'**
  String get includeOcr;

  /// No description provided for @exportWithoutOcr.
  ///
  /// In zh, this message translates to:
  /// **'匯出（不含 OCR）'**
  String get exportWithoutOcr;

  /// No description provided for @exportCompleted.
  ///
  /// In zh, this message translates to:
  /// **'匯出檔已分享或儲存'**
  String get exportCompleted;

  /// No description provided for @exportDismissed.
  ///
  /// In zh, this message translates to:
  /// **'已取消匯出，沒有確認檔案已保存'**
  String get exportDismissed;

  /// No description provided for @exportUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'系統無法確認是否已保存，請檢查你選擇的位置'**
  String get exportUnavailable;

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'匯出失敗，請再試一次'**
  String get exportFailed;

  /// No description provided for @exportShareTitle.
  ///
  /// In zh, this message translates to:
  /// **'匯出 Receipt Trail 資料'**
  String get exportShareTitle;

  /// No description provided for @exportShareSubject.
  ///
  /// In zh, this message translates to:
  /// **'Receipt Trail 資料匯出檔'**
  String get exportShareSubject;

  /// No description provided for @resetCompleted.
  ///
  /// In zh, this message translates to:
  /// **'資料已依照你的選擇清除'**
  String get resetCompleted;

  /// No description provided for @resetFailed.
  ///
  /// In zh, this message translates to:
  /// **'無法清除資料，請再試一次'**
  String get resetFailed;

  /// No description provided for @cloudDeleteUnconfirmed.
  ///
  /// In zh, this message translates to:
  /// **'雲端刪除尚未確認，本機資料仍保留，可稍後安全重試。'**
  String get cloudDeleteUnconfirmed;

  /// No description provided for @noAuthenticatedAccount.
  ///
  /// In zh, this message translates to:
  /// **'目前沒有登入帳號'**
  String get noAuthenticatedAccount;

  /// No description provided for @clearGuestTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除訪客資料？'**
  String get clearGuestTitle;

  /// No description provided for @clearGuestBody.
  ///
  /// In zh, this message translates to:
  /// **'訪客資料只存在這台裝置，刪除後無法從雲端復原。'**
  String get clearGuestBody;

  /// No description provided for @continueAction.
  ///
  /// In zh, this message translates to:
  /// **'繼續'**
  String get continueAction;

  /// No description provided for @chooseResetScope.
  ///
  /// In zh, this message translates to:
  /// **'選擇清除範圍'**
  String get chooseResetScope;

  /// No description provided for @chooseResetScopeBody.
  ///
  /// In zh, this message translates to:
  /// **'只清除此裝置會同時登出，重新登入後仍可從雲端取回資料。'**
  String get chooseResetScopeBody;

  /// No description provided for @clearThisDevice.
  ///
  /// In zh, this message translates to:
  /// **'只清除此裝置'**
  String get clearThisDevice;

  /// No description provided for @clearDeviceAndCloud.
  ///
  /// In zh, this message translates to:
  /// **'裝置與雲端全部刪除'**
  String get clearDeviceAndCloud;

  /// No description provided for @finalConfirmation.
  ///
  /// In zh, this message translates to:
  /// **'最後確認'**
  String get finalConfirmation;

  /// No description provided for @cloudResetWarning.
  ///
  /// In zh, this message translates to:
  /// **'這會永久刪除本機及雲端的全部消費紀錄。網路失敗時會保留刪除工作供你重試。'**
  String get cloudResetWarning;

  /// No description provided for @deviceResetWarning.
  ///
  /// In zh, this message translates to:
  /// **'這項操作無法復原。匯出檔目前不能由 App 匯入還原，請先確認已另行保存。'**
  String get deviceResetWarning;

  /// No description provided for @deletePhrasePrompt.
  ///
  /// In zh, this message translates to:
  /// **'請輸入「刪除我的資料」'**
  String get deletePhrasePrompt;

  /// No description provided for @deletePhrase.
  ///
  /// In zh, this message translates to:
  /// **'刪除我的資料'**
  String get deletePhrase;

  /// No description provided for @deletePermanently.
  ///
  /// In zh, this message translates to:
  /// **'永久刪除'**
  String get deletePermanently;

  /// No description provided for @authSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登入成功，歡迎回來'**
  String get authSuccess;

  /// No description provided for @logoutTitle.
  ///
  /// In zh, this message translates to:
  /// **'確定要登出？'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In zh, this message translates to:
  /// **'本機發票仍會保留，安全儲存的登入憑證將被清除。'**
  String get logoutBody;

  /// No description provided for @tagline.
  ///
  /// In zh, this message translates to:
  /// **'每張發票，都是一段生活足跡'**
  String get tagline;

  /// No description provided for @createUser.
  ///
  /// In zh, this message translates to:
  /// **'建立新使用者'**
  String get createUser;

  /// No description provided for @welcomeBack.
  ///
  /// In zh, this message translates to:
  /// **'歡迎回來'**
  String get welcomeBack;

  /// No description provided for @registerDescription.
  ///
  /// In zh, this message translates to:
  /// **'建立帳號後會立即登入，密碼只會以安全雜湊保存。'**
  String get registerDescription;

  /// No description provided for @loginDescription.
  ///
  /// In zh, this message translates to:
  /// **'登入憑證會保存於 Android Keystore 或 iOS Keychain。'**
  String get loginDescription;

  /// No description provided for @nameLabel.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get nameLabel;

  /// No description provided for @enterName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入姓名'**
  String get enterName;

  /// No description provided for @emailInvalid.
  ///
  /// In zh, this message translates to:
  /// **'請輸入正確的 Email'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In zh, this message translates to:
  /// **'密碼'**
  String get passwordLabel;

  /// No description provided for @passwordTooShort.
  ///
  /// In zh, this message translates to:
  /// **'密碼至少需要 8 個字元'**
  String get passwordTooShort;

  /// No description provided for @registerAndLogin.
  ///
  /// In zh, this message translates to:
  /// **'註冊並登入'**
  String get registerAndLogin;

  /// No description provided for @hasAccount.
  ///
  /// In zh, this message translates to:
  /// **'已有帳號？返回登入'**
  String get hasAccount;

  /// No description provided for @needsAccount.
  ///
  /// In zh, this message translates to:
  /// **'還沒有帳號？立即註冊'**
  String get needsAccount;

  /// No description provided for @authNetworkUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'目前無法連接登入服務，請檢查網路後再試一次。'**
  String get authNetworkUnavailable;

  /// No description provided for @authServiceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'雲端服務可能正在喚醒，本機資料已安全保留，請稍後重試。'**
  String get authServiceUnavailable;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In zh, this message translates to:
  /// **'Email 或密碼不正確。'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In zh, this message translates to:
  /// **'這個 Email 已經註冊。'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authSessionExpired.
  ///
  /// In zh, this message translates to:
  /// **'登入狀態已失效，請重新登入。'**
  String get authSessionExpired;

  /// No description provided for @authMalformedResponse.
  ///
  /// In zh, this message translates to:
  /// **'登入服務回傳格式錯誤，請稍後重試。'**
  String get authMalformedResponse;

  /// No description provided for @authUnknownFailure.
  ///
  /// In zh, this message translates to:
  /// **'登入失敗，請稍後重試。'**
  String get authUnknownFailure;

  /// No description provided for @homeGreeting.
  ///
  /// In zh, this message translates to:
  /// **'你好，{name}'**
  String homeGreeting(String name);

  /// No description provided for @homeDate.
  ///
  /// In zh, this message translates to:
  /// **'{month}月{day}日 星期{weekday}'**
  String homeDate(int month, int day, String weekday);

  /// No description provided for @weekdayMonday.
  ///
  /// In zh, this message translates to:
  /// **'一'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In zh, this message translates to:
  /// **'二'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In zh, this message translates to:
  /// **'三'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In zh, this message translates to:
  /// **'四'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In zh, this message translates to:
  /// **'五'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In zh, this message translates to:
  /// **'六'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get weekdaySunday;

  /// No description provided for @scanReceipt.
  ///
  /// In zh, this message translates to:
  /// **'掃描發票'**
  String get scanReceipt;

  /// No description provided for @scanAndBookkeep.
  ///
  /// In zh, this message translates to:
  /// **'辨識並自動記帳'**
  String get scanAndBookkeep;

  /// No description provided for @useCenterScanButton.
  ///
  /// In zh, this message translates to:
  /// **'請按下方中央的掃描按鈕開始辨識發票'**
  String get useCenterScanButton;

  /// No description provided for @viewMap.
  ///
  /// In zh, this message translates to:
  /// **'查看地圖'**
  String get viewMap;

  /// No description provided for @reviewSpendingTrail.
  ///
  /// In zh, this message translates to:
  /// **'回顧最近消費足跡'**
  String get reviewSpendingTrail;

  /// No description provided for @prizeReminder.
  ///
  /// In zh, this message translates to:
  /// **'兌獎提醒'**
  String get prizeReminder;

  /// No description provided for @learnMore.
  ///
  /// In zh, this message translates to:
  /// **'了解更多'**
  String get learnMore;

  /// No description provided for @recentPurchases.
  ///
  /// In zh, this message translates to:
  /// **'最近消費'**
  String get recentPurchases;

  /// No description provided for @viewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get viewAll;

  /// No description provided for @monthlySpending.
  ///
  /// In zh, this message translates to:
  /// **'本月累積消費'**
  String get monthlySpending;

  /// No description provided for @localRecords.
  ///
  /// In zh, this message translates to:
  /// **'本機紀錄'**
  String get localRecords;

  /// No description provided for @scannedReceipts.
  ///
  /// In zh, this message translates to:
  /// **'已掃描發票'**
  String get scannedReceipts;

  /// No description provided for @receiptCountUnit.
  ///
  /// In zh, this message translates to:
  /// **'{count} 張'**
  String receiptCountUnit(int count);

  /// No description provided for @spendingTrail.
  ///
  /// In zh, this message translates to:
  /// **'消費足跡'**
  String get spendingTrail;

  /// No description provided for @placeCountUnit.
  ///
  /// In zh, this message translates to:
  /// **'{count} 個地點'**
  String placeCountUnit(int count);

  /// No description provided for @generalPrizeEnabled.
  ///
  /// In zh, this message translates to:
  /// **'一般發票對獎已啟用'**
  String get generalPrizeEnabled;

  /// No description provided for @prizeStatusHint.
  ///
  /// In zh, this message translates to:
  /// **'點開消費紀錄，可查看獎別與領獎狀態。'**
  String get prizeStatusHint;

  /// No description provided for @available.
  ///
  /// In zh, this message translates to:
  /// **'可查詢'**
  String get available;

  /// No description provided for @noPurchases.
  ///
  /// In zh, this message translates to:
  /// **'尚無消費紀錄，按下方掃描按鈕新增'**
  String get noPurchases;

  /// No description provided for @purchaseRecords.
  ///
  /// In zh, this message translates to:
  /// **'消費紀錄'**
  String get purchaseRecords;

  /// No description provided for @purchaseRecordsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'每一筆消費，都是生活的足跡'**
  String get purchaseRecordsSubtitle;

  /// No description provided for @searchPurchases.
  ///
  /// In zh, this message translates to:
  /// **'搜尋店家或消費'**
  String get searchPurchases;

  /// No description provided for @allCategories.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get allCategories;

  /// No description provided for @categoryFood.
  ///
  /// In zh, this message translates to:
  /// **'餐飲'**
  String get categoryFood;

  /// No description provided for @categoryShopping.
  ///
  /// In zh, this message translates to:
  /// **'購物'**
  String get categoryShopping;

  /// No description provided for @categoryTransport.
  ///
  /// In zh, this message translates to:
  /// **'交通'**
  String get categoryTransport;

  /// No description provided for @categoryOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get categoryOther;

  /// No description provided for @noMatchingPurchases.
  ///
  /// In zh, this message translates to:
  /// **'找不到符合的消費紀錄'**
  String get noMatchingPurchases;

  /// No description provided for @monthGroup.
  ///
  /// In zh, this message translates to:
  /// **'{year} 年 {month} 月'**
  String monthGroup(int year, int month);

  /// No description provided for @synced.
  ///
  /// In zh, this message translates to:
  /// **'已同步'**
  String get synced;

  /// No description provided for @waitingToSync.
  ///
  /// In zh, this message translates to:
  /// **'等待同步'**
  String get waitingToSync;

  /// No description provided for @receiptDetails.
  ///
  /// In zh, this message translates to:
  /// **'發票詳細紀錄'**
  String get receiptDetails;

  /// No description provided for @invoicePeriod.
  ///
  /// In zh, this message translates to:
  /// **'發票期別'**
  String get invoicePeriod;

  /// No description provided for @invoicePeriodValue.
  ///
  /// In zh, this message translates to:
  /// **'{rocYear} 年 {startMonth}–{endMonth} 月'**
  String invoicePeriodValue(int rocYear, int startMonth, int endMonth);

  /// No description provided for @sellerTaxId.
  ///
  /// In zh, this message translates to:
  /// **'賣方統編'**
  String get sellerTaxId;

  /// No description provided for @itemsSubtotal.
  ///
  /// In zh, this message translates to:
  /// **'商品小計'**
  String get itemsSubtotal;

  /// No description provided for @discount.
  ///
  /// In zh, this message translates to:
  /// **'折扣'**
  String get discount;

  /// No description provided for @amountPaid.
  ///
  /// In zh, this message translates to:
  /// **'實付金額'**
  String get amountPaid;

  /// No description provided for @purchaseItems.
  ///
  /// In zh, this message translates to:
  /// **'消費明細'**
  String get purchaseItems;

  /// No description provided for @rawOcrText.
  ///
  /// In zh, this message translates to:
  /// **'OCR 辨識原文'**
  String get rawOcrText;

  /// No description provided for @googleNavigation.
  ///
  /// In zh, this message translates to:
  /// **'Google 導航'**
  String get googleNavigation;

  /// No description provided for @deleteRecord.
  ///
  /// In zh, this message translates to:
  /// **'刪除這筆紀錄'**
  String get deleteRecord;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In zh, this message translates to:
  /// **'刪除消費紀錄？'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordBody.
  ///
  /// In zh, this message translates to:
  /// **'「{merchant}」刪除後無法復原。'**
  String deleteRecordBody(String merchant);

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get delete;

  /// No description provided for @noMapApp.
  ///
  /// In zh, this message translates to:
  /// **'找不到可開啟的地圖 App'**
  String get noMapApp;

  /// No description provided for @updatingPrizeNumbers.
  ///
  /// In zh, this message translates to:
  /// **'正在更新對獎資料'**
  String get updatingPrizeNumbers;

  /// No description provided for @offlinePrizeFallback.
  ///
  /// In zh, this message translates to:
  /// **'若目前離線，將使用上次成功下載的獎號'**
  String get offlinePrizeFallback;

  /// No description provided for @prizeAwaitingDraw.
  ///
  /// In zh, this message translates to:
  /// **'本期尚未開獎'**
  String get prizeAwaitingDraw;

  /// No description provided for @prizeAwaitingNumbers.
  ///
  /// In zh, this message translates to:
  /// **'尚未取得對獎資料'**
  String get prizeAwaitingNumbers;

  /// No description provided for @prizeNotWinning.
  ///
  /// In zh, this message translates to:
  /// **'一般獎未中獎'**
  String get prizeNotWinning;

  /// No description provided for @prizeWinningBeforeClaim.
  ///
  /// In zh, this message translates to:
  /// **'中獎 · {tier}（尚未開始領獎）'**
  String prizeWinningBeforeClaim(String tier);

  /// No description provided for @prizeClaimable.
  ///
  /// In zh, this message translates to:
  /// **'恭喜中獎 · {tier}'**
  String prizeClaimable(String tier);

  /// No description provided for @prizeExpired.
  ///
  /// In zh, this message translates to:
  /// **'中獎但已逾領獎期限'**
  String get prizeExpired;

  /// No description provided for @verifyReceiptNumber.
  ///
  /// In zh, this message translates to:
  /// **'請確認發票號碼'**
  String get verifyReceiptNumber;

  /// No description provided for @prizeTierPending.
  ///
  /// In zh, this message translates to:
  /// **'待確認'**
  String get prizeTierPending;

  /// No description provided for @prizeTierSpecial.
  ///
  /// In zh, this message translates to:
  /// **'特別獎'**
  String get prizeTierSpecial;

  /// No description provided for @prizeTierGrand.
  ///
  /// In zh, this message translates to:
  /// **'特獎'**
  String get prizeTierGrand;

  /// No description provided for @prizeTierFirst.
  ///
  /// In zh, this message translates to:
  /// **'頭獎'**
  String get prizeTierFirst;

  /// No description provided for @prizeTierSecond.
  ///
  /// In zh, this message translates to:
  /// **'二獎'**
  String get prizeTierSecond;

  /// No description provided for @prizeTierThird.
  ///
  /// In zh, this message translates to:
  /// **'三獎'**
  String get prizeTierThird;

  /// No description provided for @prizeTierFourth.
  ///
  /// In zh, this message translates to:
  /// **'四獎'**
  String get prizeTierFourth;

  /// No description provided for @prizeTierFifth.
  ///
  /// In zh, this message translates to:
  /// **'五獎'**
  String get prizeTierFifth;

  /// No description provided for @prizeTierSixth.
  ///
  /// In zh, this message translates to:
  /// **'六獎'**
  String get prizeTierSixth;

  /// No description provided for @prizeTierAdditionalSixth.
  ///
  /// In zh, this message translates to:
  /// **'增開六獎'**
  String get prizeTierAdditionalSixth;

  /// No description provided for @prizeOfflineCache.
  ///
  /// In zh, this message translates to:
  /// **'網路更新失敗，目前使用離線快取'**
  String get prizeOfflineCache;

  /// No description provided for @prizeLocalCache.
  ///
  /// In zh, this message translates to:
  /// **'目前使用本機快取'**
  String get prizeLocalCache;

  /// No description provided for @updatedOn.
  ///
  /// In zh, this message translates to:
  /// **'更新：{date}'**
  String updatedOn(String date);

  /// No description provided for @dataSource.
  ///
  /// In zh, this message translates to:
  /// **'資料來源：{source}'**
  String dataSource(String source);

  /// No description provided for @prizeAmount.
  ///
  /// In zh, this message translates to:
  /// **'獎金 {amount}'**
  String prizeAmount(String amount);

  /// No description provided for @prizeDisclaimer.
  ///
  /// In zh, this message translates to:
  /// **'非財政部即時查詢，實際資格以財政部為準'**
  String get prizeDisclaimer;

  /// No description provided for @exclusivePrizeDisclaimer.
  ///
  /// In zh, this message translates to:
  /// **'一般獎資料不含雲端發票專屬獎，仍請至官方確認'**
  String get exclusivePrizeDisclaimer;

  /// No description provided for @drawDate.
  ///
  /// In zh, this message translates to:
  /// **'開獎日 {date}'**
  String drawDate(String date);

  /// No description provided for @prizeSnapshotUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'後端尚無此期官方公告快照，請以財政部公告為準'**
  String get prizeSnapshotUnavailable;

  /// No description provided for @openOfficialSource.
  ///
  /// In zh, this message translates to:
  /// **'前往官方來源確認'**
  String get openOfficialSource;

  /// No description provided for @syncedUploadCount.
  ///
  /// In zh, this message translates to:
  /// **'已同步 {count} 筆本機資料'**
  String syncedUploadCount(int count);

  /// No description provided for @syncAuthenticationRequired.
  ///
  /// In zh, this message translates to:
  /// **'請先登入後再同步'**
  String get syncAuthenticationRequired;

  /// No description provided for @syncNetworkUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'目前無法連接雲端，請檢查網路後重試。'**
  String get syncNetworkUnavailable;

  /// No description provided for @syncServiceUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'雲端服務可能正在喚醒，本機資料已安全保留，請稍後重試。'**
  String get syncServiceUnavailable;

  /// No description provided for @syncMissingLocalReceipt.
  ///
  /// In zh, this message translates to:
  /// **'找不到等待同步的本機消費資料'**
  String get syncMissingLocalReceipt;

  /// No description provided for @syncInvalidResponse.
  ///
  /// In zh, this message translates to:
  /// **'雲端回傳格式錯誤，請稍後重試。'**
  String get syncInvalidResponse;

  /// No description provided for @syncUnknownFailure.
  ///
  /// In zh, this message translates to:
  /// **'雲端同步失敗，請稍後重試。'**
  String get syncUnknownFailure;

  /// No description provided for @mapLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'底圖載入失敗，請確認網路連線'**
  String get mapLoadFailed;

  /// No description provided for @mapEmpty.
  ///
  /// In zh, this message translates to:
  /// **'新增發票後，消費足跡會顯示在這裡'**
  String get mapEmpty;

  /// No description provided for @mapNoLocations.
  ///
  /// In zh, this message translates to:
  /// **'目前的發票沒有可定位地址\n新增或掃描含地址的發票後會顯示圖釘'**
  String get mapNoLocations;

  /// No description provided for @mySpendingTrail.
  ///
  /// In zh, this message translates to:
  /// **'我的消費足跡'**
  String get mySpendingTrail;

  /// No description provided for @visitCount.
  ///
  /// In zh, this message translates to:
  /// **'消費次數'**
  String get visitCount;

  /// No description provided for @visitCountValue.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次'**
  String visitCountValue(int count);

  /// No description provided for @totalSpending.
  ///
  /// In zh, this message translates to:
  /// **'總消費'**
  String get totalSpending;

  /// No description provided for @averageSpending.
  ///
  /// In zh, this message translates to:
  /// **'平均消費'**
  String get averageSpending;

  /// No description provided for @googleMaps.
  ///
  /// In zh, this message translates to:
  /// **'Google 地圖'**
  String get googleMaps;

  /// No description provided for @startNavigation.
  ///
  /// In zh, this message translates to:
  /// **'開始導航'**
  String get startNavigation;

  /// No description provided for @viewPurchaseRecords.
  ///
  /// In zh, this message translates to:
  /// **'查看消費紀錄'**
  String get viewPurchaseRecords;

  /// No description provided for @cannotOpenGoogleMaps.
  ///
  /// In zh, this message translates to:
  /// **'無法開啟 Google Maps'**
  String get cannotOpenGoogleMaps;

  /// No description provided for @scanFailureRecognition.
  ///
  /// In zh, this message translates to:
  /// **'OCR 辨識失敗，請重新拍攝或手動輸入'**
  String get scanFailureRecognition;

  /// No description provided for @scanFailureNoText.
  ///
  /// In zh, this message translates to:
  /// **'無法辨識圖片中的文字，請重新拍攝或手動輸入'**
  String get scanFailureNoText;

  /// No description provided for @scanFailureLocation.
  ///
  /// In zh, this message translates to:
  /// **'無法取得店家位置'**
  String get scanFailureLocation;

  /// No description provided for @scanFailureUnknown.
  ///
  /// In zh, this message translates to:
  /// **'辨識失敗，請重新拍攝或手動輸入'**
  String get scanFailureUnknown;

  /// No description provided for @reviewData.
  ///
  /// In zh, this message translates to:
  /// **'確認資料'**
  String get reviewData;

  /// No description provided for @saveComplete.
  ///
  /// In zh, this message translates to:
  /// **'儲存完成'**
  String get saveComplete;

  /// No description provided for @scanStepOne.
  ///
  /// In zh, this message translates to:
  /// **'步驟 1 / 3'**
  String get scanStepOne;

  /// No description provided for @scanYourReceipt.
  ///
  /// In zh, this message translates to:
  /// **'掃描你的發票'**
  String get scanYourReceipt;

  /// No description provided for @chooseReceiptType.
  ///
  /// In zh, this message translates to:
  /// **'先選擇發票類型，我們會使用最合適的辨識方式。'**
  String get chooseReceiptType;

  /// No description provided for @electronicReceipt.
  ///
  /// In zh, this message translates to:
  /// **'電子發票'**
  String get electronicReceipt;

  /// No description provided for @scanLeftQr.
  ///
  /// In zh, this message translates to:
  /// **'掃描左側 QR Code'**
  String get scanLeftQr;

  /// No description provided for @traditionalReceipt.
  ///
  /// In zh, this message translates to:
  /// **'傳統發票'**
  String get traditionalReceipt;

  /// No description provided for @photographFront.
  ///
  /// In zh, this message translates to:
  /// **'拍攝發票正面'**
  String get photographFront;

  /// No description provided for @traditionalCaptureHint.
  ///
  /// In zh, this message translates to:
  /// **'將發票號碼與日期完整放入畫面\n保持平整、光線充足並避免反光'**
  String get traditionalCaptureHint;

  /// No description provided for @electronicCaptureHint.
  ///
  /// In zh, this message translates to:
  /// **'將電子發票 QR Code 完整放入框內\n辨識後可確認或補填內容'**
  String get electronicCaptureHint;

  /// No description provided for @captureTraditional.
  ///
  /// In zh, this message translates to:
  /// **'拍攝傳統發票'**
  String get captureTraditional;

  /// No description provided for @scanElectronic.
  ///
  /// In zh, this message translates to:
  /// **'掃描電子發票'**
  String get scanElectronic;

  /// No description provided for @manualEntry.
  ///
  /// In zh, this message translates to:
  /// **'改用手動輸入'**
  String get manualEntry;

  /// No description provided for @enterReceiptContent.
  ///
  /// In zh, this message translates to:
  /// **'輸入發票內容'**
  String get enterReceiptContent;

  /// No description provided for @receiptContentSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'儲存後，首頁、紀錄與消費地圖會立即同步'**
  String get receiptContentSubtitle;

  /// No description provided for @possibleSavedMerchant.
  ///
  /// In zh, this message translates to:
  /// **'可能是已儲存的店家'**
  String get possibleSavedMerchant;

  /// No description provided for @merchantNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'店家名稱 *'**
  String get merchantNameRequired;

  /// No description provided for @enterMerchantName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入店家名稱'**
  String get enterMerchantName;

  /// No description provided for @address.
  ///
  /// In zh, this message translates to:
  /// **'地址'**
  String get address;

  /// No description provided for @receiptNumber.
  ///
  /// In zh, this message translates to:
  /// **'發票號碼'**
  String get receiptNumber;

  /// No description provided for @sellerTaxIdInvalid.
  ///
  /// In zh, this message translates to:
  /// **'賣方統編需為 8 位數字'**
  String get sellerTaxIdInvalid;

  /// No description provided for @purchaseDate.
  ///
  /// In zh, this message translates to:
  /// **'消費日期 {date}'**
  String purchaseDate(String date);

  /// No description provided for @totalAmountRequired.
  ///
  /// In zh, this message translates to:
  /// **'總金額 *'**
  String get totalAmountRequired;

  /// No description provided for @enterValidAmount.
  ///
  /// In zh, this message translates to:
  /// **'請輸入正確金額'**
  String get enterValidAmount;

  /// No description provided for @enterValidSubtotal.
  ///
  /// In zh, this message translates to:
  /// **'請輸入正確小計'**
  String get enterValidSubtotal;

  /// No description provided for @enterValidDiscount.
  ///
  /// In zh, this message translates to:
  /// **'請輸入正確折扣'**
  String get enterValidDiscount;

  /// No description provided for @spendingCategory.
  ///
  /// In zh, this message translates to:
  /// **'消費分類'**
  String get spendingCategory;

  /// No description provided for @purchaseItemRows.
  ///
  /// In zh, this message translates to:
  /// **'消費品項'**
  String get purchaseItemRows;

  /// No description provided for @itemsMayBeIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'辨識出的品項可能不完整，請核對發票並補上其餘品項。'**
  String get itemsMayBeIncomplete;

  /// No description provided for @itemName.
  ///
  /// In zh, this message translates to:
  /// **'品名'**
  String get itemName;

  /// No description provided for @enterItemName.
  ///
  /// In zh, this message translates to:
  /// **'請輸入品名'**
  String get enterItemName;

  /// No description provided for @removeItem.
  ///
  /// In zh, this message translates to:
  /// **'移除品項'**
  String get removeItem;

  /// No description provided for @quantity.
  ///
  /// In zh, this message translates to:
  /// **'數量'**
  String get quantity;

  /// No description provided for @quantityAtLeastOne.
  ///
  /// In zh, this message translates to:
  /// **'數量至少為 1'**
  String get quantityAtLeastOne;

  /// No description provided for @unitPrice.
  ///
  /// In zh, this message translates to:
  /// **'單價'**
  String get unitPrice;

  /// No description provided for @enterValidUnitPrice.
  ///
  /// In zh, this message translates to:
  /// **'請輸入正確單價'**
  String get enterValidUnitPrice;

  /// No description provided for @addItem.
  ///
  /// In zh, this message translates to:
  /// **'新增品項'**
  String get addItem;

  /// No description provided for @confirmAndSave.
  ///
  /// In zh, this message translates to:
  /// **'確認並儲存'**
  String get confirmAndSave;

  /// No description provided for @goBack.
  ///
  /// In zh, this message translates to:
  /// **'返回上一頁'**
  String get goBack;

  /// No description provided for @receiptAdded.
  ///
  /// In zh, this message translates to:
  /// **'發票已加入'**
  String get receiptAdded;

  /// No description provided for @receiptAddedBody.
  ///
  /// In zh, this message translates to:
  /// **'這筆資料會立即顯示於首頁、紀錄與消費地圖。'**
  String get receiptAddedBody;

  /// No description provided for @backHome.
  ///
  /// In zh, this message translates to:
  /// **'回到首頁'**
  String get backHome;

  /// No description provided for @dateOutOfRange.
  ///
  /// In zh, this message translates to:
  /// **'辨識出的消費日期不在可選範圍內，請重新選擇日期'**
  String get dateOutOfRange;

  /// No description provided for @amountMismatch.
  ///
  /// In zh, this message translates to:
  /// **'商品小計扣除折扣後必須等於實付金額'**
  String get amountMismatch;

  /// No description provided for @saveFailedKeepData.
  ///
  /// In zh, this message translates to:
  /// **'儲存失敗，請重試；輸入資料仍保留在畫面上'**
  String get saveFailedKeepData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
