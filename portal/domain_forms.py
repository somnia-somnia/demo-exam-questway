from django import forms
from portal.booking import Schedule
from portal.forms import SubmissionFormBase
from portal.models import Quest, Slot, Submission, Variation


class SubmissionForm(SubmissionFormBase):
    quest = forms.ModelChoiceField(Quest.objects.none(), label='Квест', empty_label='Выберите квест')
    variation = forms.ModelChoiceField(Variation.objects.none(), label='Вариация', empty_label='Выберите вариацию')
    slot = forms.ModelChoiceField(Slot.objects.none(), label='Время', empty_label='Выберите время',
        error_messages={'invalid_choice':'Это время недоступно. Выберите другой интервал.'})
    participants = forms.IntegerField(label='Количество участников', min_value=1, max_value=30,
        widget=forms.NumberInput(attrs={'placeholder':'Например, 4'}))

    class Meta:
        model = Submission
        fields = ('quest','variation','day','slot','participants','payment')
        labels = {'payment':'Способ оплаты'}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        quests = Quest.objects.filter(active=True).order_by('pk')
        self.fields['quest'].queryset = quests
        raw = self.data.get('quest') if self.is_bound else self.initial.get('quest')
        quest = quests.filter(pk=raw).first() if raw and str(raw).isascii() and str(raw).isdigit() and len(str(raw)) < 18 else None
        if quest:
            self.fields['variation'].queryset = Variation.objects.filter(quest=quest, active=True).order_by('pk')
            self.fields['slot'].queryset = Schedule.upcoming().filter(quest=quest)

    def clean(self):
        values = super().clean()
        quest, day, slot = (values.get(key) for key in ('quest','day','slot'))
        if quest and day and slot and not Schedule.free(quest, day).filter(pk=slot.pk).exists():
            self.add_error('slot', 'Это время недоступно. Выберите другой интервал.')
        return values
