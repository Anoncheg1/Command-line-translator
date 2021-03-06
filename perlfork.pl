#!/usr/bin/env perl
#-*-Perl-*-

# GOOGLE TRANSLATE SCRIPT. This tool for access Google Translate from terminal.

#    Copyright (C) 2015 Vitalij Chepelev.

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
# https://github.com/Anoncheg1/Command-line-translator
#
# requirements: 
#	libjson-perl
#	liblwp-protocol-socks-perl - if you need socks proxy
#
# features:
# -translated text, fixed text with highlight, language detection, dictionary, translit, read from file, text-to-speach
#
# used translate.google.com

package GoogleTranslator;

use strict; # ограничить применение небезопасных конструкций
#use warnings; # выводить подробные предупреждения компилятора
#use diagnostics; # выводить подробную диагностику ошибок
use Getopt::Std;
use File::Basename;
use LWP::UserAgent;
#Debian: libjson-perl
use JSON;
use HTML::Entities;
#Debian: liblwp-protocol-socks-perl
#use LWP::Protocol::socks;
use URI::Escape;
use Clone 'clone';
use utf8;
use v5.16;
#use Text::Unidecode;
#binmode(STDOUT, ":utf8");

use Encode::Locale;
use Encode;

# adjust to taste
my $FIRST_LANG='ru';		#
my $SECOND_LANG='en';		# In simple detection of direction it used for A-z latin alphabet
my $ALD=0;                      #Advanced language detection. May be slow.
my $TERMINAL_C="WOB";		#Your terminal - white on black:WOB, black on white:BOW, other unix:O, Windows:"".
my $SOUND_ALWAYS = 0;		#text-to-speach
#my $MPG123 = 0;				# 1- mpg123 0- mplayer    for speach
my $player = "mpg123 -"; #"mpv - "; #"vlc -";
    
#my $LC_ALWAYS = 1;			#Lowercase request.
my $TRANSLIT_LENGTH_MAX = 10;
my @PROXY ; #for proxy you need LWP::Protocol::socks
#@PROXY =([qw(http https)] => "socks://172.16.0.1:9150"); #tor
#@PROXY = ([qw(http https)] => "http://127.0.0.1:4445"); #i2p
#@PROXY = ('http','http://127.0.0.1:4444'); #i2p

my $USERAGENT = 'Mozilla/5.0 (Windows NT 6.1; rv:38.0) Gecko/20100101 Firefox/38.0';

#Solved problems:
#  google JSON converting problem ,,. Solved by hands.
#  google JSON article=white space - problem. Solved by hands.
#  google special characters in request. Solved by url encode.
#  tk protection. Solved by javascript beautify with hands and soimort, good man(time/3600).
#TODO
#Japane, Chinese count of words.
#  asynchronous HTTP::Request http://search.cpan.org/dist/HTTP-Async/lib/HTTP/Async.pm

