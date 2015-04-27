#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long;

# variable defaults
my $help = 0;
my $sitename = "default";
my $debug = 0;
my $test = 0;
my $backup = "daily";
my $prune = 0;
my $rollover = 7;
my $clean = 0;

# here we are handling our runtime parameters and help screen.
GetOptions(
	'h'	=> \$help,
	's=s'	=> \$sitename,
	'v'	=> \$debug,
	't'	=> \$test,
	'b=s'	=> \$backup,
	'p'	=> \$prune,
	'r=i'	=> \$rollover,
	'c'	=> \$clean,
) or die "\033[1mType ./backup.pl -h for usage.\033[0m";

if($help) 
{
	print "Usage: ./backup.pl -s=sitename [OPTIONS]\n";
	print " -s=name Specify the site name. \033[1mThis is a required switch.\n\033[0m";
	print " -h Display this help and exit.\n";
	print " -v Display debug messages.\n";
	print " -t Creates a test file in the backup location, deletes it, and exits.\n";
	print " -b=name Specify the backup name. (Default is daily)\n";
	print " -p Prune the oldest single backup.\n";
	print " -r=number Specify the number of backups to keep before deleting. (Default is 7)\n";
	print " -c Deletes all of the oldest backups that exceed the rollover number.\n";
	exit;
}


# below are our sanity checks to make sure a real configuration file exists.
if($sitename eq "")
{
	print "Please specify a site name!\n";
	exit;
}
elsif($sitename eq "default")
{
	print "You are using the default configuration file. Please copy default.pl to sitename.pl. (Ex: jmlMACH.pl) and run ./backup.pl with the -s switch.\n";
	exit;
}

my $INCLUDEFILE = "$sitename.pl";
if (!-e $INCLUDEFILE) 
{
	print "Your configuration file is missing! Please create it.\n";
	exit;
}


# load the MySQL and Linux account details from our config file.
require "$sitename.pl";

my $user = get_user();
my $password = get_password();
my $host = get_host();
my $db = get_db();
my $account = get_account();

# set backup file name, and source/destination paths.
my ($sec,$min,$hour,$day,$month,$yr19) = localtime(time);
my $year = $yr19 + 1900;
my $time_string = sprintf "%d-%02d-%02d\_%02d:%02d:%02d", $year, $month, $day, $hour, $min, $sec;

my $backup_filename = "$sitename\_$backup\_$time_string";
my $joomla_dir = "/home/$account/public_html/$sitename";
my $backup_dir = "/home/$account/mach925/sitebackups/$sitename";

# runs a quick test to ensure the system's environment supports our script and exits.
if($test == 1)
{
	&run_test();
	exit;
}
# deletest oldest backup(s) if prune is true.
if($prune == 1)
{
	&delete_loop();
}
else
{
	print "Skipping backup deletion... \n";
}

&create_backup;
exit;




sub delete_loop
{
	# Count up our files that match string pattern.
	opendir(DIR, $backup_dir);
	my $FILE;
	my $file_count = 0;
	while($FILE = readdir(DIR)) 
	{
		# Check to see if the file is a .tar.gz
		if($FILE =~ /\.tar.gz$/i)
		{
			++$file_count;
		}
		else
		{
			if($debug == 1)
			{
				print "[DEBUG]Skipping file/directory ($FILE) \n";
			}
		}
	}
	closedir(DIR);
	if($debug == 1)
	{
		print "[DEBUG]File count: $file_count \n";
	}

	# Delete oldest archive if we exceed our kept backups.
	if($file_count >= $rollover)
	{
		# We have exceeded our allowed backups, perform a loop to delete the excess files.
		if($file_count > $rollover && $clean == 1)
		{
			if($debug == 1)
			{
				print "[DEBUG]Exceeded allowed backups, multiple files will be deleted. \n";
			}
			my $diff = $file_count - $rollover;
			my $count = 0;
			while($count < $diff)
			{
				&delete_oldest_file();
				++$count;
			}
		}
		else
		{
			&delete_oldest_file();
		}
	}
}

sub delete_oldest_file
{
	my $oldest_file = (sort{(stat $a)[10] <=> (stat $b)[10]}glob "$backup_dir/*.tar.gz")[0];
	if($debug == 1)
	{
		print "[DEBUG]Deleting file: $oldest_file. \n";
	}
	system("rm $oldest_file");
}

sub create_backup
{
	if($debug == 1)
	{
		print "[DEBUG]Dumping database... \n";
	}
	system("cd $joomla_dir; mysqldump -u $user -h $host --compact --allow-keywords --extended-insert --tables --password=$password $db > softsql.sql");

	if($debug == 1)
	{
		print "[DEBUG]Creating archive... \n";
	}
	system("cd $joomla_dir; tar -zcvf $backup_dir/$backup_filename.tar.gz * > /dev/null");
}

sub run_test
{
	my $test_filename = "joomla_perl_test.txt";
	print "[TEST]Creating a file called $test_filename in $backup_dir. \n";
	system ("touch $backup_dir/$test_filename");
	
	print "[TEST]Checking for $test_filename. \n";
	my $TESTFILE = "$backup_dir/$test_filename";
	if (-e $TESTFILE) 
	{
		print "[TEST]Deleting $test_filename. \n";
	}
	else
	{
		print "[TEST]Test failed! Make sure file permissions are correct and Perl can use `system` \n";
		exit;
	}
		
	system("rm $backup_dir/$test_filename");
	if (-e $TESTFILE) 
	{
		print "[TEST]Test failed! $test_filename exists, but Perl could not delete it. \n";
		exit;
	}
	else
	{
		print "[TEST]Test successful! \n";
		exit;
	}
}
