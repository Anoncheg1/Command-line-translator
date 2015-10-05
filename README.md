[![Gitter chat](https://badges.gitter.im/cli/sonews.png)](https://gitter.im/Anoncheg1/Command-line-translator)

Google translate script.

Google translate shell, command-line translator Google Translate, Linux, Windows, easy to use, fast and comfortable.
Command-line google translate, quick translate, very simple scripts, scripts for assess Google Translate.

FILES:
perlfork.pl - Perl5 version. Google translate only.
translate - Bash version. Complete and stable.
urban.pl - optional plugin for bash version.

This tool for access translate.google.com from terminal and to have English dictionary.
mirror https://github.com/Anoncheg1/Command-line-translator

*************** Perl version ****************

REQUIREMENTS:
- perl5 >= v5.16
- perl LWP::Protocol::socks -for proxy only
- perl JSON
- mpg123 for sound

FEATURES:
  - Windows support(planned),
  - translated text,
  - fixed text with highlight,
  - language detection,
  - dictionary,
  - translit,
  - google text-to-speach
  - read from file

*************** Bash version ****************

(good for English dictionary)
REQUIREMENTS:
- UTF-8 support for required languages
- curl >= 7.21.0
- SpiderMonkey or nodejs
- mpg123 for playing pronunciation
For Debian sid: #apt-get install curl spidermonkey-bin html2text mpg123
For Debian jessie: #apt-get install curl nodejs html2text mpg123
For FreeBSD: #pkg install curl spidermonkey24 html2text mpg123
- forvo.com account for pronunciation
- urban.pl(optional)

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

for convenience. Add to ~/.bash_aliases:
~ alias t="/home/user/translate"
~ alias ts="/home/user/translate -S"

~ -s lang Set source language
~ -t lang Set target language
~ -l List of languages
Configure "FIRST_LANG" and "LATIN_LANG" in script for auto detection.

Debian Cyrillic support in tty shell:
~ 1)	#dpkg-reconfigure locales

Install en_US.utf8, ru_RU.utf8
~2)  #dpkg-reconfigure console-setup

Install . Combined - latin slavic Cyrillic; Greek
