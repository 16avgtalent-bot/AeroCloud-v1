# AeroCloud

Персональный iOS-плеер с мультиисточниками и рекомендательным движком **AE Wave**.

> Статус: **Phase 0 + Phase 1** — каркас и дизайн-система написаны;
> первая сборка и визуальная проверка выполняются через Codemagic или macOS с Xcode 27.1.
> Полный план: [`docs/PLAN.md`](docs/PLAN.md).

## Требования

- macOS с **Xcode 27.1** (iOS 27 SDK, Swift 6).
- iOS 27 Simulator или устройство.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) 2.44+.
- Для CI: macOS runner с установленным Xcode 27.1.

Проект **не собирается на Windows**. В репозитории есть CI-конфигурация для macOS.

## Быстрый старт

```bash
cd AeroCloud

# 1. Локальные секреты (файл в .gitignore)
cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
# открой Config/Secrets.xcconfig и заполни DEVELOPMENT_TEAM и ключи

# 2. Генерация Xcode-проекта
brew install xcodegen
xcodegen generate

# 3. Запуск
open AeroCloud.xcodeproj
```

В Xcode выбери схему `AeroCloud`, симулятор iPhone с iOS 27 и запусти.

## Сборка без Mac: Codemagic

Codemagic использует облачные macOS-машины, поэтому Xcode локально не нужен.
Нужен git-репозиторий на GitHub, GitLab или Bitbucket.

1. Запушь папку `AeroCloud` (корень с `project.yml`) в репозиторий.
2. Убедись, что `codemagic.yaml` лежит **в корне репозитория**, а не внутри
   вложенной папки `AeroCloud/`. Конфиг умеет сам находить `project.yml`
   как в корне, так и в подпапке `AeroCloud/`.
3. В Codemagic подключи репозиторий и нажми `Check for configuration files`.
4. Запусти workflow `ios-simulator`.

Что делает workflow:

- ставит XcodeGen и SwiftFormat;
- прогоняет `scripts/validate.py` и `scripts/check_strings.py`;
- запускает unit-тесты `AeroCloudCore`;
- генерирует `.xcodeproj` и собирает unsigned simulator build;
- запускает приложение с `-designGallery`;
- сохраняет `gallery.png` и `.app`/`.zip` как artifacts.

Для симулятора Apple Developer аккаунт не нужен: сборка идёт с
`CODE_SIGNING_ALLOWED=NO`. Для устройства и TestFlight понадобятся
Apple Developer, сертификаты и code signing в Codemagic.

Если в Codemagic ещё нет Xcode 27.1, поменяй `environment.xcode` в
`codemagic.yaml` на доступную 27.x или `latest` и проверь наличие iOS 27 SDK.

### Что уже можно посмотреть

- `AeroCloud/App/AppShell.swift` — кастомный glass-shell с таб-баром и мини-плеером.
- `AeroCloud/Features/Home/HomePreviewView.swift` — статичный Home на demo-данных.
- `AeroCloud/Features/Debug/DesignSystemGalleryView.swift` — галерея компонентов.
- В Xcode: Product → Scheme → Edit Scheme → Run → Arguments → добавь `-designGallery`,
  чтобы открыть галерею при запуске.

## Capabilities в Apple Developer

Перед первым запуском на устройстве включи в App ID `app.aerocloud.ios`:

| Capability | Зачем | Где |
|---|---|---|
| Sign in with Apple | вход через Apple ID | App ID → Sign in with Apple |
| App Groups `group.app.aerocloud` | виджеты, Live Activity, общий кэш | App ID + target → App Groups |
| Associated Domains `applinks:aerocloud.app` | universal links и возврат из Telegram | App ID + target → Associated Domains |
| Push Notifications | уведомления и Live Activity | App ID + target → Push Notifications |
| MusicKit | Apple Music playback | App ID → App Services → MusicKit |
| Background Modes → Audio | фоновая игра и lock screen | target → Signing & Capabilities |

