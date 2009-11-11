package Geo::Coder::Multiple::Multimap;

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

    my $raw_reply = $self->{GeoCoder}->geocode( location => $location );

    my $location_data = [
        {
            address     => $raw_reply->{address}->{display_name},
            longitude   => $raw_reply->{point}->{lon},
            latitude    => $raw_reply->{point}->{lat},
            geocoder    => 'multimap',
        },
    ];

    return( $location_data );
};


sub get_daily_limit { return( $_[0]->{daily_limit} ) };
sub get_name { return( $_[0]->{name} ) };



1;

__END__

