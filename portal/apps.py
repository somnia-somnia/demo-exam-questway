from django.apps import AppConfig
from django.db.backends.signals import connection_created
from django.db.models import Func, TextField


def enable_casefold(sender, connection, **kwargs):
    if connection.vendor == 'sqlite':
        connection.connection.create_function('portal_casefold', 1, str.casefold, deterministic=True)


class PortalConfig(AppConfig):
    name = 'portal'

    def ready(self):
        connection_created.connect(enable_casefold, dispatch_uid='portal.casefold')


class Casefold(Func):
    function = 'portal_casefold'
    output_field = TextField()
