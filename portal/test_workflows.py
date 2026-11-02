from datetime import date, timedelta
from django.conf import settings
from django.test import Client, TestCase
from django.urls import reverse
from portal.models import Member, Submission, Review
from portal.seed import populate
from portal.site import SITE


class Workflows(TestCase):
    @classmethod
    def setUpTestData(cls):
        populate()

    def member(self):
        self.client.post(reverse('login'), {'login': 'demo2026', 'password': 'Demo2026!'})

    def admin(self):
        self.client.post(reverse('login'), {'login': 'Admin', 'password': SITE.admin_password})

    def request_data(self):
        day = (date.today() + timedelta(days=1)).strftime('%d.%m.%Y')
        if SITE.key == 'quest':
            from portal.models import Quest, Slot, Variation
            quest = Quest.objects.get(pk=1)
            variation = Variation.objects.filter(quest=quest).first()
            slot = Slot.objects.filter(quest=quest, day=date.today()+timedelta(days=1)).first()
            return {'quest': quest.pk, 'variation': variation.pk, 'day': day, 'slot': slot.pk,
                    'participants': 4, 'payment': 'card'}
        if SITE.key == 'help':
            return {'topic': 'software', 'description': 'Приложение закрывается при запуске.',
                    'day': day, 'reported_day':day, 'priority': 'high', 'contact': 'phone'}
        return {'car': 'vesta', 'day': day, 'payment': 'cash'}

    def test_registration_and_invalid_login(self):
        good = {'login': 'alex2026', 'password': 'Safe2026!', 'full_name': 'Иванов Алексей',
                'phone': '8(916) 123-45-67', 'email': 'alex@example.com'}
        bad = self.client.post(reverse('register'), {**good, 'full_name': 'Alice', 'phone': '123'})
        self.assertFormError(bad.context['form'], 'full_name', 'Используйте кириллицу и пробелы.')
        self.assertFalse(Member.objects.filter(login='alex2026').exists())
        self.assertRedirects(self.client.post(reverse('register'), good), reverse('login'))
        self.assertNotEqual(Member.objects.get(login='alex2026').password, good['password'])
        repeat = self.client.post(reverse('register'), {**good, 'login': 'ALEX2026'})
        self.assertFormError(repeat.context['form'], 'login', 'Этот логин уже занят.')
        invalid = self.client.post(reverse('login'), {'login': "Admin' OR 1=1 --", 'password': 'wrong'})
        self.assertEqual(invalid.status_code, 200)
        self.assertNotIn('member_id', self.client.session)

    def test_create_and_scope(self):
        self.assertEqual(self.client.get(reverse('requests')).status_code, 302)
        self.member()
        self.assertEqual(self.client.get(reverse('admin_panel')).status_code, 403)
        self.assertRedirects(self.client.post(reverse('create'), self.request_data()), reverse('requests'))
        newest = Submission.objects.latest('pk')
        self.assertEqual(newest.owner.login, 'demo2026')
        self.assertEqual(newest.status, SITE.statuses[0][0])
        response = self.client.get(reverse('requests'))
        self.assertTrue(all(item.owner.login == 'demo2026' for item in response.context['items']))

    def test_review_checks_state_owner_and_uniqueness(self):
        self.member()
        own = Submission.objects.filter(owner__login='demo2026')
        pending = own.exclude(status=SITE.finished).first()
        foreign = Submission.objects.exclude(owner__login='demo2026').first()
        eligible = own.filter(status=SITE.finished, review__isnull=True).first()
        form_page = self.client.get(reverse('review', args=[eligible.pk]))
        self.assertContains(form_page, 'id="id_body"')
        for row, expected in [(pending, 403), (foreign, 404)]:
            self.assertEqual(self.client.post(reverse('review', args=[row.pk]), {'body':'Хорошая работа'}).status_code, expected)
        self.assertRedirects(self.client.post(reverse('review', args=[eligible.pk]), {'body':'Хорошая работа'}), reverse('requests'))
        self.assertEqual(self.client.post(reverse('review', args=[eligible.pk]), {'body':'Повторный отзыв'}).status_code, 403)
        self.assertEqual(Review.objects.filter(submission=eligible).count(), 1)

    def test_admin_filter_pagination_and_transition(self):
        self.admin()
        listing = self.client.get(reverse('admin_panel'))
        self.assertGreater(listing.context['page'].paginator.num_pages, 1)
        found = self.client.get(reverse('admin_panel'), {'q':'иванова'}).context['page']
        self.assertEqual(found.paginator.count, 5)
        row = Submission.objects.filter(status=SITE.statuses[0][0]).first()
        target = reverse('status', args=[row.pk])
        self.assertEqual(self.client.post(target, {'status':'unknown'}).status_code, 400)
        if SITE.key == 'quest':
            self.assertEqual(self.client.post(target, {'status':'cancelled'}).status_code, 400)
            self.assertRedirects(self.client.post(target, {'status':'cancelled','reason':'Команда перенесла визит'}), reverse('admin_panel'))
            row.refresh_from_db()
            self.assertEqual(row.reason, 'Команда перенесла визит')
        else:
            self.assertRedirects(self.client.post(target, {'status':SITE.finished}), reverse('admin_panel'))
            row.refresh_from_db()
            self.assertEqual(row.status, SITE.finished)
        self.assertEqual(self.client.get(reverse('admin_panel'), {'q':'абракадабра'}).context['page'].paginator.count, 0)

    def test_csrf_and_slot_collision(self):
        self.assertEqual(Client(enforce_csrf_checks=True).post(reverse('login'), {}).status_code, 403)
        if SITE.key != 'quest':
            return
        self.member()
        data = self.request_data()
        self.assertEqual(self.client.post(reverse('create'), data).status_code, 302)
        second = self.client.post(reverse('create'), data)
        self.assertEqual(second.status_code, 200)
        self.assertTrue(second.context['form'].errors.get('slot'))

    def test_catalog_write_and_archive(self):
        if SITE.key != 'quest':
            return
        from portal.models import Quest, Variation
        self.assertEqual(self.client.get(reverse('catalog')).status_code, 302)
        self.admin()
        self.assertEqual(self.client.post(reverse('catalog'), {'kind':'quest','name':'Дверь в подземелье','summary':'Новый маршрут'}).status_code, 302)
        item = Quest.objects.get(name='Дверь в подземелье')
        self.assertEqual(self.client.post(reverse('catalog'), {'kind':'variation','quest':item.pk,'name':'Вечерний'}).status_code, 302)
        mode = Variation.objects.get(quest=item)
        self.assertEqual(self.client.post(reverse('catalog'), {'kind':'variation','id':mode.pk,'quest':item.pk,'name':'Дневной'}).status_code, 302)
        mode.refresh_from_db()
        self.assertEqual(mode.name,'Дневной')
        self.assertEqual(self.client.post(reverse('catalog'), {'kind':'quest','id':item.pk,'action':'archive'}).status_code, 302)
        item.refresh_from_db()
        self.assertFalse(item.active)
