#!/bin/bash
# =============================================================== #
#
# Generate a passphrase based on the XKCD-comic: https://xkcd.com/936/
# By ***REMOVED***
#
# Last modified: 2021.04.21-22:17 +0200
#
# =============================================================== #

# TODO: Long options, Nah, getopts doesn't seem to support it.
# TODO: Write to log, allow for custom log.

# Default options
num_words="4"
word_list="./wordlist.txt"
capitalize="0"
output="standard output"
sep_str=""
suppress="0"
leet="0"
min_len="4"
max_len="10"
verbose="0"

read -r -d '' helptext <<- 'EOH'
Usage: passphrase [option]
Generates a passphrase and prints to standard output.

    -w FILE     Word list to generate phrase from
    -n INTEGER  Number of words to use in the phrase
    -C          Capitalize the used words
    -c          Output to clipboard
    -s STRING   Separator string
    -S          Suppress output
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

while getopts ":w:n:Ccs:SNm:M:hv" opt; do
    case ${opt} in
        w )
            if [[ -r "$OPTARG" ]] ; then
                word_list="$OPTARG"
            fi
            ;;
        n ) num_words="$OPTARG" ;;
        C ) capitalize="1" ;;
        c ) output="clipboard" ;;
        s ) sep_str="$OPTARG" ;;
        S ) suppress="1" ;;
        N ) leet="1" ;;
        m ) min_len="$OPTARG" ;;
        M ) max_len="$OPTARG" ;;
        v ) verbose="1"
            if [[ "$suppress" -eq 1 ]]; then
                echo "You cannot suppress output and have it verbose at the same time." >&2
                exit 1
            fi
            ;;
        h ) echo "$helptext"
            exit 0
            ;;
        * ) echo "$OPTARG is not a recognized flag or command. Use passphrase -h for help on usage." >&2
            exit 1
    esac
done
shift $((OPTIND - 1))


function copy_prg() {
    if [[ -x "$( command -v xsel )" ]] ; then
        echo "xsel"
    elif [[ -x "$( command -v xclip )" ]] ; then
        echo "xclip"
    else
        echo "none"
    fi
}


function prnt_verbose() {
    if [[ "$verbose" -eq 1 ]] ;  then
        echo "$1"
    fi
}


function prnt_info() {
    if [[ "$suppress" -eq 0 ]] ; then
        echo "$1"
    fi
}


formatted_wlist=$( tr --squeeze-repeats ' ' '\n' < "$word_list" \
    | awk -v a="$min_len" -v b="$max_len" '{ if( length($1) > a && length($1) < b ) print $1 }' \
    | sort --unique --ignore-case
)


num_lines=$( wc --lines <<<"$formatted_wlist" )

if [[ "$verbose" == 1 ]]; then
    echo "Verbose output is on."
    echo "Creating a passphrase consisting of ${num_words} words from ${word_list}."
    echo -n "The word list contains ${num_lines} words within the requested range"
    echo ", with a minimum length of ${min_len} characters and a maximum of ${max_len}."
    echo "Outputting to ${output}."
    if [[ "$capitalize" == 1 ]]; then
        echo "Each word will be capitalized."
    fi
    if [[ -n "$sep_str" ]] ; then
        echo "Each word will be separated by a \"$sep_str\"."
    fi
    if [[ "$leet" == 1 ]] ; then
        echo "Some characters might be replaced in a '1337-speak' fashion."
    fi
fi


if [[ "$num_lines" -lt 2048 ]]; then
    prnt_info "Your wordlist is short, this might have security implications, you should expand it."
elif [[ "$num_lines" -gt 45000 ]]; then
    prnt_info "Wow! Your word list is mighty big, this might have some performance impact."
fi

phrase_list=$( shuf --head-count="$num_words" <<<"$formatted_wlist" )

if [[ $capitalize == "1" ]] ; then
    phrase_list=$( sed 's/[^ ]\+/\L\u&/g' <<<"$phrase_list" ) ;
fi

# Turn the list of words into a phrase
if [[ -n "$sep_str" ]] ; then
    phrase=$( echo -n "$phrase_list" | tr --truncate-set1 '\n' "$sep_str" )
else
    phrase=$( tr -d '\n' <<<"$phrase_list" )
fi


if [[ "$verbose" -eq 1 ]]; then
    echo -n "Passphrase: "
fi

if [[ "$output" == "clipboard" ]] ; then
    case $(copy_prg) in
        "xsel")
            echo "$phrase" | xsel --input --clipboard --selectionTimeout 45000
            prnt_info "Phrase copied to clipboard, it will clear in 45 seconds."
            ;;
        "xclip")
            echo "$phrase" | xclip -in -selection "clipboard"
            prnt_info "Phrase copied to clipboard and it will remain there until replaced!"
            prnt_info "It is highly recommended that you copy something to the clipboard"
            prnt_info "selection when you are done using the phrase."
            ;;
        "none")
            echo "xsel(recommended) or xclip is required for clipboard functionality." >&2
            exit 1
            ;;
    esac
    exit 0
fi

echo "$phrase"

exit 0
