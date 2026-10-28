from datetime import datetime
from django import forms
from django.contrib import messages
from django.db import transaction
from django.http import JsonResponse, HttpResponseBadRequest
from django.shortcuts import get_object_or_404, redirect, render
from django.views import View
from portal.booking import Schedule
from portal.forms import StyledForm
from portal.models import Quest, Slot, Variation
from portal.security import AdminRequired, MemberRequired


class Availability(MemberRequired, View):
    def get(self, request):
        raw = request.GET.get('quest','')
        if not raw.isascii() or not raw.isdigit() or len(raw)>17:
            return JsonResponse({'variations':[], 'slots':[]})
        quest = get_object_or_404(Quest, pk=raw, active=True)
        day = request.GET.get('day','')
        try:
            parsed = datetime.strptime(day, '%d.%m.%Y').date()
        except ValueError:
            parsed = None
        modes = quest.variations.filter(active=True).order_by('pk')
        slots = Schedule.free(quest, parsed) if parsed else ()
        return JsonResponse({'variations':[{'id':item.pk,'label':item.name} for item in modes],
                             'slots':[{'id':item.pk,'label':str(item)} for item in slots]})


class QuestForm(StyledForm, forms.ModelForm):
    class Meta:
        model = Quest
        fields = ['name','summary']
        labels = {'name':'Название квеста','summary':'Описание'}
        widgets = {'summary':forms.Textarea(attrs={'rows':3})}


class VariationForm(StyledForm, forms.ModelForm):
    class Meta:
        model = Variation
        fields = ['quest','name']
        labels = {'quest':'Квест','name':'Название вариации'}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance.pk:
            self.fields['quest'].disabled = True
        else:
            self.fields['quest'].queryset = Quest.objects.filter(active=True)


class SlotForm(StyledForm, forms.ModelForm):
    day = forms.DateField(label='Дата', input_formats=['%d.%m.%Y'],
        widget=forms.TextInput(attrs={'placeholder':'ДД.ММ.ГГГГ','inputmode':'numeric','data-date':''}))
    time = forms.TimeField(label='Время', widget=forms.TimeInput(attrs={'type':'time'}))

    class Meta:
        model = Slot
        fields = ['quest','day','time']
        labels = {'quest':'Квест'}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['quest'].queryset = Quest.objects.filter(active=True)


class Catalog(AdminRequired, View):
    forms = {'quest':QuestForm,'variation':VariationForm,'slot':SlotForm}

    def get(self, request):
        kind = request.GET.get('kind','quest')
        if kind not in self.forms:
            return HttpResponseBadRequest('Неизвестный раздел каталога.')
        instance = self.find(kind, request.GET.get('id'))
        return self.show(request, kind, self.forms[kind](instance=instance), instance)

    @transaction.atomic
    def post(self, request):
        kind = request.POST.get('kind')
        if kind not in self.forms:
            return HttpResponseBadRequest('Неизвестный раздел каталога.')
        instance = self.find(kind, request.POST.get('id'))
        action = request.POST.get('action','save')
        if action in ('archive','restore') and instance and kind != 'slot':
            instance.active = action == 'restore'
            instance.save(update_fields=['active'])
            messages.success(request, 'Позиция восстановлена.' if instance.active else 'Позиция удалена из активного каталога.')
            return redirect('catalog')
        form = self.forms[kind](request.POST, instance=instance)
        if form.is_valid():
            form.save()
            messages.success(request, 'Данные каталога сохранены.')
            return redirect('catalog')
        return self.show(request, kind, form, instance, 400)

    def find(self, kind, raw):
        if not raw or kind == 'slot':
            return None
        key = int(raw) if raw.isascii() and raw.isdigit() and len(raw)<18 else 0
        return get_object_or_404(self.forms[kind]._meta.model, pk=key)

    @staticmethod
    def show(request, kind, form, instance, status=200):
        return render(request, 'portal/catalog.html', {'kind':kind,'form':form,'instance':instance,
            'quests':Quest.objects.prefetch_related('variations').order_by('pk'),
            'slots':Schedule.upcoming().select_related('quest')[:12]}, status=status)
