from django.urls import path
from portal import views
from portal.site import SITE

urlpatterns = [
    path('', views.Home.as_view(), name='home'),
    path('register/', views.Register.as_view(), name='register'),
    path('login/', views.Login.as_view(), name='login'),
    path('logout/', views.Logout.as_view(), name='logout'),
    path('requests/', views.Requests.as_view(), name='requests'),
    path('requests/new/', views.Create.as_view(), name='create'),
    path('requests/<int:pk>/review/', views.AddReview.as_view(), name='review'),
    path('staff/', views.AdminPanel.as_view(), name='admin_panel'),
    path('staff/<int:pk>/status/', views.ChangeStatus.as_view(), name='status'),
    path('ui-kit-prototype.html', views.Prototype.as_view(), name='prototype'),
]
if SITE.key == 'quest':
    from portal.quest_views import Availability, Catalog
    urlpatterns += [
        path('availability/', Availability.as_view(), name='availability'),
        path('staff/catalog/', Catalog.as_view(), name='catalog'),
    ]
