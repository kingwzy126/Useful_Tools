#!/bin/bash

SRC_DIRS=""
FORCE="N"

if [ $# -ne 0 ]; then
	while [ "x$1" != "x" ]
	do
		if [ "x$1" == "x-f" ]; then
			FORCE="Y"
		else
			SRC_DIRS="$SRC_DIRS $1"
		fi
		shift
	done
else
	echo 'No args'
fi

if [ "x$SRC_DIRS" == "x" ]; then
	echo "set SRC_DIRS to ./ !"
	SRC_DIRS="./"
else
	echo "SRC_DIRS not empty: $SRC_DIRS"
fi

MY_NAME=`whoami`
STAT_FILE="${MY_NAME}_state"
LIST_FILE="${MY_NAME}_list.txt"

if [ "x$FORCE" == "xY" ]; then
	rm -f $STAT_FILE $LIST_FILE
fi

if [ ! -e $LIST_FILE ]; then
	echo "$LIST_FILE not exist"
	echo "Find c files ..." |tee $STAT_FILE
	find -L ${SRC_DIRS} \( -iname "openssl*" -o -name "lost+found" -o -wholename "*/download/*" -o \
						   -wholename "*/u*boot*/*" \) -prune -o \
						\( -iname "*.[ch]" -o -iname "*.cc" -o -iname "*.hh" -o -name "*.[sS]" -o \
						   -name "*.mk" -o -name "*.mak" -o -name "*.cxx" -o -name "*.cpp" -o \
						   -name "*.hxx" -o -name "*.hpp" \)	\
						-exec /bin/readlink -e \{\} \;		\
						| xargs file |grep -i "text" |awk -F ":" '{print $1}' |tee ${LIST_FILE}

	cat ${LIST_FILE} |sort |uniq > ${LIST_FILE}_1
	mv ${LIST_FILE}_1 ${LIST_FILE}
fi

echo "~/bin/ctags -L ${LIST_FILE}" |tee -a $STAT_FILE
# ~/bin/ctags -L ${LIST_FILE}

echo "~/bin/cscope -bkq -i ${LIST_FILE}" |tee -a $STAT_FILE
# ~/bin/cscope -bkq -i ${LIST_FILE}

echo "Done" |tee -a $STAT_FILE
