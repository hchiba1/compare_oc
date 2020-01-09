#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [-t THRESHOLD]
";

my %OPT;
getopts('t:', \%OPT);

my $THRESHOLD = 1;
if ($OPT{t}) {
    $THRESHOLD = $OPT{t};
}

my $PREV_FILE = $ARGV[0];
my $NEW_FILE = $ARGV[1];

my %CLUSTER_MEMBER = ();
my %PREV_CLUSTER_SIZE = ();

# !@ARGV && -t and die $USAGE;
open(PREV, "$PREV_FILE") || die;
while (<PREV>) {
    chomp;
    my @f = split("\t", $_);

    my $def = pop(@f);
    my $gene = pop(@f);
    if ($gene !~ /^\w+:\S+$/) {
	print $gene, "\n";
    }

    my $para = pop(@f);
    if ($para !~ /^[a-z]+.\d+$/) {
	print $para, "\n";
    }

    # for (my $i=0; $i<@f; $i++) {
    for (my $i=0; $i<1; $i++) {
    	my $cluster = $f[$i];
    	if ($cluster !~ /^[A-Z]\w+.\d+$/) {
    	    print $cluster, "\n";
    	}

	if ($CLUSTER_MEMBER{$cluster}) {
	    push @{$CLUSTER_MEMBER{$cluster}}, $gene;
	} else {
	    $CLUSTER_MEMBER{$cluster} = [$gene];
	}

	$PREV_CLUSTER_SIZE{$cluster} ++;
    }
}
close(PREV);

my %GET_CLUSTER = ();
my %NEW_CLUSTER_SIZE = ();

open(NEW, "$NEW_FILE") || die;
while (<NEW>) {
    chomp;
    my @f = split("\t", $_);

    my $def = pop(@f);
    my $gene = pop(@f);
    if ($gene !~ /^\w+:\S+$/) {
	print $gene, "\n";
    }

    my $para = pop(@f);
    if ($para !~ /^[a-z]+.\d+$/) {
	print $para, "\n";
    }

    # for (my $i=0; $i<@f; $i++) {
    for (my $i=0; $i<1; $i++) {
    	my $cluster = $f[$i];
    	if ($cluster !~ /^[A-Z]\w+.\d+$/) {
    	    print $cluster, "\n";
    	}

	if ($GET_CLUSTER{$gene}) {
	    push @{$GET_CLUSTER{$gene}}, $cluster;
	} else {
	    $GET_CLUSTER{$gene} = [$cluster];
	}

	$NEW_CLUSTER_SIZE{$cluster} ++;
    }
}
close(NEW);

for my $cluster (keys %CLUSTER_MEMBER) {
    my @member = @{$CLUSTER_MEMBER{$cluster}};
    my $size = @member;

    if ($size < $THRESHOLD) {
	next;
    }

    print "$cluster\t$size";
    # print "$cluster ($size) $PREV_CLUSTER_SIZE{$cluster}\n";
    
    my %count_corresp = ();
    for my $member (@member) {
	if ($GET_CLUSTER{$member}) {
	    my @corresp_cluster = @{$GET_CLUSTER{$member}};
	    for my $corresp_cluster (@corresp_cluster) {
		$count_corresp{$corresp_cluster}++;
	    }
	}
    }

    my @ratio = ();
    for my $corresp_cluster (keys %count_corresp) {
	# print " $corresp_cluster ($NEW_CLUSTER_SIZE{$corresp_cluster}) ";
	# print "$count_corresp{$corresp_cluster} ";
	my $ratio = $count_corresp{$corresp_cluster}/$size;
	push @ratio, $ratio;
	# print "\n";
    }
    # print " @ratio\n";
    print "\t", max(@ratio), "\n";
}

################################################################################
### Functions ##################################################################
################################################################################
sub max {
    my @x = @_;

    if (@x == 0) {
	return;
    }

    my $max = $x[0];
    for (my $i=0; $i<@x; $i++) {
	if ($x[$i] > $max) {
	    $max = $x[$i];
	}
    }

    return $max;
}
