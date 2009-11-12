package Geo::Coder::Multiple::Google;

use strict;
use warnings;

use base 'Geo::Coder::Multiple::Generic';


sub geocode {
    my $self = shift;
    my $location = shift;

    my @raw_replies = $self->{GeoCoder}->geocode( $location );

    my $Response = Geo::Coder::Multiple::Response->new( { location => $location } );

    foreach my $raw_reply ( @raw_replies ) {
        my $tmp = {
            address     => $raw_reply->{address},
            country     => $raw_reply->{AddressDetails}->{Country}->{CountryNameCode},
            latitude    => $raw_reply->{Point}->{coordinates}->[1],
            longitude   => $raw_reply->{Point}->{coordinates}->[0],
        };

        $Response->add_response( $tmp, 'google' );
    };

    return( $Response );
};


1;

__END__

