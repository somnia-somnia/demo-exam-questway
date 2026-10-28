from django.core.management.base import BaseCommand
from django.db import transaction
from portal.seed import populate


class Command(BaseCommand):
    help = 'Создаёт демонстрационные учётные записи и наполняет предметную область.'

    @transaction.atomic
    def handle(self, *args, **options):
        populate()
        self.stdout.write(self.style.SUCCESS('Демонстрационные данные готовы.'))
