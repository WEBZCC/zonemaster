package Giraffa::Test::DNSSEC v0.0.1;

###
### This test module implements DNSSEC tests.
###

use 5.14.2;
use strict;
use warnings;

use Giraffa;
use Giraffa::Util;

###
### Entry points
###

sub all {
    my ( $class, $zone ) = @_;
    my @results;

    push @results, $class->dnssec01( $zone );

    return @results;
}

###
### Metadata Exposure
###

sub metadata {
    my ( $class ) = @_;

    return { dnssec01 => [qw( DS_DIGTYPE_OK DS_DIGTYPE_NOT_OK NO_DS )] };
}

sub version {
    return "$Giraffa::Test::DNSSEC::VERSION";
}

###
### Tests
###

sub dnssec01 {
    my ( $class, $zone ) = @_;
    my @results;

    my %type = ( 1 => 'SHA-1', 2 => 'SHA-256', 3 => 'GOST R 34.11-94', 4 => 'SHA-384' );

    my $ds_p = $zone->parent->query_one( $zone->name, 'DS' );
    die "No response from parent nameservers" if not $ds_p;
    my @ds = $ds_p->get_records( 'DS', 'answer' );

    if ( @ds == 0 ) {
        push @results, info( NO_DS => { zone => '' . $zone->name, from => $ds_p->answerfrom } );
    }
    else {
        foreach my $ds ( @ds ) {
            if ( $type{ $ds->digtype } ) {
                push @results, info( DS_DIGTYPE_OK => { keytag => $ds->keytag, digtype => $type{ $ds->digtype } } );
            }
            else {
                push @results, info( DS_DIGTYPE_NOT_OK => { keytag => $ds->keytag, digtype => $ds->digtype } );
            }
        }
    }

    return @results;
} ## end sub dnssec01

1;

=head1 NAME

Giraffa::Test::DNSSEC - dnssec module showing the expected structure of Giraffa test modules

=head1 SYNOPSIS

    my @results = Giraffa::Test::DNSSEC->all($zone);

=head1 METHODS

=over

=item all($zone)

Runs the default set of tests and returns a list of log entries made by the tests.

=item metadata()

Returns a reference to a hash, the keys of which are the names of all test methods in the module, and the corresponding values are references to
lists with all the tags that the method can use in log entries.

=item version()

Returns a version string for the module.

=back

=head1 TESTS

=over

=item dnssec01($zone)

Verifies that all DS records have digest types registered with IANA.

=back

=cut
