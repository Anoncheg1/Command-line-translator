#!/usr/bin/env perl

# AWESOME GOOGLE TRANSLATE. This tool for access translate.google.com from terminal and additional English features.

#    Copyright (C) 2012 Vitalij Chepelev.

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# You can contact me there: 
# http://www.unix.com/shell-programming-scripting/196823-completed-command-line-google-translation-tool.html                       654321 - profile name

# https://github.com/Anoncheg1/Command-line-translator
# requirements: 
#	libjson-perl
#	forvo.com account
#features:
#- translated text, fixed text with highlight, language detection, dictionary, translit
# for english: 
#- phrases, ideom, word forms, transcription, audio pronunciation
#- cache for words
#- saving words to file for learning
#
#:) translate.google.com, www.macmillandictionary.com/dictionary/british, thefreedictionary.com, lingvo-online.ru, www.forvo.com

package GoogleTranslator;

use strict; # ограничить применение небезопасных конструкций
use warnings; # выводить подробные предупреждения компилятора
use diagnostics; # выводить подробную диагностику ошибок
use Getopt::Std;
use File::Basename;
use LWP::UserAgent;
#libjson-perl
use JSON;
use HTML::Entities;
#Debian: liblwp-protocol-socks-perl
use LWP::Protocol::socks;
use URI::Escape;
use utf8;
use v5.16;
#use Text::Unidecode;
#binmode(STDOUT, ":utf8");

# adjust to taste
my $FIRST_LANG='ru';		#target language for request in LATIN_LANG		NOT in A-z latin alphabet
my $LATIN_LANG='en';		#target for all not A-z latin requests			A-z latin alphabet will be detected!
my $TERMINAL_C="WOB";		#Your terminal - white on black:WOB, black on white:BOW, anything other:O

my $TRANSLIT_WORDS_MAX = 10;
my @PROXY ;#= ('http','http://127.0.0.1:4446'); #i2p
#@PROXY =([qw(http https)] => "socks://172.16.0.1:9150"); #tor

my $USERAGENT = 'Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1';


#Solved problems:
#  gppgle JSON converting problem ,,. Solved by hands.
#  google JSON article=white space - problem. Solved by hands.

my $name = basename($0);
my %LANGS = (
    'af' => 'Afrikaans',
    'sq' => 'Albanian',
    'am' => 'Amharic',
    'ar' => 'Arabic',
    'hy' => 'Armenian',
    'az' => 'Azerbaijani',
    'eu' => 'Basque',
    'be' => 'Belarusian',
    'bn' => 'Bengali',
    'bg' => 'Bulgarian',
    'ca' => 'Catalan',
    'zh-CN' => 'Chinese (Simplified)',
    'zh' => 'Chinese',
    'hr' => 'Croatian',
    'cs' => 'Czech',
    'da' => 'Danish',
    'nl' => 'Dutch',
    'en' => 'English',
    'eo' => 'Esperanto',
    'et' => 'Estonian',
    'fo' => 'Faroese',
    'tl' => 'Filipino',
    'fi' => 'Finnish',
    'fr' => 'French',
    'gl' => 'Galician',
    'ka' => 'Georgian',
    'de' => 'German',
    'el' => 'Greek',
    'gu' => 'Gujarati',
    'ht' => 'Haitian Creole',
    'iw' => 'Hebrew',
    'hi' => 'Hindi',
    'hu' => 'Hungarian',
    'is' => 'Icelandic',
    'id' => 'Indonesian',
    'ga' => 'Irish',
    'it' => 'Italian',
    'ja' => 'Japanese',
    'kn' => 'Kannada',
    'ko' => 'Korean',
    'lo' => 'Laothian',
    'la' => 'Latin',
    'lv' => 'Latvian',
    'lt' => 'Lithuanian',
    'mk' => 'Macedonian',
    'ms' => 'Malay',
    'mt' => 'Maltese',
    'no' => 'Norwegian',
    'fa' => 'Persian',
    'pl' => 'Polish',
    'pt' => 'Portuguese',
    'ro' => 'Romanian',
    'ru' => 'Russian',
    'sr' => 'Serbian',
    'sk' => 'Slovak',
    'sl' => 'Slovenian',
    'es' => 'Spanish',
    'sw' => 'Swahili',
    'sv' => 'Swedish',
    'ta' => 'Tamil',
    'te' => 'Telugu',
    'th' => 'Thai',
    'tr' => 'Turkish',
    'uk' => 'Ukrainian',
    'ur' => 'Urdu',
    'vi' => 'Vietnamese',
    'cy' => 'Welsh',
    'yi' => 'Yiddish'
);

