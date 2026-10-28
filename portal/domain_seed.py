from datetime import date, time, timedelta
from portal.models import Quest, Slot, Variation

QUESTS = [
    ('Тайна заброшенного бункера','Исследуйте заброшенный объект и расшифруйте сигналы из подземелья.'),
    ('Побег из лаборатории','Найдите выход из секретного комплекса раньше, чем завершится эксперимент.'),
    ('Проклятие старого особняка','Разгадайте историю дома, в котором каждый предмет хранит тайну.'),
]
MODES = ['Стандартный','С актерами','Ночной режим']


def prepare(today):
    for name, summary in QUESTS:
        quest, _ = Quest.objects.get_or_create(name=name, defaults={'summary':summary})
        for mode in MODES:
            Variation.objects.get_or_create(quest=quest, name=mode)
        days = [date(2026, 10, 24)+timedelta(days=i) for i in range(19)]
        days.extend(today+timedelta(days=i) for i in range(61))
        Slot.objects.bulk_create(
            [Slot(quest=quest, day=day, time=time(hour)) for day in sorted(set(days)) for hour in (12,15,18,21)],
            ignore_conflicts=True)


def attributes(index, today):
    name = QUESTS[index%3][0]
    day = date(2026,10,24)+timedelta(days=index//3)
    mode = MODES[(index//3)%3]
    return dict(slot=Slot.objects.get(quest__name=name, day=day, time=time(18)),
                variation=Variation.objects.get(quest__name=name, name=mode),
                participants=2+index%5, payment='card' if index%2 else 'cash')
