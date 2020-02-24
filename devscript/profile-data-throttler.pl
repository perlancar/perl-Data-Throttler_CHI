#!/usr/bin/env perl

require Data::Throttler;
my $t = Data::Throttler->new(max_items=>1000, interval=>3600);
for (1..1000) { $t->try_push }
