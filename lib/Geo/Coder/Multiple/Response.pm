package Geo::Coder::Multiple::Response;

use strict;
use warnings;


sub new {
    my $class = shift;
    my $args = shift;

    my $self = {
        location        => $args->{location},
        responses       => [],
        response_code   => 401,
        geocoder        => undef,
    };

    bless $self, $class;

    return( $self );
};


sub add_response {
    my $self = shift;
    my $response = shift;
    my $geocoder = shift;

    $self->{geocoder} = $geocoder;

    if( $response->{longitude} && $response->{latitude} ) {
        push @{$self->{responses}}, $response;
        $self->{response_code} = 200;
    }
    else { return( 0 ) };

    return( 1 );
};


sub get_location { return( $_[0]->{location} ) };
sub get_response_code { return( $_[0]->{response_code} ) };
sub get_geocoder { return( $_[0]->{geocoder} ) };

sub get_responses {
    my $self = shift;

    return wantarray ? @{$self->{responses}} : $self->{responses}->[0];
};


1;