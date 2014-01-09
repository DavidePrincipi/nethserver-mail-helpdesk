nethserver-mail-helpdesk
========================

Extend nethserver-mail-server to implement a simple helpdesk scenario

The helpdesk group is a standard NethServer group of users with a
shared mailbox.

Outgoing messages from the members of the helpdesk group are
masqueraded with the helpdesk frontend mail address (configurable).

A copy of any outgoing message is sent to the helpdesk group itself.


Installation
------------

1. Install nethserver-mail package group:

   \# yum install @nethserver-mail

2. Create the group members from the server-manager web UI.

3. Clone this repository and step into the base directory:

   \# git clone git@github.com:DavidePrincipi/nethserver-mail-helpdesk.git

   \# cd nethserver-mail-helpdesk

4. Run the script:

   \# ./helpdesk_install.sh <groupname> <member1,member2,...>


If the given <groupname> does not exist, is created and initialized
with member1,member2,... as group members.  Note there must be no
spaces between the commas.


