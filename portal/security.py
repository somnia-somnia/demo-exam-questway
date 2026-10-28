from django.contrib.auth.hashers import check_password, make_password
from django.http import HttpResponseForbidden, HttpResponseRedirect
from django.urls import reverse
from portal.models import Member

FALLBACK_HASH = make_password('unused-local-account')

class MemberMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        member_id = request.session.get('member_id')
        request.member = Member.objects.filter(pk=member_id).first() if member_id else None
        return self.get_response(request)


class MemberRequired:
    admin_only = False

    def dispatch(self, request, *args, **kwargs):
        if request.member is None:
            return HttpResponseRedirect(reverse('login'))
        if request.member.is_admin != self.admin_only:
            return HttpResponseForbidden('Этот раздел недоступен для вашей учётной записи.')
        return super().dispatch(request, *args, **kwargs)


class AdminRequired(MemberRequired):
    admin_only = True


class Accounts:
    @staticmethod
    def authenticate(login, password):
        member = Member.objects.filter(login=login.lower()).first()
        valid = check_password(password, member.password if member else FALLBACK_HASH)
        if member and valid:
            return member
        return None

    @staticmethod
    def sign_in(request, member):
        request.session.flush()
        request.session['member_id'] = member.pk
        from django.middleware.csrf import rotate_token
        rotate_token(request)
