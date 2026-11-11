# AeroCloud — план реконструкции

**Статус:** на подтверждении. Код не пишется до согласования.
**Дата:** 11.11.2026
**Целевая платформа:** iOS 27.0, Xcode 27.1, Swift 6 (strict concurrency), iPhone.
**Рабочая папка:** `AeroCloud/` (рядом с существующими проектами, ничего не перезаписываем).

---

## 0. Ограничение среды, которое нужно зафиксировать сразу

Я работаю в Windows. Здесь нет Xcode, Swift toolchain и iOS Simulator. Поэтому:

- весь код, `project.yml`, тесты и CI я напишу;
- собрать и прогнать iOS-таргет локально в этой сессии невозможно;
- источник истины по сборке — macOS с Xcode 27.1 или GitHub Actions на macOS-раннере с Xcode 27.1;
- чистую логику (`AeroCloudRecommendations`, парсеры, дедупликация) можно дополнительно гонять через `swift test` на macOS/Linux, но не через SwiftUI;
- финальная приёмка «запускается и играет» требует устройства/симулятора с iOS 27 и ваших ключей провайдеров.

Это не отговорка, а условие, которое влияет на процесс: я не смогу «на глаз» поймать ошибку компиляции в SwiftUI/AVFoundation. Поэтому в проекте с первого дня будет CI, а спорные системные API я сверяю по актуальной документации Apple (iOS 27), а не по памяти.

---

## 1. Анализ репозитория

### 1.1 Что проверено

Кандидат из задания: **XIaodou0416/Beans-Music** (MIT, ~447 звёзд, iOS 26 Liquid Glass, мультиисточники).

Фактическая структура:

| Метрика | Значение |
|---|---|
| Swift-файлов | 72 |
| Строк Swift | 33 184 |
| Размер исходников | ~1,5 МБ |
| Таргетов | 1 (`Beans`) |
| SPM-пакетов | 0 |
| Тестов | 0 |
| Deployment target | iOS 15.0 |
| Swift | 5.0 |
| `NSAllowsArbitraryLoads` | `true` |
| Крупнейшие файлы | `PlayerView.swift` — 4 447 строк, `ProfileView.swift` — 3 350, `KugouMusicAPI.swift` — 2 085, `DiscoverView.swift` — 2 074, `QQMusicAPI.swift` — 1 739, `PlayerManager.swift` — 1 616 |

Паттерны:

| Паттерн | Количество |
|---|---|
| `ObservableObject` | 18 |
| `@Observable` | 0 |
| `NavigationView` | 7 |
| `NavigationStack` | 31 |
| `DispatchQueue` | 42 |
| `SwiftData` | 0 |
| `Keychain` | 0 |
| `ASWebAuthenticationSession` | 0 |
| `PKCE` | 0 |
| `AVAudioEngine` | 0 |
| `MeshGradient` | 0 |
| `glassEffect` | 9 |
| `GlassEffectContainer` | 4 |
| `matchedGeometryEffect` | 2 |
| `MPNowPlayingInfoCenter` | 3 |

### 1.2 Что внутри по существу

- **Провайдеры:** NetEase, QQ Music, Kugou. Это неофициальные китайские API с cookie/web-логином, капчами и хрупкими эндпоинтами. Модель `Song` содержит поля `qqMid`, `kugouHash`, `kugouQualityHashes`, `fee` — она привязана к конкретным площадкам и не годится как единый `Track`.
- **Аккаунты:** `AuthStore` хранит пользователя в `UserDefaults`, логин — через cookie/web-view. Нет Keychain, OAuth 2.0, PKCE, refresh-токенов, ASWebAuthenticationSession.
- **Рекомендации:** собственного движка нет. Используются готовые «ежедневные рекомендации» площадок; нет вектора фич, CF, exploration, адаптации к скипам, объяснимости.
- **Плеер:** `AVPlayer` + `MTAudioProcessingTap` для эквалайзера, `MPNowPlayingInfoCenter`, очередь, режимы, сон-таймер. Это самая полезная часть как **идея**, но код монолитный и завязан на китайские источники.
- **Liquid Glass:** 9 вызовов `glassEffect` в обёртках, но это не дизайн-система: нет токенов, нет MeshGradient, нет морфинга, нет glass-шторок, нет Reduce Motion/Reduce Transparency.
- **Качество:** 0 тестов, 0 модулей, 4-тысячестрочные view, `NSAllowsArbitraryLoads`, iOS 15, Swift 5, GCD. Для iOS 27-приложения это не база, а источник продуктовых идей.

### 1.3 Решение по репозиторию

**Beans-Music берём как репозиторий-донор и продуктовый референс, но AeroCloud пишем с нуля.**

Почему не форк:

- лицензия MIT позволяет, но переписывать 33k строк монолита дороже, чем сделать чистый каркас;
- его сетевой слой и модели несовместимы с западными провайдерами и единым `Track`;
- его auth не соответствует требованиям (Keychain, OAuth, Telegram, refresh);
- его UI-файлы невозможно безопасно эволюционировать в дизайн-систему.

Что фиксируем как переиспользуемое:

- MIT-лицензию и `THIRD_PARTY_NOTICES.md` с атрибуцией XIaodou0416/Beans-Music;
- идею 10-полосного EQ через audio tap (реализуем иначе — `AVAudioUnitEQ` в `AVAudioEngine`);
- набор EQ-пресетов (значения gain) с атрибуцией;
- продуктовый охват: очередь, сон-таймер, загрузки, режимы повтора, lyrics-подход — но код новый.

Для сравнения я посмотрел **Loriage/Minidisc** (iOS 26, Swift 6, `@Observable`, акторы, двухдековый `AVPlayer`, SwiftData, Keychain, Liquid Glass). Это архитектурно более чистая база, но:

- MPL-2.0 (file-level copyleft) — хуже для возможной проприетарной дистрибуции;
- это Subsonic-клиент, а не мультиисточник;
- нет рекомендательного движка и западных провайдеров.

Поэтому Minidisc — архитектурный benchmark, не база. Итог: **greenfield-проект AeroCloud, Beans — донор идей и атрибуции.**

---

## 2. Продукт

### 2.1 Позиционирование

AeroCloud — не «ещё один клиент», а **персональный радиоплеер**: пользователь запускает AE Wave, а приложение подстраивает энергию, настроение, темп и свежесть под контекст. Мультиисточники — способ найти и проиграть трек, а не самоцель.

### 2.2 Табы

5 табов:

1. **Главная** — приветствие по времени, hero AE Wave, продолжить, новинки, настроения.
2. **Поиск** — единый поиск по включённым источникам, фильтр источника, история, подсказки.
3. **AE Wave** — полноэкранная лента AE Wave: крупная обложка, лайк/дизлайк, причина рекомендации, настройка вайба.
4. **Библиотека** — плейлисты, альбомы, исполнители, треки, скачанное, «Мне нравится», недавнее.
5. **Профиль** — гость/аккаунт, статистика, любимые жанры, настройки.