my $name = basename($0);
my %LANGS = (
	     'af' => 'Afrikaans',
	     'ak' => 'Akan',
	     'sq' => 'Albanian',
	     'am' => 'Amharic',
	     'ar' => 'Arabic',
	     'hy' => 'Armenian',
	     'az' => 'Azerbaijani',
	     'eu' => 'Basque',
	     'be' => 'Belarusian',
	     'bem' => 'Bemba',
	     'bn' => 'Bengali',
	     'bh' => 'Bihari',
	     'xx-bork' => 'Bork, bork, bork!',
	     'bs' => 'Bosnian',
	     'br' => 'Breton',
	     'bg' => 'Bulgarian',
	     'ca' => 'Catalan',
	     'ceb' => 'Cebuano',
	     'chr' => 'Cherokee',
	     'ny' => 'Chichewa',
	     'zh' => 'Chinese',
	     'zh-CN' => 'Chinese (Simplified)',
	     'zh-TW' => 'Chinese (Traditional)',
	     'co' => 'Corsican',
	     'hr' => 'Croatian',
	     'cs' => 'Czech',
	     'da' => 'Danish',
	     'nl' => 'Dutch',
	     'xx-elmer' => 'Elmer Fudd',
	     'en' => 'English',
	     'eo' => 'Esperanto',
	     'et' => 'Estonian',
	     'ee' => 'Ewe',
	     'fo' => 'Faroese',
	     'tl' => 'Filipino',
	     'fi' => 'Finnish',
	     'fy' => 'Frisian',
	     'fr' => 'French',
	     'gaa' => 'Ga',
	     'gl' => 'Galician',
	     'ka' => 'Georgian',
	     'de' => 'German',
	     'el' => 'Greek',
	     'gu' => 'Gujarati',
	     'xx-hacker' => 'Hacker',
	     'ht' => 'Haitian Creole',
	     'ha' => 'Hausa',
	     'haw' => 'Hawaiian',
	     'iw' => 'Hebrew',
	     'hi' => 'Hindi',
	     'hmn' => 'Hmong',
	     'hu' => 'Hungarian',
	     'is' => 'Icelandic',
	     'ig' => 'Igbo',
	     'id' => 'Indonesian',
	     'ia' => 'Interlingua',
	     'ga' => 'Irish',
	     'it' => 'Italian',
	     'ja' => 'Japanese',
	     'jw' => 'Javanese',
	     'kn' => 'Kannada',
	     'kk' => 'Kazakh',
	     'km' => 'Khmer',
	     'rw' => 'Kinyarwanda',
	     'rn' => 'Kirundi',
	     'xx-klingon' => 'Klingon',
	     'kg' => 'Kongo',
	     'ko' => 'Korean',
	     'kri' => 'Krio (Sierra Leone)',
	     'ku' => 'Kurdish',
	     'ckb' => 'Kurdish (Soranî)',
	     'ky' => 'Kyrgyz',
	     'lo' => 'Laothian',
	     'la' => 'Latin',
	     'lv' => 'Latvian',
	     'ln' => 'Lingala',
	     'lt' => 'Lithuanian',
	     'loz' => 'Lozi',
	     'lg' => 'Luganda',
	     'ach' => 'Luo',
	     'mk' => 'Macedonian',
	     'mg' => 'Malagasy',
	     'ms' => 'Malay',
	     'ml' => 'Malayalam',
	     'mt' => 'Maltese',
	     'mi' => 'Maori',
	     'mr' => 'Marathi',
	     'mfe' => 'Mauritian Creole',
	     'mo' => 'Moldavian',
	     'mn' => 'Mongolian',
	     'sr-ME' => 'Montenegrin',
	     'my' => 'Myanmar (Burmese)',
	     'ne' => 'Nepali',
	     'pcm' => 'Nigerian Pidgin',
	     'nso' => 'Northern Sotho',
	     'no' => 'Norwegian',
	     'nn' => 'Norwegian (Nynorsk)',
	     'oc' => 'Occitan',
	     'or' => 'Oriya',
	     'om' => 'Oromo',
	     'ps' => 'Pashto',
	     'fa' => 'Persian',
	     'xx-pirate' => 'Pirate',
	     'pl' => 'Polish',
	     'pt' => 'Portuguese',
	     'pt-BR' => 'Portuguese (Brazil)',
	     'pt-PT' => 'Portuguese (Portugal)',
	     'pa' => 'Punjabi',
	     'qu' => 'Quechua',
	     'ro' => 'Romanian',
	     'rm' => 'Romansh',
	     'nyn' => 'Runyakitara',
	     'ru' => 'Russian',
	     'gd' => 'Scots Gaelic',
	     'sr' => 'Serbian',
	     'sh' => 'Serbo-Croatian',
	     'st' => 'Sesotho',
	     'tn' => 'Setswana',
	     'crs' => 'Seychellois Creole',
	     'sn' => 'Shona',
	     'sd' => 'Sindhi',
	     'si' => 'Sinhalese',
	     'sk' => 'Slovak',
	     'sl' => 'Slovenian',
	     'so' => 'Somali',
	     'es' => 'Spanish',
	     'es-419' => 'Spanish (Latin American)',
	     'su' => 'Sundanese',
	     'sw' => 'Swahili',
	     'sv' => 'Swedish',
	     'tg' => 'Tajik',
	     'ta' => 'Tamil',
	     'tt' => 'Tatar',
	     'te' => 'Telugu',
	     'th' => 'Thai',
	     'ti' => 'Tigrinya',
	     'to' => 'Tonga',
	     'lua' => 'Tshiluba',
	     'tum' => 'Tumbuka',
	     'tr' => 'Turkish',
	     'tk' => 'Turkmen',
	     'tw' => 'Twi',
	     'ug' => 'Uighur',
	     'uk' => 'Ukrainian',
	     'ur' => 'Urdu',
	     'uz' => 'Uzbek',
	     'vi' => 'Vietnamese',
	     'cy' => 'Welsh',
	     'wo' => 'Wolof',
	     'xh' => 'Xhosa',
	     'yi' => 'Yiddish',
	     'yo' => 'Yoruba',
	     'zu' => 'Zulu'
	    );

