#!/bin/bash
set -e
set -x

path="."

while [ -n "$1" ]; do
	case "$1" in
    -path)
        path="$2"
        shift;;
    -analyze) analyze=True;;
	-test) test=True;;
	*) echo "Option $1 not recognized" ;;
	esac
	shift
done

if [ $path ] 
then 
    cd $path
fi

flutter packages pub get

if [ $analyze ] 
then 
    printf "\n\nANALYZE\n\n"
    flutter analyze || true
fi

if [ $test ] 
then
    printf "\n\nTEST\n\n"
    flutter test || true
fi
