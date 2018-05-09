#!/usr/bin/perl
# Disk Monitor
# USAGE: dmon <mount> <percent>
# e.g.: dmon /usr 80
@notify_cmd = ‘/usr/platform/SUNW,Netra x40/sbin/scadm’;
if (scalar(@ARGV) != 2)
{
print STDERR "USAGE: dmon.pl <mount_point> <percentage>\n";
print STDERR " e.g. dmon.pl /export/home 80\n\n";
exit;
}
open(DF, "df -k|");
$title = <DF>;
$found = 0;
while ($fields = <DF>)
{
chop($fields);
($fs, $size, $used, $avail, $capacity, $mount) = split(‘ ‘,$fields);
if ($ARGV[0] eq $mount)
{
$found = 1;
if ($capacity > $ARGV[1])
{
print STDERR "ALERT: '", $mount, "\” is at ", $capacity,\
" of capacity, sending notification\n";
$notify_msg = ‘mount point "‘.$mount.’" is at ‘. $capacity.’ of capacity’;
exec (@notify_cmd, ‘send_event’, ‘-c’, $nofify_msg) || die "ERROR: $!\n";
}
}
}
if ($found != 1)
{
print STDERR "ERROR: '", $ARGV[0],
“\” is not a valid mount point\n\n";
}
close(DF);