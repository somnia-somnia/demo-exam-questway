import re
from django import forms
from django.contrib.auth.hashers import make_password
from django.db import IntegrityError, transaction
from portal.models import Member, Review, Submission
from portal.site import SITE


class StyledForm:
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for name, field in self.fields.items():
            field.widget.attrs.setdefault('aria-describedby', f'id_{name}_error')


class RegistrationForm(StyledForm, forms.Form):
    login = forms.RegexField(r'\A[A-Za-z0-9]{6,64}\Z', label='Логин', max_length=64,
        error_messages={'invalid':'От 6 символов, только латиница и цифры.'},
        widget=forms.TextInput(attrs={'placeholder':'например, marina2026','autocomplete':'username','minlength':6,'pattern':'[A-Za-z0-9]{6,64}','data-invalid':'От 6 символов, только латиница и цифры.'}))
    password = forms.CharField(label='Пароль', min_length=8, max_length=128, strip=False,
        widget=forms.PasswordInput(attrs={'placeholder':'Не менее 8 символов','autocomplete':'new-password','data-invalid':'Пароль должен содержать минимум 8 символов.'}))
    full_name = forms.RegexField(r'\A[А-Яа-яЁё ]+\Z', label='ФИО', max_length=150,
        error_messages={'invalid':'Используйте кириллицу и пробелы.'},
        widget=forms.TextInput(attrs={'placeholder':'Иванова Марина Олеговна','autocomplete':'name','pattern':'[А-Яа-яЁё ]+','data-invalid':'Используйте кириллицу и пробелы.'}))
    phone = forms.RegexField(r'\A8\([0-9]{3}\) ?[0-9]{3}-[0-9]{2}-[0-9]{2}\Z',
        label='Телефон', max_length=16,
        error_messages={'invalid':'Введите номер в формате 8(900)123-45-67.'},
        widget=forms.TextInput(attrs={'placeholder':'8(900)123-45-67','type':'tel','inputmode':'tel','autocomplete':'tel-national','pattern':r'8\([0-9]{3}\) ?[0-9]{3}-[0-9]{2}-[0-9]{2}','data-phone':'','data-invalid':'Введите номер в формате 8(900)123-45-67.'}))
    email = forms.EmailField(label='Электронная почта', max_length=Member._meta.get_field('email').max_length,
        widget=forms.EmailInput(attrs={'placeholder':'mail@example.ru','autocomplete':'email','data-invalid':'Введите корректный email.'}))

    def clean_login(self):
        login = self.cleaned_data['login'].lower()
        if Member.objects.filter(login=login).exists():
            raise forms.ValidationError('Этот логин уже занят.')
        return login

    def save(self):
        values = self.cleaned_data.copy()
        values['password'] = make_password(values['password'])
        try:
            with transaction.atomic():
                return Member.objects.create(**values)
        except IntegrityError:
            self.add_error('login', 'Этот логин уже занят.')
            return None


class LoginForm(StyledForm, forms.Form):
    login = forms.CharField(label='Логин', max_length=64,
        widget=forms.TextInput(attrs={'placeholder':'Ваш логин','autocomplete':'username'}))
    password = forms.CharField(label='Пароль', max_length=128, strip=False,
        widget=forms.PasswordInput(attrs={'placeholder':'Ваш пароль','autocomplete':'current-password'}))


class ReviewForm(StyledForm, forms.ModelForm):
    class Meta:
        model = Review
        fields = ('body',)
        labels = {'body':'Ваш отзыв'}
        widgets = {'body':forms.Textarea(attrs={'rows':3,'placeholder':'Расскажите, что вам понравилось'})}


class StatusForm(StyledForm, forms.Form):
    status = forms.ChoiceField(label='Новый статус', choices=SITE.statuses)
    reason = forms.CharField(label='Причина отмены', required=False, max_length=500,
        widget=forms.Textarea(attrs={'rows':3,'placeholder':'Укажите причину для пользователя'}))

    def clean(self):
        values = super().clean()
        if values.get('status') == 'cancelled' and not values.get('reason'):
            self.add_error('reason', 'Укажите причину отмены.')
        return values


class PortalDateField(forms.DateField):
    widget = forms.TextInput(attrs={'placeholder':'ДД.ММ.ГГГГ','inputmode':'numeric','data-date':'',
        'pattern':r'[0-9]{2}\.[0-9]{2}\.[0-9]{4}','maxlength':10,'data-invalid':'Введите дату в формате ДД.ММ.ГГГГ.'})
    default_error_messages = {'invalid':'Введите дату в формате ДД.ММ.ГГГГ.'}
    input_formats = ['%d.%m.%Y']

    def to_python(self, value):
        if value and not re.fullmatch(r'[0-9]{2}\.[0-9]{2}\.[0-9]{4}', value):
            raise forms.ValidationError(self.error_messages['invalid'], code='invalid')
        return super().to_python(value)


class SubmissionFormBase(StyledForm, forms.ModelForm):
    day = PortalDateField(label=SITE.date_label)
