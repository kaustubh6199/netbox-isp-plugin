from rest_framework import viewsets
from ..models import FiberEnclosure, OpticalSplitter, FiberConnection
from .serializers import FiberEnclosureSerializer, OpticalSplitterSerializer, FiberConnectionSerializer


class FiberEnclosureViewSet(viewsets.ModelViewSet):
    """ViewSet for viewing and editing FiberEnclosure instances."""
    queryset = FiberEnclosure.objects.all()
    serializer_class = FiberEnclosureSerializer


class OpticalSplitterViewSet(viewsets.ModelViewSet):
    """ViewSet for viewing and editing OpticalSplitter instances."""
    queryset = OpticalSplitter.objects.all()
    serializer_class = OpticalSplitterSerializer


class FiberConnectionViewSet(viewsets.ModelViewSet):
    """ViewSet for viewing and editing FiberConnection instances."""
    queryset = FiberConnection.objects.all()
    serializer_class = FiberConnectionSerializer