Плеер — не таб, а **root-overlay** над всем shell. Мини-плеер — glass-карточка над таб-баром. Это нужно для matched geometry и для того, чтобы плеер не терял состояние при смене таба.

### 2.3 Визуальный язык

- Глубокий синий фон `#0A1628`, многослойный mesh-градиент, лёгкий шум.
- Акцент — градиент `#00D4FF → #0066FF`.
- Стекло — полупрозрачные синие поверхности `rgba(10,22,40,0.72)`, белые кромки, внутренняя подсветка.
- Тёмная тема — основная для v1. Светлую не делаем, пока не согласовано: палитра задания рассчитана на тёмный фон. При этом поддерживаем Increase Contrast и Reduce Transparency.
- Анимации — пружины, matched geometry, живой waveform, параллакс, shimmer, пульсация обложки.

---

## 3. Архитектура

### 3.1 MVVM + Coordinator, не TCA

Выбор: **MVVM + Coordinator**.

- SwiftUI + `@Observable` дают минимальный boilerplate; TCA для одного приложения добавляет много кода и усложняет кривую входа.
- Coordinator владеет навигацией и deep links; View не знает о маршрутах.
- ViewModel — `@MainActor @Observable`, только presentation state и вызовы сервисов.
- Сервисы — акторы/структуры за протоколами, без SwiftUI.
- Тестируемость: TCA выигрывает в тестах сложных reducer-ов, но наши сложные части — рекомендации, парсеры и плеер — тестируются как чистые сервисы. Навигацию покрываем unit-тестами координатора.

Trade-off: меньше «магии» и меньше зависимости от сторонней библиотеки; за счёт этого проще собрать и сопровождать.

### 3.2 Модули

```
AeroCloud/                         # app target + extensions
Packages/
  AeroCloudCore/                   # модели, протоколы, сеть, SwiftData, утилиты
  AeroCloudUI/                     # дизайн-система и компоненты
  AeroCloudPlayer/                 # движок, очередь, EQ, waveform, Now Playing
  AeroCloudRecommendations/        # фичи, CF, вайб, лента, объяснения
  AeroCloudAuth/                   # Telegram, Apple, Keychain, refresh
  AeroCloudProviders/              # Apple Music, Spotify, SoundCloud, Deezer, Last.fm, YT, Demo
Extensions/
  AeroCloudWidgets/                # WidgetKit
  AeroCloudLiveActivity/           # ActivityKit
Server/                            # Cloudflare Worker: Telegram, Apple, sync, SoundCloud token
Tests/                             # unit + snapshot + UI
```

Зависимости:

```
Core ← UI
Core ← Player
Core ← Recommendations
Core ← Auth
Core ← Providers
все ← App
```

`AeroCloudUI` не импортирует Player/Auth/Providers — только Core-модели. `AeroCloudPlayer` не импортирует SwiftUI. `AeroCloudRecommendations` не импортирует SwiftData (чистая логика + протокол кэша).

### 3.3 Concurrency

- Swift 6 language mode, `SWIFT_STRICT_CONCURRENCY=complete`, `SWIFT_DEFAULT_ACTOR_ISOLATION=MainActor`.
- UI — `@MainActor`.
- Сеть, кэш, рекомендации, токены — акторы.
- Плеер — `@MainActor` фасад над движком; аудио-колбэки уходят в `AsyncStream`.
- Никакого `DispatchQueue` в новом коде. В сторонних пакетах (AudioStreaming) GCD остаётся внутри — это допустимо, но мы не протаскиваем его в свой код.
- `TaskGroup` для параллельного поиска, `AsyncStream` для состояния плеера и ленты рекомендаций, `ContinuousClock` для кроссфейда и сна.

### 3.4 Хранение

SwiftData:

- `CachedTrack`, `CachedArtist`, `CachedAlbum`
- `PlaylistEntity`, `PlaylistItemEntity`
- `PlaybackEventEntity`
- `TrackFeatureEntity`
- `RecommendationEntity`
- `DownloadEntity`
- `UserProfileEntity`
- `ProviderAccountEntity`
- `SearchHistoryEntity`
- `VibePresetEntity`

Правила:

- `@ModelActor` для фоновых записей; между акторами передаём `PersistentIdentifier`, не `@Model`-объекты.
- `ModelContainer` с App Group URL `group.app.aerocloud` — для виджетов.
- Виджетам не отдаём SwiftData напрямую: пишем компактный `WidgetSnapshot.json` в App Group.
- Кэш рекомендаций — top-200 кандидатов + фичи; оффлайн-лента собирается из них.

### 3.5 DI, ошибки, логи

- `AppDependencies` — composition root; протоколы, никаких синглтонов в фичах.
- `AeroError`: `network`, `auth`, `provider`, `playback`, `persistence`, `unavailable(reason)`; локализованные сообщения.
- `ErrorPresenter` — `@MainActor @Observable`, glass-тост сверху, retry action, auto-dismiss 4 с.
- `Result` используем на границах, где важна частичная успешность (поиск по провайдерам); внутри сервисов — `async throws`.
- `os.Logger` с категориями; токены и PII редактируем.

### 3.6 Секреты

Важное уточнение: **client secret нельзя хранить в `.xcconfig`**. `.xcconfig` попадает в бандл, его можно достать. Поэтому:

- в `.xcconfig` — только публичные client ID, base URL, bundle ID, App Group;
- Telegram bot token, SoundCloud client secret, Last.fm shared secret, JWT signing key — только на backend (Cloudflare secrets);
- в Keychain — access/refresh токены, provider refresh tokens;
- `Secrets.xcconfig` — в `.gitignore`, `Secrets.example.xcconfig` — в репозитории.

---

## 4. Дизайн-система

### 4.1 Токены

**Цвета:**

| Токен | Значение |
|---|---|
| `background` | `#0A1628` |
| `backgroundElevated` | `#0E1E36` |
| `surface` | `rgba(10,22,40,0.72)` |
| `accentStart` | `#00D4FF` |
| `accentEnd` | `#0066FF` |
| `textPrimary` | `#F0F4FF` |
| `textSecondary` | `#F0F4FF` @ 64% |
| `textTertiary` | `#F0F4FF` @ 40% |
| `stroke` | white @ 12% |
| `strokeHighlight` | white @ 28% |
| `success` | `#3DDC97` |
| `warning` | `#FFB020` |
| `error` | `#FF5A6E` |
| `like` | `#FF4D8D` |

