#!/usr/bin/perl

# This script allows you to get a list of all the counters available for a
# particular object, including their counter IDs (which you will need to
# query them for data). Counter IDs vary between stacks, as it is
# 'system assigned' (probably generated during install).
#
# How to use:
# ./list-counters.pl --config vmware_config_isdvi --object <object name> --object_type <object type>

use strict;
use warnings;

use VMware::VIRuntime;

my %opts = (
    object => {
        type        => '=s',
        required    => 1,
        help        => 'Name of object to list counters for'
    },
    object_type => {
        type        => '=s',
        required    => 1,
        help        => 'Type of object'
    }
);

Opts::add_options(%opts);
Opts::parse();
Opts::validate();

Util::connect();

eval {

    my $object = Opts::get_option('object');
    my $object_type = Opts::get_option('object_type');

    # Find the object in question
    my $entity = Vim::find_entity_view( 
        view_type => $object_type, 
        filter => { 'name' => $object } );

    if (!$entity) {
        print "Object not found\n";
        Util::disconnect();
        exit 1;
    }

    # Get a performance manager
    my $perfmgr_view = Vim::get_view(mo_ref => Vim::get_service_content()->perfManager);

    # Use it to get the refresh rate of the object - you need to supply this with
    # your query for counters to get all the real-time counters (otherwise it just
    # shows counters with historical data)
    my $perf_summary = $perfmgr_view->QueryPerfProviderSummary( entity => $entity );
    my $refresh_rate = $perf_summary->refreshRate;
       
    # Ask for all the counters for the entity
    my $metric_ids = $perfmgr_view->QueryAvailablePerfMetric(
        entity      => $entity,
        intervalId  => $refresh_rate
    );

    # Walk the returned counter IDs and resolve their descriptions etc.
    foreach my $metric_id (@$metric_ids) {
        my $perf_counter = $perfmgr_view->QueryPerfCounter(counterId => $metric_id->counterId);
        print "---\n";
        print "Counter ID: " . $perf_counter->[0]->key . "\n";
        print "Name:       " . $perf_counter->[0]->nameInfo->key . "\n";
        print "Instance:   " . $metric_id->instance . "\n";
        print "Summary:    " . $perf_counter->[0]->nameInfo->summary . "\n";
    }
 
    Util::disconnect();
    1;

} or do {
    print ref($@->detail) . "\n";
    Util::disconnect();
}
