#!/bin/bash

DIR="/home/spider/project/git/spood-homepage"
NAME="spood-homepage"

screen -dmS $NAME $(which bash)
screen -S $NAME -X stuff "cd ${DIR} \n"
screen -S $NAME -X stuff "lapis serve prod \n"