############ Functions
#$SIG{INT} = \&sig_handler;
#sub sig_handler { #Ctrl+C detection.
#   print "Exit signal detected. Deleting cache files.\n";
#   exit;
#}

# Message about this program and how to use it
sub usage()
{
    print STDOUT << "EOF";
$name [-S] [-l] [-h] [-p] [-s language_2_chars] [-t language_2_chars] text | -
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
-r
  force retranslate with fixed string
-o FILE 
  read request from file
-
  read from STDIN pipe
Configure "FIRST_LANG" and "LATIN_LANG" in script for auto detection of direction by the first character!
You neeed UTF-8 support for required languages.
EOF
    exit;
}

my $C_RED = "";            #highlight
my $C_YELLOW = "";         #highlight
my $C_GRAY = "";           #language detected
my $C_CYAN_RAW = "";       #forms
my $C_GRAY_RED_RAW = "";   #phrases
my $C_DARK_BLUE_RAW = "";  #link for dictionary
my $C_BLUE_RAW = "";       #dictionary and vform1, suggestions
my $C_BRIGHT_RAW = "";     #phrases, examples main part, vform2
my $C_GREEN = "";          #t_result

my $C_NORMAL="`tput sgr0`"; #erase
my $C_NORMAL_RAW="\033[0m";

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
}elsif( $TERMINAL_C eq "O" ){ #universal unix
    $C_RED="`tput setaf 1`";
    $C_YELLOW="`tput bold`";
    $C_GRAY="";
    $C_CYAN_RAW="";
    $C_GRAY_RED_RAW="";
    $C_DARK_BLUE_RAW="";
    $C_BLUE_RAW="";
    $C_BRIGHT_RAW="`tput bold`";
    $C_GREEN="`tput bold`";
}else{
    $C_NORMAL = ""; #nothing at all
    $C_NORMAL_RAW = "";
}

my %opt =();
getopts( ":hlpSrs:t:o:", \%opt ) or print STDERR "Usage: $name: [-S] [-h] [-l] [-p] [-s language_2_chars] [-t language_2_chars] [-o source_FILE]\n" and exit 1;

my $source;
my $target;
my $sound = $SOUND_ALWAYS;
#my $PROMPT_MODE_ACTIVATED;
my $TLSOURCE;
my $TLTARGET;
my $request;
my $filesource;
my $reforced;

