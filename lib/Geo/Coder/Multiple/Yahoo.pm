package Geo::Coder::Multiple::Yahoo;

use strict;
use warnings;

use base 'Geo::Coder::Multiple::Generic';


sub geocode {
    my $self = shift;
    my $location = shift;

    my $raw_replies = $self->{GeoCoder}->geocode( location => $location );

    my $Response = Geo::Coder::Multiple::Response->new( { location => $location } );

    my $location_data = [];

    foreach my $raw_reply ( @{$raw_replies} ) {
        my $tmp = {
            address     => $raw_reply->{address},
            country     => $raw_reply->{country},
            longitude   => $raw_reply->{longitude},
            latitude    => $raw_reply->{latitude},
        };

        $Response->add_response( $tmp, 'yahoo' );
    };

    return( $Response );
};


sub get_name { return 'yahoo' };


1;


__END__
