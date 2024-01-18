#!/bin/bash

# cd /home

# mkdir newFolder

# echo "Hello world" 1> ./newFolder/hello.txt

# ls /home/work_dir

mariadb -h $DB_SERVER_NAME -u $DB_USER --port=$DB_PORT --password=$MARIADB_ROOT_PASSWORD < "/home/work_dir/createdb.sql"

# bash
