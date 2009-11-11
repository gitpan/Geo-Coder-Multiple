package Geo::Coder::Multiple::Google;

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

    my @raw_replies = $self->{GeoCoder}->geocode( $location );

    my $location_data = [];

    foreach my $raw_reply ( @raw_replies ) {
        my $tmp = {
            address     => $raw_reply->{address},
            country     => $raw_reply->{AddressDetails}->{Country}->{CountryNameCode},
            latitude    => $raw_reply->{Point}->{coordinates}->[1],
            longitude   => $raw_reply->{Point}->{coordinates}->[0],
            geocoder    => 'google',
        };

        push @{$location_data}, $tmp;
    };

    return( $location_data );
};

sub get_daily_limit { return( $_[0]->{daily_limit} ) };
sub get_name { return( $_[0]->{name} ) };


1;

__END__

