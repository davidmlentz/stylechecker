#!/bin/bash
#
# Interactive script prompting the user for strings that should not appear
# in our posts (DONT) and the strings we should use to replace them (DO).
# This script writes each DO/DONT pair into keywords.txt
# (In case there are duplicates, when the script runs to scan the MarkDown file, 
# it starts by removing dupes from keywords.txt and re-saving that file.)
#
clear
go='y'
while [ $go == 'y' ]
do
	echo "Hi. What's the word we should find and highlight?"
	read DONT
	echo "OK. What do you want to replace it with?"
	read DO
	echo "OK. We've added it to the style guide and we'll replace \"$DONT\" with \"$DO\" from now on."
	echo "$DONT|$DO" >> keywords.txt
	echo "Add another? (y/n)"
	read go
done
