# Receipt Trail 發票足跡

Receipt Trail 是以 Flutter 開發的台灣發票與消費紀錄 App，將發票掃描、記帳、消費地圖及一般統一發票對獎整理在同一個介面中。

Android 與 iOS 共用同一套 Dart 程式碼。目前已在 Windows 與 Android 模擬器完成主要流程測試；iOS 專案檔已保留，但最終建置與實機測試仍需使用 macOS 與 Xcode。

## 目前功能

- 支援繁體中文與英文，預設為繁體中文。
- 可選擇訪客模式、註冊或登入帳號。
- 訪客資料保存在本機；之後登入時可將訪客紀錄移入該帳號。
- 使用 Drift／SQLite 保存發票、消費金額、店家、地址、品項及同步狀態。
- 支援電子發票 QR Code 掃描、傳統發票 OCR 及手動輸入。
- 掃描完成後可修改店家、日期、金額、分類及商品明細，再確認儲存。
- 提供消費紀錄、月份分類、金額統計及發票詳細資料。
- 在地圖顯示有位置資訊的消費店家，並可開啟 Google Maps 搜尋或導航。
- 可使用已匯入的獎號資料比對一般統一發票獎項及領獎狀態。
- 支援本機資料匯出、清除及登入帳號的同步流程。
- 使用 FastAPI 提供開發環境所需的登入、發票、同步及獎號 API。

> 對獎功能目前不是財政部即時查詢服務，且不包含雲端發票專屬獎。實際中獎資格、獎別與領獎方式仍以財政部公告為準。

## 資料保存方式

- 訪客資料只存在目前裝置，刪除 App 後將無法恢復。
- 登入帳號後，資料會在後端服務可用時進行同步；只有已成功同步的紀錄，才能在重新安裝 App 後透過同一帳號恢復。
- 發票圖片不會保存或上傳。
- OCR 原文預設不會上傳到後端，也不會包含在一般資料匯出中。

## 專案架構

| 區域 | 路徑 | 用途 |
| --- | --- | --- |
| App | `lib/src/app/` | 建立依賴、主題、語言與主要導覽 |
| 共用元件 | `lib/src/core/` | 格式化、主題、共用 Widget 與語言控制 |
| 登入功能 | `lib/src/features/auth/` | 註冊、登入、Token 更新與安全儲存 |
| 使用者狀態 | `lib/src/features/session/` | 歡迎頁、訪客模式、帳號模式與訪客資料認領 |
| 消費資料 | `lib/src/features/purchases/` | 發票模型、消費統計、Repository 與 Drift 資料庫 |
| 掃描功能 | `lib/src/features/scanning/` | QR Code、OCR、欄位辨識與資料確認流程 |
| 地圖功能 | `lib/src/features/map/` | 消費足跡、店家標記與外部地圖導航 |
| 對獎功能 | `lib/src/features/prizes/` | 一般發票獎號比對、領獎狀態與本機快取 |
| 同步功能 | `lib/src/features/sync/` | 本機待同步工作與後端 HTTP Gateway |
| 多語系 | `lib/l10n/` | 繁體中文、英文 ARB 與產生的語系程式碼 |
| Flutter 測試 | `test/` | 單元測試、資料庫測試及 Widget 測試 |
| 後端 API | `backend/receipt_trail_api/` | FastAPI、驗證、資料庫與 Repository |
| 後端測試 | `backend/test_*.py` | API、驗證、資料庫及遷移測試 |
| Android | `android/` | Android Runner、權限、簽章及 App 圖示設定 |
| iOS | `ios/` | iOS Runner、權限文字、App 圖示及 Xcode 專案 |
| 靜態資產 | `assets/` | App 圖示與地圖樣式 |

### 主要資料表

| 資料表 | 用途 |
| --- | --- |
| `purchase_records` | 消費金額、分類、擁有者與同步狀態 |
| `uniform_invoices` | 發票號碼、期別及相關欄位 |
| `purchase_places` | 店家名稱、地址與座標 |
| `receipt_items` | 發票商品明細 |
| `sync_outbox` | 等待同步的新增、更新與刪除工作 |
| `app_metadata` | 資料版本、搬移狀態與 App 設定 |

## 開發環境

- Flutter SDK
- Android Studio 或 Android SDK
- Python 3.12
- [uv](https://docs.astral.sh/uv/)
- iOS 建置需要 macOS、Xcode 與 Apple Developer 簽章

## 執行 Flutter App

安裝套件並執行檢查：

```powershell
flutter pub get
flutter analyze
flutter test
```

啟動 Android 模擬器後執行：

```powershell
flutter run
```

若需要測試登入與同步，請先啟動本機後端，再讓 Android 模擬器透過 `10.0.2.2` 連線：

```powershell
flutter run --dart-define=AUTH_API_BASE_URL=http://10.0.2.2:8000
```

## 執行 FastAPI 後端

```powershell
cd backend
uv sync
uv run python -m uvicorn app:app --host 0.0.0.0 --port 8000
```

後端測試：

```powershell
cd backend
uv run python -m pytest -q
```

本機開發預設使用 SQLite 資料庫。

## 未來待開發

- Email 驗證、忘記密碼及 App 內帳號刪除流程。
- 串接財政部授權服務，更新正式一般獎號並處理雲端發票專屬獎。
- 將 FastAPI 部署到 HTTPS，並改用具備備份機制的 PostgreSQL；Render／Neon 可作為測試環境候選方案。
- 加入正式隱私政策、資料安全聲明、錯誤監控與後端速率限制。
- 完成 Android App Bundle、Google Play 封閉測試及正式發布流程。
- 在 macOS 上完成 iOS Simulator、實機、Keychain、相機及 App Store 簽章測試。
"# Receipt-Trail" 
