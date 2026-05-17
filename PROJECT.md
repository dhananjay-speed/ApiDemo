# CMExpertise Precticle — Project Overview

A small iOS demo app (UIKit + Storyboard, Swift) that fetches a 5-day / 3-hour weather forecast from the OpenWeatherMap API and displays it grouped by date. Its main purpose is to demonstrate **three different networking styles** against the same endpoint:

1. Classic `URLSession` + completion handler with `Result`
2. Combine publishers (`dataTaskPublisher`)
3. Modern Swift Concurrency (`async`/`await`)

The home screen shows one row per day; each row contains a horizontal collection of 3-hour forecast tiles (icon, temperature in °C, time).

---

## Tech Stack

- **Language:** Swift
- **UI:** UIKit, Storyboard (`Main.storyboard`), Auto Layout
- **Reactive:** Combine (`@Published`, `AnyPublisher`, `sink`)
- **Concurrency:** `async/await` + `Task { @MainActor in ... }`
- **Networking:** `URLSession` (no third-party libraries)
- **Target IDE:** Xcode (project file: `CMExpertise Precticle.xcodeproj`)
- **Min device template:** iPhone (portrait, retina6_12 in storyboard)

---

## Directory Layout

```
ApiDemo/
├── CMExpertise Precticle.xcodeproj/        # Xcode project
├── CMExpertise Precticle/
│   ├── AppDelegate.swift                   # App entry point (minimal)
│   ├── Base.lproj/
│   │   ├── Main.storyboard                 # Root UI (single VC scene)
│   │   └── LaunchScreen.storyboard
│   ├── Assets.xcassets/                    # App icons, loading image
│   ├── Model/
│   │   └── WeatherResModel.swift           # Decodable models
│   ├── ViewModel/
│   │   └── WeatherDataViewModel.swift      # ObservableObject, @Published list
│   ├── View/
│   │   └── HomeView/
│   │       ├── ViewController.swift        # Home screen
│   │       ├── TableCell/WetherCell.swift  # Row per day (hosts collection)
│   │       └── CollectionCell/DataCell.swift # 3-hour forecast tile
│   ├── Webservice/
│   │   ├── WebService.swift                # Three API methods (closure/Combine/async)
│   │   └── APIKeys.swift                   # OpenWeatherMap endpoint enum
│   └── Extension/
│       ├── Error.swift                     # `ApiError` enum
│       ├── String+Extension.swift          # Date/time parsing helpers
│       ├── Double+Extension.swift          # `getCelcius()` (Kelvin → °C)
│       └── UIImage+Extension.swift         # `UIImageView.load(url:)` async image
└── PROJECT.md                              # This file
```

---

## Architecture — MVVM (lightweight)

```
        OpenWeatherMap REST API
                │
        ┌───────▼────────┐
        │   WebService   │  3 flavors: closure / Combine / async-await
        └───────┬────────┘
                │
   ┌────────────▼──────────────┐
   │ WeatherDataViewModel       │   ObservableObject
   │  @Published var list       │   Combine subject the View binds to
   └────────────┬──────────────┘
                │ Combine sink
   ┌────────────▼──────────────┐
   │     ViewController         │   Home screen
   │  - groups List by date     │
   │  - UITableView (per-day)   │
   │      └── UICollectionView  │   3-hour tiles inside each row
   └────────────────────────────┘
```

### Data flow

1. `ViewController.viewDidLoad` subscribes to `viewModel.$list` and calls `getDataWithAwait()` (default path; closure and Combine variants are kept as commented examples for reference).
2. The view model calls `WebService().getDataWithWait(...)`, decodes JSON into `WeatherResModel`, and assigns it to its `@Published list`.
3. The publisher fires `refresData(data:)`, which groups the flat `[List]` by `dt_txt`'s date portion into `[WData]` (date + entries for that day).
4. The table reloads. Each `WetherCell` shows the date label and hosts a horizontal collection of `DataCell` tiles for that day's 3-hour slots.
5. Each `DataCell` shows a placeholder `"loading"` image, the time (`HH:mm`), the temperature in °C, and asynchronously loads the OpenWeatherMap icon from `https://openweathermap.org/img/wn/{icon}.png` via `UIImageView.load(url:)`.

---

## Key Files

