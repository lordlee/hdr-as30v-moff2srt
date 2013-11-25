#!/usr/bin/perl -w

use strict;

my $file = $ARGV[0];
exit if $file !~ /moff$/;

open (AA, $file) || die 'can not open file';

my $serial=1;
my $start_time;
my $cur_time;
while (<AA>) {
        chomp;
        my $line = $_;
        if ( $line =~ /^\$GP/ ) {
                my @fields = split /,/,$line;

                #$fields[1]             #time
                #$fields[3].$fields[4]  #position
                #$fields[5].$fields[6]  #position
                #$fields[7]*1.852       #knots
                #$fields[9]             #date
                if ( $fields[0] eq '$GPRMC') {
                        print "$serial\n";
                        $serial++;
                        if (!$start_time) {
                                $start_time = ret_timestamp($fields[9], $fields[1]);
                                print "00:00:00";
                        }
                        $cur_time = ret_timestamp($fields[9], $fields[1]);
                        print ret_format_ts($cur_time - $start_time);
                        print ",000 --> 00:00:01,000\n";
                        print ret_timestring($fields[9],$fields[1]);
                        print "\n";
                        print sprintf("%-d KM/H\n", $fields[7]*1.852);
                        print "\n";
                }
        }

}

# timestring for subtitle display
sub ret_timestring {
        use POSIX qw/mktime strftime/;
        my $DD = shift;
        my $TT = shift;
        return unless $DD & $TT;

        my ($dd, $MM, $yy) = $DD =~ /^(..)(..)(..)$/;
        my ($hh, $mm, $ss) = $TT =~ /^(..)(..)(..)/;
        $yy = $yy + 2000 - 1900;

        my $ts = strftime "%s", localtime( mktime($ss, $mm, $hh, $dd, $MM, $yy) );
        $ts = $ts+(60*60*8); # GMT+8
        my $string = strftime "%Y/%m/%d %T", localtime($ts);
        return $string;
}

sub ret_timestamp {
        use POSIX qw/mktime strftime/;
        my $DD = shift;
        my $TT = shift;
        return unless $DD & $TT;

        my ($dd, $MM, $yy) = $DD =~ /^(..)(..)(..)$/;
        my ($hh, $mm, $ss) = $TT =~ /^(..)(..)(..)/;
        $yy = $yy + 2000 - 1900;

        my $ts = strftime "%s", localtime( mktime($ss, $mm, $hh, $dd, $MM, $yy) );
        $ts = $ts+(60*60*8); # GMT+8
        return $ts;
}

sub ret_format_ts {
        my $TT = shift;
        return unless $TT;
        $TT=$TT-(60*60*8); # GMT+8, subs it back

        my $ts = strftime "%T", localtime($TT);
        return $ts;
}
