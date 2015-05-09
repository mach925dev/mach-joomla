#!/usr/bin/perl -w

=head1 NAME

Joomla backup export

=head1 SYNOPSIS

Creates hard links in the outgoing directory to a site's backups 

=head1 DESCRIPTION

The backup script stores its backups into a directory that is not visible to any ftp user. However, we want a directory visible to such a user so that offsite backups are possible. This script maintains an "outgoing" directory for that purpose. The backups visible there are hard links to the actual backups. There is no accumulation of files in this outgoing directory. Rather, this directory is an exact mirror of the internal backup directory.

=head1 AUTHOR

CaveDude (author of plagiarized code)
Barry Weinstein

=head1 DATE CREATED

May 04, 2015

=cut

use strict;
use warnings;
use Getopt::Long;

my $sitename = "";

&get_options;
&sanity_checks;

my $home = $ENV{'HOME'};
my $backup_dir = "$home/mach925/sitebackups/$sitename";
my $export_dir = "$home/public_ftp/outgoing/backup/sites/$sitename";

&export_backups;
exit;

sub export_backups
{
	print "exporting backups for site $sitename\n";
	# Delete all previous exports.
	print "cleaning export directory\n";
	system("rm $export_dir/*");
	opendir(my $DIR, $backup_dir);
	my $FILE;
	while($FILE = readdir($DIR)) 
	{
		print "linking $FILE\n";
		# Use hard links since the ftp user operates in a chroot jail.
		# ln will complain when the file is a directory (e.g. "." and "..").
		# A reasonable todo is to skip over directories. 
		system("ln $backup_dir/$FILE $export_dir/$FILE 2>/dev/null");
	}
	closedir($DIR);
}

sub sanity_checks
{
	# below are our sanity checks to make sure a real configuration file exists.
	if($sitename eq "")
	{
		print "Please specify a site name!\n";
		exit;
	}
}

sub get_options
{
	my $help = 0;
	# here we are handling our runtime parameters and help screen.
	GetOptions(
		'h'	=> \$help,
		's=s'	=> \$sitename,
	) or die "\033[1mType ./export.pl -h for usage.\033[0m";

	if($help) 
	{
		print "Usage: ./backup.pl -s=sitename [OPTIONS]\n";
		print " -s=name Specify the site name. \033[1mThis is a required switch.\n\033[0m";
		print " -h Display this help and exit.\n";
		exit;
	}
}
