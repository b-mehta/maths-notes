string=$(find . -name \*.tex -type f -print0 | xargs -0 stat -f "%m %N" | sort -rn | head -1 | cut -f2- -d" ");
string=${string%%.tex}
string=${string#./}
echo $string > state
