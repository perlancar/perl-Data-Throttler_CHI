#!/usr/bin/env perl

require CHI;
require Data::Throttler_CHI;
my $t = Data::Throttler_CHI->new(max_items=>1000, interval=>3600, cache=>CHI->new(driver=>"Memory", datastore=>{}));
for (1..1000) { $t->try_push }
