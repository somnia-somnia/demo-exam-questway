from datetime import date, time, timedelta
from portal.models import Quest, Slot, Variation

QUESTS = [
    ('Тайна заброшенного бункера','Исследуйте заброшенный объект и расшифруйте сигналы из подземелья.'),
    ('Побег из лаборатории','Найдите выход из секретного комплекса раньше, чем завершится эксперимент.'),
    ('Проклятие старого особняка','Разгадайте историю дома, в котором каждый предмет хранит тайну.'),
]
MODES = ['Стандартный','С актерами','Ночной режим']
ARCHIVED_QUESTS = [
    ('Код полярной станции','Сезонная игра о восстановлении связи с экспедицией.'),
    ('Последний рейс','Временный сценарий о поиске пропавшего багажа.'),
    ('Архив часовщика','Закрытая выставочная игра с механическими головоломками.'),
]


def prepare(today):
    # Demo fixture IDs stay stable when an administrator edits display names.
    for key, (name, summary) in enumerate(QUESTS, 1):
        quest, created = Quest.objects.get_or_create(pk=key, defaults={'name':name,'summary':summary})
        if created:
            Variation.objects.bulk_create([Variation(quest=quest, name=mode) for mode in MODES])
        if not quest.active:
            continue
        days = [date(2026, 10, 24)+timedelta(days=i) for i in range(19)]
        days.extend(today+timedelta(days=i) for i in range(61))
        Slot.objects.bulk_create(
            [Slot(quest=quest, day=day, time=time(hour)) for day in sorted(set(days)) for hour in (12,15,18,21)],
            ignore_conflicts=True)
    for key, (name, summary) in enumerate(ARCHIVED_QUESTS, len(QUESTS)+1):
        Quest.objects.get_or_create(pk=key, defaults={'name':name,'summary':summary,'active':False})


def attributes(index, today):
    name = QUESTS[index%3][0]
    day = date(2026,10,24)+timedelta(days=index//3)
    mode = MODES[(index//3)%3]
    return dict(slot=Slot.objects.get(quest__name=name, day=day, time=time(18)),
                variation=Variation.objects.get(quest__name=name, name=mode),
                participants=2+index%5, payment='card' if index%2 else 'cash')
