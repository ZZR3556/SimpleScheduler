#!/Strawberry/perl/bin/perl
use strict;
use warnings;

use CGI;
use DBI;
use DBD::Oracle;

my $q = CGI->new;
print $q->header;

my $host = "localhost";
my $sid = "orcl";
my $port = 1521;
my $dataSource = "dbi:Oracle:host=localhost;sid=orcl;port=1521";
my $user = "scott";
my $passwd = "tiger";

my $action = $q->param('action');

if ( defined $action )
{
  if ( $action eq "addAppointment" )
  {
    my $date = $q->param('date');
    my $time = $q->param('time');
    my $desc = $q->param('desc');
    my $dts = $q->param('dts');

    my $db = getConnection();

    my $query = "insert into schedule values (?,?,?,?)";
    my $statement = $db->prepare($query);
    $statement->execute($date,$time,$desc,$dts) or die $DBI::errstr;

    $db->commit or die $DBI::errstr;

    END { $db->disconnect if defined($db); }
  }

  print loadFile('SimpleSchedule.html');
}
else
{
  my $search_string = $q->param('getAppointments');

  if ( defined $search_string )
  {
    my $db = getConnection();

    my $query = "select app_date, app_time, app_desc from schedule where app_desc like ? order by dts";
    my $statement = $db->prepare($query);
    my $query_arg = '%' . $search_string . '%';
    $statement->execute( $query_arg ) or die $DBI::errstr;

    my $rows_returned = $statement->rows;

    my $apps = "[";

    while ( my @row = $statement->fetchrow_array() )
    {
      my ( $app_date, $app_time, $app_desc ) = @row;

      $apps = $apps . '{"date":"' . $app_date . '","time":"' . $app_time . '","desc":"' . $app_desc . '"},';
    }

    $statement->finish();

    if ( length $apps > 1 )
    {
      $apps = substr($apps, 0, -1);
    }

    $apps = $apps . "]";

    print $apps;

    END { $db->disconnect if defined($db); }
  }
  else
  {
    print loadFile('SimpleSchedule.html');
  }
}

sub getConnection
{
  my $db = DBI->connect($dataSource,$user,$passwd) or die $DBI::errstr;

  $db->{AutoCommit} = 0;
  $db->{RaiseError} = 1;

  $db;
}

sub loadFile
{
  local $/ = undef;
  my $template_file = shift;
  open F, $template_file or die "can't open $template_file";
  my $template = <F>;
  close F;
  $template;
}