Цвета источников — только в бейджах, не в фоне: SoundCloud `#FF5500`, Spotify `#1DB954`, Apple Music `#FA2D48`, YouTube `#FF0033`, Deezer `#A238FF`, Last.fm `#D51007`.

**Типографика:** системный SF Pro; заголовки — `.rounded` для hero-цифр, остальное — `.default`. Все размеры масштабируются через semantic styles/`@ScaledMetric`, фиксированных px в UI нет. Шкала: Display 34/40, Title 28/32, Title2 22/26, Title3 20/24, Headline 17/22, Body 17/22, Callout 16/21, Subheadline 15/20, Footnote 13/18, Caption 12/16, Caption2 11/13. Время — `.monospacedDigit()`.

**Spacing:** 4, 8, 12, 16, 20, 24, 32, 40, 48, 64. Сетка 4 pt.

**Radius:** 8, 12, 16, 20, 24, 28, 32, 36, capsule.

**Тени/свечение:**

- card: black 35%, radius 24, y 12;
- glow: accent 55%, radius 16, y 0;
- glass inner highlight: white 22%, 1 pt сверху;
- stroke: white 12%, 1 pt.

### 4.2 Liquid Glass

Базовые обёртки:

- `GlassCard`: `.glassEffect(.regular.tint(AeroColor.glassTint).interactive(), in: .rect(cornerRadius: 28))` + stroke + inner highlight.
- `GlassSheet`: `.presentationBackground(.clear)`, контент в glass-карточке, corner 36, detents `.medium/.large`.
- `GlassToast`: `.glassEffect(.regular.tint(...), in: .capsule)`.
- `GlassEffectContainer(spacing: 16)` — для таб-бара и мини-плеера, чтобы формы могли сливаться.
- `.glassEffectID("miniPlayer", in: namespace)` — для морфинга.
- Кнопки: системный `.buttonStyle(.glass)` там, где нужен системный вид; брендовые — `AeroButton` с градиентом и glow.

Три обязательные точки glass: **таб-бар**, **мини-плеер**, **шторка вайба**. Дополнительно: тосты, контекстные меню, карточки Home.

### 4.3 Компоненты

| Компонент | Файл | Ключевые параметры |
|---|---|---|
| `AuroraBackground` | `AeroCloudUI/Background/AuroraBackground.swift` | MeshGradient 3×3, 4 анимированные точки, 18 с цикл; noise 128×128, `.plusLighter`, opacity 0.035 |
| `GlassCard` | `AeroCloudUI/Glass/GlassCard.swift` | corner 28, tint 0.55, stroke 0.12, inner highlight 0.22 |
| `AeroButton` | `AeroCloudUI/Buttons/AeroButton.swift` | primary 52 pt / corner 18; icon 44 pt; press scale 0.97; glow 16 |
| `GlowButtonStyle` | `AeroCloudUI/Buttons/GlowButtonStyle.swift` | shadow accent 0.55, radius 16; in 0.18 s, out 0.45 s |
| `TrackRow` | `AeroCloudUI/Rows/TrackRow.swift` | 64 pt; artwork 52/corner 10; title 16 semibold; artist 14; badge 18 pt |
| `SourceBadge` | `AeroCloudUI/Badges/SourceBadge.swift` | capsule 20 pt; fill source 12%; label 10 semibold |
| `WaveformView` | `AeroCloudUI/Waveform/WaveformView.swift` | 64 бара, Canvas, 30 fps, gradient cyan→blue, attack 0.08 s / decay 0.28 s |
| `VibeSlider` | `AeroCloudUI/Vibe/VibeSlider.swift` | track 8 pt, thumb 24 pt glass, value bubble, haptic каждые 0.1 |
| `Skeleton` | `AeroCloudUI/Loading/Skeleton.swift` | shimmer 1.4 s linear, gradient -1→2; Reduce Motion → static |
| `ErrorToast` | `AeroCloudUI/Feedback/ErrorToast.swift` | top inset 8, glass capsule, icon + text + retry, 4 s |
| `ArtworkView` | `AeroCloudUI/Artwork/ArtworkView.swift` | NukeUI, downsampling, placeholder gradient, palette cache |
| `PlayPauseButton` | `AeroCloudUI/Player/PlayPauseButton.swift` | 76 pt, gradient circle, glow, symbol replace |
| `MiniPlayerView` | `AeroCloud/Features/Player/MiniPlayerView.swift` | 64 pt, corner 26, artwork 44, progress 2 pt |
| `AeroTabBar` | `AeroCloud/App/AeroTabBar.swift` | 5 items, 64 pt, glass capsule, selected pill matched geometry |

### 4.4 Motion

| Событие | Анимация |
|---|---|
| Таб | `.spring(response: 0.32, dampingFraction: 0.78)` |
| Mini → Player | `.spring(response: 0.48, dampingFraction: 0.82)` + `matchedGeometryEffect(id: "artwork")` |
| Player dismiss | `.spring(response: 0.42, dampingFraction: 0.88)` |
| Play/pause | `.spring(response: 0.28, dampingFraction: 0.65)` + symbol bounce |
| Like | `.spring(response: 0.30, dampingFraction: 0.55)` + частицы |
| Vibe slider | `.interactiveSpring(response: 0.22, dampingFraction: 0.90)` |
| Cover pulse | 4.2 s ease-in-out repeat; scale 1.0→1.015 |
| Parallax | `offset * 0.35`; scale `1 + max(0, -offset)/1200`; blur 0→12 |
| Shimmer | 1.4 s linear repeat |
| Glow press | 0.18 s ease-out in; 0.45 s ease-out out |
| Waveform | 30 fps; attack 0.08 s; decay 0.28 s |

Все анимации уважают `accessibilityReduceMotion`: переходы → crossfade 0.2 s, pulse/parallax/shimmer отключаются, waveform становится статичной.

### 4.5 Доступность

- Dynamic Type до AX5; никаких фиксированных высот, которые обрезают текст.
- VoiceOver: `TrackRow` — «Трек, исполнитель, длительность, источник»; waveform — «Визуализация трека»; слайдеры — adjustable.
- Reduce Transparency: glass → solid surface с opacity 0.92.
- Increase Contrast: stroke 28%, text 100%.
- Hit targets ≥ 44×44.
- Фокус-порядок в плеере: обложка → название → прогресс → транспорт → вторичные действия.
- Никаких миганий > 3 Гц.

---

## 5. Ядро и провайдеры

### 5.1 Модели

