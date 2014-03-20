ccj.cli
=======

A collection of command line scripts for the ccj hosting environment.

/
-

Misc. scripts which have not been sorted into a subdirectory.

hostname_create.sh
: startup tasks for new accounts on hosting servers.
: creates USERNAME ServerAlias, plus outputs DNS snippets

ew
--

Scripts for interacting with the EdgeWave API.

mailbox_report.sh 
: compiles a list of all active mailboxes for each domain, across all accounts
: creates a summary CSV report ACCOUNT, DOMAIN, # of MBOX

whm-hooks
---------

Scripts which hook into the WHM framework.

prekillacct
: actions which should automatically take place before an account is terminated in WHM
: backs up account, and places backup tarball in a deleted account folder.
