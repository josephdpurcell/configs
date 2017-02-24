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

# Add rules for input.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment "allow all connections originating from server"
iptables -A INPUT -i lo -j ACCEPT -m comment --comment "allow everything on loopback interface"
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP -m comment --comment "drop null packets"
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP -m comment --comment "drop empty connections and syn-flood packets"
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP -m comment --comment "drop XMAS packets"

# Block all inbound traffic except for whitelisted IPs.
iptables -A INPUT -p tcp -s X.X.X.X --dport 3306 -j ACCEPT -m comment --comment "allow MySQL from App Server"

# Also allow SSH from these IPs:
iptables -A INPUT -p tcp -s X.X.X.X --dport 22 -j ACCEPT -m comment --comment "allow SSH from ACME office"
iptables -A INPUT -p tcp -s X.X.X.X --dport 22 -j ACCEPT -m comment --comment "allow SSH from Joe Home"

# Drop all input that isn't accepted by a rule.
iptables -P INPUT DROP

# Drop all forward rules since we aren't doing NAT.
iptables -P FORWARD DROP

# Accept all outbound packets.
# @todo change default to DROP and insert some allows
iptables -P OUTPUT ACCEPT

# Save the iptables.
/sbin/service iptables save