```swift
struct Track: Identifiable, Codable, Hashable, Sendable {
    let id: String                 // "source:sourceID"
    let title: String
    let artist: String
    let album: String?
    let artworkURL: URL?
    let duration: TimeInterval
    let source: MusicSource
    let sourceID: String
    let isrc: String?
    let releaseYear: Int?
    let isExplicit: Bool
    let language: TrackLanguage
    var playback: PlaybackAvailability
    var features: TrackFeatures?
}

enum MusicSource: String, Codable, CaseIterable, Sendable {
    case appleMusic, spotify, soundCloud, youtubeMusic, deezer, lastFM, local, demo
}

enum PlaybackAvailability: Codable, Hashable, Sendable {
    case remote(URL)                       // прямой поток
    case appleMusic(id: String)            // нативное воспроизведение MusicKit
    case preview(URL, seconds: Int)        // 30-секундное превью
    case unavailable(reason: String)
}

struct TrackFeatures: Codable, Hashable, Sendable {
    var energy: Double            // 0...1
    var valence: Double           // 0...1
    var tempo: Double             // 0...1 (нормализованный BPM)
    var popularity: Double        // 0...1
    var acousticness: Double      // 0...1
    var danceability: Double      // 0...1
    var instrumentalness: Double  // 0...1
    var freshness: Double         // 0...1
    var language: TrackLanguage
    var genres: [String]
    var bpm: Double?
    var confidence: Double        // 0...1
}
```

`TrackGroup` — канонический трек + варианты из разных источников + лучший вариант для воспроизведения. Бейдж источника показывает, откуда взят вариант.

### 5.2 Протокол

```swift
protocol MusicProvider: Sendable {
    var source: MusicSource { get }
    var capabilities: ProviderCapabilities { get }

    func search(query: String, type: SearchType, limit: Int) async throws -> SearchPage
    func streamURL(for track: Track) async throws -> PlaybackAvailability
    func metadata(for track: Track) async throws -> Track
    func artworkURL(for track: Track, size: CGSize) async -> URL?
    func artist(id: String) async throws -> Artist
    func album(id: String) async throws -> Album
    func playlist(id: String) async throws -> Playlist
}
```

`ProviderCapabilities`: search, metadata, artwork, stream, preview, nativePlayback, auth, download, lyrics, audioFeatures, librarySync.

### 5.3 Матрица реальности провайдеров

| Источник | Поиск | Метаданные | Обложки | Полный стрим | Авторизация | Ограничения |
|---|---|---|---|---|---|---|
| Apple Music | ✅ MusicKit | ✅ | ✅ | ✅ нативно, по подписке | MusicKit | нет raw URL; EQ/waveform недоступны для DRM |
| Spotify | ✅ Web API | ✅ | ✅ | ⚠️ только 30 с preview; полный — через Spotify Connect (Premium) | PKCE | audio features deprecated; нельзя скачивать |
| SoundCloud | ✅ API (по одобрению) | ✅ | ✅ | ✅ `stream_url` с OAuth; часть треков — preview | OAuth via backend | API закрыт для новых приложений; ToS |
| YouTube Music | ⚠️ неофициально | ✅ | ✅ | ⚠️ через пользовательский proxy | нет | нет официального API; риск ToS и App Review; **выключено по умолчанию** |
| Deezer | ✅ public API | ✅ | ✅ | ⚠️ 30 с preview | нет | полный стрим — только по партнёрству |
| Last.fm | ❌ | ✅ similar/tags | ✅ | ❌ | API key | обогащение и scrobbling, не источник аудио |
| Demo | ✅ локально | ✅ | ✅ | ✅ CC0-файл | нет | для CI, превью и запуска без ключей |

Это ключевое продуктовое ограничение: **«стриминг из Spotify» в юридически чистом виде невозможен**. Spotify Web API не отдаёт полные аудиопотоки. Мы делаем поиск/метаданные/превью и, для Premium, удалённое управление Spotify Connect; полный звук остаётся в Spotify. Аналогично Apple Music: играем через MusicKit, но не получаем URL.

### 5.4 Единый поиск и дедупликация

`SearchService`:

- debounce 300 мс;
- параллельный `withThrowingTaskGroup` по включённым провайдерам;
- таймаут 2,5 с на провайдер, частичные результаты;
- отмена предыдущего поиска при новом вводе;
- ранжирование: релевантность + предпочтение источника + популярность.

`TrackDeduplicator`:

- нормализация: lowercase, diacritics folding, удаление `feat.`, `remaster`, `radio edit`, пунктуации, текста в скобках;
- artist set: пересечение токенов;
- duration tolerance ±3 с;
- ISRC — точное совпадение;
- score = 0.6·title + 0.3·artist + 0.1·duration;
- порог 0.82; объединение в `TrackGroup`;
- лучший вариант: приоритет полного стрима, затем качество, затем источник пользователя.

Тесты: 12 кейсов, включая «Song (Remastered)» vs «Song», «feat.» vs основной артист, разные версии длиннее 10 с (не мержить), одинаковый title у разных артистов (не мержить).

### 5.5 Юридические предупреждения

- **YouTube Music:** в приложении нет кода извлечения потоков и нет yt-dlp. Провайдер общается с пользовательским proxy по абстрактному контракту, выключен флагом `FeatureFlags.youtubeMusicEnabled = false`. В `docs/LEGAL.md` — предупреждение о ToS YouTube и риске App Review. Включать только на свой риск и не в App Store-сборке.
- **SoundCloud:** stream URL временные, не кэшировать; скачивание — только если трек разрешён; атрибуция обязательна.
- **Spotify:** не использовать недокументированные эндпоинты и audio-features; не риппить; preview — по ToS.
- **Apple Music:** MusicKit, без приватных API; artwork — по правилам Apple; DRM не обходим.
- **Deezer:** public API, previews; полный стрим — только по договору.
- **Last.fm:** API key, rate limits, scrobbling по правилам.
- **Telegram:** bot token только на сервере; домен виджета настраивается в BotFather; персональные данные — в privacy policy.
- **App Store:** Sign in with Apple обязателен рядом с Telegram (4.8), удаление аккаунта (5.1.1(v)), privacy manifest, без риппинга чужого контента.

---

## 6. AE Wave: рекомендательный движок

### 6.1 Сигналы

Явные:

- лайк/дизлайк;
- вайб-пресет и ползунки;
- язык;
- жанры при онбординге.

Неявные:

- прослушивания: старт, завершение, повтор, скип;
- позиция скипа (< 30 с или < 20% длительности — сильный отрицательный сигнал);
- время суток и день недели;
- контекст: экран, предыдущий трек, очередь;
- источник.

### 6.2 Вектор фич

9 измерений: energy, valence, tempo, popularity, acousticness, danceability, instrumentalness, freshness, language. Плюс `genres` и `confidence`.

Источники фич по приоритету:

1. нативные фичи провайдера (если есть и разрешены);
2. BPM/жанр из Deezer/Last.fm;
3. эвристики по метаданным:
   - жанровые prior-векторы (electronic, classical, metal, hip-hop, jazz, pop, rock, ambient, lo-fi…);
   - release year → freshness;
   - popularity из источника;
   - instrumentalness по жанру и ключевым словам;
   - valence по жанру/ладу, если есть ключ;
   - confidence: 0.3 — только жанр, 0.7 — есть BPM/теги, 1.0 — нативные фичи.

