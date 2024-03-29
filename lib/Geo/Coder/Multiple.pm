package Geo::Coder::Multiple;

$VERSION = 0.61;

use strict;
use warnings;

use List::Util::WeightedRoundRobin;

use Geo::Coder::Multiple::Bing;
use Geo::Coder::Multiple::Google;
use Geo::Coder::Multiple::Multimap;
use Geo::Coder::Multiple::Yahoo;


sub new {
    my $class = shift;
    my $args = shift;

    my $self = {
        cache               => undef,
        geocoders           => {},
        weighted_list       => [],
        normalize_code_ref  => $args->{normalize_code_ref},
    };

    bless $self, $class;

    if( $args->{cache} ) {
        $self->_set_caching_object( $args->{cache} );
    };

    return( $self );
};


sub add_geocoder { 
    my $self = shift;
    my $args = shift;

    my $geocoder_ref = ref( $args->{geocoder} );

    $geocoder_ref =~ s/Geo::Coder::/Geo::Coder::Multiple::/;

    eval {
        my $geocoder = $geocoder_ref->new( $args );
        $self->{geocoders}->{$geocoder_ref} = $geocoder;
    };

    if( $@ ) {
        warn "Geocoder not supported - $geocoder_ref\n";
        return 0;
    };

    $self->_recalculate_geocoder_stats();

    return 1;
};


sub geocode {
    my $self = shift;
    my $args = shift;

    unless( $args->{no_cache} ) {
        my $Response = $self->_get_from_cache( $args->{location}, $args->{cache} );
        if( defined($Response) ) { return( $Response ) };
    };

    my $geocoders_count = @{$self->_get_geocoders()};
    my $Response;
    my $previous_geocoder_name = '';

    while( (!defined($Response) || $Response->get_response_code != 200) && ($geocoders_count > 0) ) {
        $geocoders_count--;
        my $geocoder = $self->_get_next_geocoder();
        my $geocoder_name = $geocoder->get_name();
        next if( $geocoder_name eq $previous_geocoder_name );
        next if( grep /^$geocoder_name$/, @{$args->{geocoders_to_skip}} );
        $Response = $geocoder->geocode( $args->{location} );
        $previous_geocoder_name = $geocoder_name;
    };

    unless( $args->{no_cache} && (!defined($Response) || $Response->get_response_code != 200) ) {
        $self->_set_in_cache( $args->{location}, $Response, $args->{cache} );
    };

    return( $Response );
};


sub _get_geocoders { 
    my $self = shift;

    my $geocoders = [];

    foreach my $key ( keys %{$self->{geocoders}} ) {
        push @{$geocoders}, $self->{geocoders}->{$key};
    };

    return( $geocoders );
};


sub _get_next_geocoder {
    my $self = shift;

    # Return the next most appropriate geocoder based on the weighted
    # round robin scoring
    my $next = shift @{$self->{weighted_list}};
    push @{$self->{weighted_list}}, $next;   

    return( $self->{geocoders}->{$next} );
};


sub _recalculate_geocoder_stats {
    my $self = shift;
    
    my $geocoders = $self->_get_geocoders();
    my $slim_geocoders = [];

    foreach my $geocoder ( @{$geocoders} ) {
        my $tmp = {
            weight  => $geocoder->{daily_limit},
            name    => ref( $geocoder ),
        };
        push @{$slim_geocoders}, $tmp;
    };

    my $WeightedList = List::Util::WeightedRoundRobin->new();
    $self->{weighted_list} = $WeightedList->create_weighted_list( $slim_geocoders );

    unless( @{$self->{weighted_list}} ) {
        die "Unable to create weighted list from list of geocoders";
    };

    return;
};


sub _cleanse_address {
    my $self = shift;
    my $raw_location = shift;

    # Remove extra spaces
    $raw_location =~ s/^\s*//;
    $raw_location =~ s/\s*$//;
    $raw_location =~ s/\s{2}/ /g;

    return( $raw_location );
};

# Set the list of cache objects
#
sub _set_caching_object {
    my $self = shift;
    my $cache_obj = shift;

    $self->_test_cache_object( $cache_obj );
    $self->{cache} = $cache_obj;
    $self->{cache_enabled} = 1;

    return;
};


# Test the cache to ensure it has 'get' and 'set' methods
#
sub _test_cache_object {
    my $self = shift;
    my $cache_object = shift;

    # Test to ensure the cache works
    eval {
        $cache_object->set( '1234', 'test' );
        die unless( $cache_object->get('1234') eq 'test' );
    };

    if( $@ ) { 
        die "Unable to use user provided cache object: ". ref($cache_object);
    };

    return;
};


# Store the result in the cache
sub _set_in_cache {
    my $self = shift;
    my $location = shift;
    my $Response = shift;
    my $cache = shift || $self->{cache};

    my $normalized_location = $self->_normalize_location_string( $location );
    my $location_key = $normalized_location || $location;

    if( $cache ) {
        $cache->set( $location_key, $Response );
        return( 1 );
    };

    return( 0 );
};


# Check the cache to see if the data is available
sub _get_from_cache {
    my $self = shift;
    my $location = shift;
    my $cache = shift || $self->{cache};

    if( $cache ) {
        my $normalized_location = $self->_normalize_location_string($location);
        my $location_key = $normalized_location || $location;

        my $Response = $cache->get( $location_key );
        if( $Response ) {
            $Response->{response_code} = 210;
            return( $Response );
        };
    };

    return;
};


