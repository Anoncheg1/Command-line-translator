[![Gitter chat](https://badges.gitter.im/cli/sonews.png)](https://gitter.im/Anoncheg1/Command-line-translator)

Google translate script. It gives you easy access to Google Translate in your terminal:

```
$ t (options) "anything"

```

https://github.com/Anoncheg1/Command-line-translator

Google translate shell, Google translate command-line, command-line translator Google Translate, Linux, Windows, easy to use, fast and comfortable.
Command-line google translate, quick translate, very simple scripts, scripts for assess Google Translate, Google Translate CLI.

FILES:
- perlfork.pl - Perl5 version. Google translate only.
- translate - Bash version. Good for English dictionary.
- urban.pl - optional plugin for bash version.

### Perl version
get perl version:

    $ wget http://git.io/vEUKU
    $ chmod +x perlfork.pl

REQUIREMENTS:
- perl5 >= v5.16
- perl LWP::Protocol::socks -if you need socks proxy
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

There is two systems for direction of detection($FIRST_LANG or $SECOND_LANG):
- Simple direction of detection. First it search Latin or Russian symbols and decide. If not found it use $source = 'auto'; $target = 'en';
- Advanced detection of direction. ALD=1;

###  Bash version

REQUIREMENTS:
- UTF-8 support for required languages
- curl >= 7.21.0
- SpiderMonkey or nodejs
- mpg123 for playing pronunciation
For Debian sid: #apt-get install curl spidermonkey-bin html2text mpg123
For Debian jessie: #apt-get install curl nodejs html2text mpg123
For FreeBSD: #pkg install curl spidermonkey24 html2text mpg123
- forvo.com account for pronunciation
- urban.pl(optional, see URBAN_DICTIONARY)

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
- alias t="/home/user/translate"
- alias ts="/home/user/translate -S"

Commands:
- -s source language (can be "auto")
- -t target language (can't be)
- -l List of languages

Examples:
- t -s auto -t en 母亲

Debian Cyrillic support in tty shell:
- 1)	#dpkg-reconfigure locales
- Install en_US.utf8, ru_RU.utf8
- 2)  #dpkg-reconfigure console-setup
- Install . Combined - latin slavic Cyrillic; Greek