Никакого скрейпинга Spotify audio features: эндпоинт закрыт для новых приложений. Это сознательное ограничение, а не недоделка.

### 6.3 VibeProfile

```swift
struct VibeProfile: Codable, Hashable, Sendable {
    var energy: Double = 0.5
    var valence: Double = 0.5
    var tempo: Double = 0.5
    var popularity: Double = 0.5
    var electronic: Double = 0.5   // акустика ↔ электроника
    var danceability: Double = 0.5
    var instrumentalness: Double = 0.5
    var freshness: Double = 0.5
    var language: LanguagePreference = .any
    var weights: [Feature: Double] = [:]
    var presetID: String?
}
```

Пресеты (целевые значения):

| Пресет | Energy | Valence | Tempo | Pop | Electronic | Dance | Instr | Fresh |
|---|---|---|---|---|---|---|---|---|
| Для работы | 0.45 | 0.55 | 0.40 | 0.35 | 0.55 | 0.35 | 0.70 | 0.50 |
| Для тренировки | 0.90 | 0.70 | 0.80 | 0.60 | 0.70 | 0.85 | 0.20 | 0.40 |
| Ночная поездка | 0.65 | 0.35 | 0.55 | 0.50 | 0.75 | 0.60 | 0.50 | 0.45 |
| Утро | 0.50 | 0.80 | 0.50 | 0.55 | 0.35 | 0.50 | 0.30 | 0.65 |
| Дождь за окном | 0.25 | 0.30 | 0.30 | 0.30 | 0.25 | 0.20 | 0.60 | 0.35 |
| Фокус | 0.35 | 0.50 | 0.35 | 0.25 | 0.50 | 0.25 | 0.85 | 0.40 |
| Вечеринка | 0.95 | 0.90 | 0.85 | 0.80 | 0.80 | 0.95 | 0.10 | 0.55 |
| Романтика | 0.35 | 0.65 | 0.40 | 0.50 | 0.25 | 0.40 | 0.35 | 0.30 |

### 6.4 Гибридный ранкер

Для кандидата `t` и профиля `p`:

```
content(t) = Σ wᵢ · pᵢ · fᵢ(t) / (sqrt(Σ wᵢ · pᵢ²) · sqrt(Σ wᵢ · fᵢ(t)²))
```

где `wᵢ` — важность фичи (из вайба и пользовательских весов), `fᵢ` — фичи трека.

Item-based CF:

```
cfSim(i,j) = |Sᵢ ∩ Sⱼ| / sqrt(|Sᵢ| · |Sⱼ|)
cfScore(t) = Σⱼ cfSim(t,j) · feedback(j) / Σⱼ |cfSim(t,j)|
```

Implicit feedback:

- play +1;
- complete +1.5;
- repeat +2;
- like +3;
- dislike −3;
- skip −1.5.

Гибрид:

```
score = 0.45·content + 0.30·cf + 0.10·popularity + 0.10·freshness + 0.05·novelty
```

Cold start: если CF недоступен, `content=0.70, cf=0, popularity=0.15, freshness=0.10, novelty=0.05`.

Exploration/exploitation: ε-greedy, ε = 0.15. С вероятностью 15% берём кандидата из top-30 вне top-10, взвешенно по score.

Diversity: MMR, λ = 0.7; не более 2 треков одного артиста на 20 и не более 3 одного жанра на 20.

No-repeat: трек — 6 часов, артист — 45 минут. Леджер в SwiftData.

### 6.5 Адаптация в реальном времени

- 3 скипа подряд → `energyTarget -= 0.15`, `valenceTarget -= 0.05`, штраф жанрам скипнутых треков; эффект затухает 0.9 за трек.
- 3 завершения подряд → усилить текущий кластер на 0.1.
- Повтор трека → +0.15 к похожести на него в следующем батче.
- Смена пресета → пересборка следующих 10 треков, текущий не прерывается.
- Время суток: утро +0.1 valence, вечер +0.05 energy, ночь −0.15 energy; blend 10–20% к целям, если пресет не выбран явно.

### 6.6 Объяснимость

`RecommendationReason`:

- `.similarTo(artist, title)` — «Похоже на X»;
- `.becauseGenre(genre)` — «Потому что вы слушаете {жанр}»;
- `.newFrom(artist)` — «Новое от X»;
- `.becauseVibe(preset)` — «Подходит под вайб “Ночная поездка”»;
- `.rediscover` — «Вы давно не слушали».

Чип — small glass, тап открывает `ExplanationSheet` с 2–3 предложениями и кнопкой «Не похоже» (дизлайк сигнала).

### 6.7 Лента и кэш

- `RecommendationEngine` — актор.
- `nextBatch(context:limit:)` → 30 треков; пополнение при остатке < 10.
- `AsyncStream<[RecommendedTrack]>` для UI.
- Кэш top-200 кандидатов + фичи; оффлайн-режим собирает ленту из кэша, помечает «оффлайн».
- Дедупликация и no-repeat применяются до выдачи.

### 6.8 Тесты движка

- 20+ unit-тестов, seeded RNG.
- cold start;
- cosine symmetry;
- CF на синтетической матрице;
- ε-greedy детерминирован при seed;
- MMR diversity;
- 3 скипа → energy target ниже;
- 3 завершения → cluster boost;
- no-repeat 6 ч / артист 45 мин;
- пресеты;
- объяснения;
- offline cache.

---

## 7. Плеер

### 7.1 Движок

Два бэкенда за протоколом `PlaybackEngine`:

1. **`AeroStreamEngine`** — `AudioStreaming` (MIT, `AVAudioEngine`) + два дека для кроссфейда.
   - HTTP-стриминг MP3/AAC/FLAC/Ogg, локальные файлы, gapless-очередь.
   - `AVAudioUnitEQ(numberOfBands: 10)` через `attach(node:)`.
   - tap на `mainMixerNode` → PCM-буферы → `WaveformAnalyzer`.
   - `volume` для кроссфейда, `rate` для скорости.
   - Это закрывает требование «AVAudioEngine tap → буферы → Canvas».

2. **`AppleMusicEngine`** — MusicKit `ApplicationMusicPlayer`.
   - Полные треки по подписке.
   - Нет PCM-доступа (DRM) → waveform синтетическая (по BPM/времени), EQ и кроссфейд недоступны.
   - Это честно показывается в UI: бейдж «Apple Music», отключённые EQ/кроссфейд с пояснением.

`PlaybackCoordinator` выбирает движок по `PlaybackAvailability`.

### 7.2 Очередь

