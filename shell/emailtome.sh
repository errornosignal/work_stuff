#!/bin/bash
# emailtome
# email a file to yourself using linux default mail


EMAIL_HEADER="emailtome - "
USERNAME=$(whoami)
AT="@"
DOMAIN=$(hostname -d)
EMAIL="$USERNAME$AT$DOMAIN"

if [ -z "$1" ]
    then
    echo "error: no files given"
    echo "usage: emailtome fileName"
    exit 0
elif [ -z "$2" ]
    then
    FILE="$1"
    FULL_SUBJECT="$EMAIL_HEADER$1"
else
    echo "error: too many arguments"
    echo "usage: emailtome fileName"
    exit 0
fi

echo "file to send: $FILE"
echo "trying to send to: $EMAIL"

if (echo "" | mail -s "$FULL_SUBJECT" -a "$FILE" "$EMAIL")
    then
    echo "mail sent!"
else
    echo "mail-fail bruh ¯\_(ツ)_/¯"
fi

#end