#Switch options
usage() if defined $opt{h};
$sound = 1 if defined $opt{S};
$reforced = 1 if defined $opt{r};
if (defined $opt{l}){
    foreach my $value (sort { $LANGS{$a} cmp $LANGS{$b} } keys %LANGS){
	print $value."\t".$LANGS{$value}."\n";}
    exit;
}
if (defined $opt{s}){
    $TLSOURCE = $opt{s} if (defined $LANGS{$opt{s}} || $opt{s} == "auto") ;
}
if (defined $opt{t}){
    $TLTARGET = $opt{t} if defined $LANGS{$opt{t}};
}
if (defined $opt{o}){ #read from file
    open FILE, $opt{o} or print STDERR "-o argument: couldn't open file: $!" and exit 1;
    local $/ = undef;
    $request = <FILE>;
}elsif(defined $ARGV[0] && $ARGV[0] eq "-"){ #read from pipe
	#$request = do{ local $/; <STDIN> }; #multiline
	$request = <STDIN>; #one line
}else{ #read from arguments
    $request = join(" ", @ARGV);
    #$request =~ tr/\x{a}/\n/; #I forgot what is that.
}
#$request = quotemeta($request);

$request =~ s/^\s+//g;     #trim front sides
#$request =~ s/\s+$//g;     #trim back sides СССР error
exit 1 if ! length $request;

#my $w_count = scalar(split(/\s+/,$request)); #LENGHT OF REQUEST IN WORDS

$source = 'auto'; #default
$target = 'en';   #default
###### SIMPLE DETECTION OF DIRECTION by the first found character
#This is complicated thing with Latin languages. We can detect language by first character.
#But all latin characters used same symbols.
#Same thing with other languages.
if( $ALD == 0 ){
    my $rutf8 = $request; utf8::decode($rutf8); #- to utf8 solid characters
    foreach my $ch (map {split //} split('\s',(substr $rutf8,0,12))){ #first 12 characters
	#print ord $ch, "\n"; #65 - 122 = Latin
	if (ord $ch >= 65 && ord $ch <= 122 )        #Latin
	{	    $source = $SECOND_LANG;   $target = $FIRST_LANG;    last;
	}elsif(ord $ch >= 1040 && ord $ch <= 1103 ){ #Russian #may fail rarely
            $source = 'ru';   $target = $SECOND_LANG;    last; }
    }
}
######
$source = $TLSOURCE if $TLSOURCE;
$target = $TLTARGET if $TLTARGET;

my $ua = LWP::UserAgent->new; #Internet connection main object, we will clone it
$ua->agent($USERAGENT);
$ua->proxy(@PROXY) if @PROXY;

# TKK GOOGLE "PROTECTION"
#TODO:detect language and get translation from tkk first google request
=temporarely replaced with url client=gtx to "/translate_a/single?client=gtx"
my $url="https://translate.google.com";
my $req = HTTP::Request->new(GET => $url);
my $response;
$response = $ua->request($req);
$response = $ua->request($req) if (! $response->is_success); #resent
my $cont;
if (!$response->is_success){print "Can't connect google: ".$response->status_line, "\n"; exit 1;}
my $tkka;
my $tkkb;

if ($response->decoded_content =~ /TKK=eval(.*)\(a\+b\)}\)/){
	$cont=$1;
}else{ print "tkk error","\n"; exit 1;}
if ($cont =~ /a\\x3d([-+]?[0-9]*)/){
	$tkka = $1;
}else{ print "tkka error","\n"; exit 1;}
if ($cont =~ /b\\x3d([-+]?[0-9]*)/){
	$tkkb = $1;
}else{ print "tkkb error","\n"; exit 1;}
my $tk_hacked=&google_tk_hack($request,$tkka,$tkkb);
=cut
#
########### google request
my $response;
my $rsum; # translation
my $translit_s; # translit source
my $translit_t; # translit target
my @suggest; #google suggestions. appears sometimes.(options_for_one_word)
my @detected_languages;
my $corr_raw; #error with highlight
my $corr_clear; #correct version
my @dictionary;
#my $url = "https://translate.google.com/translate_a/single?client=t&sl=".$source."&tl=".$target."&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8&tk=".$tk_hacked;
my $url = "https://translate.google.com/translate_a/single?client=gtx&sl=".$source."&tl=".$target."&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8";
##
#side effect function
&google(clone($ua), $url); #$_[0] - ua    $_[1] - url
#$rsum =~ s/(.)/sprintf("%x",ord($1))/eg; #replace every character with HEX

