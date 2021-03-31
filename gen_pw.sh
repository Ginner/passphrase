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
#   - Minimum word length (default: 4) -m,--min-word-len<#>
#   - Show help (default: no) -h,--help
#   - Verbose output (default: no) -v,--verbose

# TODO: Long options, Nah, getopts doesn't seem to support it.
# TODO: Check for a sane length of the word list (if wc -l < 2500 print: "Bad security my dude!")
# If --num-words is larger than the number of words in the wordlist, the words in the wordlist are all used and determines the length of the passphrase.
# TODO: Check the uniqueness of the word list
# Formatting my 10k wordlist is instantaneous...

# Default options
num_words="4"
word_list="./wordlist"
capitalize="False"
output="sdtout"
sep=""
leet="False"
min_len="4"
verbose="False"

while getopts ":w:n:CcsNm:hv" opt; do
    case ${opt} in
        w )
            if [ -r "$OPTARG" ] ; then
                word_list="$OPTARG"
            fi

            ;;
        n ) num_words="$OPTARG" ;;
        C ) capitalize="True" ;;
        c ) output="clipboard" ;;
        s ) sep_str="$OPTARG" ;;
        N ) leet="True" ;;
        m ) min_len="$OPTARG" ;;
        h )
            ;;
    esac
done
shift $((OPTIND -1))

formatted_wlist=$( cat $word_list \
    | tr -s ' ' '\n' \
    | awk 'length($1) > $min_len { print $1 }' \
    | sort -uf )

num_lines=$( wc --lines < $formatted_wlist )

if [ $num_lines -lt 2500 ]; then
    echo "Your wordlist is short, this might have security implications, you should expand it."
elif [ $num_lines -gt 45000 ]; then
    echo "Wow! Your word list is mighty big, this might have some performance impact."
fi

phrase_list=  $( shuf -n $num_words $formatted_wlist )

if [ $capitalize=="True" ] ; then
    phrase_list=$(sed 's/[^ ]\+/\L\u&/g' $phrase_list)
fi

# Working commands:
# awk 'length($2) > 4 { print $2 }' lemma-10k-2017-ex.txt | shuf -n4 | sed 's/[^ ]\+/\L\u&/g' | tr -d '\n'
# cat <file> | tr -s ' ' '\n'  # Strips spaces and empty lines from <file>
