=head1 SYNOPSIS

Skeleton of the configuration file for the Joomla backup script
 
=head1 DESCRIPTION

These parameters are invariant across scheduled backups of a single site. Parameters which vary according to purpose are supplied as switches to the backup script. 

This file should be copied and renamed to <sitename>.pl for each site being backed up. The values in this file will vary according to the requirements of that site. For example, each site has its own, dedicated MySQL database.

=head1 AUTHOR

CaveDude

=head1 DATE CREATED

April 27, 2015

=cut

use warnings;

# Used in the MySQL mysqldump command
sub get_host { return "localhost" };
# MySQL database user
sub get_user { return "myuser" };
# MySQL database password
sub get_password { return "mypassword" };
# MySQL database name
sub get_db      { return "mydatabase" };

1;
