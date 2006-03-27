#!/usr/bin/perl

# calculate the probabilities of every utterance
# usage: scripts/cal_utt.pl test.ark 3 > result

($ark, $labNum) = @ARGV;

open(IN, $ark);

@label = "";
for($i=0;$i<$labNum;$i++)
{
	push(@label, 0);
}

while($line = <IN>)
{
	chomp($line);
	$line =~ s/^\s+//g;
	if($line =~ /\[/)
	{
		$line =~ s/\s*\[\s*//g;
		print $line;
	}
	elsif($line =~ /\]/)
	{
		$line =~ s/\s*\]\s*//g;
		@chunk = split(/\s+/, $line);
		for($i=0;$i<$labNum;$i++)
		{
			$label[$i] = $label[$i] + log($chunk[$i]);
			print " " . $label[$i];
		}
		print "\n";
		@label = "";
		for($i=0;$i<$labNum;$i++)
		{
			push(@label, 0);
		}
	}
	else
	{
		@chunk = split(/\s+/, $line);
		for($i=0;$i<$labNum;$i++)
		{
			$label[$i] = $label[$i] + log($chunk[$i]);
		}
	}
}

close IN;