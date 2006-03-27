#!/usr/bin/perl

# create an ark file from a matrix file according to the corresponding ark file
# e.g. perl ../scripts/mat2ark.pl bn_data_nosig_strange/clusterFeature_50 bn_data_nosig_strange/feats_train_n3_noise_bnfea.ark > bn_data_nosig_strange/feats_train_n3_noise_bnfea_cluster50.ori.ark

($matFile, $arkFile) = @ARGV;

open(IN1, $arkFile);
open(IN2, $matFile);

while($line1 = <IN1>)
{
	if ($line1 =~ /\[/)
	{
		print $line1;
	}
	elsif ($line1 =~ /\]/)
	{
		$line2 = <IN2>;
		chomp($line2);
		print "  " . $line2 . " \]\n";
	}
	else
	{
		$line2 = <IN2>;
		chomp($line2);
		print "  " . $line2 . " \n";
	}
}

close IN2;
close IN1;
