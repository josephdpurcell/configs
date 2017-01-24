#!/bin/bash
#
# Firewall Rules for Database Server
#
# This is a work in progress. The general idea is to block all inbound traffic
# except for application ports (e.g. 80, 443, 3306).
#
# Also, many thanks to Digital Ocean from which I drew a few hints:
# https://www.digitalocean.com/community/articles/how-to-setup-a-basic-ip-tables-configuration-on-centos-6
#
# Instructions:
#   1. Change the X.X.X.X to the server that will be connecting to MySQL.
#   2. Change the Y.Y.Y.Y IPs to any IPs you want to SSH from.
#
# Tip:
#   * Run "iptables --list --numeric --line-numbers --verbose" to list iptables

# Clear all iptable rules.
iptables -F
iptables -X

# Add rules for accepted input.
# Allow any connection that originated from this server.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Accept everything no matter port on the loopback interface.
iptables -A INPUT -i lo -j ACCEPT
# Drop all null packets (recon packets).
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
# Drop all empty connections (syn-flood packets).
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
# Drop all packets full of options (XMAS packets, also recon packets).
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Block all inbound traffic except for MySQL from the app server.
iptables -A INPUT -p tcp -s X.X.X.X --dport 3306 -j ACCEPT

# Also allow SSH from these IPs:
# ACME Office
iptables -A INPUT -p tcp -s Y.Y.Y.Y --dport 22 -j ACCEPT
# Other Example Office
iptables -A INPUT -p tcp -s Y.Y.Y.Y --dport 22 -j ACCEPT

# Drop all input that isn't accepted by a rule.
iptables -P INPUT DROP

# Drop all forward rules since we aren't doing NAT.
iptables -P FORWARD DROP

# Accept all outbound packets.
# @todo change default to DROP and insert some allows
iptables -P OUTPUT ACCEPT

# Save the iptables.
/sbin/service iptables save
