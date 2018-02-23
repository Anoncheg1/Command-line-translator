[![Gitter chat](https://badges.gitter.im/cli/sonews.png)](https://gitter.im/Anoncheg1/Command-line-translator)

Google translate script. It gives you easy access to Google Translate in your terminal:

>Installation step by step:
>- 1) download one of the version Perl (perlfork.pl) or Bash (translate and urban.pl)
>- 2) install requirements
>- 3) execute command: $ chmod +x perlfork.pl translate urban.pl
>- 4) add to ~/.bash_aliases: alias t="/home/user/perlfork.pl"
>- 5) (optional) edit options section in script perlfork.pl or translate for your taste (choose language detection scema)

```
$ t die unbekannten Sprache
	Language: German
	...
$ t -l
	de	German
$ alias tde="t -s de -t en"
$ tde "die unbekannten Sprache"
	the unknown language
```

https://github.com/Anoncheg1/Command-line-translator

Google translate shell, Google translate command-line, command-line translator Google Translate, Linux, easy to use, fast and comfortable.
Command-line google translate, quick translate, very simple scripts, scripts for assess Google Translate, Google Translate CLI.

FILES:
- perlfork.pl - Perl5 version. Google translate only.
- translate - Bash version. Good for English dictionary.
- urban.pl - optional plugin for bash version.

### Perl version - google only
get perl version:

    $ wget http://git.io/vEUKU
    $ chmod +x perlfork.pl

REQUIREMENTS:
- perl5 >= v5.16
- perl JSON
- perl Clone
- perl LWP::Protocol::socks -if you need socks proxy
- mplayer or mpg123 -for sound

FEATURES:
  - Windows support(planned),
  - translated text,
  - fixed text with highlight,
  - language detection,
  - dictionary,
  - translit,
  - google text-to-speach

There is two systems for detection of direction($FIRST_LANG to $SECOND_LANG or vice versa):
- Simple detection of direction. First it search Latin or Russian symbols and decide. If not found it use $source = 'auto'; $target = 'en';
- Advanced detection of direction. ALD=1;

###  Bash version - extended support for english and german

REQUIREMENTS:
- UTF-8 support for required languages
- curl >= 7.21.0
- SpiderMonkey or nodejs
- mpg123 for playing pronunciation
For Debian sid: #apt-get install curl spidermonkey-bin html2text mpg123
For Debian jessie: #apt-get install curl nodejs html2text mpg123
For FreeBSD: #pkg install curl spidermonkey24 html2text mpg123
- forvo.com account for pronunciation
- optional: urban.pl, perl HTML-Tree (see URBAN_DICTIONARY)

FEATURES:
  - translated text,
  - fixed text with highlight,
  - language detection,
  - dictionary,
  - translit,
  - execution without parameters will translate fixed string for 1-2 words
  - prompt mode
  
for english: 
- phrases, forms, ideom, transcription, audio pronunciation
- cache for words
- saving english words to file for learning
- urban dictionary

for german:
- transcription

for convenience. Add to ~/.bash_aliases:
- alias t="/home/user/perlfork.pl"
- alias ts="/home/user/translate -S"

Commands:
- -s Source language (can be "auto")
- -t Target language (can't be)
- -l List of languages
- -h Help

Examples:
- t -s auto -t en 母亲
- cat file | t -

Debian Cyrillic support in tty shell:
- 1)	#dpkg-reconfigure locales
- Install en_US.utf8, ru_RU.utf8
- 2)  #dpkg-reconfigure console-setup
- Install . Combined - latin slavic Cyrillic; Greek