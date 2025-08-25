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


    my @img_list;
    my @xhtml_list;
    my @spine_list;

    my @shosi;
    my @koumoku_content;
    
    my @standard_opf;
    my @xhtml_one;

    my $page_count;
    my $image_count;
    my @tmp_var;
        
    my $gazou_count;    
    my $count;

    my @log;
    
	my @chosha_mei;
    my @chosha_temp;
    my @go_opf_chosha;
    
    my $ichi_height;
        
	my @mate_folders;

	my $notate;
	my $aki;
	
	
#	================================================================================================================================
#	rmdir("04_output/$koumoku{'kd_num'}") or die "cant delete folder\n";		#未完成。データ残りあるとあるとエラーになるのであらかじめデータ除去。	

#	================================================================================================================================
#    opfに使うタグの、imgリスト & xhtmlリスト & spineリストの取り込み    =========================================

    open(IN_IMG_LIST, "<:encoding(UTF-8)", "00_templates/opf_img.txt") or die "cant open img_list\n";
    @img_list = <IN_IMG_LIST>;
    close(IN_IMG_LIST);

    open(IN_XHTML_LIST, "<:encoding(UTF-8)", "00_templates/opf_xhtml.txt") or die "cant open xhtml_list\n";
    @xhtml_list = <IN_XHTML_LIST>;
    close(IN_XHTML_LIST);
    
    open(IN_SPINE_LIST, "<:encoding(UTF-8)", "00_templates/opf_spine.txt") or die "cant open spine_list\n";
    @spine_list = <IN_SPINE_LIST>;
    close(IN_SPINE_LIST);


#    shosi.csvの読み込み部分   	 ===========================================================================

    open(IN_SHOSI, "<:encoding(UTF-8)", "shosi.csv") or die "cant open shosi\n";
    @shosi = <IN_SHOSI>;
    close(IN_SHOSI);

    foreach(@shosi) {
        @koumoku_content = split(/,/);

        # [1]がブランクなら[2]もブランクにする
        if (!defined $koumoku_content[1] || $koumoku_content[1] eq '') {
            $koumoku_content[2] = '';
        }

        &pre_check;						#prcs00		書誌とデータのチェック
   		 
   		 &chosha_divide;					#prcs01		著者複数の場合

   		 &output_folders;   				#prcs02		フォルダ類＆画像ファイルを出力

   		 &gazou_glob;   					#prcs03		画像情報の取得
   		 
   		 &make_xhtml_one;   				#prcs04		p-001xhtmlのセッティング

   		 &make_xhtml_extra;   				#prcs05		p-002以降のxhtmlのセッティング

   		 &make_opf;   						#prcs06		opfファイルのセッティング
   		 
   		 &output_txts;   					#prcs07		テキスト類の出力
   		 
   		 &output_log;						#prcs08		ログファイルの出力

   	 }

   	 open(LOGS, ">:encoding(UTF-8)", "04_output/log.txt") or die "cant open log_file\n";   	 #002以降xhtmlファイルの出力
   	 print LOGS @log;
   	 close(LOGS);


# 事前チェック    ===========================================================================
    sub pre_check{
		
		opendir(DIRHANDLE, "03_materials");		# ディレクトリエントリの取得

		foreach(readdir(DIRHANDLE)){
			next if /^\.{1,2}$/;				# '.'や'..'をスキップ
#			print "$_\n";
		}

#		my @mate_folders = readdir(DIRHANDLE);
		
#		print @mate_folders;
		
		
#		my @foo = ( "bar", "hoge", "fuga" );
#		for my $data ( @foo ) {
#   	print "OK" if $data eq "hoge"; 
#		}


		my $data = $koumoku_content[47];
		
		for (@mate_folders) {

		if ($_ eq $data){
  				print "ok\n";
			} else {
  				print "$data nai\n";
		}

		}


	}

