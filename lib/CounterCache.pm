package CounterCache;

use strict;
use warnings;

use FindBin;

use Connection;
use Configuration;
use Data::Dumper;
use Text::CSV;

sub build {
    my $connection = Connection::get();

    # Get a performance manager
    my $perfmgr_view = $connection->get_view(mo_ref => $connection->get_service_content()->perfManager);

    # Read the counter.conf file, figure out what counters the user wants
    # isdvi.VirtualMachine.wwwapps-uat-a.cpu.usage.default
    my $csv = Text::CSV->new( sep_char => "." );
    open my $fh, "$FindBin::Bind/../conf/counters.conf" or die "$!";
    
    while (my $row = $csv->getline( $fh )) {

        # Decompose into variables
        my ($vcenter, $entity_type, $entity_filter, $countergroup, $countername, $instance);

        # If the vcenter is not the one we were started with, skip it
        next unless ($vcenter eq $Configuration::vcenter);

    }

    # Find a single VM and get all the counters from it
    my $entity = $connection->find_entity_view( view_type => "VirtualMachine" );
    my $perf_summary = $perfmgr_view->QueryPerfProviderSummary( entity => $entity );
    my $refresh_rate = $perf_summary->refreshRate;
    my $metrics = $perfmgr_view->QueryAvailablePerfMetric(
        entity      => $entity,
        intervalId  => $refresh_rate   
    );

    my $cache;
    foreach my $metric (@$metrics) {
        my $perf_counter = ($perfmgr_view->QueryPerfCounter(counterId => $metric->counterId))->[0];
        # Reference hashref is formed like this:
        # group->name->instance = counterid
        my $instance = $metric->instance ? $metric->instance : "default";
        $cache->{$perf_counter->groupInfo->key}->{$perf_counter->nameInfo->key}->{$instance} = $perf_counter->key; 
    }

    print Dumper $cache;
    
}

1;
