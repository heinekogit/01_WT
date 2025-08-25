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
use File::Copy::Recursive 'dircopy';
use Image::Size 'imgsize';

use File::Path 'rmtree';



my @list;
my $dh;

my @log;
my @mate_folders;

my @shosi;
my @koumoku_content;
my @check_shosi;
my $check_shosi;
    
my $count_data;
my $count_shosi;

my @gazou_jpeg;
my @gazou_png;
my @gazou_renban;

my @titles;
my $titles;


# 	 把握スタート		==============================================================

   	 @gazou_renban = glob("02_collection/*/*.jpg");   		 #フォルダ内画像
   	 
#   	 @titles = glob("01_ASG_check/*");   		 #タイトルのフォルダ名把握


# 	 画像サイズチェック		==============================================================

	print "\n画像サイズチェック　---------------------------------------------------------\n";		#ログの見やすさ整理

	 my $size_count = 0;

   	 foreach(@gazou_renban) {
   	 
   	    		 (my $width, my $height) = imgsize($gazou_renban[$size_count]);
   	    		 
   	    		 if($width ne 700) {
   	    		 		if($height > 30000) {
   	    		 			
   	    			 		print $gazou_renban[$size_count] . "：" . $width . "×" . $height . " ＝＝ 横サイズ NG ／ 縦サイズ NG\n";
   	    		 		
   	    		 		} else {
   	    		 			
   	    		    	    print $gazou_renban[$size_count] . "：" . $width . "×" . $height . " ＝＝ 横サイズ NG ／ 縦サイズ ok\n";
						}
   	    		 		
   	    		 	} else {
   	    		 		
   	    		 		if($height > 30000) {
   	    		 			
   	    			 		print $gazou_renban[$size_count] . "：" . $width . "×" . $height . " ＝＝ 横サイズ ok ／ 縦サイズ NG\n";
   	    		 		
   	    		 		} else {
   	    		 			
   	    		    	    print $gazou_renban[$size_count] . "：" . $width . "×" . $height . " ＝＝ ok\n";
						} 
					}  	    		
   	    		 
   	    		 $size_count ++;
   	  
   	 }
 


# 	 素材フォルダ内部・画像ファイル名チェック		==============================================================
#	ファイル名が「aaa_01.jpg」のようなゼロ埋めの2桁連番になっているかチェック


	print "\n画像ファイル名チェック　---------------------------------------------------------\n";	#ログの見やすさ整理

	my $renban_count = 0;
	
	while($renban_count < @gazou_renban){

		if ( $gazou_renban[$renban_count] =~ /\_[0-9][0-9].jpg/) {
						print $gazou_renban[$renban_count] . "　ファイル名ok\n";					#例：randomchat102_01.jpgがマッチ（ルール適合）
						
						$renban_count ++;
						
		} else {
						print $gazou_renban[$renban_count] . "　はファイル名ルールに抵触・NG\n";	#ファイル名ルールに不適合

						$renban_count ++;
#  				last;
		}
	}


# 	 素材フォルダ内部・画像の拡張子チェック（「.jpeg」を不正とする）==================================================

   	 @gazou_jpeg = glob("02_collection/*/*.jpeg");   			 #

#	print $gazou_jpeg[0] . "\n";
	print "\n画像の拡張子チェック_jpeg　---------------------------------------------------------\n";				#ログの見やすさ整理
	print @gazou_jpeg . "個のjpegファイルありok\n";

	my $jpeg_count = 0;
	
		if ( @gazou_jpeg ne "0"){
			
				while ($jpeg_count < @gazou_jpeg) {
						print $gazou_jpeg[$jpeg_count] . "\n\n";
						
						$jpeg_count ++;
					}
						
			} else {
  				print "拡張子がjpegのファイルなしok\n\n";
		}


# 	 素材フォルダ内部・画像の拡張子チェック（「.png」を不正とする）==================================================

   	 @gazou_png = glob("02_collection/*/*.png");   			 #

#	print $gazou_png[0] . "\n";
	print "\n画像の拡張子チェック_png　---------------------------------------------------------\n";				#ログの見やすさ整理
	print @gazou_png . "個のpngファイルありok\n";

	my $png_count = 0;
	
		if ( @gazou_png ne "0"){
			
				while ($png_count < @gazou_png) {
						print $gazou_png[$png_count] . "\n\n";
						
						$png_count ++;
					}
						
			} else {
  				print "拡張子がpngのファイルなしok\n\n";
		}


# 	 納品用のフォルダ生成		==============================================================

#   	 foreach(@titles) {
 
# 						s/01_ASG_check\///g;   			 #2L以上は使わない

#   	 					print $_ . " フォルダ名\n";

# 					  	 mkdir(">:encoding(UTF-8)", "05_ePub検証_納品格納/$_", 0755) or die "納品用のタイトルフォルダを作成できませんでした\n";
 
 
#   	 					}




   	 dircopy("01_ASG_arrange","06_ePub_shipping") or die "納品用フォルダをコピーできません\n";	#[05_ePub_shipping]フォルダに
   	 																							#納品用にフォルダごとコピー
   	 																							#内容物を消せないでいる。
   	 																							#ハコだけにしたいが。
   	 																							#検証時に消す等、運用でカバーか。
   	 																							#8/31、このままの方が運用上都合良いと判明。
   	 																							#ママイキ。

#	my $del_target = "05_ePub_shipping/*/*";

#	rmdir($del_target) or die "cant delete folder\n";		#未完成。データ残りあるとあるとエラーになるのであらかじめデータ除去。	
#	rmdir("05_ePub_shipping/*/*") or die "cant delete folder\n";		#未完成。データ残りあるとあるとエラーになるのであらかじめデータ除去。	














#  	  open(LOGS, ">:encoding(UTF-8)", "01_output/log.txt") or die "cant open log_file\n";  	  #002以降xhtmlファイルの出力
#  	  print LOGS @log;
#  	  close(LOGS);


