#!/usr/bin/env python3
"""Bootstrap the AeroCloud String Catalog.

Xcode is the source of truth after the first edit; this script exists so the
initial catalog can be regenerated deterministically.
"""

from __future__ import annotations

import json
from pathlib import Path

STRINGS: dict[str, tuple[str, str]] = {
    "app.name": ("AeroCloud", "AeroCloud"),
    "tab.home": ("Home", "Главная"),
    "tab.search": ("Search", "Поиск"),
    "tab.wave": ("AE Wave", "AE Wave"),
    "tab.library": ("Library", "Библиотека"),
    "tab.profile": ("Profile", "Профиль"),
    "home.greeting.evening": ("Good evening", "Добрый вечер"),
    "home.continue": ("Continue", "Продолжить"),
    "home.moods": ("Moods", "Настроения"),
    "home.wave.title": ("Your wave", "Ваша волна"),
    "home.wave.subtitle": ("Tuned for the evening", "Подстроено под вечер"),
    "home.wave.play": ("Play", "Слушать"),
    "home.wave.tune": ("Tune", "Настроить"),
    "profile.open": ("Open profile", "Открыть профиль"),
    "common.more": ("More", "Ещё"),
    "common.seeAll": ("See all", "Все"),
    "common.close": ("Close", "Закрыть"),
    "common.open": ("Open", "Открыть"),
    "common.retry": ("Retry", "Повторить"),
    "common.source": ("Source:", "Источник:"),
    "waveform.active": ("Active sound wave", "Активная звуковая волна"),
    "waveform.idle": ("Sound wave", "Звуковая волна"),
    "mood.evening": ("Evening", "Вечер"),
    "mood.focus": ("Focus", "Фокус"),
    "mood.workout": ("Workout", "Спорт"),
    "mood.rain": ("Rain", "Дождь"),
    "mood.night": ("Night", "Ночь"),
    "mood.sunrise": ("Sunrise", "Рассвет"),
    "placeholder.search.title": ("Search", "Поиск"),
    "placeholder.search.subtitle": (
        "Unified search across sources arrives in Phase 4.",
        "Единый поиск по источникам появится в Phase 4.",
    ),
    "placeholder.library.title": ("Library", "Библиотека"),
    "placeholder.library.subtitle": (
        "Playlists, albums, artists and downloads arrive in Phase 4.",
        "Плейлисты, альбомы, исполнители и скачанное появятся в Phase 4.",
    ),
    "placeholder.profile.title": ("Profile", "Профиль"),
    "placeholder.profile.subtitle": (
        "Telegram, Apple ID, guest mode and stats arrive in Phase 6.",
        "Telegram, Apple ID, гостевой режим и статистика появятся в Phase 6.",
    ),
    "wave.title": ("AE Wave", "AE Wave"),
    "wave.subtitle": (
        "Mood, energy and freshness in one stream.",
        "Настроение, энергия и новизна — в одном потоке.",
    ),
    "wave.reason": (
        "Similar to your evening tracks",
        "Похоже на ваши вечерние треки",
    ),
    "wave.vibe": ("Tune the vibe", "Настроить вайб"),
    "wave.reset": ("Reset", "Сбросить"),
    "wave.energy": ("Energy", "Энергия"),
    "wave.calm": ("Calm", "Спокойно"),
    "wave.intense": ("Intense", "Интенсивно"),
    "wave.mood": ("Mood", "Настроение"),
    "wave.melancholy": ("Melancholy", "Меланхолия"),
    "wave.joyful": ("Joy", "Радость"),
    "wave.freshness": ("Freshness", "Новизна"),
    "wave.familiar": ("Familiar", "Знакомое"),
    "wave.fresh": ("Fresh", "Новое"),
    "player.shuffle": ("Shuffle", "Перемешать"),
    "player.play": ("Play", "Играть"),
    "player.pause": ("Pause", "Пауза"),
    "player.open": ("Open player", "Открыть плеер"),
    "player.previous": ("Previous", "Предыдущий"),
    "player.next": ("Next", "Следующий"),
    "player.repeat": ("Repeat", "Повтор"),
    "player.nowPlaying": ("Now playing", "Сейчас играет"),
    "player.close": ("Close player", "Закрыть плеер"),
    "player.like": ("Like", "Нравится"),
    "player.download": ("Download", "Скачать"),
    "player.share": ("Share", "Поделиться"),
    "player.queue": ("Queue", "Очередь"),
    "gallery.title": ("Design system", "Дизайн-система"),
    "gallery.subtitle": (
        "Liquid Glass · iOS 27 · Phase 1",
        "Liquid Glass · iOS 27 · Phase 1",
    ),
    "gallery.colors": ("Colors", "Цвета"),
    "gallery.typography": ("Typography", "Типографика"),
    "gallery.buttons": ("Buttons", "Кнопки"),
    "gallery.button.primary": ("Primary", "Основная"),
    "gallery.button.secondary": ("Secondary", "Вторичная"),
    "gallery.button.ghost": ("Ghost", "Ghost"),
    "gallery.button.delete": ("Delete", "Удалить"),
    "gallery.glass": ("Liquid Glass", "Liquid Glass"),
    "gallery.glass.title": ("Glass and light", "Стекло и свет"),
    "gallery.glass.body": (
        "Material, edge and shadow work together.",
        "Материал, кант и тень работают вместе.",
    ),
    "gallery.tracks": ("Tracks", "Треки"),
    "gallery.sources": ("Sources", "Источники"),
    "gallery.waveform": ("Waveform", "Waveform"),
    "gallery.vibe": ("Vibe", "Вайб"),
    "gallery.vibe.energy": ("Energy", "Энергия"),
    "gallery.vibe.low": ("Lower", "Ниже"),
    "gallery.vibe.high": ("Higher", "Выше"),
    "gallery.vibe.mood": ("Mood", "Настроение"),
    "gallery.vibe.melancholy": ("Melancholy", "Меланхолия"),
    "gallery.vibe.joyful": ("Joy", "Радость"),
    "gallery.loading": ("Loading", "Загрузка"),
    "gallery.feedback": ("Feedback", "Обратная связь"),
    "gallery.feedback.show": ("Show toast", "Показать тост"),
    "gallery.miniPlayer": ("Mini player", "Мини-плеер"),
    "gallery.tabBar": ("Tab bar", "Таб-бар"),
    "gallery.footer": (
        "AeroCloud · Phase 1 · Design System",
        "AeroCloud · Phase 1 · Design System",
    ),
}


def unit(value: str) -> dict:
    return {
        "stringUnit": {
            "state": "translated",
            "value": value,
        }
    }


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    output = root / "AeroCloud" / "Resources" / "Localizable.xcstrings"
    output.parent.mkdir(parents=True, exist_ok=True)

    catalog = {
        "sourceLanguage": "en",
        "strings": {
            key: {
                "localizations": {
                    "en": unit(en),
                    "ru": unit(ru),
                }
            }
            for key, (en, ru) in STRINGS.items()
        },
        "version": "1.0",
    }

    output.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(STRINGS)} keys to {output}")


if __name__ == "__main__":
    main()
