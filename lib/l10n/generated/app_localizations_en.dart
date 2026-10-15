// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Receipt Trail';

  @override
  String get language => 'Language';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get english => 'English';

  @override
  String get languageSaveFailed =>
      'Couldn\'t save the language setting. Please try again.';

  @override
  String get welcomeTitle => 'Welcome to Receipt Trail';

  @override
  String get welcomeDescription =>
      'Sign in to sync and restore your data after reinstalling. Guest data stays only on this device and cannot be recovered after you delete the app.';

  @override
  String get loginOrRegister => 'Sign in or register';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get guestMigrationNote =>
      'When you sign in later, guest records on this device will move to your account automatically.';

  @override
  String get dataRepairTitle => 'Your data needs repair';

  @override
  String get dataRepairFallback =>
      'The data transfer is not complete. Your original data is still preserved.';

  @override
  String get dataMigrationFailed =>
      'Data migration failed. Your original data is still preserved, and it is safe to retry.';

  @override
  String get guestClaimFailed =>
      'Sign-in succeeded, but your guest data could not be moved to this account. Please retry.';

  @override
  String get dataRepairFailed =>
      'Data repair is not complete. Your original data has not been deleted.';

  @override
  String get retryDataRepair => 'Retry data repair';

  @override
  String get navOverview => 'Overview';

  @override
  String get navReceipts => 'Receipts';

  @override
  String get navScan => 'Scan';

  @override
  String get navMap => 'Map';

  @override
  String get navAccount => 'Account';

  @override
  String get accountTitle => 'My account';

  @override
  String get guestInitial => 'G';

  @override
  String get guestName => 'Guest';

  @override
  String get guestSyncPrompt => 'Sign in to sync across devices';

  @override
  String get securityTitle => 'Security';

  @override
  String get biometricLogin => 'Biometric quick sign-in';

  @override
  String get loginFirst => 'Sign in first';

  @override
  String get secureTokenSaved =>
      'Your token is stored in secure system storage';

  @override
  String get biometricComingSoon =>
      'Biometric system verification is coming in a future update';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordUnavailable =>
      'Password changes are not available yet';

  @override
  String get dataAndSyncTitle => 'Data and sync';

  @override
  String get syncStatus => 'Sync status';

  @override
  String get signInToSync => 'Sign in to enable cloud sync';

  @override
  String get syncingData => 'Syncing data…';

  @override
  String get dataSynced => 'Your data is synced with the cloud';

  @override
  String pendingSyncCount(int count) {
    return '$count records waiting to sync';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get localData => 'Local data';

  @override
  String localDataSummary(int receiptCount, int storeCount) {
    String _temp0 = intl.Intl.pluralLogic(
      receiptCount,
      locale: localeName,
      other: '$receiptCount receipts',
      one: '1 receipt',
    );
    String _temp1 = intl.Intl.pluralLogic(
      storeCount,
      locale: localeName,
      other: '$storeCount merchants',
      one: '1 merchant',
    );
    return '$_temp0 · $_temp1 · permanently saved';
  }

  @override
  String get localDataSaved => 'Your data is safely stored on this device';

  @override
  String get exportData => 'Export data';

  @override
  String get exportSubtitle =>
      'Export visible CSV and JSON snapshots from this device';

  @override
  String get resetAll => 'Reset all data';

  @override
  String get resetGuestSubtitle =>
      'Permanently delete guest records from this device';

  @override
  String get resetAccountSubtitle =>
      'Clear only this device or delete all cloud records';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get syncNotifications => 'Sync notifications';

  @override
  String get logout => 'Sign out';

  @override
  String get exportDialogTitle => 'Export purchase data';

  @override
  String get exportDialogBody =>
      'The ZIP contains unencrypted personal data currently visible on this device, including purchases, receipts, addresses, and coordinates. The app cannot import or restore it yet. Raw OCR text may contain more personal data, so excluding it is recommended.';

  @override
  String get cancel => 'Cancel';

  @override
  String get includeOcr => 'Include raw OCR text';

  @override
  String get exportWithoutOcr => 'Export without OCR';

  @override
  String get exportCompleted => 'The export was shared or saved';

  @override
  String get exportDismissed => 'Export cancelled; no saved file was confirmed';

  @override
  String get exportUnavailable =>
      'The system could not confirm the save. Check the location you selected.';

  @override
  String get exportFailed => 'Export failed. Please try again.';

  @override
  String get exportShareTitle => 'Export Receipt Trail data';

  @override
  String get exportShareSubject => 'Receipt Trail data export';

  @override
  String get resetCompleted => 'Your data was cleared as requested';

  @override
  String get resetFailed => 'Couldn\'t clear your data. Please try again.';

  @override
  String get cloudDeleteUnconfirmed =>
      'Cloud deletion is not confirmed. Local data is still preserved, and you can retry safely later.';

  @override
  String get noAuthenticatedAccount => 'No account is currently signed in';

  @override
  String get clearGuestTitle => 'Clear guest data?';

  @override
  String get clearGuestBody =>
      'Guest data exists only on this device and cannot be restored from the cloud after deletion.';

  @override
  String get continueAction => 'Continue';

  @override
  String get chooseResetScope => 'Choose what to clear';

  @override
  String get chooseResetScopeBody =>
      'Clearing only this device also signs you out. You can restore cloud data after signing in again.';

  @override
  String get clearThisDevice => 'Clear this device only';

  @override
  String get clearDeviceAndCloud => 'Delete device and cloud data';

  @override
  String get finalConfirmation => 'Final confirmation';

  @override
  String get cloudResetWarning =>
      'This permanently deletes every purchase record on this device and in the cloud. If the network fails, the deletion job is kept so you can retry.';

  @override
  String get deviceResetWarning =>
      'This cannot be undone. The app cannot restore an export yet, so make sure you saved it elsewhere first.';

  @override
  String get deletePhrasePrompt => 'Type “DELETE MY DATA”';

  @override
  String get deletePhrase => 'DELETE MY DATA';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get authSuccess => 'Signed in successfully. Welcome back.';

  @override
  String get logoutTitle => 'Sign out?';

  @override
  String get logoutBody =>
      'Local receipts remain on this device, but securely stored sign-in credentials will be removed.';

  @override
  String get tagline => 'Every receipt tells part of your story';

  @override
  String get createUser => 'Create a new user';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get registerDescription =>
      'Your account signs in immediately. Passwords are stored only as secure hashes.';

  @override
  String get loginDescription =>
      'Credentials are stored in Android Keystore or iOS Keychain.';

  @override
  String get nameLabel => 'Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordTooShort => 'Password must contain at least 8 characters';

  @override
  String get registerAndLogin => 'Register and sign in';

  @override
  String get hasAccount => 'Already have an account? Sign in';

  @override
  String get needsAccount => 'New here? Register now';

  @override
  String get authNetworkUnavailable =>
      'Couldn\'t reach the sign-in service. Check your connection and try again.';

  @override
  String get authServiceUnavailable =>
      'The cloud service may be waking up. Your local data is safe; please try again shortly.';

  @override
  String get authInvalidCredentials => 'The email or password is incorrect.';

  @override
  String get authEmailAlreadyRegistered => 'This email is already registered.';

  @override
  String get authSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get authMalformedResponse =>
      'The sign-in service returned an invalid response. Please try again later.';

  @override
  String get authUnknownFailure => 'Sign-in failed. Please try again later.';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String homeDate(int month, int day, String weekday) {
    return '$weekday, $month/$day';
  }

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get scanAndBookkeep => 'Recognize and record automatically';

  @override
  String get useCenterScanButton =>
      'Use the center Scan button below to recognize a receipt';

  @override
  String get viewMap => 'View map';

  @override
  String get reviewSpendingTrail => 'Review your recent spending trail';

  @override
  String get prizeReminder => 'Prize reminder';

  @override
  String get learnMore => 'Learn more';

  @override
  String get recentPurchases => 'Recent purchases';

  @override
  String get viewAll => 'View all';

  @override
  String get monthlySpending => 'Spending this month';

  @override
  String get localRecords => 'Local records';

  @override
  String get scannedReceipts => 'Scanned receipts';

  @override
  String receiptCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receipts',
      one: '1 receipt',
    );
    return '$_temp0';
  }

  @override
  String get spendingTrail => 'Spending trail';

  @override
  String placeCountUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get generalPrizeEnabled => 'General invoice prize checking is active';

  @override
  String get prizeStatusHint =>
      'Open a purchase record to see its prize and claim status.';

  @override
  String get available => 'Available';

  @override
  String get noPurchases =>
      'No purchases yet. Use the Scan button below to add one.';

  @override
  String get purchaseRecords => 'Purchase records';

  @override
  String get purchaseRecordsSubtitle =>
      'Every purchase is part of your daily trail';

  @override
  String get searchPurchases => 'Search merchants or purchases';

  @override
  String get allCategories => 'All';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryOther => 'Other';

  @override
  String get noMatchingPurchases => 'No matching purchase records';

  @override
  String monthGroup(int year, int month) {
    return '$month/$year';
  }

  @override
  String get synced => 'Synced';

  @override
  String get waitingToSync => 'Waiting to sync';

  @override
  String get receiptDetails => 'Receipt details';

  @override
  String get invoicePeriod => 'Invoice period';

  @override
  String invoicePeriodValue(int rocYear, int startMonth, int endMonth) {
    return 'ROC $rocYear, months $startMonth–$endMonth';
  }

  @override
  String get sellerTaxId => 'Seller tax ID';

  @override
  String get itemsSubtotal => 'Items subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get amountPaid => 'Amount paid';

  @override
  String get purchaseItems => 'Purchase items';

  @override
  String get rawOcrText => 'Raw OCR text';

  @override
  String get googleNavigation => 'Google navigation';

  @override
  String get deleteRecord => 'Delete this record';

  @override
  String get deleteRecordTitle => 'Delete purchase record?';

  @override
  String deleteRecordBody(String merchant) {
    return 'Deleting “$merchant” cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get noMapApp => 'No compatible map app was found';

  @override
  String get updatingPrizeNumbers => 'Updating prize numbers';

  @override
  String get offlinePrizeFallback =>
      'If you are offline, the last downloaded prize numbers will be used';

  @override
  String get prizeAwaitingDraw => 'This period has not been drawn yet';

  @override
  String get prizeAwaitingNumbers => 'Awaiting official prize numbers';

  @override
  String get prizeNotWinning => 'No general invoice prize';

  @override
  String prizeWinningBeforeClaim(String tier) {
    return 'Winner · $tier (claim period has not started)';
  }

  @override
  String prizeClaimable(String tier) {
    return 'Congratulations · $tier';
  }

  @override
  String get prizeExpired =>
      'Winning receipt, but the claim deadline has passed';

  @override
  String get verifyReceiptNumber => 'Verify the receipt number';

  @override
  String get prizeTierPending => 'Pending confirmation';

  @override
  String get prizeTierSpecial => 'Special Prize';

  @override
  String get prizeTierGrand => 'Grand Prize';

  @override
  String get prizeTierFirst => 'First Prize';

  @override
  String get prizeTierSecond => 'Second Prize';

  @override
  String get prizeTierThird => 'Third Prize';

  @override
  String get prizeTierFourth => 'Fourth Prize';

  @override
  String get prizeTierFifth => 'Fifth Prize';

  @override
  String get prizeTierSixth => 'Sixth Prize';

  @override
  String get prizeTierAdditionalSixth => 'Additional Sixth Prize';

  @override
  String get prizeOfflineCache =>
      'Network update failed; using the offline cache';

  @override
  String get prizeLocalCache => 'Using the local cache';

  @override
  String updatedOn(String date) {
    return 'Updated: $date';
  }

  @override
  String dataSource(String source) {
    return 'Source: $source';
  }

  @override
  String prizeAmount(String amount) {
    return 'Prize $amount';
  }

  @override
  String get prizeDisclaimer =>
      'This is not a live Ministry of Finance lookup. Final eligibility follows official records.';

  @override
  String get exclusivePrizeDisclaimer =>
      'General prize data excludes cloud-invoice-only prizes. Check the official source as well.';

  @override
  String drawDate(String date) {
    return 'Draw date: $date';
  }

  @override
  String get prizeSnapshotUnavailable =>
      'No official snapshot is available for this period yet. Follow the Ministry of Finance announcement.';

  @override
  String get openOfficialSource => 'Check the official source';

  @override
  String syncedUploadCount(int count) {
    return 'Synced $count local records';
  }

  @override
  String get syncAuthenticationRequired => 'Sign in before syncing';

  @override
  String get syncNetworkUnavailable =>
      'Couldn\'t reach the cloud. Check your connection and try again.';

  @override
  String get syncServiceUnavailable =>
      'The cloud service may be waking up. Your local data is safe; please try again shortly.';

  @override
  String get syncMissingLocalReceipt =>
      'A local purchase waiting to sync could not be found';

  @override
  String get syncInvalidResponse =>
      'The cloud returned an invalid response. Please try again later.';

  @override
  String get syncUnknownFailure => 'Cloud sync failed. Please try again later.';

  @override
  String get mapLoadFailed => 'The map failed to load. Check your connection.';

  @override
  String get mapEmpty =>
      'Your spending trail will appear here after you add a receipt';

  @override
  String get mapNoLocations =>
      'Current receipts have no locations\nAdd or scan a receipt with an address to show map pins';

  @override
  String get mySpendingTrail => 'My spending trail';

  @override
  String get visitCount => 'Visits';

  @override
  String visitCountValue(int count) {
    return '$count visits';
  }

  @override
  String get totalSpending => 'Total spending';

  @override
  String get averageSpending => 'Average spending';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get startNavigation => 'Start navigation';

  @override
  String get viewPurchaseRecords => 'View purchase records';

  @override
  String get cannotOpenGoogleMaps => 'Couldn\'t open Google Maps';

  @override
  String get scanFailureRecognition =>
      'OCR failed. Retake the photo or enter the receipt manually.';

  @override
  String get scanFailureNoText =>
      'No text was recognized. Retake the photo or enter the receipt manually.';

  @override
  String get scanFailureLocation => 'The merchant location could not be found';

  @override
  String get scanFailureUnknown =>
      'Recognition failed. Retake the photo or enter the receipt manually.';

  @override
  String get reviewData => 'Review data';

  @override
  String get saveComplete => 'Saved';

  @override
  String get scanStepOne => 'Step 1 of 3';

  @override
  String get scanYourReceipt => 'Scan your receipt';

  @override
  String get chooseReceiptType =>
      'Choose a receipt type so we can use the best recognition method.';

  @override
  String get electronicReceipt => 'Electronic receipt';

  @override
  String get scanLeftQr => 'Scan the left QR code';

  @override
  String get traditionalReceipt => 'Traditional receipt';

  @override
  String get photographFront => 'Photograph the front';

  @override
  String get traditionalCaptureHint =>
      'Fit the receipt number and date in the frame\nKeep it flat, well lit, and free of glare';

  @override
  String get electronicCaptureHint =>
      'Fit the electronic receipt QR code in the frame\nYou can review or complete the result afterward';

  @override
  String get captureTraditional => 'Photograph traditional receipt';

  @override
  String get scanElectronic => 'Scan electronic receipt';

  @override
  String get manualEntry => 'Enter manually';

  @override
  String get enterReceiptContent => 'Enter receipt details';

  @override
  String get receiptContentSubtitle =>
      'After saving, the dashboard, records, and spending map update immediately';

  @override
  String get possibleSavedMerchant => 'Possible saved merchant';

  @override
  String get merchantNameRequired => 'Merchant name *';

  @override
  String get enterMerchantName => 'Enter a merchant name';

  @override
  String get address => 'Address';

  @override
  String get receiptNumber => 'Receipt number';

  @override
  String get sellerTaxIdInvalid => 'The seller tax ID must contain 8 digits';

  @override
  String purchaseDate(String date) {
    return 'Purchase date $date';
  }

  @override
  String get totalAmountRequired => 'Total amount *';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get enterValidSubtotal => 'Enter a valid subtotal';

  @override
  String get enterValidDiscount => 'Enter a valid discount';

  @override
  String get spendingCategory => 'Category';

  @override
  String get purchaseItemRows => 'Purchase items';

  @override
  String get itemsMayBeIncomplete =>
      'Recognized items may be incomplete. Check the receipt and add any missing items.';

  @override
  String get itemName => 'Item name';

  @override
  String get enterItemName => 'Enter an item name';

  @override
  String get removeItem => 'Remove item';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityAtLeastOne => 'Quantity must be at least 1';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get enterValidUnitPrice => 'Enter a valid unit price';

  @override
  String get addItem => 'Add item';

  @override
  String get confirmAndSave => 'Review and save';

  @override
  String get goBack => 'Go back';

  @override
  String get receiptAdded => 'Receipt added';

  @override
  String get receiptAddedBody =>
      'This purchase now appears on the dashboard, records, and spending map.';

  @override
  String get backHome => 'Back to dashboard';

  @override
  String get dateOutOfRange =>
      'The recognized purchase date is outside the selectable range. Choose another date.';

  @override
  String get amountMismatch =>
      'Subtotal minus discount must equal the amount paid';

  @override
  String get saveFailedKeepData =>
      'Save failed. Try again; your entries are still on screen.';
}