############ Functions
$SIG{INT} = \&sig_handler;
sub sig_handler { #Ctrl+C detection.
   print "Exit signal detected. Deleting cache files.\n";
   exit;
}

# Message about this program and how to use it
sub usage()
{
    print STDERR << "EOF";
$name [-S] [-l] [-h] [-p] [-s language_2_chars] [-t language_2_chars]
if text is LATIN_LANG, then target language is FIRST_LANG
otherwise, target language is LATIN_LANG
-S
  enable sound for one word
//-p prompt mode
-s CODE
  source language
-t CODE
  target language
-l
  list of language codes
-o FILE 
    read request from file
Configure "FIRST_LANG" and "LATIN_LANG" in script for auto detection of direction by the first character!
You neeed UTF-8 support for required languages.
EOF
    exit 0;
}

sub testing($){
    my $g_array = $_[0];
    if(ref($g_array) eq 'ARRAY'){
	for (my $row = 0; $row < @{$g_array}; $row++){
	    if(ref($g_array->[$row]) eq 'ARRAY'){
		for (my $col = 0; $col < @{$g_array->[$row]}; $col++) {
		    if(ref($g_array->[$row][$col]) eq 'ARRAY'){
			for (my $i = 0; $i < @{$g_array->[$row][$col]}; $i++) {
			    if(ref($g_array->[$row][$col][$i]) eq 'ARRAY'){
				for (my $j = 0; $j < @{$g_array->[$row][$col][$i]}; $j++) {
				    if(ref($g_array->[$row][$col][$i][$j]) eq 'ARRAY'){
					for (my $s = 0; $s < @{$g_array->[$row][$col][$i][$j]}; $s++) {
					    if(ref($g_array->[$row][$col][$i][$j][$s]) eq 'ARRAY'){
						for (my $k = 0; $k < @{$g_array->[$row][$col][$i][$j][$s]}; $k++) {
						    print "a5:$row,$col,$i,$j,$s,$k:".$g_array->[$row][$col][$i][$j][$s][$k]."\n";
						}
					    }else{print "e5:$row,$col,$i,$j,$s:".$g_array->[$row][$col][$i][$j][$s]."\n";}
					}
				    }else{print "e4:$row,$col,$i,$j:".$g_array->[$row][$col][$i][$j]."\n";}
				}
			    }else{ print "e3:$row,$col,$i:".$g_array->[$row][$col][$i]."\n";}
			}
		    }else{ print "e2:$row,$col:".$g_array->[$row][$col]."\n";}
		}
	    }else{ print "e1:$row:".$g_array->[$row]."\n";}
	}
    }
}

