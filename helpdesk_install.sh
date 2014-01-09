#!/bin/bash

#
# Copyright (C) 2014 Nethesis S.r.l.
# http://www.nethesis.it - support@nethesis.it
# 
# This script is part of NethServer.
# 
# NethServer is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License,
# or any later version.
# 
# NethServer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with NethServer.  If not, see <http://www.gnu.org/licenses/>.
#

set -e

domain=`config get DomainName`
groupName=$1
shift
members=$1
shift

if [ -z "${groupName}" ]; then
    echo "group name is missing!";
    exit 1
fi

if [ -z "${members}" ]; then
    echo "members argument is missing!";
    exit 2
fi


# Install custom templates, if missing:
if ! [ -f /etc/e-smith/templates-custom/etc/postfix/main.cf/60helpdesk ]; then
    echo "Installing custom templates"
    rsync -Cav templates-custom/ /etc/e-smith/templates-custom/
fi

if ! getent group "${groupName}"; then

    echo "Configuring group ${groupName}"

    # Create group with shared mail delivery and initialize configuration:
    db accounts set "${groupName}" "group" MailDeliveryType "shared" MailStatus "enabled" Members "${members}" Description ""

    config set helpdesk "configuration" FrontendAddress "${groupName}@${domain}" FrontendName '' GroupName "${groupName}"

    signal-event group-create-pseudonyms ${groupName}
    signal-event group-create ${groupName}

    perl -e '
use strict;
use NethServer::MailServer;
my $groupName = shift;
my $imap = NethServer::MailServer->connectAclManager($groupName . "*vmail");

$imap->create("Sent");
$imap->setAcl("Sent", "\$" . $groupName, "lrs");

' -- ${groupName}
fi



# Expand extra-templates:
echo "Expanding templates"
expand-template /etc/postfix/helpdesk_maps
expand-template /etc/postfix/helpdesk_header.pcre

echo "Signaling nethserver-mail-server-update event"
signal-event nethserver-mail-server-update
