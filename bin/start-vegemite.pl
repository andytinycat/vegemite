#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Proc::Daemon;

use CounterCache;
use Configuration;
use Connection;

use Getopt::Long;

GetOptions ("vcenter|c=s", => \$Configuration::vcenter);
die "No vCenter chosen" unless defined $Configuration::vcenter;

CounterCache::refresh();
Connection::logout();