# 画像情報を作成    ===========================================================================
    sub gazou_glob{

    # jpg のファイル数を取得    -----------------------------
   	 my @gazou_files = glob("04_output/$koumoku_content[47]/item/image/*.jpg");   		 #outpubフォルダ内画像

#   	 print @gazou_files;   						 #テスト　画像ファイル名取得の確認

   	 # ファイル数カウント    -----------------------------
   	 $count = 0;

   	 while ($count < @gazou_files){

   		 my $img_count = $count + 1;
   		 my $sanketa_number = sprintf("%03d", $img_count);    					 #ファイル名が000の3桁なので。

   		 rename $gazou_files[$count], "04_output/$koumoku_content[47]/item/image/i-$sanketa_number.jpg";						#画像リネーム イキ、のはずがバグのため外しても影響なし？？？

   			 $count ++;

   		 }
   		 
   		 my $gazou_count = $count;   												#確定の画像数
#  		 print "$koumoku_content[47] gazou count ha $gazou_count\n";   				 #確認用

   		 $page_count = $gazou_count - 1;   						 #画像数-1、が作るxhtmlページ数
#  		 print "page_count ha $page_count\n";   				 #確認用

     }


#    p-001.xhtmlの読み込み部分    ===========================================================================

    sub make_xhtml_one{
    
   	 open(IN_01, "<:encoding(UTF-8)", "00_templates/p-001.xhtml") or die "cant open 01xhtml\n";
   	 @xhtml_one = <IN_01>;
   	 close(IN_01);

#	i-001.jpg のサイズを取得    ------------------------------------

   	 my $zeroone = glob("04_output/$koumoku_content[47]/item/image/i-001.jpg");   				#
   	 # .jpg のサイズを取得
   		 (my $width, $ichi_height) = imgsize("04_output/$koumoku_content[47]/item/image/i-001.jpg");		#パターンa	001を直で指定	イキ

#   	 print $xhtml_one[0];   						 #確認用

   	 foreach(@xhtml_one){

   			 &umekomi;   								 
  			s/▼縦サイズ▼/$ichi_height/g;   			 #環境変数から用意
  			s/▼横サイズ▼/$width/g;   			 		#環境変数から用意_1030に幅700pix（仕様）戻しに伴い修正追加
#			$ichi_height = ();

   		 }
    }


#    p-002.xhtml以降の作成部分    ===========================================================================

    sub make_xhtml_extra{
   	 
    #    xhtmlの2枚目以降を作成   	 ----------------------------------------
    
   	 my $pcounter = 0;

   	 while ($pcounter <= $page_count) {
   		 
   		 my $page_num = $pcounter + 1;
   		 
   			 # p-3桁のファイル連番を作成    -----------------------
   				 my $sanketa_name = sprintf("%03d", $page_num);
#   				 print $sanketa . "\n";

   	 my $two_after = glob("04_output/$koumoku_content[47]/item/image/i-$sanketa_name.jpg");   		 #materialフォルダ内画像

   	 # .jpg のサイズを取得
#   		 (my $width, my $two_after_height) = imgsize($two_after);
   		 (my $width, my $two_after_height) = imgsize("04_output/$koumoku_content[47]/item/image/i-$sanketa_name.jpg");

#   			 print "$width and $two_after_height\n";   										#画像サイズ    確認テスト

   			 # p-002のテンプレを読み込む    -----------------------

   				 open(IN_02, "<:encoding(UTF-8)", "00_templates/p-00n.xhtml") or die "cant open 02xhtml\n";;
   				 my @xhtml_extra = <IN_02>;
   				 close(IN_02);
   	 
    #   		 ----------------------------------------

   			 foreach(@xhtml_extra) {
   						 &umekomi;    
    					s/▼ファイル名数字▼/$sanketa_name/g;   		#xhtmlファイル名
  						s/▼縦サイズ▼/$two_after_height/g;   			 #環境変数から用意
  						s/▼横サイズ▼/$width/g;   			 		#環境変数から用意_1030に幅700pix（仕様）戻しに伴い修正追加
   					 }

   			 # p-002以降のhtml名を生成    -----------------------
   			 my $file_count_name = "p-" . $sanketa_name . ".xhtml";   								 #    
#   			 print $file_count_name ."\n";   										 #xhtmファイル名テスト　1枚ずつ出力

#   			 print $sanketa_name ." sanketa\n";   										 #上がる

   	 open(OUT_02, ">:encoding(UTF-8)", "04_output/$koumoku_content[47]/item/xhtml/$file_count_name") or die "cant open xhtml_extra\n";   	 #002以降xhtmlファイルの出力
   	 print OUT_02 @xhtml_extra;
   	 close(OUT_02);
   	 
   	     	$pcounter ++;
   		 }

    }


