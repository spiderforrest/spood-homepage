#!/usr/bin/env bash

# get the project dir and the name directly from the directory name
DIR=$(dirname "$(realpath "$0")")
NAME=$(basename "$DIR")
cd "$DIR"

LAPIS_CMD=""
if [[ $(which lapis 2>/dev/null) ]] ; then
  LAPIS_CMD="lapis"
elif [[ $(which lapis5.1 2>/dev/null) ]] ; then
  LAPIS_CMD="lapis5.1"
else
  LAPIS_CMD="$DIR/.rocks/bin/lapis"
  # set lua's paths to use luarocks
  export LUA_PATH="$DIR/.rocks/share/lua/5.1/?.lua;$DIR/.rocks/share/lua/5.1/?/init.lua;;"
  # note ;; is at the front here, so we prefer native libraries-this is primarily for openssl
  export LUA_CPATH=";;$DIR/.rocks/lib/lua/5.1/?.so;"

fi


# do one of the things
case "$1" in
  "watch"|"start"|"test")
    mkdir "$DIR/.temp"
    # kill the server on ctrl c
    trap "$LAPIS_CMD term; echo -e \"\e[33m/// watcher: terminated! ///\e[0m\"" INT

    # start the server
    $LAPIS_CMD serve &

    # watch every file the server doesn't touch for changes
    inotifywait -mre modify --exclude "temp|compiled|logs|store" . |
      while read -r change;
      do
        # call the lapis command that refreshes the server in place
        $LAPIS_CMD build >/dev/null
        echo -e "\e[33m/// watcher: $change changed! /// \e[0m"
      done

    # who watches the watcher
    # inotifywait -me modify "$0" && exec "$0"
    ;;

  "prod")
    mkdir "$DIR/.temp"
    # spawn screen and start the prod server inside it for monitoring
    screen -dmS "$NAME" "$(which bash)"
    screen -S "$NAME" -X stuff "cd ${DIR} \n"
    screen -S "$NAME" -X stuff "$LAPIS_CMD serve prod \n"
    ;;

  "update-botlist")
    # if you want good indexing, maybe investigate this list; AppleBot plays nice and it's on the list
    curl https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/refs/heads/main/robots.txt > "$DIR/static/robots.txt"

    # i don't trust like that, so nginx actually bock them
    BOTLIST="$(head -n -1 "$DIR/static/robots.txt" | cut -c13- | tr '\n' '|')" # go from robots.txt to bot1|bot2|bot3|
    BOTLIST=${BOTLIST::-1} # cut trailing |

    echo "return '$BOTLIST'" > "$DIR/botlist.lua"
    # now just hope they don't lie with their user agents ._.
    ;;
  *)
  echo "need \$1 from: watch, prod, cert, update-botlist"
esac

