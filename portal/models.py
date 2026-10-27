from django.db import models
from portal.core_models import Member, Review, BaseSubmission
from portal.site import SITE

PAYMENTS = [('cash','Наличными'), ('card','Банковской картой')]


class Quest(models.Model):
    name = models.CharField(max_length=120, unique=True)
    summary = models.CharField(max_length=300)
    active = models.BooleanField(default=True)

    def __str__(self):
        return self.name


class Variation(models.Model):
    quest = models.ForeignKey(Quest, on_delete=models.PROTECT, related_name='variations')
    name = models.CharField(max_length=80)
    active = models.BooleanField(default=True)

    class Meta:
        constraints = [models.UniqueConstraint(fields=['quest','name'], name='unique_variation_name')]

    def __str__(self):
        return self.name


class Slot(models.Model):
    quest = models.ForeignKey(Quest, on_delete=models.PROTECT, related_name='slots')
    day = models.DateField()
    time = models.TimeField()

    class Meta:
        ordering = ['day','time']
        constraints = [models.UniqueConstraint(fields=['quest','day','time'], name='unique_quest_time')]

    def __str__(self):
        return self.time.strftime('%H:%M')


class Submission(BaseSubmission):
    variation = models.ForeignKey(Variation, on_delete=models.PROTECT, related_name='bookings')
    slot = models.ForeignKey(Slot, on_delete=models.PROTECT, related_name='bookings')
    participants = models.PositiveIntegerField()
    payment = models.CharField(max_length=8, choices=PAYMENTS)
    reason = models.CharField(max_length=500, blank=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['slot'], condition=~models.Q(status='cancelled'), name='one_booking_per_live_slot'),
            models.CheckConstraint(condition=models.Q(status__in=[key for key, _ in SITE.statuses]), name='valid_quest_status'),
            models.CheckConstraint(condition=(models.Q(status='cancelled') & ~models.Q(reason='')) |
                (~models.Q(status='cancelled') & models.Q(reason='')), name='reason_only_for_cancellation'),
            models.CheckConstraint(condition=models.Q(participants__gte=1, participants__lte=30), name='valid_team_size'),
        ]

    @property
    def title(self):
        return self.slot.quest.name

    @property
    def details(self):
        return [('Вариация', self.variation.name), ('Дата и время', f'{self.slot.day:%d.%m.%Y} · {self.slot.time:%H:%M}'),
                ('Участники', self.participants), ('Оплата', self.get_payment_display())]

    @property
    def note(self):
        return f'Причина отмены: {self.reason}' if self.reason else ''
