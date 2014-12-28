#/bin/sh

export PATH=$PATH:~/bin
DICT_ENCODING=cp1251
#DICT_ENCODING=

function encode() {
  if [ "$DICT_ENCODING" != "" ]; then
    iconv -f utf-8 -t $DICT_ENCODING
  else
    cat
  fi
}

function decode() {
  if [ "$DICT_ENCODING" != "" ]; then
    iconv -f $DICT_ENCODING
  else
    cat
  fi
}

MFL_JAR_DIR="$HOME/work/ukr/spelling/grammar/morfologik-stemming/morfologik-tools/target"
MFL_JAR="morfologik-tools-*-standalone.jar"

MFL_CMD="java -jar $MFL_JAR_DIR/$MFL_JAR"

#MFL_CMD="mfl"

export LANG=POSIX
FSA_FLAGS="-f cfsa2"

# grep -v ":bad"

if [ "$2" != "-x" ]; then

echo -e "\nGenerating POS dictionary"

grep -h "^[^#].*[a-z]" tagged.main.txt | encode | tr ' ' '\t' | sort -u > all.tagged.tmp
$MFL_CMD tab2morph -i all.tagged.tmp | \
$MFL_CMD fsa_build $FSA_FLAGS -o ukrainian.dict 2>&1 | decode

echo -e "\nGenerating synthesizer dictionary"

cat all.tagged.tmp | awk -F '\t' '{print $2"|"$3"\t"$1"\t"}' | \
$MFL_CMD tab2morph | \
$MFL_CMD fsa_build $FSA_FLAGS -o ukrainian_synth.dict

rm -f all.tagged.tmp

grep "^[^# ].*[a-z]" tagged.main.txt | awk '{ print $3 }' | sort | uniq > ukrainian_tags.txt

fi


if [ "$1" == "-f" ]; then
#    spell_uk_dir="$HOME/work/ukr/spelling/spell-uk"
#    cat $spell_uk_dir/test/all_aspell.srt | encode | LC_ALL=C sort -u > all.tagged.tmp && \

#    cat all_words.lst | encode | sort -u > all.tagged.tmp && \
#    cat all.tagged.tmp | $MFL_CMD fsa_build $FSA_FLAGS -o uk_UA.dict && \
#    mv uk_UA.dict ../hunspell/
    
    BASE="../../../../../../../../../.."
    LT_DIR=`ls $BASE/languagetool-standalone/target/LanguageTool-?.*-SNAPSHOT`
    LIBDIR="$BASE/languagetool-standalone/target/$LT_DIR/$LT_DIR/libs"
    for i in `ls $LIBDIR/*.jar`; do
      LIBS=$LIBS:$i
    done
    LIBS=$LIBS:$BASE/languagetool-language-modules/uk/target/classes

    #LT_STD_CP="$BASE/languagetool-standalone/target/$LT_DIR/$LT_DIR//languagetool.jar"
    LT_STD_CP=$BASE/languagetool-standalone/target/classes:$LIBS

    cat all_words.lst | encode | sort -u > all.tagged.tmp && \
    java -cp $LT_STD_CP org.languagetool.dev.SpellDictionaryBuilder uk-UA all.tagged.tmp ../hunspell/uk_UA.info freq/uk_wordlist.xml -o uk_UA.dict
    mv uk_UA.dict ../hunspell/

    rm -f all.tagged.tmp
fi
