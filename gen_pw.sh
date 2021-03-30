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
# If there are multiple words in any lines, the first word is used

# Default options
num_words="4"
word_list="./wordlist"
capitalize="False"
output="sdtout"
sep=""
leet="False"
min_len="4"
verbose="False"

while getopts ":n:l:CcsNm:hv" opt; do
    case ${opt} in
        \? )
            # Default
            ;;
        n ) num_words="$OPTARG" ;;
        w )
            if [ -r "$OPTARG" ] ; then
                word_list="$OPTARG"

            ;;
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

# Working commands:
# awk 'length($2) > 4 { print $2 }' lemma-10k-2017-ex.txt | shuf -n4 | sed 's/[^ ]\+/\L\u&/g' | tr -d '\n'
# cat <file> | tr -s ' ' '\n'  # Strips spaces and empty lines from <file>
