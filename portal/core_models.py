from django.db import models
from django.db.models.functions import Lower
from portal.site import SITE


class Member(models.Model):
    login = models.CharField(max_length=64, unique=True)
    password = models.CharField(max_length=128)
    full_name = models.CharField(max_length=150)
    phone = models.CharField(max_length=16)
    email = models.EmailField()
    is_admin = models.BooleanField(default=False)

    class Meta:
        constraints = [models.UniqueConstraint(Lower('login'), name='unique_login_casefold')]

    def __str__(self):
        return self.login


class BaseSubmission(models.Model):
    owner = models.ForeignKey(Member, on_delete=models.PROTECT, related_name='submissions')
    status = models.CharField(max_length=16, choices=SITE.statuses, default=SITE.statuses[0][0])
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        abstract = True

    @property
    def review_allowed(self):
        return self.status == SITE.finished and not hasattr(self, 'review')


class Review(models.Model):
    submission = models.OneToOneField('Submission', on_delete=models.CASCADE, related_name='review')
    body = models.CharField(max_length=600)
    created_at = models.DateTimeField(auto_now_add=True)
