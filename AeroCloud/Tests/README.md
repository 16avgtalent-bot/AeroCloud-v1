# Tests

Пока здесь нет app test target: Phase 1 проверяется через Xcode Previews и
`DesignSystemGalleryView`. Пакетные unit-тесты лежат рядом с кодом:

```bash
swift test --package-path Packages/AeroCloudCore
```

Планируется:

- Phase 2 — unit-тесты `MusicProvider`, дедупликатора и репозиториев;
- Phase 3 — тесты очереди, crossfade/gapless и EQ;
- Phase 7 — детерминированные тесты AE Wave (фиксированный seed);
- Phase 9 — snapshot-эталоны для ru/en, Dynamic Type и Reduce Motion.
