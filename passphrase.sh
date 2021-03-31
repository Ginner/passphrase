#!/bin/bash
#
# Generate a passphrase based on the XKCD-comic: https://xkcd.com/936/

# Provide flags for:
#   - Number of words (default: 4) -n,--num-words <#>
#   - Wordlist (default:min_ord_liste) -w,--word-list <file>
#   - Capitalize words (defualt: no (makes it easier to distinguish the words)) -C,--capitalize
#   - Output to clipboard (default: stdout) -c, --clipboard
#   - Separator? (default: None) -s,--separator <separator string>
#   - 1337 speak? (default: Nope) -N,--leet
#   - Minimum word length (default: 4) -m,--min-word-len <#>
#   - Maximum word length (default: None) -M, --max-word-len <#>
#   - Show help (default: no) -h,--help
#   - Verbose output (default: no) -v,--verbose

# TODO: Long options, Nah, getopts doesn't seem to support it.
# TODO: -F option to force through warnings
# If --num-words is larger than the number of words in the wordlist, the words in the wordlist are all used and determines the length of the passphrase.
# Formatting my 10k wordlist is instantaneous...

# Default options
num_words="4"
word_list="./wordlist"
capitalize="0"
output="sdtout"
sep=""
leet="0"
min_len="4"
max_len="12"
verbose="0"

helptext <<EOH
Usage: passphrase [option]
Generates a passphrase and prints to standard output.

    -w FILE     Word list to generate phrase from
    -n INTEGER  Number of words to use in the phrase
    -C          Capitalize the used words
    -c          Output to clipboard
    -s STRING   Separator string
    -N          Use '1337'-speak
    -m INTEGER  Minimum length of the words used in the phrase
    -M INTEGER  Maximum length of the words used in the phrase
    -v          Verbose output
    -h          Print this help and exit
    -V          Print version information and exit

Examples:
    passphrase      Outputs a 4 word passphrase using words with a minimum
                    length of 5 characters.
    passphrase -n 5 -s "-"
                    Outputs a 5 word passphrase with words separated by a single dash.

Further documentation, help and contact options available here: https://github.com/Ginner/passphrase
EOH

while getopts ":w:n:CcsNm:hv" opt; do
    case ${opt} in
        w )
            if [ -r "$OPTARG" ] ; then
                word_list="$OPTARG"
            fi

            ;;
        n ) num_words="$OPTARG" ;;
        C ) capitalize="1" ;;
        c ) output="clipboard" ;;
        s ) sep_str="$OPTARG" ;;
        N ) leet="1" ;;
        m ) min_len="$OPTARG" ;;
        M ) max_len="$OPTARG" ;;
        v ) verbose="1"
        h )
            ;;
    esac
done
shift $((OPTIND -1))

formatted_wlist=$( cat $word_list \
    | tr --squeeze-repeats ' ' '\n' \
    | awk '{ if(( length($1) > $min_len ) && (length($1) < $max_len )) print $1 }' \
    | sort --unique --ignore-case )

num_lines=$( wc --lines < $formatted_wlist )

if [ $num_lines -lt 2500 ]; then
    echo "Your wordlist is short, this might have security implications, you should expand it."
elif [ $num_lines -gt 45000 ]; then
    echo "Wow! Your word list is mighty big, this might have some performance impact."
fi

phrase_list=$( shuf --head-count=$num_words $formatted_wlist )

if [ $capitalize=="True" ] ; then
    phrase_list=$(sed 's/[^ ]\+/\L\u&/g' $phrase_list)
fi

# Working commands:
# awk 'length($2) > 4 { print $2 }' lemma-10k-2017-ex.txt | shuf -n4 | sed 's/[^ ]\+/\L\u&/g' | tr -d '\n'
# cat <file> | tr -s ' ' '\n'  # Strips spaces and empty lines from <file>