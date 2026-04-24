from django.shortcuts import render
from django.views import generic
from .models import FiberEnclosure, OpticalSplitter, FiberConnection


class FiberEnclosureListView(generic.ListView):
    """View for listing fiber enclosures"""
    model = FiberEnclosure
    template_name = 'netbox_fiber/enclosure_list.html'
    context_object_name = 'enclosures'
    paginate_by = 50


class FiberEnclosureDetailView(generic.DetailView):
    """View for displaying a single fiber enclosure"""
    model = FiberEnclosure
    template_name = 'netbox_fiber/enclosure_detail.html'
    context_object_name = 'enclosure'


class OpticalSplitterListView(generic.ListView):
    """View for listing optical splitters"""
    model = OpticalSplitter
    template_name = 'netbox_fiber/splitter_list.html'
    context_object_name = 'splitters'
    paginate_by = 50


class OpticalSplitterDetailView(generic.DetailView):
    """View for displaying a single optical splitter"""
    model = OpticalSplitter
    template_name = 'netbox_fiber/splitter_detail.html'
    context_object_name = 'splitter'


class FiberConnectionListView(generic.ListView):
    """View for listing fiber connections"""
    model = FiberConnection
    template_name = 'netbox_fiber/connection_list.html'
    context_object_name = 'connections'
    paginate_by = 50


class FiberConnectionDetailView(generic.DetailView):
    """View for displaying a single fiber connection"""
    model = FiberConnection
    template_name = 'netbox_fiber/connection_detail.html'
    context_object_name = 'connection'


class FiberMapView(generic.TemplateView):
    """View for displaying the fiber map"""
    template_name = 'netbox_fiber/fiber_map.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Add any data needed for the fiber map visualization
        context['enclosures'] = FiberEnclosure.objects.all()[:100]  # Limit for performance
        context['splitters'] = OpticalSplitter.objects.all()[:100]
        context['connections'] = FiberConnection.objects.all()[:100]
        return context