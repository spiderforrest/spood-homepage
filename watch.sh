#!/usr/bin/env bash

# kill the server on ctrl c
trap 'lapis term; echo -e "\e[33m/// watcher: terminated! ///\e[0m"' INT

# start the server
lapis serve &

# watch every file the server doesn't touch for changes
inotifywait -mre modify --exclude "temp|compiled|logs|store" . |
  while read -r change;
  do
    # call the lapis command that refreshes the server in place
    lapis build >/dev/null
    echo -e "\e[33m/// watcher: $change changed! /// \e[0m"
  done


# who watches the watcher
# inotifywait -me modify "$0" && exec "$0"
