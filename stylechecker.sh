#!/bin/bash
#
# This scans a file provided by the user and looks for words and phrases
# that should be corrected, according to our style guide.
#

# De-dupe the keywords file and save it (temporarily) under a new name
cat keywords.txt | sort | uniq > keywords_temp.txt

# Move that de-duped file back to the original filename
mv keywords_temp.txt keywords.txt

# Download the file to be scanned. The URL can begin with  http(s):// or file://
echo "What's a public URL where I can fetch a copy of the file?"
read URL

# Download the file
curl -q -o outfile.md $URL

# Create a string that'll hold a list of words that occurred in the post
# and should be reviewed
returnstring="OK I've found occurrences of the following terms you should review for consistency with our style guide:"

# Before we start looping over our keywords data source (keywords.txt),
# (re-)create keywords.md which is a prettier version. We'll add lines 
# as we loop over keywords.txt
echo "Words and phrases" > keywords.md

# Loop over keywords.txt
while read -r line;
	do 
		# Split each keywords line into DONT and DO, separated by |
		dont=$(echo $line | sed 's/^\(.*\)\|\(.*\)\|\(.*\)$/\1/')
		do=$(echo $line | sed 's/^\(.*\)\|\(.*\)\|\(.*\)$/\2/')
		because=$(echo $line | sed 's/^\(.*\)\|\(.*\)\|\(.*\)$/\3/')
echo "### $dont" >> keywords.md
echo "Instead, use \`$do\`." >> keywords.md
if [[ ! -z "$because" ]]; then
	echo "" >> keywords.md
	echo "$because" >> keywords.md
fi

		# Each time a DONT appears, bold it and italicize it
		cat outfile.md | sed "s/$dont/==[$dont](https:\/\/github.com\/davidmlentz\/stylechecker\/blob\/master\/keywords.md#$dont)==/g" > outfile2.md
		cp outfile2.md outfile.md

		# If the word we're looking for appeared, add it to the 
		# return string we'll print at the end. Just keeping score.
		grep "$dont" outfile.md > /dev/null
		if [ $? -eq 0 ]; then
			returnstring=$(printf "\n\n$returnstring\n$dont")
		fi
done < keywords.txt

# Clean up
rm outfile2.md

# Give some feedback
echo $returnstring

# If MacDown is installed, this'll open the revised version there
# which should make it easier to see the strings that need your attn
brew cask list | grep macdown > /dev/null
if [ $? -eq 0 ]; then
	open -a macdown outfile.md
else
	echo "I don't find Macdown installed here. You can install it with "
	echo "'brew cask install macdown' and then try running this script again. "
	echo "Meanwhile I'll try opening the output in some other application."
	open outfile.md
fi
