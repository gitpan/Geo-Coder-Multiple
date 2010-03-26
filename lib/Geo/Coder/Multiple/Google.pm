package Geo::Coder::Multiple::Google;

use strict;
use warnings;

use base 'Geo::Coder::Multiple::Generic';


my $STATUS_LOOKUP = {
    200     => 200,
    500     => 403,
    601     => 403,
    602     => 401,
    603     => 401,
    610     => 403,
    620     => 402,
};


sub geocode {
    my $self = shift;
    my $location = shift;

    my $raw_reply = $self->{GeoCoder}->geocode( $location );

    my $Response = Geo::Coder::Multiple::Response->new( { location => $location } );
    $Response->set_status( $STATUS_LOOKUP->{$raw_reply->{Status}} );
    $Response->set_geocoder( $self->get_name() );

    my $total_responses = 0;
    foreach my $placemark ( @{$raw_reply->{Placemark}} ) {
        my $tmp = {
            address     => $placemark->{address},
            country     => $placemark->{AddressDetails}->{Country}->{CountryNameCode},
            latitude    => $placemark->{Point}->{coordinates}->[1],
            longitude   => $placemark->{Point}->{coordinates}->[0],
            accuracy    => $placemark->{AddressDetails}->{Accuracy}
        };

        $Response->add_response( $tmp );
        $total_responses++;
    };

    unless( $total_responses ) { $Response->set_status( 401 ) };

    return( $Response );
};


sub get_name { return 'google' };


1;

__END__

