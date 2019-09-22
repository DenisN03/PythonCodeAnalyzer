#!/bin/bash

PYTHON=python3
packs=()

VERSION=1.0

echo "Python Code Analyzer ver. $VERSION"

echo
usage="Program to improve and analyze python code. \

usage: $(basename "$0") [-e(--exclude)] [-d(--disable)] [-pw(--pkg-whitelist)] [-req(--requirements)] [-h(--help)] \

where:
    -h   show this help text
    -d   disable some pylint checks
    -pw  disable some imports from pylint checks
    -req generate requirements file for project
    -e   set the exclude path (only one folder support)"

for i in "$@"
do
case $i in
    -e=*|--exclude=*)
    EXCLUDE="${i#*=}"
    shift
    ;;
    -d=*|--disable=*)
    DISABLE="${i#*=}"
    shift
    ;;
    -pw=*|--pkg-whitelist=*)
    WHITELIST="${i#*=}"
    shift
    ;;
    -req|--requirements)
    REQUIREMENTS=YES
    shift
    ;;
    -h|--help)
    echo "$usage"
    exit
    ;;
    *)
    ;;
esac
done

for i in pipreqs pylint yapf isort autopep8 autoflake radon
do
    if $PYTHON -c "import $i" &> /dev/null; then
        :
    else
        packs+=("$i")
    fi
done

if [[ ${#packs[@]} -gt 0 ]]
then
    echo "The following packages will be installed: ${packs[@]}"
    ver=$($PYTHON -c"import sys; print(sys.version_info.major)")
    if [[ $ver -eq 2 ]]; then
        sudo pip install "${packs[@]}"
    elif [[ $ver -eq 3 ]]; then
        sudo pip3 install "${packs[@]}"
    fi
fi

if [[ ${#EXCLUDE[@]} -eq 0 ]]
then
    FILES=$(find . -iname "*.py")
else
    echo "Folder(s) ${EXCLUDE} will be excluded from analysis."
    FILES=$(find . -iname "*.py" ! -path "${EXCLUDE}*")
fi

echo
echo Testing.
for f in $FILES
    do
        SCORE=$($PYTHON -c"from pylint.lint import Run; results = Run(['$f', '--disable=${DISABLE}',\
        '--extension-pkg-whitelist=${WHITELIST}'], do_exit=False);\
        score = results.linter.stats['global_note']" 2>&1 /dev/null)

        delimiter=Your' 'code' 'has' 'been' 'rated' 'at
        s=$SCORE$delimiter
        array=();
        while [[ $s ]]; do
            array+=( "${s%%"$delimiter"*}" );
            s=${s#*"$delimiter"};
        done;
        declare -p array &> /dev/null
    done

echo
echo Performing corrections of code.
for f in $FILES
    do
        yapf -i $f
        isort $f &> /dev/null
        autopep8 --in-place $f
        autoflake --in-place $f
    done

echo
echo Final testing.
for f in $FILES
    do
        echo
        echo $f
        SCORE=$($PYTHON -c"from pylint.lint import Run; results = Run(['$f', '--disable=${DISABLE}',\
        '--extension-pkg-whitelist=${WHITELIST}', '--output-format=text'], do_exit=False);\
        score = results.linter.stats['global_note']" 2>&1 /dev/null) #/dev/null

        delimiter=Your' 'code' 'has' 'been' 'rated' 'at
        s=$SCORE$delimiter
        array=();
        while [[ $s ]]; do
            array+=( "${s%%"$delimiter"*}" );
            s=${s#*"$delimiter"};
        done;
        declare -p array &> /dev/null
        echo Your code has been rated at ${array[1]}
    done

echo
echo Code complexity score:
echo
radon cc -e "${EXCLUDE:2}/*" . -s -na

if [ ! -z ${REQUIREMENTS} ]
then
    echo
    pipreqs . --ignore=${EXCLUDE} --force
fi