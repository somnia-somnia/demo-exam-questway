from types import SimpleNamespace
from portal.brand import BRAND

SITE = SimpleNamespace(**BRAND)


def brand_context(request):
    return {'site': SITE}
