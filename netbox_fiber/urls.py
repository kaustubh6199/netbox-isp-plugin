from django.urls import path, include
from . import views

app_name = 'netbox_fiber'
urlpatterns = [
    # Fiber Enclosures
    path('enclosures/', views.FiberEnclosureListView.as_view(), name='enclosure_list'),
    path('enclosures/<int:pk>/', views.FiberEnclosureDetailView.as_view(), name='enclosure'),
    
    # Optical Splitters
    path('splitters/', views.OpticalSplitterListView.as_view(), name='splitter_list'),
    path('splitters/<int:pk>/', views.OpticalSplitterDetailView.as_view(), name='splitter'),
    
    # Fiber Connections
    path('connections/', views.FiberConnectionListView.as_view(), name='connection_list'),
    path('connections/<int:pk>/', views.FiberConnectionDetailView.as_view(), name='connection'),
    
    # Fiber Map
    path('map/', views.FiberMapView.as_view(), name='fiber_map'),
]