MusicKit **не** добавляет entitlement-ключ в `AeroCloud.entitlements`: Apple
регистрирует сервис на уровне App ID. В коде достаточно `NSAppleMusicUsageDescription`
и авторизации MusicKit в Phase 5.

Entitlements уже лежат в `Config/AeroCloud.entitlements`. Для симулятора можно
собирать с `CODE_SIGNING_ALLOWED=NO`; для устройства нужен `DEVELOPMENT_TEAM`
и включённые capabilities.

## Секреты

- В репозиторий не попадают: `Config/Secrets.xcconfig`, токены, сертификаты, `.p8`, `.p12`.
- `TELEGRAM_BOT_TOKEN` хранится **только** в Cloudflare Worker secrets.
- Клиентские идентификаторы (Spotify Client ID, SoundCloud Client ID, Last.fm API key,
  Deezer App ID) не являются секретами в строгом смысле, но всё равно вынесены в xcconfig.
- `AEROCLOUD_BACKEND_URL` подставляется в `Info.plist`; пустое значение означает
  «backend не настроен», UI должен показывать понятное состояние.

Подробнее — в [`docs/PLAN.md`](docs/PLAN.md), раздел 12.

## Структура

```text
AeroCloud/
├── AeroCloud/                     # app target
│   ├── App/                       # entry point, shell, tab bar
│   ├── Features/                  # Home / Player / Debug
│   └── Resources/                 # Assets, String Catalog, Privacy Manifest
├── Config/                        # xcconfig, entitlements
├── Packages/
│   ├── AeroCloudCore/             # models, contracts, utilities
│   ├── AeroCloudUI/               # design system, Liquid Glass components
│   ├── AeroCloudPlayer/           # playback engine (Phase 3)
│   ├── AeroCloudRecommendations/  # AE Wave engine (Phase 7)
│   ├── AeroCloudAuth/             # Telegram / Apple / Keychain (Phase 6)
│   └── AeroCloudProviders/        # Apple Music, Spotify, SoundCloud, ... (Phase 5)
├── Tests/
├── docs/PLAN.md
├── project.yml
├── codemagic.yaml
└── .github/workflows/ci.yml
```

## Дизайн-токены

| Токен | Значение |
|---|---|
| Background | `#0A1628` |
| Accent start | `#00D4FF` |
| Accent end | `#0066FF` |
| Text primary | `#F0F4FF` |
| Text secondary | `#F0F4FF` @ 64% |
| Text tertiary | `#F0F4FF` @ 40% |
| Card radius | 28 pt |
| Button radius | 18 pt |
| Spring tab | response 0.32, damping 0.78 |
| Spring player | response 0.48, damping 0.82 |

Токены: `Packages/AeroCloudUI/Sources/AeroCloudUI/Tokens/`.

## Тесты

```bash
swift test --package-path Packages/AeroCloudCore
```

Пакетные тесты используют Swift Testing. Snapshot-тесты появятся в Phase 9,
когда будут доступны macOS/Xcode для записи эталонов.

## CI

`.github/workflows/ci.yml`:

1. выбирает Xcode 27.1;
2. генерирует проект через XcodeGen;
3. собирает app target для generic iOS Simulator без подписи;
4. запускает тесты `AeroCloudCore`.

Если Xcode 27.1 ещё не установлен на runner — job падает с явной ошибкой,
это ожидаемо до обновления CI-образа.

## Юридические ограничения

- YouTube Music **выключен по умолчанию**; включение — только осознанно, с предупреждением.
- Spotify: полноценный streaming недоступен сторонним клиентам; используем preview
  и Spotify Connect, если пользователь авторизован.
- SoundCloud API имеет ограничения; часть треков будет недоступна для playback.
- Приложение не риппит контент и не обходит DRM.
- Last.fm требует attribution; логотипы и названия принадлежат правообладателям.
- Demo-каталог будет собран из CC0/CC-BY треков с указанием лицензий
  в `THIRD_PARTY_NOTICES.md`.

## Лицензия

MIT. См. [`LICENSE`](LICENSE).