- `QueueController` — актор/`@MainActor` модель.
- Shuffle — «bag»: каждый трек ровно один раз до исчерпания, без повторов подряд.
- Repeat: off / one / all.
- Drag-to-reorder, swipe-to-delete, «Играет далее».
- Восстановление очереди и позиции после запуска (paused).

### 7.3 Кроссфейд и gapless

- Crossfade 0–12 с, настройка в Settings.
- Два дека: следующий трек стартует за `crossfade` секунд до конца, громкости рампаются по equal-power кривой.
- При crossfade = 0 — gapless-очередь библиотеки.
- Для Apple Music — без кроссфейда.

### 7.4 Эквалайзер

- 10 полос: 31, 62, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Гц.
- Gain −12…+12 dB, preamp −12…0 dB.
- Пресеты: Flat, Bass, Vocal, Pop, Rock, Classical, Jazz, Electronic, Custom (значения — с атрибуцией Beans).
- Glass-слайдеры, кривая АЧХ на Canvas.
- Только для `AeroStreamEngine`.

### 7.5 Сон-таймер

- 15/30/45/60/90 мин, «до конца трека».
- Плавное затухание 10 с.
- Live Activity показывает остаток.

### 7.6 Now Playing (iOS 27)

Ключевое изменение: на iOS 27 Apple ввела фреймворк **Now Playing** (`import NowPlaying`), который заменяет `MPNowPlayingInfoCenter` + `MPRemoteCommandCenter` для локальных сессий. Смешивать старый и новый API для одной сессии нельзя — Apple прямо предупреждает о undefined behavior.

Поэтому:

```swift
@Observable @MainActor
final class NowPlayingModel: MediaSessionRepresentable {
    let id = "app.aerocloud.session"
    var content: (any MediaContentRepresentable)?
    var playbackSnapshot: MediaPlaybackSnapshot?
    var commands: [MediaCommand] { ... }
}
```

- `MusicContent(id:songTitle:artistName:albumName:type:.audio,duration:.finite(...),artwork: Artwork(...))`.
- `MediaSession(model)` + `requestToBecomeApplicationPrimary()`.
- Команды: play, pause, next, previous, seek, skip.
- Artwork — `Artwork` с async-загрузкой и downsample.
- Live Activity и Dynamic Island — ActivityKit, отдельно.

Старый `MPNowPlayingInfoCenter` не используем, потому что target — iOS 27. Если бы нужен был iOS 26, сделали бы отдельный legacy-адаптер, но не оба одновременно.

### 7.7 Waveform

- Tap на mixer → `AVAudioPCMBuffer`.
- `WaveformAnalyzer` — актор: 64 лог-полосы 40 Гц–16 кГц, FFT через Accelerate/vDSP, RMS + peak.
- 30 fps, attack 0.08 с, decay 0.28 с.
- `Canvas` рисует 64 скруглённых бара, gradient cyan→blue.
- Idle — синусоидальное дыхание 0.06 амплитуды.
- Reduce Motion — статичная форма.
- Apple Music — синтетическая waveform по BPM/времени, без утверждения «реальный поток».

### 7.8 Скачивание

- Только источники, где это разрешено: SoundCloud (если трек downloadable), demo/local.
- Spotify/Apple Music/Deezer preview — не скачиваем.
- `DownloadManager` — background URLSession, прогресс, отмена, лимит хранилища, Wi-Fi only.
- Файлы — в Application Support/Downloads, excluded from backup.

### 7.9 Ограничения, которые фиксируем в UI

- Spotify: полный стрим недоступен → бейдж «Preview 30s» или «Открыть в Spotify».
- Apple Music: нет EQ/waveform/crossfade → бейдж и пояснение.
- YouTube Music: выключен по умолчанию, предупреждение.
- SoundCloud: часть треков только preview.

---

## 8. Аккаунты и backend

### 8.1 Telegram end-to-end

1. Приложение генерирует `state` (32 байта, base64url) и PKCE `code_verifier/challenge` (S256).
2. Открывает `ASWebAuthenticationSession` на `https://auth.aerocloud.app/auth/telegram/start?state=...&code_challenge=...&redirect_uri=aerocloud://auth/telegram`.
3. Backend хранит state + challenge в KV (TTL 10 мин) и отдаёт HTML с Telegram Login Widget (`data-telegram-login="AeroCloudBot"`, `data-auth-url="https://auth.aerocloud.app/auth/telegram/callback"`).
4. Telegram редиректит на callback с `id`, `first_name`, `last_name`, `username`, `photo_url`, `auth_date`, `hash`.
5. Backend проверяет HMAC-SHA256: `secret = SHA256(bot_token)`, `hash = HMAC_SHA256(data_check_string, secret)`, constant-time compare, `auth_date` < 5 мин.
6. Backend создаёт one-time code (32 байта, хранит hash, TTL 60 с) и редиректит на `aerocloud://auth/telegram?code=...&state=...`.
7. Приложение ловит deep link, проверяет state, вызывает `POST /auth/token` с code + code_verifier.
8. Получает access JWT (15 мин) + refresh (30 дней) + профиль; кладёт в Keychain.
9. Refresh — single-flight актор, ротация refresh-токена; 401 → один retry.

### 8.2 Sign in with Apple

Обязателен по App Store 4.8 рядом с Telegram:

- `ASAuthorizationAppleIDProvider` + `ASAuthorizationController`, nonce;
- backend проверяет identity token по Apple JWKS, audience = bundle ID;
- upsert пользователя, выдача своих JWT.

### 8.3 Гость

- Локальный профиль, без синхронизации.
- Все данные в SwiftData.
- При входе — merge: плейлисты/лайки по `updatedAt`, last-write-wins, дубликаты треков схлопываются.
- Гостевой режим не требует сети.

### 8.4 Keychain