my $advdd = 0; #loop disabler.
##### Advanced detection of direction
if ($ALD == 1 && ! $TLSOURCE){
    if($detected_languages[0]){
	if($detected_languages[0] eq $FIRST_LANG && $source ne $FIRST_LANG){
	    $target = $SECOND_LANG; $advdd = 1;
	}elsif($detected_languages[0] eq $SECOND_LANG && $source ne $SECOND_LANG){
	    $target = $FIRST_LANG; $advdd = 1;
	}
    }
}
##### language detection loop
#test
#t ma vie
#franch translate
#t gereer
#Afrikaans translate
#t mithematic
#fixed mathematic


my @d_l; # det lang before loop
my $so; #detected language in  @d_l
#if
# no error
# was detected languages
# det lang != source
#stop if
# result != request
# or we have dictionary
if( !$advdd && ! $corr_raw && $detected_languages[0] && $detected_languages[0] ne $source){
    @d_l = @detected_languages;
    print "Detected languages: "; print $_."," foreach @d_l; print "\n";

    foreach $so (@d_l){
		#$target = "en";
		print "trying with:".$LANGS{$so},"\n";
		###side effect function
		undef $rsum; # translation
		undef $translit_s; # translit source
		undef $translit_t; # translit target
		undef @suggest; #google suggestions. appears sometimes.(options_for_one_word)
		undef @detected_languages;
		undef $corr_raw; #error with highlight
		undef $corr_clear; #correct version
		undef @dictionary;
		#$url = "https://translate.google.com/translate_a/single?client=t&sl=".$source."&tl=".$target."&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8&tk=".$tk_hacked;
		$url = "https://translate.google.com/translate_a/single?client=gtx&sl=".$so."&tl=".$target."&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8";
		&google(clone($ua), $url); #$_[0] - ua    $_[1] - url
		last if ((lc $rsum) ne (lc $request) || @dictionary);
    }
}
#if -r option - rerequest with fixed
if($reforced && $corr_raw){
  $request = $corr_clear;
  $url = "https://translate.google.com/translate_a/single?client=gtx&sl=".$so."&tl=".$target."&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8";
  undef $rsum;		# translation
  undef $translit_s;		# translit source
  undef $translit_t;		# translit target
  undef @suggest; 		#google suggestions. appears sometimes.(options_for_one_word)
  undef @detected_languages;
  undef $corr_raw;		#error with highlight
  undef $corr_clear;	#correct version
  undef @dictionary;
  &google(clone($ua), $url);	#$_[0] - ua    $_[1] - url
}

############ Echo
#utf8::decode($rsum);
#utf8::decode($corr_raw);
#utf8::decode($_) foreach @dictionary;
#utf8::decode($_) foreach @suggest;
#utf8::decode($translit_s);
#utf8::decode($translit_t);

print $C_GREEN.$rsum.$C_NORMAL_RAW,"\n" if $rsum; #echo result
if($corr_raw){
    print $corr_raw,"\n"; #echo error   
}elsif(@dictionary){
    print $_,"\n" foreach @dictionary;  #echo dictionary
}
if( (scalar @dictionary < 13) && (scalar @suggest > 1) ){	#echo suggestions
    print $C_BLUE_RAW."Options:".$C_NORMAL_RAW,"\n";
    print $_,"\n" foreach @suggest;
}

