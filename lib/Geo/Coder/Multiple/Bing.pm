package Geo::Coder::Multiple::Bing;

use strict;
use warnings;

use base 'Geo::Coder::Multiple::Generic';


sub geocode {
    my $self = shift;
    my $location = shift;

    my $raw_reply = $self->{GeoCoder}->geocode( location => $location );

    my $Response = Geo::Coder::Multiple::Response->new( { location => $location } );
    $Response->set_geocoder( $self->get_name() );

    foreach my $option ( @{$raw_reply->{Locations}} ) {
        my $tmp = {
            address     => $raw_reply->{Address}->{FormattedAddress},
            country     => $raw_reply->{Address}->{CountryRegion},
            longitude   => $option->{Coordinates}->{Longitude},
            latitude    => $option->{Coordinates}->{Latitude},
        };

        $Response->add_response( $tmp );
    };

    return( $Response );
};


sub get_name { return 'bing' };


1;

__END__

