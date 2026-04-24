from rest_framework import serializers
from ..models import FiberEnclosure, OpticalSplitter, FiberConnection
from dcim.api.serializers import SiteSerializer, LocationSerializer, RackSerializer


class FiberEnclosureSerializer(serializers.ModelSerializer):
    """Serializer for the FiberEnclosure model"""
    site = SiteSerializer(nested=True)
    location = LocationSerializer(nested=True, required=False, allow_null=True)
    rack = RackSerializer(nested=True, required=False, allow_null=True)
    
    class Meta:
        model = FiberEnclosure
        fields = [
            'id', 'url', 'display', 'name', 'site', 'location', 'rack',
            'position', 'height', 'enclosure_type', 'port_count',
            'layout_data', 'max_split_ratio', 'created', 'last_updated'
        ]


class OpticalSplitterSerializer(serializers.ModelSerializer):
    """Serializer for the OpticalSplitter model"""
    site = SiteSerializer(nested=True)
    location = LocationSerializer(nested=True, required=False, allow_null=True)
    
    class Meta:
        model = OpticalSplitter
        fields = [
            'id', 'url', 'display', 'name', 'site', 'location',
            'input_ports', 'output_ports', 'split_ratio',
            'wavelength_upstream_min', 'wavelength_upstream_max',
            'wavelength_downstream_min', 'wavelength_downstream_max',
            'wavelength_video_min', 'wavelength_video_max',
            'insertion_loss', 'splitter_class', 'manufacturer',
            'part_number', 'is_passive', 'created', 'last_updated'
        ]


class FiberConnectionSerializer(serializers.ModelSerializer):
    """Serializer for the FiberConnection model"""
    
    class Meta:
        model = FiberConnection
        fields = [
            'id', 'url', 'display', 'termination_a_type', 'termination_a_id',
            'termination_b_type', 'termination_b_id', 'cable_type', 'length',
            'attenuation_coefficient', 'connection_loss', 'installation_date',
            'notes', 'created', 'last_updated'
        ]