if( $rsum && (lc $rsum) ne (lc $request) ) {
    print "  ".$translit_s,"\n" if $translit_s;
    print "  ".$translit_t,"\n" if $translit_t;

    ### Text-To-Speach
    #url = HttpProtocol HttpHost "/translate_tts?ie=UTF-8&client=t"	\
    #       "&tl=" tl "&q=" preprocess(text)
    #    my $url="https://translate.google.com//translate_tts?ie=UTF-8&client=t&tl=en&zq=cat";
    if($sound && length($request) < 25){
		my $lang = (@detected_languages && ! $TLSOURCE) ? $detected_languages[0] : $source;
		#tkk$url="https://translate.google.com//translate_tts?ie=UTF-8&client=t&tk=".$tk_hacked."&tl=".$lang."&q=".uri_escape($request); # for source
		$url="https://translate.google.com//translate_tts?ie=UTF-8&client=gtx&tl=".$lang."&q=".uri_escape($request); # for source
		#$url="https://translate.google.com//translate_tts?ie=UTF-8&client=t&tk&tl=".$target."&q=".uri_escape($rsum); # for target - alternative version old
		my $req = HTTP::Request->new(GET => $url);

		my $uac = clone($ua);
		my $response;
		$response = $uac->request($req);
		$response = $uac->request($req) if (! $response->is_success); #resent

		if ($response->is_success) {
		  open(FOO, "|".$player." 2>/dev/null 1>/dev/null") || ( print STDERR "Failed: $!\n" and exit 1 );
		  print FOO $response->content;

			# if($MPG123){
			# 	open(FOO, "|mpg123 - 2>/dev/null 1>/dev/null") || ( print STDERR "Failed: $!\n" and exit 1 );
			#     print FOO $response->content;
			# }else{
			# 	my $t = "tmpspeachfileo1o.mpga";
			# 	open FILE, ">", "$t";
			# 	print FILE $response->content;
			# 	close FILE;			
			# 	system "mplayer $t >/dev/null 2>&1";
			# 	system "rm -f $t >/dev/null 2>&1";
			# }
		}else{
		    print STDERR "Can't get sound from google: ".$response->status_line, "\n"; exit 1;
		}
    }

}

#THE END
























#SIDE EFFECT:
#$rsum; # translation
#$translit_s; # translit source
#$translit_t; # translit target
#@suggest; #google suggestions. appears sometimes.(options_for_one_word)
#@detected_languages;
#$corr_raw; #error with highlight
#$corr_clear; #correct version
#@dictionary;
#READ:
#$request
sub google($$){#$_[0] - ua (object)    $_[1] - url
    my $req = HTTP::Request->new(POST => $_[1]);
    $req->content("text=".uri_escape($request)); #encode to url REQUIRED

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

    }else {
		print "Can't connect google: ".$response->status_line, "\n"; exit 1;
    }

 #   my $rsum; # translation
 #   my $translit_s; # translit source
 #   my $translit_t; # translit target
 #   my @suggest; #google suggestions. appears sometimes.(options_for_one_word)
 #   my @detected_languages;
 #   my $corr_raw; #error with highlight
 #   my $corr_clear; #correct version
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
		$corr_raw = decode_entities($g_array->[7][0]); #decode html character entities
		$corr_clear = $g_array->[7][1];

		#Highlight - error checking
		if(length($request) < 18){ #bad for Japanese and Chinese, fix it late
			my $r = $request; 
			utf8::decode($r);
			utf8::decode($corr_clear);
		    my @request = split //,$r;
		    my @right = split //, $corr_clear;
		    my @fixed = @right;#working array
		    my $count = 0;    #insertions
		    my $save = -1;    #last error position
		    my $pos;          #index + insertions
		    my $n = scalar @right;
		    for(my $i = 0, my $j = 0; $i < $n; $i++, $j++){ #diff strings and highlight insertion
			if(! $request[$i]){ $j--; }
			if($right[$i] ne $request[$j]){
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
		    $corr_raw = join '', @fixed;
			utf8::encode($corr_raw);
		}else{
		    $corr_raw =~ s|<b><i>|$C_YELLOW|g;
		    $corr_raw =~ s|</i></b>|$C_NORMAL_RAW|g;
		}
	    }elsif($g_array->[7][1]){
		$corr_raw = $g_array->[7][1];
		$corr_clear = $corr_raw;
	    } #else{ print "strange error in google json2 [7][1] error"; exit 1;}
	    utf8::encode($corr_clear);
	}

