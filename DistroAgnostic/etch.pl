#!/usr/bin/env perl


my $src = $ARGV[0];
my $dst = $ARGV[1];

if (not defined $src) {
  print "First argument should be the source file. Aborting!\n";
  exit(1);
}

if (not defined $dst) {
  print "Second argument should be the destination device. Aborting!\n";
  exit(1);
}

if (not -e $src) {
  print "Source file $src does not exist. Aborting!\n";
  exit(1);
}

if (not -e $dst) {
  print "Destination device $dst does not exist. Aborting!\n";
  exit(1);
}


my $cmd = "sudo dd if=$src of=$dst bs=16M conv=noerror,sync status=progress";

print "Running command '$cmd'\n";

system($cmd);

system('sync');