my $C_RED;            #highlight
my $C_YELLOW;         #highlight
my $C_GRAY;           #language detected
my $C_CYAN_RAW;       #forms
my $C_GRAY_RED_RAW;   #phrases
my $C_DARK_BLUE_RAW;  #link for dictionary
my $C_BLUE_RAW;       #dictionary and vform1, suggestions
my $C_BRIGHT_RAW;     #phrases, examples main part, vform2
my $C_GREEN;          #t_result
if ($TERMINAL_C eq "WOB" ){
    $C_RED=`tput bold`.`tput setaf 1`;
    $C_YELLOW=`tput bold`.`tput setaf 3`;
    $C_GRAY="`tput setaf 7`";
    $C_CYAN_RAW="\033[1;36m";
    $C_GRAY_RED_RAW="\033[1;35m";
    $C_DARK_BLUE_RAW="\033[34m";
    $C_BLUE_RAW="\033[1;34m";
    $C_BRIGHT_RAW="\033[1;37m";
    $C_GREEN="\033[1;32m";
}elsif( $TERMINAL_C eq "BOW" ){
    $C_RED="`tput bold``tput setaf 1`";
    $C_YELLOW="`tput setaf 3`";
    $C_GRAY="`tput bold``tput setaf 5`";
    $C_CYAN_RAW="\033[1;36m";
    $C_GRAY_RED_RAW="\033[1;35m";
    $C_DARK_BLUE_RAW="`tput setaf 7`";
    $C_BLUE_RAW="\033[1;34m";
    $C_BRIGHT_RAW="`tput bold`";
    $C_GREEN="`tput bold`";
}else{ #universal
    $C_RED="`tput setaf 1`";
    $C_YELLOW="`tput bold`";
    $C_GRAY="";
    $C_CYAN_RAW="";
    $C_GRAY_RED_RAW="";
    $C_DARK_BLUE_RAW="";
    $C_BLUE_RAW="";
    $C_BRIGHT_RAW="`tput bold`";
    $C_GREEN="`tput bold`";
}
my $C_NORMAL="`tput sgr0`";
my $C_NORMAL_RAW="\033[0m";

my %opt =();
getopts( ":hlpSs:t:o:", \%opt ) or print "Usage: $name: [-S] [-h] [-l] [-p] [-s language_2_chars] [-t language_2_chars] [-o source_FILE]\n" and exit;

my $source;
my $target;
my $sound = 0;
#my $PROMPT_MODE_ACTIVATED;
my $TLSOURCE;
my $TLTARGET;
my $request;
my $filesource;

#Switch options
usage() if defined $opt{h};
$sound = 1 if defined $opt{S};
#if ($opt{p}){
#	print STDERR "Prompt mode activated";
#	$PROMPT_MODE_ACTIVATED=1;
#}
if (defined $opt{l}){
    foreach my $value (sort { $LANGS{$a} cmp $LANGS{$b} } keys %LANGS){
	print $value."\t".$LANGS{$value}."\n";}
    exit;
}
if (defined $opt{s}){
    $TLSOURCE = $opt{s} if defined $LANGS{$opt{s}};
#    print $TLSOURCE;
}
if (defined $opt{t}){
    $TLTARGET = $opt{t} if defined $LANGS{$opt{t}};    
}

if (defined $opt{o}){
    open FILE, $opt{o} or die "-o argument: couldn't open file: $!";
    local $/ = undef;
    $request = <FILE>;
}else{
    $request = join(" ", @ARGV);
    $request =~ tr/\x{a}/\n/;
}
#$request = quotemeta($request);
$request =~ s/^\s+|\s+$//g;     #trim both sides
exit 1 if ! length $request;

my $w_count = scalar(split(/\s+/,$request)); #LENGHT OF REQUEST IN WORDS

