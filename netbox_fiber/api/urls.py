from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import FiberEnclosureViewSet, OpticalSplitterViewSet, FiberConnectionViewSet

router = DefaultRouter()
router.register(r'enclosures', FiberEnclosureViewSet)
router.register(r'splitters', OpticalSplitterViewSet)
router.register(r'connections', FiberConnectionViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
]