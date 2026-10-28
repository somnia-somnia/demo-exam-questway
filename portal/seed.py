from django.contrib.auth.hashers import make_password
from django.utils import timezone
from portal import domain_seed
from portal.models import Member, Review, Submission
from portal.site import SITE

NAMES = ['Иванова Марина Олеговна','Смирнов Артём Ильич','Орлова Елена Сергеевна',
         'Кузнецов Павел Андреевич','Соколова Дарья Викторовна','Попов Михаил Юрьевич']
REVIEWS = {
    'help': ['Всё заработало после консультации. Спасибо за понятную инструкцию.',
             'Специалист быстро связался и помог восстановить доступ.'],
    'quest': ['Отличная атмосфера. Подсказки появлялись в нужный момент.',
              'Локация понравилась всей команде, обязательно вернёмся.'],
    'rent': ['Машину выдали вовремя, оформление заняло несколько минут.',
             'Автомобиль чистый, сотрудники подробно объяснили условия.'],
}


def account(login, password, **defaults):
    member = Member.objects.filter(login=login).first()
    return member or Member.objects.create(login=login, password=make_password(password), **defaults)


def populate():
    today = timezone.localdate()
    account('admin', SITE.admin_password, full_name='Администратор Портала',
            phone='8(900)000-00-01', email=SITE.support, is_admin=True)
    members = [account('demo2026' if i == 0 else f'client{i}26', 'Demo2026!',
                full_name=name, phone=f'8(916)440-26-{30+i}', email=f'client{i}@example.ru')
               for i,name in enumerate(NAMES)]
    domain_seed.prepare(today)
    if Submission.objects.exists():
        return
    statuses = [key for key, label in SITE.statuses]
    for i in range(20):
        owner = members[0] if i >= 15 else members[1+i%5]
        status = SITE.finished if i < 6 or i == 19 else statuses[(i-6)%len(statuses)]
        values = domain_seed.attributes(i, today)
        if status == 'cancelled':
            values['reason'] = 'Команда попросила перенести посещение.'
        row = Submission.objects.create(owner=owner, status=status, **values)
        if i < 6:
            Review.objects.create(submission=row, body=REVIEWS[SITE.key][i%2])
