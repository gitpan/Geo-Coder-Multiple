package Geo::Coder::Multiple::Yahoo;

use strict;
use warnings;


sub new {
    my $class = shift;
    my $args = shift;

    my $self = {
        GeoCoder    => $args->{geocoder},
        daily_limit => $args->{daily_limit},
    };

    bless $self, $class;

    return( $self );
};


sub geocode {
    my $self = shift;
    my $location = shift;

    my $raw_replies = $self->{GeoCoder}->geocode( location => $location );

    my $location_data = [];

    foreach my $raw_reply ( @{$raw_replies} ) {
        my $tmp = {
            address     => $raw_reply->{address},
            country     => $raw_reply->{country},
            longitude   => $raw_reply->{longitude},
            latitude    => $raw_reply->{latitude},
            geocoder    => 'yahoo',
        };

        push @{$location_data}, $tmp;
    };

    return( $location_data );
};


sub get_daily_limit { return( $_[0]->{daily_limit} ) };
sub get_name { return( $_[0]->{name} ) };


1;

__END__

