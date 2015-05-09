# mach-joomla
The [mach925.org][] website is the community portal of the MACH 925 makerspace.

## Joomla

The website is implemented using [Joomla][] content management system (CMS). Joomla eliminates much of the heavy lifting of delivering a website; we can mainly focus on content.

A Joomla website is portable. It can by moved to any host who supports the Joomla platform. (Actually, PHP and MySQL are the only requirements.) Moving the website involves copying a single directory tree and a MySQL database. Such a copy would also serve as a backup of the site should it need to be restored.

## Backups

We use Namecheap as our web host. They do supply basic backup functionality. However, it is not very flexible. On the surface, it doesn't seem to support more than one schedule (e.g. daily and weekly schedules). Even if it did, we couldn't find documentation explaining how to set that up. Also, it's not obvious how the backup makes its decision on how and when to roll files. There is no visibility into what the actual process is. The backup code is a PHP script which is not readable by our account user.

We decided to write our own backup. Not only will the process be completely transparent, it will also allow us to accompany the backup with other scheduled tasks. For example, we will copy our backups into a folder accessible to an ftp user. That user account will serve as source for offsite backups.

## Restoring from a backup

A backup is a single tarball. In the archive is the installation directory tree and a file respresenting a dump of the MySQL database found in the root of that tree. Follow these steps to bring up the website on a fresh Joomla install.

*  Expand the tarball into the doc root directory of your website.

*  Edit the `configuration.php` file in that root directory. Changes to this file are mostly self explanatory. You'll alter configuration options representing file system locations, database user name, and database password.

    One option in this configuration file is "force_ssl". Set this to 0 if you do not have, or want to use, an SSL certificate and the https protocol. 

*  Build your database using the sql dump found in the root directory. Simply redirect the stdin of the mysql to read from this file. For example, `mysql -u root -p dbname < dumpfile.sql`. The dumpfile will atempt to recreate the database. So if the database already exists, delete it before you try to restore.

*  Assuming Apache is your web server, ensure that mod_rewrite is enabled. Also, make sure Apache will allow `Options +FollowSymLinks` for the Joomla doc root. Apache needs to be configured this way in order for our relative URLs to follow a simple pattern. Here's some detail.

    In Joomla's administrative interface our site has "Search Engine Friendly URLs" turned on. This allows our links to look like `http://mc17/jmlMACH/index.php/blog` rather than `http://mc17/jmlMACH/index.php?option=com_content&view=category&layout=blog&id=9&Itemid=114`. 

    We've taken this one step further and turned on "Use URL Rewriting". This allows us to have links like `http://mc17/jmlMACH/blog` rather than `http://mc17/jmlMACH/index.php/blog`.

    If you simply want to have a working site without the webserver fuss, then you only have to turn these two features off in the administrative interface.

## The code

This repository is the definitive source of the backup code as well as any other utilities written to support the site. Of course, the only code that matters is what's installed and running on the web host. Rarely, if ever, should the utilities be modified directly on the host. Rather, the versions in the git repository should be modified, tested with a local installation of Joomla, and then copied to the host.

Backups must not be tested on the web host. It has happened that a couple tests of a backup caused us to exceed our allowed disk I/O limits. As a consequence, Namecheap throttled our site for over 10 minutes. 

[mach925.org]: https://burnwafuss.com/jmlMACH "Mach925.org" target="_blank"
[joomla]: http://www.joomla.org "Joomla" target="_blank"