#    standard.opfの読み込み部分    ===========================================================================

    sub make_opf{   				 

   	 open(IN_STD, "<:encoding(UTF-8)", "00_templates/standard.opf")  or die "cant open opf\n";
   	 @standard_opf = <IN_STD>;
   	 close(IN_STD);

#   		 print $standard_opf[0];   											 #確認用

   	 $image_count = $page_count - 1;

   	 push(my @cut_img_list, @img_list[0..$image_count]);   					 #画像枚数だけ、imgタグを出力（imageだけ１回少なく）
   	 push(my @cut_xhtml_list, @xhtml_list[0..$page_count]);   				 #画像枚数だけ、xhtmlタグを出力
   	 push(my @cut_spine_list, @spine_list[0..$page_count]);   				 #画像枚数だけ、spineタグを出力
   				 
#   	 print @cut_img_list;   												 #確認用

   	 foreach(@standard_opf)   	 
   		 {
   			 &umekomi;   												 #

   			s/▼著者情報テキスト挿入位置▼/join "", @go_opf_chosha/eg;   			 #サブルーチン chosha_divide の生成テキストを挿入

   			 s/▼画像ファイルタグ印字位置▼/join "", @cut_img_list/e;   			 #これがいちばんマシ

   			 s/▼xhtmlファイルタグ印字位置▼/join "", @cut_xhtml_list/eg;   		 #環境変数から用意
 
   			 s/▼spineタグ印字位置▼/join "", @cut_spine_list/eg;   				 #環境変数から用意
   		 }
   		 
   	@go_opf_chosha = ();											#opfに埋め込む著者情報の配列を初期化
   		 
    }


#    出力    ===========================================================================

#    フォルダ・画像類の出力・コピー    ------------------------------------------

    sub output_folders{

#   	 $koumoku_name[47];   							 #話のファイル名

   	 mkdir("04_output/$koumoku_content[47]", 0755) or die "話のフォルダを作成できませんでした\n";
   	 mkdir("04_output/$koumoku_content[47]/item", 0755) or die "itemフォルダを作成できませんでした\n";
   	 mkdir("04_output/$koumoku_content[47]/META-INF", 0755) or die "META-INFのフォルダを作成できませんでした\n";
   	 mkdir("04_output/$koumoku_content[47]/item/xhtml", 0755) or die "xmlフォルダを作成できませんでした\n";
   	 mkdir("04_output/$koumoku_content[47]/item/style", 0755) or die "styleのフォルダを作成できませんでした\n";
   	 mkdir("04_output/$koumoku_content[47]/item/image", 0755) or die "話の画像のフォルダを作成できませんでした\n";

   	 #    テンプレよりテキスト類のコピー    -----------    

   	 rcopy("00_templates/META-INF/container.xml","04_output/$koumoku_content[47]/META-INF") or die "container.xmlをコピーできません\n";
   	 rcopy("00_templates/mimetype","04_output/$koumoku_content[47]") or die "mimetypeをコピーできません\n";
   	 rcopy("00_templates/item/style","04_output/$koumoku_content[47]/item/style") or die "styleをコピーできません\n";
   	 rcopy("00_templates/item/navigation-documents.xhtml","04_output/$koumoku_content[47]/item") or die "styleをコピーできません\n";

  	 #    画像ファイルコピー    -----------    

   	 rcopy("03_materials/$koumoku_content[47]","04_output/$koumoku_content[47]/item/image") or die "$koumoku_content[47]の画像をコピーできません\n";

  	 #    shosi.csvを生成xhtml階層にログ的コピー保存    -----------    

   	 rcopy("shosi.csv","04_output") or die "shosiを履歴用にコピーできません\n";

    }


    #    テキスト類の出力    ----------------------------------------------------------------------------
    
   	 sub output_txts{

   	 open(OUT_STD, ">:encoding(UTF-8)", "04_output/$koumoku_content[47]/item/standard.opf") or die "cant make opf\n";   		 #opfファイルの出力
   	 print OUT_STD @standard_opf;
   	 close(OUT_STD);

   	 open(OUT_01, ">:encoding(UTF-8)", "04_output/$koumoku_content[47]/item/xhtml/p-001.xhtml") or die "cant make xhtml\n";   	 #001のxhtmlファイルの出力
   	 print OUT_01 @xhtml_one;
   	 close(OUT_01);

    }



