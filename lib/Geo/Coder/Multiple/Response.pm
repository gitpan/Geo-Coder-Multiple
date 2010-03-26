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

    if( $response->{longitude} && $response->{latitude} ) {
        push @{$self->{responses}}, $response;
        $self->{response_code} = 200;
    }
    else { return( 0 ) };

    $self->_sort_responses();

    return( 1 );
};


sub set_geocoder { $_[0]->{geocoder} = $_[1]; };
sub set_status { $_[0]->{status} = $_[1]; };


sub get_location { return( $_[0]->{location} ) };
sub get_response_code { return( $_[0]->{response_code} ) };
sub get_geocoder { return( $_[0]->{geocoder} ) };
sub get_status { return( $_[0]->{status} ) };


sub get_responses {
    my $self = shift;

    return wantarray ? @{$self->{responses}} : $self->{responses}->[0];
};


sub _sort_responses {
    my $self = shift;

    my $tmp_responses = [];

    foreach my $response ( sort { $b->{accuracy} <=> $a->{accuracy} } @{$self->{responses}} ) {
        push @{$tmp_responses}, $response;
    };

    $self->{responses} = $tmp_responses;

    return;
};



1;