#	if( ! defined $corr_raw){
	#translation
	$_=$request; my $nc = tr/\n|\x{a}//;   #check for \x{a} unicode or \n - we will skip multiline too.
	if((length $request < 1000) && ($nc == 0)){ # if <1000 we will fix english article problem if >1000 leave it be
	    if(ref($g_array->[5]) eq 'ARRAY'){
		for (my $col = 0; $col < @{$g_array->[5]}; $col++) {
		    if($g_array->[5][$col][2] eq 'ARRAY'){ if($g_array->[5][$col][2][0][0]){
			my $t = $g_array->[5][$col][2][0][0];
			$rsum .= $t." ";
		    }}
		}
	    }
	}
	if(! defined $rsum){ # >1000 or not defined $rsum
	    if(ref($g_array->[0]) eq 'ARRAY'){
		for (my $col = 0; $col < @{$g_array->[0]}; $col++) {
		    if($g_array->[0][$col][0]){
			my $t = $g_array->[0][$col][0];
			$rsum .= $t;
		    }
		}
	    }
	}
	if ($rsum){
		#$rsum =~ s/^\s+|\s+$//g; #trim both sides СССР error
		$rsum =~ s/^\s+//g; #trim both sides
		$rsum =~ s/\s+,/,/g; #asd , asd
		$rsum =~ s/\s+\./\./g; #asdas .
		$rsum =~ s/\s+\?/?/g; #asdas ?
		$rsum =~ s/\s+\!/!/g; #asdas !
		$rsum =~ s/\s+\"\s+/' /g; #students’ are either   =  студенты " либо
	}
	#translit
	if( length($request) <= $TRANSLIT_LENGTH_MAX){
		if($g_array->[0]){
			if($g_array->[0][1][3]){
			$translit_s = $g_array->[0][1][3];
			}
			if($g_array->[0][1][2]){
			$translit_t = $g_array->[0][1][2];
			}
		}
	}
	#suggestions or options
	if (length($request) <= 12){ #number of words #not woring for Chinese.
		if($g_array->[14]){#for source
			if(ref($g_array->[14][0]) eq 'ARRAY'){	
				for (my $col = 0; $col < @{$g_array->[14][0]}; $col++) {
					if($g_array->[14][0][$col]){
					    @suggest=(@suggest,$g_array->[14][0][$col]);#add element
					}
				}
			}
		}elsif($g_array->[5]){#for target
			if(ref($g_array->[5][0][2]) eq 'ARRAY'){
				for (my $col = 0; $col < @{$g_array->[5][0][2]}; $col++) {
					if($g_array->[5][0][2][$col][0]){
					    @suggest=(@suggest,$g_array->[5][0][2][$col][0]);#add element
					}
				}
			}
		}
	}
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
				$freq=sprintf ('%.2f', $freq/3);
				$freq=sprintf ('%.0f', $freq);
			    }
			    $freq = $freq ? " ".$freq : "";  #delete 0
			    my @v;
			    @v=(@v,$_) foreach @{$g_array->[1][$row][2][$col][1]};
			    @dictionary = (@dictionary, $g_array->[1][$row][2][$col][0]." ".join(",", @v).$freq); #dictionary style
			}
		    }
		}
	    }
	}
    }else{ #print $response,"\n";
		print "Wrong answer from google","\n"; exit 1;}
}