# サブルーチン　文字変換    ===========================================================================

sub umekomi {

    $aki = "　";  # 初期値として全角スペース

    # ▼話巻順番▼ の置換
    my $notate = $koumoku_content[0];
    if (defined $koumoku_content[1] && $koumoku_content[1] ne '') {
        $notate .= $koumoku_content[1];
    }
    s/●話巻順番●/$notate/g;

    s/●タイトル名●/$koumoku_content[0]/g;
    s/●タイトル名カタカナ●/$koumoku_content[5]/g;
    s/●話数3桁●/$koumoku_content[2]/g;
    s/●出版社名●/$koumoku_content[12]/g;
    s/●出版社名カタカナ●/$koumoku_content[15]/g;
}


# サブルーチン　ログ出力    ===========================================================================

    sub output_log{
    # [1]が空欄なら[0]のみ、それ以外は[0]+[1]
    my $notate = $koumoku_content[0];
    if (defined $koumoku_content[1] && $koumoku_content[1] ne '') {
        $notate .= $koumoku_content[1];
    }
    s/●話巻順番●/$notate/g;
    push(@log, "$koumoku_content[47],$notate\n");
}


# サブルーチン　著者分割    ===========================================================================
#	16（著者名）と18（著者名カタカナ）の人数分が「┴」分割で必要。
#	人数分出力と、カウント回し

    sub chosha_divide{
    
#		print $koumoku_content[0].$koumoku_content[1]."\n";

    	  @chosha_mei = split(/┴/, "$koumoku_content[16]");    	  
#    	  print $chosha_mei[0]."\n";
#    	  print $chosha_mei[1]."\n";

    	 my @chosha_katakana = split(/┴/, "$koumoku_content[18]");
#    	 print $chosha_katakana[0]."\n";

			my $chosha_counter = 0;

   			while ($chosha_counter < @chosha_mei){
   			 
				my $fig_counter = $chosha_counter + 1;
#				print $fig_counter . "回目\n";

				
    			open(CHOSHA_TEMP, "<:encoding(UTF-8)", "00_templates/opf_choshamei.txt") or die "cant open opf_choshamei\n";		#著者情報のテンプレを読み込み
   	 			@chosha_temp = <CHOSHA_TEMP>;
    			close(CHOSHA_TEMP);

				foreach(@chosha_temp){
					s/●作家名●/$chosha_mei[$chosha_counter]/g;   			 						#サブルーチンに移管
					s/●作家名カタカナ●/$chosha_katakana[$chosha_counter]/g;   							#サブルーチンに移管
					s/▼作家順番▼/$fig_counter/g;
				}

   				push(@go_opf_chosha, @chosha_temp);
    	     	@chosha_temp = ();

    	     	$chosha_counter ++;
    	     	
    	     
  		 	}

		}

# 						    ===========================================================================


