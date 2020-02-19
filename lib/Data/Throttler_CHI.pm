package Data::Throttler_CHI;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

use List::BinarySearch::XS qw(binsearch_pos);

sub new {
    my ($package, %args) = @_;
    bless \%args, $package;
}

my $counter = 0;
sub try_push {
    my $self = shift;
    my $now = time();
    $counter++;
    $counter = 0 if $counter == 2e31; # wraparound 32bit int
    $self->{cache}->set(sprintf("%010d %d", $now, $counter), 1, $self->{interval}); # Y2286!

    # we assume the driver returns keys in insert order, to avoid having to sort()
    #my @keys = sort $self->{cache}->get_keys;
    my @keys = $self->{cache}->get_keys;

    return 1 if @keys <= $self->{max_items};

    my $time_expired = $now - $self->{interval};
    my $pos_not_expired = binsearch_pos { no warnings 'numeric'; $a <=> $b } $time_expired, @keys;

    $self->{cache}->purge if rand() < 0.01;

    (@keys - $pos_not_expired) <= $self->{max_items} ? 1:0;
}

1;
# ABSTRACT: Data::Throttler-like throttler with CHI backend

=head1 SYNOPSIS

 use Data::Throttler_CHI;
 use CHI;

 my $throttler = Data::Throttler_CHI->new(
     max_items => 100,
     interval  => 3600,
     cache     => CHI->new(driver=>"Memory", datastore=>{}),
 );

 if ($throttle->try_push) {
     print "Item can be pushed\n";
 } else {
     print "Item must wait\n";
 }


=head1 DESCRIPTION

EXPERIMENTAL, PROOF OF CONCEPT.

This module tries to use L<CHI> as the backend for data throttling. It presents
an interface similar to, but simpler than, L<Data::Throttler>.


=head1 METHODS

=head2 new

Usage:

 my $throttler = Data::Throttler_CHI->new(%args);

Known arguments (C<*> means required):

=over

=item * max_items*

=item * interval*

=item * cache*

CHI instance.

=back


=head2 try_push

Usage:

 $bool = $throttler->try_push(%args);

Return 1 if data can be pushed, or 0 if it must wait.

Known arguments:

=over

=back


=head1 SEE ALSO

L<Data::Throttler>

L<CHI>