#no side effect
sub google_tk_hack($$$){
    my $a = $_[0]; utf8::decode($a);
	my $TKK_a = $_[1];
	my $TKK_b = $_[2];
    my @d;
	my $TKK1= $TKK_a+$TKK_b;
	my $TKKe= int(time/3600); #window[TKK]   #15 dec 2015
	#print $a,"\n";
    #print $TKK_a,"\n";
	#print $TKK_b,"\n";
	#print length $a,"\n";
    #$a - in @d - out
    for ( my $e = 0, my $f = 0; $f < (length $a); $f++) { #dump function "hexdump" " -v -e'1/1 \"%03u\" \" \"'"
	    my $char = ord substr($a, $f, $f+1);
	    if( 128 > $char){
		$d[$e++] = $char;
	    }else{
		if( 2048 > $char ){
		    $d[$e++] = ($char >> 6) | 192;
		}else{
		    if( (55296 == ($char & 64512)) && (($f + 1) < (length $a)) && (56320 == (ord substr($a,$f+1,$f+2) & 64512))  ){
			$f++;
			$char = 65536 + (($char & 1023) << 10) + (ord substr($a,$f,$f+1) & 1023);
			$d[$e++] = ($char >> 18) | 240;
			$d[$e++] = ($char >> 12) & 63 | 128;
		    }else{
			$d[$e++] = ($char >> 12) | 224;
		    }
		    $d[$e++] = ($char >> 6) & 63 | 128;
		}
		$d[$e++] = ($char & 63) | 128;
	    }
		
    }
	
	$a = $TKKe;
	
    for (my $e = 0; $e < scalar @d ; $e++){
	$a += $d[$e];
	#$a = &RLVb($a); 
	my $dr = scalar ($a<<(10+(64-32)))>>(64-32);
	$a = ($a + $dr) & 4294967295;
	$a = ($a - 4294967296) if ($a > 2147483647); #2**31-1 and 2*32 corrections
	$dr = $a < 0 ? (4294967296+($a)) >> 6 : $a >> 6; #>>>	
	if ($a<0){ #there is error but it is working anyway
	    $a=((4294967295 & $a) ^ $dr);
	}elsif($dr<0){
	    $a=((4294967295 & $dr) ^ $a);
        }else{
	    $a = $a ^ $dr;
        }
    }

    #$a = &RLUb($a);
    my $db = scalar ($a<<(3+(64-32)))>>(64-32);
    $a = $a + $db & 4294967295; 
    $db = $a < 0 ? (2**32+($a)) >> 11 : $a >> 11; #>>> 
    $a = $a ^ $db;
    $db = scalar ($a<<(15+(64-32)))>>(64-32);
    $a = $a + $db & 4294967295;
    $a = $a > 2147483647 ? $a - 4294967296 : $a;

	#$a ^= $TKK1;  #@2**32-1 = 4294967295
	if ($a<0){
		$a=((4294967295 & $a) ^ $TKK1);
	}elsif($TKK1<0){
	    $a=((4294967295 & $TKK1) ^ $a);
        }else{
	    $a = $a ^ $TKK1;
        }

	if (0 > $a){
		$a = ($a & 2147483647) + 2147483648;
    }
    $a %= 1000000; #1E6
	#print sprintf("%i.%i",$a,($a ^ $TKKe));
    return sprintf("%i.%i",$a,($a ^ $TKKe));
}

sub testing($){  #not used
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

=comment multiline_comment
    sub RLVb($) { #+-a^+6  1447840518
	my $a = $_[0];
	my $dr = scalar ($a<<(10+(64-32)))>>(64-32);
	$a = ($a + $dr) & 4294967295;
	$a = ($a - 4294967296) if ($a > 2147483647); #2**31-1 and 2*32 corrections
	$dr = $a < 0 ? (2**32+($a)) >> 6 : $a >> 6; #>>>	
	if ($a<0){
	    $a=(((4294967296 + $a) ^ $dr) - 4294967296 );
	}elsif($dr<0){
	    $a=(((4294967296+$dr) ^ $a)-4294967296 );
        }else{
	    $a = $a ^ $dr; #-609717580   57582026
        }
	return $a;
    }

    sub RLUb($) { #+-3^+b+-f
	my $a = $_[0];
	my $db = scalar ($a<<(3+(64-32)))>>(64-32);
	$a = $a + $db & 4294967295; #1710107718
	$db = $a < 0 ? (2**32+($a)) >> 11 : $a >> 11; #>>> #835013
	$a = $a ^ $db; #1709347203
	$db = scalar ($a<<(15+(64-32)))>>(64-32);#1220640768
	$a = $a + $db & 4294967295; #-1364979325
	$a = $a > 2**31-1 ? $a - 2**32 : $a;
	return $a;
    }
=cut
