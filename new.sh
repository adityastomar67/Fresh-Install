#!/bin/bash

# while getopts 'lha:' OPTION; do
#   case "$OPTION" in
#     l)
#       echo "linuxconfig"
#       ;;
#     h)
#       echo "you have supplied the -h option"
#       ;;
#     a)
#       avalue="$OPTARG"
#       echo "The value provided is $OPTARG"
#       ;;
#     ?)
#       echo "script usage: $(basename \$0) [-l] [-h] [-a somevalue]" >&2
#       exit 1
#       ;;
#   esac
# done
# shift "$(($OPTIND -1))"

if [ $# -gt 0 ]; then
	case "$1" in
    -l|--vim)
      echo "linuxconfig"
      ;;
    h)
      echo "you have supplied the -h option"
      ;;
    a)
      avalue="$OPTARG"
      echo "The value provided is $OPTARG"
      ;;
    ?)
      echo "script usage: $(basename \$0) [-l] [-h] [-a somevalue]" >&2
      exit 1
      ;;
	esac
else
    echo "No args"
fi
