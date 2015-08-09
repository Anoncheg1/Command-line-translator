#!/usr/bin/env perl
use strict; # ограничить применение небезопасных конструкций
use warnings; # выводить подробные предупреждения компилятора
use diagnostics; # выводить подробную диагностику ошибок
use Getopt::Std;
use File::Basename;
use LWP::UserAgent;
#use Lingua::Identify;
#libjson-perl
use JSON;
use utf8;
use v5.16;
package main;

# adjust to taste
my $FIRST_LANG='ru';			#target language for request in LATIN_LANG		NOT in A-z latin alphabet
my $LATIN_LANG='en';			#target for all not A-z latin requests			A-z latin alphabet will be detected!
my @PROXY ;#= ('http','http://127.0.0.1:4446');

my $USERAGENT = 'Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1';


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
-S Enable sound for one word
//-p Prompt mode
-s lang Set source language
-t lang Set target language
-l List of languages
You can force the language with environment varibles by command:
export TLSOURCE=en TLTARGET=ru
but better configure "FIRST_LANG" and "LATIN_LANG" in script for auto detection of direction by the first character!
You neeed UTF-8 support for required languages.
EOF
    exit 0;
}

sub google($$$){#$_[0] - ua    $_[1] - url   #$_[2] - request
    my $req = HTTP::Request->new(POST => $_[1]);
    $req->content("text=$_[2]");
    my $response;
    $response = $_[0]->request($req);
    $response = $_[0]->request($req) if (! $response->is_success); #resent
    return $response;
}


my %opt =();
getopts( ":hlpSs:t:", \%opt ) or print "Usage: $name: [-S] [-h] [-l] [-p] [-s language_2_chars] [-t language_2_chars]\n" and exit;

my $source;
my $target;
my $sound = 0;
#my $PROMPT_MODE_ACTIVATED;
my $TLSOURCE;
my $TLTARGET;
my $request;

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
if ($opt{t}){
    $TLSOURCE = $opt{t} if defined $LANGS{$opt{t}};    
}
$request= join(" ", @ARGV);
$request =~ s/^\s+|\s+$//g;     #trim both sides
exit 1 if ! length $request;

#Language detection by the first character (very simple)
foreach my $ch (map {split //} split('\s',(substr $request,0,10))){
#    print ord $ch, "\n"; #65 - 122 = Latin
    if (ord $ch > 65 && ord $ch < 122 )
    {	    $source = $LATIN_LANG;   $target = $FIRST_LANG;    last;
    }else{  $source = 'auto';        $target = $LATIN_LANG;   } # For any other language
}
print 'A'.$request."A\n";

my $ua = LWP::UserAgent->new; #параметры подключения
$ua->agent($USERAGENT);
$ua->proxy([$PROXY[0]], $PROXY[1]) if @PROXY;
     
my $ua2 = $ua->clone;

my $url="https://translate.google.com/translate_a/single?client=t&sl=$source&tl=$target&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=at&ie=UTF-8&oe=UTF-8";
#my $req = HTTP::Request->new(POST => $url);
#$req->content("text=$request");
#my $response;
#$response = $ua->request($req);
#$response = $ua->request($req) if (! $response->is_success); #resent
my $response = &google($ua, $url, $request) ; #$_[0] - ua    $_[1] - url   #$_[2] - request

my $g_array;
if ($response->is_success) { #to array
    #print $response->decoded_content;
#    if ($response->isa('HTTP::Response::JSON')) {
    #my $json = $response->json_content; #decoded
    #    my $js = $response->decoded_content;
    my $js = $response->content;
    $js =~ s/,,/,"",/g;
    $js =~ s/,,/,"",/g;
    $js =~ s/\[,/\["",/g;
    $js =~ s/,\]/,""\]/g;
    print $js."\n";
    #my $g_array = decode_json($js);
    #my @objs = JSON->new->incr_parse ($js);
    $g_array =  JSON->new->decode($js);
   # my $pp = $json->pretty->encode( $g_array ); # pretty-printing
  #  print $pp;
    
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
					    print "a5:$row,$col,$i,$j,$s:".$g_array->[$row][$col][$i][$j][$s]."\n";
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
else {
    print $response->status_line, "\n"; exit 1;
}

my $rsum; # translation
if(ref($g_array) eq 'ARRAY'){
    if(ref($g_array->[0]) eq 'ARRAY'){
	for (my $col = 0; $col < @{$g_array->[0]}; $col++) {
	    if($g_array->[0][$col][0]){
		my $t=$g_array->[0][$col][0];
		#print $t,"\n";
		$t =~ s/\s+,/,/g;
		$t =~ s/\s+\./\./g;
		#print $t,"\n";
		$rsum .= $t;
	    }
	}
    }
    
}else{ print $response,"\n"; exit 1;}
print $rsum,"\n";