- `kSecClassGenericPassword`, service `app.aerocloud.session`, account `current`.
- `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
- Access/refresh + provider refresh tokens.
- Никаких токенов в UserDefaults/логах.
- Опционально Face ID для повторного входа.

### 8.5 Backend (Cloudflare Worker + Hono + D1)

Эндпоинты:

```
GET  /health
GET  /auth/telegram/start
GET  /auth/telegram/callback
POST /auth/token
POST /auth/refresh
POST /auth/apple
POST /auth/logout
GET  /v1/me
PATCH /v1/me
DELETE /v1/me                 # удаление аккаунта
POST /v1/sync                 # batch: events, likes, playlists
GET  /v1/sync?since=...
GET  /v1/releases?artistIDs=...
POST /v1/soundcloud/token
POST /v1/lastfm/...           # подпись shared secret на сервере
```

D1-схема: users, identities, refresh_tokens, telegram_states, one_time_codes, provider_tokens, devices, release_subscriptions.

Безопасность: rate limit, PKCE, state, JWT signing key в secrets, refresh-токены хэшированные, provider tokens шифруются AES-GCM, PII не логируется.

### 8.6 App Store

- Sign in with Apple.
- Удаление аккаунта в приложении.
- Privacy manifest `PrivacyInfo.xcprivacy`.
- Никакого трекинга без ATT; аналитика — opt-in, локальная.
- Не риппим чужой контент; YouTube — off by default.

---

## 9. Экраны

### 9.1 Home

Файл: `AeroCloud/Features/Home/HomeView.swift`.

- `ScrollView` + `LazyVStack(spacing: 24)`.
- Header: «Добрый вечер» + дата + аватар.
- `WaveHeroCard` 340×220: mesh, waveform, AE Wave, текущий пресет, play, «Настроить».
- «Продолжить» — `LazyHStack`, карточки 160×160, parallax.
- «Новинки от ваших артистов» — горизонтальные карточки 180×220.
- «Для вас» — 2-колоночная сетка, reason-чипы.
- «Настроения» — 8 пресетов, горизонтальный скролл.
- Skeleton при загрузке, pull-to-refresh, offline banner.

### 9.2 Search

Файл: `AeroCloud/Features/Search/SearchView.swift`.

- Large title, glass search field.
- Glass-меню «Искать в: Все ▾» с multi-select источников.
- Debounce 300 мс, отмена.
- История + подсказки (Last.fm) + чипы.
- Сегменты: Треки / Альбомы / Исполнители / Плейлисты.
- `TrackRow` с бейджами; merged group раскрывается в варианты.
- Empty state с жанровыми плитками.

### 9.3 Wave

Файл: `AeroCloud/Features/Wave/WaveView.swift`.

- Полноэкранная лента: крупная обложка 320, название, артист, reason-чип.
- Like/dislike, «В очередь», «Не похоже».
- Кнопка «Настроить вайб» → `VibeSheet`.
- Прогресс ленты, «Дальше».
- Анимация смены трека: карточка уезжает вверх, новая въезжает, spring 0.45/0.8.

### 9.4 Player

Файл: `AeroCloud/Features/Player/PlayerOverlay.swift`.

- Root overlay, `matchedGeometryEffect(id: "artwork")`.
- Фон — доминирующий цвет обложки + mesh, blur 40.
- Обложка 320, corner 28, shadow, pulse при игре.
- Waveform 64 бара, 64 pt, scrub по drag.
- Прогресс, время, транспорт.
- Вторичные: like, download, share, EQ, sleep, lyrics (если есть), queue.
- Queue sheet: drag-to-reorder, swipe delete.
- Свайп вниз — закрытие, интерактивное.
- Reduce Motion — crossfade вместо полёта.

### 9.5 Library

Файл: `AeroCloud/Features/Library/LibraryView.swift`.

- Glass-сегменты: Плейлисты / Альбомы / Исполнители / Треки / Скачано.
- Grid/list toggle, sort menu.
- Playlist detail: hero из обложки, play/shuffle, редактирование.
- «Мне нравится», «Недавно прослушанные», «Топ-5», downloads.

### 9.6 Profile

Файл: `AeroCloud/Features/Profile/ProfileView.swift`.

- Гость: glass-карточка с Telegram/Apple, «Продолжить как гость».
- Аккаунт: аватар, имя, @username, статистика (минуты, треки, артисты, streak), топ-жанры (bar chart), топ-артисты, heatmap 12 недель.
- Настройки, выход, удаление аккаунта.

### 9.7 Settings

Файл: `AeroCloud/Features/Settings/SettingsView.swift`.

- Аккаунт, источники (connect/disconnect, статус, capabilities), качество, загрузки, воспроизведение (crossfade, gapless, EQ, normalize), внешний вид (тема, reduce motion, glass intensity), приватность, о приложении/лицензии.

### 9.8 VibeSheet

Файл: `AeroCloud/Features/Wave/VibeSheet.swift`.

- `.presentationDetents([.medium, .large])`, corner 36, `.presentationBackground(.clear)`.
- Пресеты, 8 слайдеров, язык, «Собрать волну».
- Изменения debounce 400 мс; текущий трек не прерывается.
- Glass-карточка внутри sheet.

### 9.9 AuthSheet

Файл: `AeroCloud/Features/Auth/AuthSheet.swift`.

- Логотип, Telegram primary, Apple secondary, guest.
- Loading/error states.
- После успеха — merge progress.

### 9.10 Навигация и deep links

- `AppCoordinator` с `paths: [Tab: NavigationPath]`.
- `AppRoute`: artist, album, playlist, trackGroup, settings, downloads, vibeEditor, auth.
- Deep links: `aerocloud://auth/telegram`, `aerocloud://track/{source}/{id}`, `aerocloud://playlist/{id}`, `aerocloud://wave?vibe=night-drive`.
- Universal Links `https://aerocloud.app/t/...` для шаринга.
- Восстановление таба/стека/очереди/позиции.

---

## 10. Дополнительно

### 10.1 Виджеты

- AE Wave — small, кнопка Play.
- «Сейчас играет» — medium, обложка, прогресс, play/pause.
- «Топ-5» — medium, список.
- Данные — `WidgetSnapshot.json` в App Group; обновление по timeline + после изменений.

### 10.2 Live Activity

- Compact: обложка + прогресс.
- Minimal: иконка.
- Expanded: обложка, название, прогресс, транспорт.
- Обновление из `PlaybackCoordinator`; артворк — downsample в App Group.

### 10.3 App Intents / Siri

- `PlayMyWaveIntent`, `PauseIntent`, `NextIntent`, `SearchIntent`.
- `AppShortcutsProvider` с фразами на ru/en.
- Интенты вызывают те же сервисы, без второго состояния.

### 10.4 CarPlay

- `CarPlaySceneDelegate` + `CPTemplate` за флагом `AEROCLOUD_CARPLAY`.
- Требует entitlement `com.apple.developer.carplay-music`, который Apple выдаёт не всем.
- В сборке по умолчанию выключено; в `docs/LEGAL.md` — как запрашивать.

### 10.5 Уведомления о релизах

- Backend `/v1/releases` + APNs.
- Opt-in в Settings.
- Локальные уведомления, если push недоступен.

### 10.6 Шаринг

- `ShareLink` с universal link на трек/плейлист.
- OG-страница на backend (можно позже).

### 10.7 Локализация

- `Localizable.xcstrings` (ru/en), `InfoPlist.xcstrings`.
- Все строки через `String(localized:)`/`LocalizedStringKey`.
- Комментарии в коде — на русском (по заданию), UI-строки — только в каталоге.

### 10.8 Тесты и CI

