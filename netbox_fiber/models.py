from django.db import models
from django.core.exceptions import ValidationError
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from dcim.models import Site, Location, Rack
from netbox.models import NetBoxModel


def validate_split_ratio(value):
    """Validate that split ratio values sum to 100"""
    if not isinstance(value, list):
        raise ValidationError("Split ratio must be a list of numbers")
    
    if len(value) == 0:
        raise ValidationError("Split ratio cannot be empty")
    
    # Check that all values are numbers
    try:
        total = sum(float(v) for v in value)
    except (ValueError, TypeError):
        raise ValidationError("All split ratio values must be numbers")
    
    # Allow small tolerance for floating point arithmetic
    if abs(total - 100.0) > 0.1:
        raise ValidationError(f"Split ratio values must sum to 100 (currently sums to {total})")


class FiberEnclosure(NetBoxModel):
    """Model representing a fiber enclosure for PON networks"""
    
    ENCLOSURE_TYPE_CHOICES = [
        ('olt_terminal', 'OLT Terminal'),
        ('splitter_enclosure', 'Splitter Enclosure'),
        ('ont_distribution', 'ONT Distribution'),
        ('splice_enclosure', 'Splice Enclosure'),
        ('other', 'Other'),
    ]
    
    name = models.CharField(max_length=100)
    site = models.ForeignKey(
        to=Site,
        on_delete=models.CASCADE
    )
    location = models.ForeignKey(
        to=Location,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    rack = models.ForeignKey(
        to=Rack,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    position = models.PositiveSmallIntegerField(
        help_text="U position in rack"
    )
    height = models.PositiveSmallIntegerField(
        help_text="Height in rack units"
    )
    
    # PON-specific port labeling
    enclosure_type = models.CharField(
        max_length=50,
        choices=ENCLOSURE_TYPE_CHOICES
    )
    
    port_count = models.PositiveIntegerField()
    
    # For layout mapping
    layout_data = models.JSONField(
        help_text="JSON structure defining port positions and enclosure internals",
        default=dict,
        blank=True
    )
    
    # Additional PON fields
    max_split_ratio = models.PositiveIntegerField(
        help_text="Maximum split ratio supported by this enclosure (e.g., 64 for 1:64)",
        blank=True,
        null=True
    )
    
    class Meta:
        verbose_name = "Fiber Enclosure"
        verbose_name_plural = "Fiber Enclosures"
        ordering = ['site', 'name']
    
    def __str__(self):
        return self.name


class OpticalSplitter(NetBoxModel):
    """Model representing an optical splitter for PON networks"""
    
    SPLITTER_CLASS_CHOICES = [
        ('standard', 'Standard Splitter'),
        ('wdm', 'WDM Splitter'),
        ('tunable', 'Tunable Splitter'),
    ]
    
    name = models.CharField(max_length=100)
    site = models.ForeignKey(
        to=Site,
        on_delete=models.CASCADE
    )
    location = models.ForeignKey(
        to=Location,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    
    # PON-relevant port configuration
    input_ports = models.PositiveSmallIntegerField(
        default=1,
        help_text="Number of input ports (typically 1 for PON)"
    )
    output_ports = models.PositiveSmallIntegerField(
        help_text="Number of output ports (e.g., 32 for 1:32 splitter)"
    )
    
    # Split ratio - critical for PON
    split_ratio = models.JSONField(
        help_text="Array of output port ratios (must sum to 100)",
        default=list,
        blank=True,
        validators=[validate_split_ratio]
    )
    
    # PON wavelength specifications
    wavelength_upstream_min = models.PositiveIntegerField(
        help_text="Upstream min wavelength (nm)",
        default=1260
    )
    wavelength_upstream_max = models.PositiveIntegerField(
        help_text="Upstream max wavelength (nm)",
        default=1360
    )
    wavelength_downstream_min = models.PositiveIntegerField(
        help_text="Downstream min wavelength (nm)",
        default=1480
    )
    wavelength_downstream_max = models.PositiveIntegerField(
        help_text="Downstream max wavelength (nm)",
        default=1500
    )
    wavelength_video_min = models.PositiveIntegerField(
        help_text="Video overlay min wavelength (nm)",
        blank=True,
        null=True
    )
    wavelength_video_max = models.PositiveIntegerField(
        help_text="Video overlay max wavelength (nm)",
        blank=True,
        null=True
    )
    
    # Insertion loss (important for PON power budget)
    insertion_loss = models.DecimalField(
        max_digits=4,
        decimal_places=2,
        help_text="Typical insertion loss (dB)"
    )
    
    # Additional PON-specific fields
    splitter_class = models.CharField(
        max_length=20,
        choices=SPLITTER_CLASS_CHOICES,
        default='standard'
    )
    
    # Manufacturing data
    manufacturer = models.CharField(max_length=100, blank=True)
    part_number = models.CharField(max_length=100, blank=True)
    
    is_passive = models.BooleanField(default=True)
    
    class Meta:
        verbose_name = "Optical Splitter"
        verbose_name_plural = "Optical Splitters"
        ordering = ['site', 'name']
    
    def __str__(self):
        return self.name
    
    def clean(self):
        super().clean()
        
        # Additional validation: number of ratios should match output_ports
        if self.split_ratio and len(self.split_ratio) != self.output_ports:
            raise ValidationError({
                'split_ratio': f"Number of ratio values ({len(self.split_ratio)}) must match output ports ({self.output_ports})"
            })
        
        # Validate wavelength ranges
        if self.wavelength_upstream_min >= self.wavelength_upstream_max:
            raise ValidationError({
                'wavelength_upstream_max': "Upstream max wavelength must be greater than min wavelength"
            })
        
        if self.wavelength_downstream_min >= self.wavelength_downstream_max:
            raise ValidationError({
                'wavelength_downstream_max': "Downstream max wavelength must be greater than min wavelength"
            })


class FiberConnection(NetBoxModel):
    """Model representing a fiber connection between two termination points"""
    
    termination_a_type = models.ForeignKey(
        to=ContentType,
        on_delete=models.CASCADE,
        related_name='%(class)s_termination_a'
    )
    termination_a_id = models.PositiveBigIntegerField()
    termination_a = GenericForeignKey('termination_a_type', 'termination_a_id')
    
    termination_b_type = models.ForeignKey(
        to=ContentType,
        on_delete=models.CASCADE,
        related_name='%(class)s_termination_b'
    )
    termination_b_id = models.PositiveBigIntegerField()
    termination_b = GenericForeignKey('termination_b_type', 'termination_b_id')
    
    cable_type = models.CharField(max_length=50)  # e.g., 'OS2 Single Mode'
    length = models.DecimalField(
        max_digits=6,
        decimal_places=2,
        help_text="Length in meters"
    )
    
    # PON-specific optical properties
    attenuation_coefficient = models.DecimalField(
        max_digits=4,
        decimal_places=3,
        help_text="Attenuation coefficient (dB/km) at operating wavelength",
        default=0.35  # Typical for SMF at 1550nm
    )
    
    # Calculated field for connection loss
    connection_loss = models.DecimalField(
        max_digits=4,
        decimal_places=2,
        help_text="Total connection loss including connectors (dB)",
        blank=True,
        null=True
    )
    
    installation_date = models.DateField(null=True, blank=True)
    notes = models.TextField(blank=True)
    
    class Meta:
        verbose_name = "Fiber Connection"
        verbose_name_plural = "Fiber Connections"
        ordering = ['-created']
    
    def __str__(self):
        return f"{self.termination_a} to {self.termination_b}"
    
    def save(self, *args, **kwargs):
        # Auto-calculate connection loss if not provided
        if not self.connection_loss:
            self.connection_loss = self.calculate_loss()
        super().save(*args, **kwargs)
    
    def calculate_loss(self):
        """Calculate total connection loss based on length and attenuation"""
        if self.length and self.attenuation_coefficient:
            # Basic fiber loss + connector losses (typically 0.5dB per connector pair)
            fiber_loss = float(self.length) * float(self.attenuation_coefficient) / 1000  # Convert m to km
            connector_loss = 1.0  # Two connectors, 0.5dB each
            return round(fiber_loss + connector_loss, 2)
        return None
    
    def get_available_power_budget(self, transmitter_power, receiver_sensitivity):
        """
        Calculate available power budget for this connection
        
        Args:
            transmitter_power: Transmitter output power (dBm)
            receiver_sensitivity: Receiver sensitivity (dBm)
            
        Returns:
            Available power budget (dBm) or None if calculation not possible
        """
        if self.connection_loss is None:
            return None
            
        # Power budget = Transmitter power - Receiver sensitivity - Connection loss
        return transmitter_power - receiver_sensitivity - float(self.connection_loss)