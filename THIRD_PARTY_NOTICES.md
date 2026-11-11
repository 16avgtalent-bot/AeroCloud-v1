# Third-Party Notices

AeroCloud — greenfield-проект. Сторонний код используется только там, где это
явно указано ниже.

## Design / product reference

### Beans-Music

- Repository: <https://github.com/XIaodou0416/Beans-Music>
- License: MIT
- Copyright: XIaodou0416 and contributors
- Usage: **только продуктовый и визуальный референс**. Код не копировался;
  AeroCloud написан с нуля под iOS 27, Swift 6 и собственную архитектуру.

## Planned dependencies (ещё не подключены)

Эти пакеты появятся в следующих фазах. Перед добавлением в `project.yml`
проверяется актуальная версия и лицензия.

| Пакет | Назначение | Лицензия | Фаза |
|---|---|---|---|
| [AudioStreaming](https://github.com/dimitris-c/AudioStreaming) | AVAudioEngine dual-deck | MIT | 3 |
| [Nuke](https://github.com/kean/Nuke) / NukeUI | загрузка и кэш обложек | MIT | 2–3 |
| [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) | snapshot-тесты | MIT | 9 |

## Demo catalog

Demo-треки будут добавлены в Phase 2 из источников с лицензиями CC0/CC-BY.
Для каждого трека фиксируются:

- название, автор, источник;
- лицензия и ссылка на оригинал;
- дата добавления.

До появления каталога UI использует статические `DemoTracks` без аудиофайлов.

## Apple frameworks

Apple Music, MusicKit, StoreKit, SwiftUI, SwiftData, AVFoundation, WidgetKit,
ActivityKit и связанные технологии — собственность Apple Inc. Использование
регулируется Apple Developer Program License Agreement.
