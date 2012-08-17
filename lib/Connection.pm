package Connection;

use strict;
use warnings;

use VMware::VIRuntime;

my $connection;

sub get {
    
    if (not defined $connection) {
        $connection = Vim->new(service_url => Configuration::get("service_url"));
        $connection->login(user_name => Configuration::get("username"), password => Configuration::get("password"));
        return $connection;        
    } else {
        return $connection;
    }

}

sub logout {
    $connection->logout() if defined $connection;
}

1;
