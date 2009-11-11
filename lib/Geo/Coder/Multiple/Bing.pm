package Geo::Coder::Multiple::Bing;

use strict;
use warnings;


sub new {
    my $class = shift;
    my $args = shift;

    my $self = {
        GeoCoder    => $args->{geocoder},
        daily_limit => $args->{daily_limit},
        name        => $class,
    };

    bless $self, $class;

    return( $self );
};


sub geocode {
    my $self = shift;
    my $location = shift;

    my $raw_reply = $self->{GeoCoder}->geocode( location => $location );

    my $location_data = [];

    foreach my $option ( @{$raw_reply->{Locations}} ) {
        my $tmp = {
            address     => $raw_reply->{Address}->{FormattedAddress},
            country     => $raw_reply->{Address}->{CountryRegion},
            longitude   => $option->{Coordinates}->{Longitude},
            latitude   => $option->{Coordinates}->{Latitude},
            geocoder    => 'bing',
        };

        push @{$location_data}, $tmp;
    };

    return( $location_data );
};


sub get_daily_limit { return( $_[0]->{daily_limit} ) };
sub get_name { return( $_[0]->{name} ) };

1;

__END__