| File | Responsibility |
| --- | --- |
| `AppDelegate.swift` | Standard delegate; storyboard handles root VC. |
| `View/HomeView/ViewController.swift` | Home screen. Sets up the table, subscribes to view-model updates, groups responses into `WData` (date → list), and configures a top navigation bar titled **"Wethor data"**. |
| `View/HomeView/TableCell/WetherCell.swift` | One row per day; owns a horizontal `UICollectionView` of forecast tiles. |
| `View/HomeView/CollectionCell/DataCell.swift` | Single 3-hour forecast tile (icon, temp, time). |
| `ViewModel/WeatherDataViewModel.swift` | Owns the three API entry points and the `@Published var list`. |
| `Webservice/WebService.swift` | Three generic networking methods: `apiToGetData` (closure + `Result`), `apiToGetDataToCombine` (Combine publisher), `getDataWithWait` (async/await). |
| `Webservice/APIKeys.swift` | Hardcoded OpenWeatherMap forecast URL (city id 6940463). **The `appid` is committed in source — see Security Notes.** |
| `Model/WeatherResModel.swift` | `Decodable` classes: `WeatherResModel` → `[List]` → `Main` (temp) + `[Weather]` (icon) + `dt_txt`. |
| `Extension/String+Extension.swift` | Parses `yyyy-MM-dd HH:mm:ss` into `dd/MM/yyyy` and `HH:mm`. |
| `Extension/Double+Extension.swift` | Kelvin-to-Celsius formatting via `getCelcius()`. |
| `Extension/UIImage+Extension.swift` | Background `Data(contentsOf:)` image loader for `UIImageView`. |
| `Extension/Error.swift` | `ApiError` enum (single `.fail` case). |

---

## API

- **Provider:** OpenWeatherMap — 5 day / 3 hour forecast endpoint
- **Endpoint:** `http://api.openweathermap.org/data/2.5/forecast?id=<cityId>&appid=<APP_ID>`
- **City id used:** `6940463`
- Icon URL pattern: `https://openweathermap.org/img/wn/{iconCode}.png`
- Temperature is returned in Kelvin and converted to Celsius client-side.

---

## How to Run

1. Open `CMExpertise Precticle.xcodeproj` in Xcode.
2. Select a simulator (e.g. iPhone 15).
3. Build & Run (⌘R).
4. The home screen loads the forecast and renders day-grouped rows.

No CocoaPods / SPM / Carthage dependencies — pure stdlib + Apple frameworks.

---

## Coding Conventions Observed

- `//MARK: -` section banners in every file.
- IBOutlets are connected through Storyboard (`Main.storyboard`).
- View models conform to `ObservableObject` and expose `@Published` state.
- Decoding uses `try? decodeIfPresent` defensively for every key.
- Networking methods are generic over `T: Decodable` and share the same `(resModel:url:)` shape across all three styles.

---

## Known Issues / Things an Agent Should Know Before Editing

- **Force-try in JSON decode:** `WebService` uses `try! jsonDecoder.decode(...)` in all three methods. Malformed responses will crash. Replace with `try` + proper error propagation if hardening.
- **Hardcoded secret in repo:** `APIKeys.swift` ships the OpenWeatherMap `appid` in source. Move to a secure config / `.xcconfig` / environment lookup before publishing.
- **Plaintext HTTP:** The forecast URL uses `http://`, which requires an ATS exception (or upgrade to `https://`).
- **Typos in identifiers:** `WetherCell`, `CollectionWether`, `cancalable`, `getCelcius`, `imgWether`, struct `WData` — preserved as-is to keep storyboard outlets / `reuseIdentifier` strings valid. Renames must be done in tandem with the storyboard XML.
- **Navigation bar title** is set programmatically in `ViewController.setUpNavigationBar()` because the home VC is not embedded in a `UINavigationController` in the storyboard.
- **Three API paths exist; only one runs:** `getDataWithAwait()` is wired in `setUpData()`. The closure and Combine variants are intentionally retained as reference implementations.
- **Image loading** in `UIImage+Extension` uses `Data(contentsOf:)` on a background queue without caching — fine for a demo, not for production.

---

## Suggested Improvements (non-binding)

- Replace force-tries with proper `do/catch` + surfaced `ApiError`.
- Move the API endpoint and key out of source (xcconfig + Info.plist redaction).
- Switch to HTTPS to drop the ATS exception requirement.
- Add unit tests for date grouping in `refresData(data:)` and for the `String+Extension` parsers.
- Consider migrating the screen to SwiftUI given the view model is already `ObservableObject`.
