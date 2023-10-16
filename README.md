# Passphrase
Simple passphrase generator based on the logic behind the famous XKCD-comic found [here](https://xkcd.com/936/).

I sometimes use passphrases as described in the linked comic.
Humans are bad at randomness, so making words up myself was unreliable and insecure.
I've tried the online generators, but cannot shake the feeling that once the passphrase is provided, it simultaneously end up, prehashed, in all the rainbow tables.

## Requirements
The script uses a lot of standard Linux command line tools. However I, at least, had to install the following:
- Clipboard functionality requires `xsel` or `xclip`.

## Word lists
I've found comprehensive word lists online consisting of over 300k words.
These are readily available for anyone with a search engine.

However these oftenmost include pseudo-words like aa, aaa, aal, aali, aalis, ababdeh, ababua, etc. etc.
I think the premise of the passphrases as described in the comic, is that the phrase is easily remembered.
For this to be the case, I hypothesize that the words used must be rather recognizable.

Further more, I think there might be security improvements in 'creating' and, at least, auditing your own list.
The search word to use when creating such lists is 'lemma'.
It kind of means the word you would find in a dictionary, i.e. not aa, aaa, etc.
I know there are many governments who provide word lists as part of their 'Department of literature' or whatever.
See for instance, EFF's wordlists, they provide both a [long](https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt) and a [short](https://www.eff.org/files/2016/09/08/eff_short_wordlist_1.txt) one.

This kinda brings me to another point; maybe use a word list in your native language for an increase in rememberability and a possible (slight) increase in security.

For illustration/inspiration purposes, I will describe how I created the word list included in the repo.
I found an `xlsx`-file(Excel spreadsheet) in the supplementary material in [this](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4965448/) article.
(Now, why would you use an Excel sheet for this? Excel - The worlds most used database *sigh*)
To extract a usable word list I used LibreOffice headless, because I have LibreOffice installed.
There are many other programs available if you need to handle `xlsx`-files (e.g. `xlsx2csv` or maybe you can just unzip it?).

```
$ libreoffice --headless --convert-to csv Data_Sheet_1.XLSX
$ cat Data_Sheet_1.csv | awk -F , '{ print $1 }' > wordlist.txt
$ wc -l < wordlist.txt
61801
```

In my case the words was in the first column (hence the `$1` in `awk`).
You can check whether that is the case with `$ cat <file>.csv | tail -n 5`.

I check the length of the file with the last line above.
Your word list should have a good amount of words in order to make an less predictable phrase.
The program will complain if the list is shorter than 2500 words (I guess that with unique word lists that is less of an issue).

You can gauge the list with something like `$ cat wordlist.txt | tail -n 8000 | head -n 40` to see 40 words somewhere in the middle of the file.

## Contributing
The script is intended to be short and easily auditable.

I'll be tremendously grateful for any contribution, however, the transparency of the program is paramount in my opinion.
I will be hesitant to excessively complicate the program in order to safeguard against a theoretical attack.

**The script has to remain easily auditable, even by a bash novice like myself.
I find this paramount for the trust in the function it provides.**

## Disclaimers

### Security
I cannot say much about the security of this script and the quality of the passphrases it provides (which relies heavily on the supplied wordlist).
I am in no way well versed in the techniques and technicalities of security.
There are no cryptography involved in the generation of the passphrases.
I have, however, tried to include some security-minded checks.

Some good advice could be:
- Check your word list. The program, rudimentarily, checks it for shortness and uniqueness, however a rather long word list consisting of `word1, word2, ..., wordn` will pass those tests and make the passphrase sucky.
- Check the output (you need to remember it, right?). This will mitigate the problem above.
- Use words with a length of at least 4 characters and use at least 4 words in a phrase.
- Consider the necessity of a memorable passphrase. A password manager-provided random password is better security-wise (You should definitely be using a password manager, I personally recommend [bitwarden](https://bitwarden.com/)).

Also, check the explanation of the comic [here](https://www.explainxkcd.com/wiki/index.php/936:_Password_Strength), which also discusses the security.
It should be said that a _truly random_ string of characters is a lot more secure, as described in the aforementioned discussion (though way harder to remember).

### Performance
The script is just various readily available Linux commands chained together and I have not optimized it for performance.
On my own machine with a word list of approximately 10k lines, the passphrase is provided, perceptually, instantaneous.
If you plan on using the script in other programs, it might very well be a bottleneck.


## References
- https://www.eff.org/dice - EFF article on dice generated passwords.
- https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases - EFF article on their wordlists.
- https://xkcd.com/936/ - The basis of the program.
- https://www.explainxkcd.com/wiki/index.php/936:_Password_Strength - Explanation of the comic linked above and discussion on the security of it.
- [Article](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4965448/) Supplementary materials/Data_Sheet_1.xlsx: Brysbaert M, Stevens M, Mandera P, Keuleers E. How Many Words Do We Know? Practical Estimates of Vocabulary Size Dependent on Word Definition, the Degree of Language Input and the Participant's Age. Front Psychol. 2016;7:1116. Published 2016 Jul 29. doi:10.3389/fpsyg.2016.01116 (License: CC BY)
- [xsel](https://github.com/kfish/xsel)
- [xclip](https://github.com/astrand/xclip)

### Similar projects
- https://github.com/redacted/XKCD-password-generator
- [pwgen](https://linux.die.net/man/1/pwgen)