$source = 'auto';   $target = $LATIN_LANG;   #default
#Language detection by the first found Latin character
my $rutf8 = $request; utf8::decode($rutf8); #- to utf8 solid characters
foreach my $ch (map {split //} split('\s',(substr $rutf8,0,10))){ #first 10 characters
    #print $ch,ord $ch, "\n"; #65 - 122 = Latin
    if (ord $ch > 65 && ord $ch < 122 )
    {	    $source = $LATIN_LANG;   $target = $FIRST_LANG;    last;    }
}
$source = $TLSOURCE if $TLSOURCE;
$target = $TLTARGET if $TLTARGET;


my $ua = LWP::UserAgent->new; #Internet connection main object, we will clone it
$ua->agent($USERAGENT);
$ua->proxy(@PROXY) if @PROXY;

#my $url="https://check.torproject.org/";
#my $req = HTTP::Request->new(GET => $url);
#my $response = $ua->request($req);
#if ($response->is_success) {
#    print $response->decoded_content;
#}

########### google request
my $url="https://translate.google.com/translate_a/single?client=t&sl=$source&tl=$target&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8";
##
my $response;
my $rsum; # translation
my $translit; # translit
my @suggest; #google suggestions. appears sometimes.(options_for_one_word)
my @detected_languages;
my $error1; #error with highlight
my $error2; #correct version
my @dictionary;
##
#side effect function
&google($ua->clone, $url, $request); #$_[0] - ua    $_[1] - url   $_[2] - request

############ Echo
if( ! $error1 && $detected_languages[0] && $detected_languages[0] ne $source && ((lc $rsum) eq (lc $request))){
    print "detected languages: "; print $_."," foreach @detected_languages; print "\n";

    $source = $LANGS{$detected_languages[0]};
    print "trying with:".$source,"\n";

    ###side effect function
    undef $rsum; # translation
    undef $translit; # translit
    undef @suggest; #google suggestions. appears sometimes.(options_for_one_word)
    undef @detected_languages;
    undef $error1; #error with highlight
    undef $error2; #correct version
    undef @dictionary;
    my $url="https://translate.google.com/translate_a/single?client=t&sl=$source&tl=$target&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8";
    &google($ua->clone, $url, $request); #$_[0] - ua    $_[1] - url   $_[2] - request
}

print $C_GREEN.$rsum.$C_NORMAL_RAW,"\n"; #echo result
if($error1){
    print $error1,"\n"; #echo error   
}else{
    print $_,"\n" foreach @dictionary;  #echo dictionary
}

#if(scalar @suggest > 1){ #echo options or suggestions (working but sucks)
#    print $C_BLUE_RAW."Options:".$C_NORMAL_RAW,"\n";
#    print $_,"\n" foreach @suggest;
#};


#THE END








#SIDE EFFECT:
#$rsum; # translation
#$translit; # translit
#@suggest; #google suggestions. appears sometimes.(options_for_one_word)
#@detected_languages;
#$error1; #error with highlight
#$error2; #correct version
#@dictionary;
sub google($$$){#$_[0] - ua (object)    $_[1] - url      $_[2] - request
    my $req = HTTP::Request->new(POST => $_[1]);
    $req->content("text=".uri_escape("$_[2]")); #encode to url REQUIRED

    my $response;
    $response = $_[0]->request($req);
    $response = $_[0]->request($req) if (! $response->is_success); #resent
 
    my $g_array;
    if ($response->is_success) { #to array
	#print $response->decoded_content;
	#    if ($response->isa('HTTP::Response::JSON')) {
	#my $json = $response->json_content; #decoded
	my $js = $response->decoded_content;
	$js =~ s/,,/,"",/g;
	$js =~ s/,,/,"",/g;
	$js =~ s/\[,/\["",/g;
	$js =~ s/,\]/,""\]/g;
	#    print $js."\n";
	#my $g_array = decode_json($js);
	#my @objs = JSON->new->incr_parse ($js);
	$g_array =  JSON->new->decode($js);
	#    my $pp = JSON->new->pretty->encode( $g_array ); # pretty-printing
	#    print $pp;
	
	#&testing($g_array); #TESTING

    }
    else {
	print "Can't connect google: ".$response->status_line, "\n"; exit 1;
    }

 #   my $rsum; # translation
 #   my $translit; # translit
 #   my @suggest; #google suggestions. appears sometimes.(options_for_one_word)
 #   my @detected_languages;
 #   my $error1; #error with highlight
 #   my $error2; #correct version
 #   my @dictionary;
    if(ref($g_array) eq 'ARRAY'){
	#language detections
	if(ref($g_array->[8]) eq 'ARRAY'){
	    if($g_array->[8][0][0]){
		@detected_languages=(@detected_languages,$_) foreach @{$g_array->[8][0]};
	    }else{ print "strange error in google json1";}
	}
	#error detection
	if(ref($g_array->[7]) eq 'ARRAY'){	
	    if($g_array->[7][0] && $g_array->[7][1]){
		$error1 = decode_entities($g_array->[7][0]); #decode html character entities
		$error2 = $g_array->[7][1];
	    }else{ print "strange error in google json2";}
	    
	    #Highlight - error checking
	    if($w_count <= 2){ #complicated, I knew
		my @request = split //,$request;
		my @right = split //, $error2;
		my @fixed = @right;#working array
		my $count = 0;    #insertions
		my $save = -1;    #last error position
		my $pos;          #index + insertions
		my $n = (scalar @right > scalar @request)? scalar @request : scalar @right; #lowest
		for(my $i = 0; $i < $n; $i++){ #diff strings and highlight insertion
		    if($right[$i] ne $request[$i]){
			if ($save+1 != $i){
			    $pos = $count+$i;
			    @fixed = (@fixed[0..$pos-1], $C_RED ,@fixed[$pos..$n+$count-1]);
			    $count++;
			}
			$save=$i;#error save position
		    }elsif($save+1 == $i){
			$pos = $count+$i;
			@fixed = (@fixed[0..$pos-1], $C_YELLOW ,@fixed[$pos..$n+$count-1]);
			$count++;
		    }
		}
		@fixed = (@fixed, $C_NORMAL_RAW);
		$error1 = join '', @fixed;
	    }else{
		$error1 =~ s|<b><i>|$C_YELLOW|g;
		$error1 =~ s|</i></b>|$C_NORMAL_RAW|g;
	    }
	}

#	if( ! defined $error1){
	#translation
	$_=$request; my $nc = tr/\n//;   #check for \x{a} unicode or \n
	if(! defined $error1 && (length $request < 1000) && ($nc == 0) ){ # if <1000 we will fix english article problem if >1000 leave it be
	    if(ref($g_array->[5]) eq 'ARRAY'){
		for (my $col = 0; $col < @{$g_array->[5]}; $col++) {
		    if($g_array->[5][$col][2][0][0]){
			my $t = $g_array->[5][$col][2][0][0];
			$rsum .= $t." ";
		    }
		}
	    }
	}else{ # >1000
	    if(ref($g_array->[0]) eq 'ARRAY'){
		for (my $col = 0; $col < @{$g_array->[0]}; $col++) {
		    if($g_array->[0][$col][0]){
			my $t = $g_array->[0][$col][0];
			$rsum .= $t;
		    }
		}
	    }
	}
	$rsum =~ s/\s+,/,/g; #asd , asd
	$rsum =~ s/\s+\./\./g; #asdas .
	$rsum =~ s/\s+\?/?/g; #asdas ?
	$rsum =~ s/\s+\!/!/g; #asdas !
	$rsum =~ s/\s+\"\s+/ /g; #students’ are either   =  студенты " либо
	#translit
	if($w_count <= $TRANSLIT_WORDS_MAX){
	    if($g_array->[0][1][3]){
		$translit = $g_array->[0][1][3];
	    }
	}
	#suggestions(working but sucks)
	#	if(ref($g_array->[5][0][2]) eq 'ARRAY'){	
	#	    for (my $col = 0; $col < @{$g_array->[5][0][2]}; $col++) {
	#		if($g_array->[5][0][2][$col][0]){
	#		    @suggest=(@suggest,$g_array->[5][0][2][$col][0]);#add element
	#		}
	#	    }
	#	}
	#Dictionary
	if(ref($g_array->[1]) eq 'ARRAY'){
	    for (my $row = 0; $row < @{$g_array->[1]}; $row++) {
		if($g_array->[1][$row][0]){
		    @dictionary = (@dictionary, $C_BLUE_RAW.$g_array->[1][$row][0].$C_NORMAL_RAW); #noun, verb
		    if(ref($g_array->[1][$row][2])){
			for (my $col = 0; $col < @{$g_array->[1][$row][2]}; $col++) {
			    my $freq;
			    if ($g_array->[1][$row][2][$col][3]){
				$freq=$g_array->[1][$row][2][$col][3];
				$freq=sprintf ('%.2f', ($freq*100000)/10);
				$freq=sprintf ('%.2f', $freq/3) if ($freq > 1 );
				$freq=sprintf ('%.0f', $freq);
			    }
			    $freq = $freq ? " ".$freq : "";  #delete 0
			    my @v;
			    @v=(@v,$_) foreach @{$g_array->[1][$row][2][$col][1]};
			    @dictionary = (@dictionary, $g_array->[1][$row][2][$col][0]." ".join(", ", @v).$freq);
			}
		    }
		}
	    }
	}
    }else{ #print $response,"\n";
		print "Wrong answer from google","\n"; exit 1;}
}
