#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [-t THRESHOLD] PREV_FILE NEW_FILE
";

my %OPT;
getopts('t:', \%OPT);

my $THRESHOLD = 1;
if ($OPT{t}) {
    $THRESHOLD = $OPT{t};
}

### Arguments
my $PREV_FILE = $ARGV[0];
my $NEW_FILE = $ARGV[1];

### Read new file
my %GET_CLUSTER = ();

open(NEW, "$NEW_FILE") || die;
while (<NEW>) {
    chomp;
    my @f = split("\t", $_);

    my $def = pop(@f);
    my $gene = pop(@f);

    if ($gene !~ /^(\w+):\S+$/) {
	print STDERR $gene, "\n";
    }

    my $para = pop(@f);
    if ($para !~ /^[a-z]+.\d+$/) {
	print STDERR $para, "\n";
    }

    for (my $i=0; $i<1; $i++) {
    	my $cluster = $f[$i];
    	if ($cluster !~ /^[A-Z]\w+.\d+$/) {
    	    print STDERR $cluster, "\n";
    	}

	if ($GET_CLUSTER{$gene}) {
	    push @{$GET_CLUSTER{$gene}}, $cluster;
	} else {
	    $GET_CLUSTER{$gene} = [$cluster];
	}
    }
}
close(NEW);

print STDERR "file2 read.\n";

### Read PREV_FILE
my %CLUSTER_MEMBER = ();
my %PREV_CLUSTER_SIZE = ();

open(PREV, "$PREV_FILE") || die;
while (<PREV>) {
    chomp;
    my @f = split("\t", $_);

    my $def = pop(@f);
    my $gene = pop(@f);

    if ($gene !~ /^\w+:\S+$/) {
	print STDERR $gene, "\n";
    }

    my $para = pop(@f);
    if ($para !~ /^[a-z]+.\d+$/) {
	print STDERR $para, "\n";
    }

    ### Check if previous genes exist in the new dataset
    if ($GET_CLUSTER{$gene}) {
	# print STDERR "found $gene\n";
    } else {
	next;
	# print STDERR "cannot find $gene\n";
    }

    for (my $i=0; $i<1; $i++) {
    	my $cluster = $f[$i];
    	if ($cluster !~ /^[A-Z]\w+.\d+$/) {
    	    print STDERR $cluster, "\n";
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

print STDERR "file1 read.\n";

### Count corresponding genes
for my $cluster (keys %CLUSTER_MEMBER) {
    if ($PREV_CLUSTER_SIZE{$cluster} < $THRESHOLD) {
	next;
    }
    
    my %count_corresp = ();
    for my $member (@{$CLUSTER_MEMBER{$cluster}}) {
	if ($GET_CLUSTER{$member}) {
	    my @corresp_cluster = @{$GET_CLUSTER{$member}};
	    for my $corresp_cluster (@corresp_cluster) {
		$count_corresp{$corresp_cluster}++;
	    }
	}
    }

    my @ratio = ();
    for my $corresp_cluster (keys %count_corresp) {
	my $ratio = $count_corresp{$corresp_cluster}/$PREV_CLUSTER_SIZE{$cluster};
	push @ratio, $ratio;
    }

    print "$cluster\t$PREV_CLUSTER_SIZE{$cluster}\t", max(@ratio), "\n";
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
