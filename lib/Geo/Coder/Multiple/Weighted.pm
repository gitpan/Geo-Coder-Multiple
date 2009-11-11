package Geo::Coder::Multiple::Weighted;

use strict;

use Math::Round qw( round );

sub new {
    my $class = shift;

    my $self = {
        weighted_list   => [],
    };
    bless $self, $class;

    return( $self );
};


sub initialize_sources {
    my $self = shift;
    my $sources = shift;

    $sources = $self->_reduce_and_sort_weightings( $sources );

    my $total_weight = 0;
    map { $total_weight += $_->{weight} } @{$sources};

    foreach my $source ( @{$sources} ) {
        my $frequency = $total_weight / ($source->{weight} + 1);
        $self->_fill_weighted_list( $frequency, $source->{name}, $total_weight-1 );
    };

    return;
};


sub get_list { return( $_[0]->{weighted_list} ) };


sub _reduce_and_sort_weightings {
    my $self = shift;
    my $sources = shift;

    my @weights = ();

    foreach my $source ( @{$sources} ) {
        push @weights, $source->{weight};
    };   

    my $common_factor = multigcf( @weights );

    my $sorted_sources = [];

    foreach my $source ( sort sort_weights_descending(@{$sources}) ) {
        $source->{weight} /= $common_factor;
        push @{$sorted_sources}, $source;
    };   

    return( $sorted_sources );
};


sub sort_weights_descending { $a->{weight} <=> $b->{weight}; };


sub _fill_weighted_list {
    my $self = shift;
    my $frequency = shift;
    my $name = shift;
    my $total = shift;

    for( my $count = $frequency; $count < $total; $count += $frequency ) {
        my $temp_count = round( $count ) - 1;
        while( defined($self->{weighted_list}->[$temp_count]) && $temp_count < $total ) {
            $temp_count++;
        };
       
        if( defined($self->{weighted_list}->[$temp_count]) && $temp_count == $total ) { 
            $temp_count = 0;
        };

        $self->{weighted_list}->[$temp_count] = $name;
    };

    return;
};


# Taken from: http://www.perlmonks.org/?node=greatest%20common%20factor
sub gcf {
    my ($x, $y) = @_;
    ($x, $y) = ($y, $x % $y) while $y;
    return $x;
}

sub multigcf {
    my $x = shift;
    $x = gcf($x, shift) while @_;
    return $x;
};

1;