- Unit: рекомендации, дедупликация, парсеры, PKCE, очередь, EQ, кроссфейд.
- Snapshot: `swift-snapshot-testing` — TrackRow, MiniPlayer, VibeSlider, GlassCard, Home skeleton, Player.
- UI: guest → demo → play → player → vibe → skip 3 → проверить adaptation через debug inspector.
- CI: macOS + Xcode 27.1, `xcodebuild test`, `xcodebuild build`, warnings-as-errors для своих таргетов, кэш SPM.
- Если GitHub-раннер без Xcode 27 — self-hosted macOS или скрипт с явной ошибкой.

---

## 11. Roadmap

| Фаза | Срок | Что делаем | Критерий готовности |
|---|---|---|---|
| 0. Каркас | 0.5–1 день | `project.yml`, XcodeGen, пакеты, конфиги, `.gitignore`, лицензии, CI, пустой app с табами | `xcodebuild` собирает, 0 warning, Swift 6 strict |
| 1. Дизайн-система | 2 дня | Токены, AuroraBackground, GlassCard, AeroButton, TrackRow, SourceBadge, WaveformView, VibeSlider, Skeleton, ErrorToast, галерея компонентов | Галерея в ru/en, Dynamic Type, Reduce Motion; snapshot-эталоны |
| 2. Ядро | 2 дня | Модели, `MusicProvider`, `ProviderRegistry`, HTTPClient, PKCE, SwiftData, репозитории, дедупликатор, DemoProvider | Unit-тесты зелёные; demo-поиск и merge работают |
| 3. Плеер | 3–4 дня | AudioStreaming dual-deck, EQ, tap→waveform, очередь, shuffle/repeat, crossfade/gapless, sleep, Now Playing iOS 27, Live Activity | Demo-трек играет в фоне, lock screen, waveform, EQ, очередь |
| 4. Экраны | 3 дня | Shell, координаторы, Home/Search/Library/Profile/Settings/Auth UI на mock-данных | Все экраны кликабельны, skeleton/empty states, VoiceOver |
| 5. Провайдеры | 3–4 дня | Apple Music, Spotify PKCE, SoundCloud OAuth, Deezer, Last.fm, YouTube (флаг), единый поиск, source picker | Поиск по 3 источникам, частичные ошибки не ломают UI, токены обновляются |
| 6. Аккаунты | 3 дня | Cloudflare Worker, Telegram, Apple, JWT, Keychain, guest merge, статистика | Telegram end-to-end на устройстве, сессия переживает перезапуск, logout/delete |
| 7. AE Wave | 4–5 дней | Фичи, эвристики, CF, гибрид, ε-greedy, MMR, адаптация, объяснения, пресеты, лента, оффлайн-кэш, Wave/Vibe UI | 3 скипа → энергия ниже; лайк → похожие; no-repeat; reason-чипы |
| 8. Extras | 3 дня | Виджеты, Live Activity polish, App Intents, share, релизы, CarPlay (флаг), EQ UI, темы, локализация, доступность | Виджеты и Siri работают; ru/en; accessibility audit |
| 9. Полировка | 2 дня | Перформанс, анимации, snapshot, HIG-аудит, legal docs, README, demo | Launch < 1.5 с, 120 fps, memory < 250 МБ, CI зелёный |

Итого: ~25–30 рабочих дней. Дробить буду по фазам; после каждой — отчёт и подтверждение.

---

## 12. Риски и mitigation

| Риск | Вероятность | Mitigation |
|---|---|---|
| Нет macOS/Xcode 27 локально | 100% | CI на macOS + ваша финальная сборка; код по документированным API |
| iOS 27 NowPlaying API новый | средняя | адаптер `NowPlayingPublishing`, один файл; fake для тестов; сверка по SDK |
| SoundCloud API закрыт для новых apps | высокая | провайдер включается при наличии ключей; DemoProvider; честный `unavailable` |
| Spotify не даёт полный стрим | 100% | preview + Spotify Connect; явный бейдж; не обещаем невозможное |
| YouTube Music ToS/App Review | высокая | off by default, proxy-абстракция, отдельная сборка, legal warning |
| AudioStreaming заброшен | низкая | MIT, обёрнут в протокол; fallback — dual AVPlayer |
| Apple Music DRM | 100% | отдельный engine; synthetic waveform; EQ/crossfade disabled |
| App Store 4.8 / 5.1.1(v) | средняя | Sign in with Apple, удаление аккаунта, privacy manifest |
| Сложность matched geometry | средняя | custom shell, один namespace; fallback — zoom transition |
| Размер проекта | высокая | фазы, приоритеты, demo-режим без ключей |

---

## 13. Что нужно подтвердить / предоставить

### Подтвердить

1. **База:** Beans-Music как донор идей + greenfield AeroCloud (рекомендую) — или форк другого репозитория.
2. **iOS:** только 27.0 + новый NowPlaying framework (рекомендую) — или 26+ с legacy MediaPlayer fallback.
3. **Таб-бар:** кастомный glass shell с морфингом и matched geometry (рекомендую для эффекта) — или нативный iOS 27 TabView.
4. **Backend:** Cloudflare Worker + D1 (рекомендую) — или Node/Fastify, или пока mock.
5. **Тема:** только тёмная в v1 (рекомендую) — или сразу light+dark.
6. **Demo-каталог:** включить CC0-треки, чтобы приложение играло без ключей (рекомендую).

### Предоставить (когда дойдём до соответствующей фазы)

- Apple Developer Team ID, bundle ID, App Group.
- Telegram bot username + token (в Cloudflare secrets), домен для Login Widget.
- Spotify Client ID (PKCE, без secret).
- SoundCloud Client ID/secret (если есть доступ к API).
- Last.fm API key/shared secret.
- Deezer App ID (опционально).
- Mac с Xcode 27.1 или доступ к macOS CI-раннеру.

---

## 14. Что будет первым после подтверждения

**Фаза 0 + Фаза 1:**

- `project.yml`, `Config/*.xcconfig`, `.gitignore`, `README.md`, `LICENSE`, `THIRD_PARTY_NOTICES.md`;
- `Packages/AeroCloudCore`, `AeroCloudUI`, `AeroCloudPlayer`, `AeroCloudRecommendations`, `AeroCloudAuth`, `AeroCloudProviders` — скелеты `Package.swift`;
- `AeroCloud/App/AeroCloudApp.swift`, `AppShell.swift`, `AeroTabBar.swift`;
- дизайн-токены, `AuroraBackground`, `GlassCard`, `AeroButton`, `GlowButtonStyle`, `TrackRow`, `SourceBadge`, `WaveformView`, `VibeSlider`, `Skeleton`, `ErrorToast`;
- debug-галерея компонентов;
- CI workflow.

Покажу полные файлы и список путей. Дальше — Фаза 2 (ядро), и так далее.
