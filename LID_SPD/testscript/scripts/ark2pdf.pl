#!/usr/bin/perl

# generate label file according to ark file

open(IN, $ARGV[0]);

while($line = <IN>)
{
	chomp($line);
	if($line =~ /\[/)
	{
		$line =~ s/\s*\[\s*//g;
		print $line;
		if($line =~ /English/)
		{
			$lab = 0;
		}
		elsif($line =~ /NorthMandarin/)
		{
			$lab = 1;
		}
		elsif($line =~ /Uighur/)
		{
			$lab = 2;
		}
	}
	else
	{
		print " " . $lab;
		if($line =~ /\]/)
		{
			print "\n";
		}
	}
}

close IN;