#!"C:\xampp\perl\bin\perl.exe"
use strict;
use warnings;
 
use CGI;
my $q = CGI->new;
print $q->header;
 
my $name = $q->param('name') || '';
 
print "Hello $name\n";