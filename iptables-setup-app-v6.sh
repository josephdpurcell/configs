#!/bin/bash
#
# Firewall Rules for HTTP Application Server
#
# This is a work in progress. The general idea is to block all inbound traffic
# except for application ports (e.g. 80, 443, 3306).
#
# Also, many thanks to Digital Ocean from which I drew a few hints:
# https://www.digitalocean.com/community/articles/how-to-setup-a-basic-ip-tables-configuration-on-centos-6
#
# Instructions:
#   1. Change the Y.Y.Y.Y IPs to any IPs you want to SSH from.
#
# Tip:
#   * Run "ip6tables --list --numeric --line-numbers --verbose" to list iptables

# Clear all iptable rules.
ip6tables -F
ip6tables -X

# Add rules for input.
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment "allow all connections originating from server"
ip6tables -A INPUT -i lo -j ACCEPT -m comment --comment "allow everything on loopback interface"
ip6tables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP -m comment --comment "drop null packets"
ip6tables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP -m comment --comment "drop empty connections and syn-flood packets"
ip6tables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP -m comment --comment "drop XMAS packets"

# Block all inbound traffic except HTTP ports.
ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "allow HTTP from WAN"
ip6tables -A INPUT -p tcp --dport 443 -j ACCEPT -m comment --comment "allow HTTPS from WAN"

# Also allow SSH from these IPs:
ip6tables -A INPUT -p tcp -s X.X.X.X --dport 22 -j ACCEPT -m comment --comment "allow SSH from ACME office"
ip6tables -A INPUT -p tcp -s X.X.X.X --dport 22 -j ACCEPT -m comment --comment "allow SSH from Joe Home"

# Drop all input that isn't accepted by a rule.
ip6tables -P INPUT DROP

# Drop all forward rules since we aren't doing NAT.
ip6tables -P FORWARD DROP

# Accept all outbound packets.
# @todo change default to DROP and insert some allows
ip6tables -P OUTPUT ACCEPT

# Save the iptables.
/sbin/service iptables save
