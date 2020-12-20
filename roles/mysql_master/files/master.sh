#!/usr/bin/env bash
# $1 Container's name
# $2 mysql user
# $3 mysql pass
# $4 master user for replication
# $5 master pass for replication
# $6 database
# $7 root pass
sleep 5
# add replicate to master

docker exec -ti $1 'mysql' \
            -uroot -p$7 -vvv \
            -e"CREATE USER IF NOT EXISTS '$2'@'%' IDENTIFIED BY '$3'; "

docker exec -ti $1 'mysql' \
            -uroot -p$7 -vvv \
            -e"CREATE USER IF NOT EXISTS '$4'@'%' IDENTIFIED BY '$5'; "
# create database
docker exec -ti $1 'mysql' \
            -uroot -p$7 -vvv \
            -e"CREATE DATABASE IF NOT EXISTS $6;"

docker exec -ti $1 'mysql' \
            -uroot -p$7 -vvv \
            -e"GRANT ALL ON \`$6\`.* TO '$4'@'%' ;"

docker exec -ti $1 'mysql' \
            -uroot -p$7 -vvv \
            -e"FLUSH PRIVILEGES ;"

docker exec -ti $1 'mysql' \
            -uroot -p$7 -vvv \
            -e"GRANT REPLICATION SLAVE ON *.* TO $4@'%'; "


# import file *.sql to the database
#docker exec -ti $1 'mysql' \
#            -u$2 -p$3 -vvv \
#            -e"use $6; source /tmp/dump/product.sql;"