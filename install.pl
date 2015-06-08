#!/usr/bin/perl -w

use strict;


# Misc vars
my (%options, $version, $name, $user);
$version = "1.1.6";
$name = "torrtux";
if(!($user = getlogin()))
{
    print "Error in Unix permissions !";
}


# Editable paths
$options{'sharedir'} = "/usr/share/$name";
$options{'docdir'} = "/usr/share/doc/$name";
$options{'scriptdir'} = "/usr/bin";
$options{'configdir'} = "/home/$user/";
$options{'mandir'} = "/usr/share/man/man1";


# Help overrides anything else
for (@ARGV)	{
	if (/^(--help|-h)$/) {
		print <<END_HELP;
Usage: $0 [OPTION]
This program installs torrtux. Options are as follows:

Options:
  -q  --quiet           turn off progress messages	
      --verbose         turn on extra progress information, overrides -q
      --sharedir=DIR    install shared files to DIR instead of
                        /usr/share/torrtux/
      --mandir=DIR	install manpage to DIR
      --scriptdir=DIR   install scripts to DIR instead of /usr/bin/
      --docdir=DIR      install documentation to DIR/torrtux
                        instead of /usr/share/doc/torrtux

Bugs and comments to huguenindl\@gmail.com
END_HELP
		exit;
	}
}


# Parse options
for (@ARGV)
{
	if (/^--sharedir=(.+)$/)
	{
		$options{'sharedir'} = $1;
	}
	elsif (/^--scriptdir=(.+)$/)
	{
		$options{'scriptdir'} = $1;
	}
	elsif (/^--docdir=(.+)$/)
	{
		$options{'docdir'} = "$1/$name";
	}
	elsif (/^--mandir=(.+)$/)
	{
	    	$options{'mandir'} = $1;
 	}
	elsif (/^(--quiet|-q)$/)
	{
		$options{'quiet'} = 1;
	}
	elsif (/^--verbose$/)
	{
		$options{'verbose'} = 1;
	}
	else {
		die "Unknown option: $_\n";
	}
}

# verbose overrides quiet
if ($options{'verbose'} and $options{'quiet'}) {undef $options{'quiet'}}


# Install:

# defs:
if ($options{'verbose'}) { warn "Installing definitions files to directory $options{'sharedir'}\n" }

if (system("install -d $options{'sharedir'}")) {
	die "Error creating install directory. See above for reason.\n";
}

if (system("install *.pm $options{'sharedir'}/")) {
	die "Error installing definition files. See above for reason.\n";
}


# docs:
if ($options{'verbose'}) { warn "Installing docs to directory $options{'docdir'}\n" }

if (system("install -d $options{'docdir'}")) {
	die "Error creating documentation directory. See above for reason.\n";
}

if (system("install TODO DEPENDS LICENSE README $options{'docdir'}")) {
	die "Error installing documentation files. See above for reason.\n";
}


# scripts:
if ($options{'verbose'}) { warn "Installing scripts to directory $options{'scriptdir'}\n" }

if (system("install -d $options{'scriptdir'}")) {
	die "Error creating scripts directory. See above for reason.\n";
}

if (system("install $name $options{'scriptdir'}")) {
	die "Error installing script. See above for reason.\n";
}

# configfile:
if ($options{'verbose'}) { warn "Installing configfile to directory $options{'scriptdir'}\n" }

if(-e "$options{'configdir'}.torrtuxrc"){
    if(system("install .torrtuxrc $options{'docdir'}/torrtuxrc")) {
	die "Error installing configfile. See above for reason.\n";
    }
    print "!!! New configfile put in $options{'docdir'}/torrtuxrc. Move the file to $options{'configdir'}.torrtuxrc if necessary.\n";
   }

else{
if (system("install -Dm644 .torrtuxrc $options{'configdir'} && chown $user $options{'configdir'}.torrtuxrc")) {
	die "Error installing configfile. See above for reason.\n";
}}

# manpage:
if ($options{'verbose'}) { warn "Installing manpage to directory $options{'mandir'}\n" }

if (system("install -Dm644 torrtux.1.gz $options{'mandir'}")) {
	die "Error installing manpage. See above for reason.\n";
}

unless ($options{'quiet'}) {warn "torrtux $version installed successfully.\n" }
