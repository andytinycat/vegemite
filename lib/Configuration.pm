package Configuration;

use strict;
use warnings;

use FindBin;
use Config::General;
use Data::Dumper;

my %config;
our $vcenter;

sub get {
    read_config() unless scalar(keys %config) > 0;
    my $param = shift;
    $config{'vcenter'}->{$vcenter}->{$param};
}

sub read_config {
    %config = Config::General::ParseConfig("$FindBin::Bin/../conf/vegemite.conf");
}

1;
