from django.db.models import Exists, OuterRef, Q
from django.utils import timezone
from portal.models import Slot, Submission


class Schedule:
    @staticmethod
    def upcoming():
        now = timezone.localtime()
        future = Q(day__gt=now.date()) | Q(day=now.date(), time__gt=now.time())
        return Slot.objects.filter(future, quest__active=True)

    @classmethod
    def free(cls, quest, day):
        live_booking = Submission.objects.filter(slot_id=OuterRef('pk')).exclude(status='cancelled')
        return cls.upcoming().filter(quest=quest, day=day).filter(~Exists(live_booking))
