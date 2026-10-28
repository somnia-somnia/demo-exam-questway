from django.contrib import messages
from django.core.paginator import Paginator
from django.db import transaction
from django.db.models import Q
from django.http import HttpResponseForbidden
from django.shortcuts import get_object_or_404, redirect, render
from django.views import View
from django.views.generic import TemplateView
from portal.apps import Casefold
from portal.domain_forms import SubmissionForm
from portal.forms import LoginForm, RegistrationForm, ReviewForm, StatusForm
from portal.models import Review, Submission
from portal.security import Accounts, AdminRequired, MemberRequired
from portal.site import SITE


def submissions():
    rows = Submission.objects.select_related('owner','review').order_by('-pk')
    if SITE.key == 'quest':
        rows = rows.select_related('variation','slot__quest')
    return rows


class Home(TemplateView):
    template_name = 'portal/home.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if SITE.key == 'quest':
            from portal.models import Quest
            context['quests'] = Quest.objects.filter(active=True).order_by('pk')
        return context


class PublicForm(View):
    template_name = 'portal/auth.html'
    form_class = None
    action = None

    def get(self, request):
        if request.member:
            return redirect('admin_panel' if request.member.is_admin else 'requests')
        return self.show(request, self.form_class())

    def post(self, request):
        if request.member:
            return redirect('admin_panel' if request.member.is_admin else 'requests')
        form = self.form_class(request.POST)
        if form.is_valid():
            response = self.accept(request, form)
            if response:
                return response
        return self.show(request, form)

    def show(self, request, form):
        return render(request, self.template_name, {'form':form, 'action':self.action})


class Register(PublicForm):
    form_class = RegistrationForm
    action = 'register'

    def accept(self, request, form):
        if form.save():
            messages.success(request, 'Аккаунт создан. Войдите под своим логином.')
            return redirect('login')
        return None


class Login(PublicForm):
    form_class = LoginForm
    action = 'login'

    def accept(self, request, form):
        member = Accounts.authenticate(form.cleaned_data['login'], form.cleaned_data['password'])
        if member is None:
            form.add_error('password', 'Неверный логин или пароль.')
            return None
        Accounts.sign_in(request, member)
        return redirect('admin_panel' if member.is_admin else 'requests')


class Logout(View):
    def post(self, request):
        request.session.flush()
        return redirect('home')


class Requests(MemberRequired, View):
    def get(self, request):
        return self.show(request)

    @staticmethod
    def show(request, row=None, form=None, status=200):
        items = submissions().filter(owner=request.member)
        return render(request, 'portal/requests.html',
                      {'items':items, 'review_row':row, 'review_form':form}, status=status)


class Create(MemberRequired, View):
    def get(self, request):
        quest = request.GET.get('quest','')
        initial = {'quest':int(quest)} if quest.isascii() and quest.isdigit() and len(quest) < 18 else {}
        return self.show(request, SubmissionForm(initial=initial))

    def post(self, request):
        form = SubmissionForm(request.POST)
        with transaction.atomic():
            if form.is_valid():
                row = form.save(commit=False)
                row.owner = request.member
                row.save()
                messages.success(request, 'Заявка отправлена. Статус появится в кабинете.')
                return redirect('requests')
        return self.show(request, form)

    @staticmethod
    def show(request, form):
        return render(request, 'portal/create.html', {'form':form})


class AddReview(MemberRequired, View):
    def get(self, request, pk):
        row = get_object_or_404(submissions(), pk=pk, owner=request.member)
        if not row.review_allowed:
            return HttpResponseForbidden('Отзыв доступен после завершения и только один раз.')
        return Requests.show(request, row, ReviewForm())

    @transaction.atomic
    def post(self, request, pk):
        row = get_object_or_404(submissions(), pk=pk, owner=request.member)
        if not row.review_allowed:
            return HttpResponseForbidden('Отзыв доступен после завершения и только один раз.')
        form = ReviewForm(request.POST)
        if form.is_valid():
            review = form.save(commit=False)
            review.submission = row
            review.save()
            messages.success(request, 'Отзыв опубликован. Спасибо!')
            return redirect('requests')
        return Requests.show(request, row, form, status=400)


class AdminPanel(AdminRequired, View):
    def get(self, request):
        return self.show(request)

    @staticmethod
    def show(request, row=None, form=None, status=200):
        search = request.GET.get('q','').strip()[:100]
        selected = request.GET.get('status','')
        rows = submissions()
        if selected in dict(SITE.statuses):
            rows = rows.filter(status=selected)
        if search:
            folded = search.casefold()
            rows = rows.alias(person_name=Casefold('owner__full_name'), person_login=Casefold('owner__login'))
            matches = Q(person_name__contains=folded) | Q(person_login__contains=folded)
            if search.isascii() and search.isdigit() and len(search)<18:
                matches |= Q(pk=int(search))
            if SITE.key == 'quest':
                rows = rows.alias(quest_name=Casefold('slot__quest__name'))
                matches |= Q(quest_name__contains=folded)
            else:
                field = 'topic' if SITE.key == 'help' else 'car'
                choices = Submission._meta.get_field(field).choices
                matches |= Q(**{field+'__in':[key for key, label in choices if folded in label.casefold()]})
            rows = rows.filter(matches)
        page = Paginator(rows, 5).get_page(request.GET.get('page'))
        filters = request.GET.copy()
        filters.pop('page', None)
        return render(request, 'portal/admin.html', {
            'page':page,'search':search,'selected':selected,'filter_query':filters.urlencode(),
            'status_row':row,'status_form':form,
        }, status=status)


class ChangeStatus(AdminRequired, View):
    def get(self, request, pk):
        row = get_object_or_404(submissions(), pk=pk)
        return AdminPanel.show(request, row, StatusForm(initial={'status':row.status,'reason':getattr(row,'reason','')}))

    @transaction.atomic
    def post(self, request, pk):
        row = get_object_or_404(submissions(), pk=pk)
        form = StatusForm(request.POST)
        if form.is_valid():
            target = form.cleaned_data['status']
            if row.status == SITE.finished and target != SITE.finished:
                form.add_error('status', 'Завершённую заявку нельзя вернуть в работу.')
            elif target == SITE.statuses[0][0] and row.status != target:
                form.add_error('status', 'Первичный статус присваивается при создании заявки.')
            elif SITE.cancelled and target != 'cancelled' and Submission.objects.filter(slot=row.slot).exclude(pk=row.pk).exclude(status='cancelled').exists():
                form.add_error('status', 'Интервал уже занят другим бронированием.')
            else:
                row.status = target
                columns = ['status']
                if SITE.cancelled:
                    row.reason = form.cleaned_data['reason'] if target == 'cancelled' else ''
                    columns.append('reason')
                row.save(update_fields=columns)
                messages.success(request, f'Статус №{row.pk} обновлён: {row.get_status_display()}.')
                return redirect('admin_panel')
        return AdminPanel.show(request, row, form, status=400)


class Prototype(TemplateView):
    template_name = 'portal/prototype.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['prototype_states'] = [
            ('default','Обычное'), ('hover','Наведение'), ('pressed','Нажатие'),
            ('disabled','Неактивное'), ('error','Ошибка'),
        ]
        context['prototype_pages'] = [
            ('home','Главная'), ('register','Регистрация'), ('login','Авторизация'),
            ('requests','Бронирования'), ('create','Оформление'), ('admin','Панель администратора'),
        ]
        return context
