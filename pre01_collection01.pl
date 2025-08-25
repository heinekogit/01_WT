#!/usr/local/bin/perl

use strict;
use warnings;

use utf8;
binmode STDIN, 'encoding(cp932)';
binmode STDOUT, 'encoding(cp932)';
binmode STDERR, 'encoding(cp932)';
use Encode;

use File::Path 'mkpath';
use File::Copy;
use File::Copy::Recursive qw(rcopy);
use Image::Size 'imgsize';

my @trgt_folder;
my $trgt_folder;

my @folders;

# 	 ASG作成画像のフォルダから		==================================================

#   	 @trgt_folder = glob("制作シミュレーション");   		 #materialフォルダ内画像
   	 @trgt_folder = glob("01_ASG_arrange/*");   		 #materialフォルダ内画像

	print @trgt_folder . " folder\n";
#	print $trgt_folder[0] . "\n";

	my $i = 0;

	while ($i < @trgt_folder){

   	 rcopy($trgt_folder[$i],"02_collection") or die "話フォルダをコピーできません\n";

			$i ++;
	}
	


