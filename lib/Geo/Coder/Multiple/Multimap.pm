package Geo::Coder::Multiple::Multimap;

use strict;
use warnings;

use base 'Geo::Coder::Multiple::Generic';


sub geocode {
    my $self = shift;
    my $location = shift;

    my $raw_reply = $self->{GeoCoder}->geocode( location => $location );

    my $Response = Geo::Coder::Multiple::Response->new( { location => $location } );

    my $tmp = {
        address     => $raw_reply->{address}->{display_name},
        longitude   => $raw_reply->{point}->{lon},
        latitude    => $raw_reply->{point}->{lat},
    };

    $Response->add_response( $tmp, 'multimap' );

    return( $Response );
};


sub get_name { return 'multimap' };


1;

__END__

