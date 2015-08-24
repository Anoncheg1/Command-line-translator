#!/usr/bin/env perl
use strict; # ограничить применение небезопасных конструкций
use warnings; # выводить подробные предупреждения компилятора
use diagnostics; # выводить подробную диагностику ошибок
use LWP::UserAgent;
require HTTP::Response;
use HTML::TreeBuilder;
#use Getopt::Std;
package main;

# устанавливаем обработчик сигнала INT
#$SIG{INT} = \&sig_handler; # ссылка на подпрограмму
#sub sig_handler { # подпрограмма-обработчик сигнала
#   print "Получен сигнал INT по нажатию Ctrl+C\n";
#   print "Заканчиваю работу!\n";
#   exit; # завершение выполнения программы
#}

my $ua = LWP::UserAgent->new; #параметры подключения
$ua->agent("Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1");
#$ua->proxy(['http'], "http://127.0.0.1:4446");
my $url="http://www.urbandictionary.com/define.php?term=".join ('+', @ARGV);
my $req = HTTP::Request->new(GET => $url);
my $res = $ua->request($req);
if ($res->is_success){
    my $tree = HTML::TreeBuilder->new; # обрабатываем первую страницу в дерево
    $tree->ignore_ignorable_whitespace(0);
    $tree->store_comments(0);
    $tree->parse($res->decoded_content);
    $tree->eof();
    #$tree->dump;
    my $el = $tree->look_down("class", "def-panel"); #начинаем парсить
    if(!$el){exit;}
    my $meaning = $el->look_down("class", "meaning")->as_text;
    if($meaning =~ m/There aren't any definitions for/){exit;}
    my $example = $el->look_down("class", "example")->as_text;
    my $thumbup = $el->look_down("class", "thumb up")->look_down("class", "count")->as_text;
    my $thumbdown = $el->look_down("class", "thumb down")->look_down("class", "count")->as_text;
    if($thumbup < 20 || $thumbup > 8000 || ($thumbup-$thumbdown) < 13 ){exit;} #silent exit if too many ppl like it
    $meaning =~ s/^\s+|\s+$//g;     #trim both sides
	$meaning =~ s/[#\-%&\$*+()]//g; #remove bad characters
	$example =~ s/^\s+|\s+$//g;     #trim both sides
	$example =~ s/[#\-%&\$*+()]//g;
    binmode(STDOUT, ":utf8");
    print "Urban ".$thumbup."/".$thumbdown.":\n";
    print $meaning."\n";
    print $example."\n";
#    $elr->dump;
}else{print (($res->status_line)." Can't connect urban.\n")};



#my @threads = $tree->look_down("class", "thread");


#my $aa=join '+' @ARGV;
#print $url;