sub _normalize_location_string {
    my $self = shift;
    my $location = shift;

    if( $self->{normalize_code_ref} ) {
        my $code_ref = $self->{normalize_code_ref};
        my $normalized_location = &$code_ref( $location ); 

        return $normalized_location;
    };

    return $location;
};


1;

__END__

=head1 NAME

Geo::Coder::Multiple - Module to tie together multiple Geo::Coder::* modules

=head1 SYNOPSIS

  # for Geo::Coder::Jingle and Geo::Coder::Bells
  use Geo::Coder::Jingle;
  use Geo::Coder::Bells;
  use Geo::Coder::Multiple;
  
  my $options = {
    cache   => $cache_object,
  };

  my $geocoder_multi = Geo::Coder::Multiple->new( $options );

  my $jingle = Geo::Coder::Jingle->new( apikey => 'Jingle API Key' );

  my $jingle_options = {
    geocoder    => $jingle,
    daily_limit => 25000,
  };

  my $geocoder_multi->add_geocoder( $jingle_options );

  my $bells = Geo::Coder::Bells->new( apikey => 'Bells API Key' );

  my $bells_options = {
    geocoder    => $bells,
    daily_limit => 4000,
  };

  my $geocoder_multi->add_geocoder( $bells_options );

  my $location = $geocoder_multi->geocode( { location => '82 Clerkenwell Road, London, EC1M 5RF' } );

  if( $location->{response_code} == 200 ) {
    print $location->{address} ."\n";
  };

=head1 DESCRIPTION

Geo::Coder::Multiple is a wrapper for multiple Geo::Coder::* modules.

Most free geocoding datasource specify a limit to the number of queries which
can be sent from an IP or made using an API key in a 24 hour period. This 
module balances the incoming requests across the available sources to ensure
individual limits are exceeded only when the total limit is exceeded.

The algorithm for load balancing takes into account the limit imposed by the 
source per 24 hour period. 

Any network or source outages are handled by C<Geo::Coder::Multiple>.

=head1 METHOD

=over 4

=head2 new   

Constructs a new C<Geo::Coder::Multiple> object and returns it. If no options 
are specified, no caching will be done for the geocoding results.

The 'normalize_code_ref' is a code reference which is used to normalize
location strings to ensure that all cache keys are normalized for correct
lookup.

  KEY                   VALUE
  -----------           --------------------
  cache                 cache object reference  (optional)
  normalize_code_ref    A normalization code ref (optional)


=head2 add_geocoder

  my $jingle = Geo::Coder::Jingle->new( apikey => 'Jingle API Key' );
  my $jingle_limit = 25000;

  my $options = {
    geocoder    => $jingle,
    daily_limit => $jingle_limit,
  };

  my $geocoder_multi->add_geocoder( $options );


In order to load balance geocode queries across multiple sources, these sources
must be added to the list of available sources.

Before any geocoding can be performed, at least one geocoder must be added
to the list of available geocoders.

If the same geocoder is added twice, only the instance added first will be 
used. All other additions will be ignored.

  KEY                   VALUE
  -----------           --------------------
  geocoder              geocoder reference object
  limit                 geocoder source limit per 24 hour period


=head2 geocode

  my $options = {
    location        => $location,
    results_cache   => $cache,
  };

  my $found_location = $geocoder_multi->geocode( $options );

The arguments to the C<geocode> method are:

  KEY                   VALUE
  -----------           --------------------
  location              location string to pass to geocoder
  results_cache         reference to a cache object, will over-ride the default
  no_cache              if set, the result will not be retrieved or set in cache (off by default)

This method is the basis for the class, it will retrieve result from cache
first, and return if cache hit.

If the cache is missed, the C<geocode> method is called, with the location as 
the argument, on the next available geocoder object in the sequence.

If called in an array context all the matching results will be returned,
otherwise the first result will be returned.

A matching address will have the following keys in the hash reference.

  KEY                   VALUE
  -----------           --------------------
  response_code         integer response code (see below)
  address               matched address
  latitude              latitude of matched address
  longitude             longitude of matched address
  country               country of matched address (not available for all geocoders)
  geocoder              source used to lookup address

The C<geocoder> key will contain a string denoting which geocoder returned the
results (eg, 'jingle').

The C<response_code> key will contain the response code. The possible values
are:

  200   Success 
  210   Success (from cache)
  401   Unable to find location
  402   All geocoder limits reached (not yet implemented)
  403   Unspecified failure

=head1 NOTES

All cache objects used must support 'get' and 'set' methods.

The input (location) string is expected to be in utf-8. Incorrectly encoded
strings will make for unreliable geocoding results. All strings returned will
be in utf-8. returned latitude and longitude co-ordinates will be in WGS84
format.

In the case of an error, this module will print a warning and then may call
die().


=head1 Geo::Coder Interface

The Geo::Coder::* modules added to the geocoding source list must have a 
C<geocode> method which takes a single location string as an argument.

Currently supported Geo::Coder::* modules are:

  Geo::Coder::Bing
  Geo::Coder::Google
  Geo::Coder::Multimap
  Geo::Coder::Yahoo


=head1 SEE ALSO

  Geo::Coder::Bing
  Geo::Coder::Google
  Geo::Coder::Multimap
  Geo::Coder::Yahoo


=head1 AUTHOR

Alistair Francis, http://search.cpan.org/~friffin/

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.

=cut

