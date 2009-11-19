package Geo::Coder::Multiple::Generic;

use strict;
use warnings;

use Geo::Coder::Multiple::Response;

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


sub geocode { die "This method must be over-ridden" };
sub get_daily_limit { return( $_[0]->{daily_limit} ) };
sub get_name { return( $_[0]->{name} ) };



1;

__END__

