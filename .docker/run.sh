#!/bin/bash

mkdir -p /db

dbg="false"
if [ -n "$DEBUG" ]; then
  dbg="true"
fi

cookiename="phpliteadmin"
if [ -n "$COOKIE" ]; then
  cookiename="$COOKIE"
fi

hexblobs="false"
if [ -n "$HEXBLOBS" ]; then
  hexblobs="true"
fi

language="en"
if [ -n "$LANGUAGE" ]; then
  language="$LANGUAGE"
fi

rowsNum="30"
if [ -n "$ROWS_NUM" ]; then
  rowsNum="$ROWS_NUM"
fi

charsNum="300"
if [ -n "$CHARS_NUM" ]; then
  charsNum="$CHARS_NUM"
fi

maxSavedQueries="10"
if [ -n "$MAX_SAVED_QUERIES" ]; then
  maxSavedQueries="$MAX_SAVED_QUERIES"
fi

password="$( tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 64 | head -1 )"
if [ -n "$PASSWORD" ]; then
  password="$PASSWORD"
else
  echo ""
  echo "==================================================================================="
  echo ""
  printf "    PASSWORD := %s\n" "$password"
  echo ""
  echo "==================================================================================="
  echo ""
fi



{

    echo '<?php'
    printf '$password = "%s";\n' "$password"

    echo '$directory = "/db";'

    echo '$subdirectories = true;'

    echo '$databases = [];'

    echo '$theme = "phpliteadmin.css";'
    printf '$language = "%s";\n' "$language"
    printf '$rowsNum = %s;\n' "$rowsNum"
    printf '$charsNum = %s;\n' "$charsNum"
    printf '$maxSavedQueries = %s;\n' "$maxSavedQueries"

    echo '$custom_functions = array( "md5", "sha1", "strtotime" );'

    printf '$cookie_name = "%s";\n' "$cookiename"

    printf '$debug = %s;\n' "$dbg" 

    echo '$allowed_extensions = array("db","db3","sqlite","sqlite3");'

    printf '$hexblobs = %s;\n' "$hexblobs"


} > "/srv/http/phpliteadmin.config.php"

cp "_docker/php.ini" "/etc/php/conf.d/999_custom.ini"

cp "_docker/httpd.conf" "/etc/httpd/conf/httpd.conf"

rm -rf "srv/http/.git"
rm -rf "srv/http/.docker"
rm -rf "srv/http/Dockerfile"
rm -rf "srv/http/build.php"

function clean_up {
    kill $APACHE_PID
    exit
}

trap clean_up SIGHUP SIGINT SIGTERM

httpd -D FOREGROUND &
APACHE_PID=$!
wait $APACHE_PID

