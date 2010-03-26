package Geo::Coder::Multiple::Yahoo;

use strict;
use warnings;

use base 'Geo::Coder::Multiple::Generic';


my $STATUS_LOOKUP = {
    200     => 200,
    400     => 403,
    403     => 402,
    503     => 403,
};


sub geocode {
    my $self = shift;
    my $location = shift;

    my $raw_reply = $self->{GeoCoder}->geocode( location => $location );

    my $Response = Geo::Coder::Multiple::Response->new( { location => $location } );
    $Response->set_status( $STATUS_LOOKUP->{$raw_reply->{http_code}} );
    $Response->set_geocoder( $self->get_name() );

    my $location_data = [];

    my $total_responses = 0;
    foreach my $result ( @{$raw_reply->{results}} ) {
        my $tmp = {
            address     => $result->{address},
            country     => $result->{country},
            longitude   => $result->{longitude},
            latitude    => $result->{latitude},
        };

        $Response->add_response( $tmp );
        $total_responses++;
    };

    unless( $total_responses ) { $Response->set_status( 401 ) };

    return( $Response );
};


sub get_name { return 'yahoo' };


1;


__END__
