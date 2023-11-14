#!/bin/bash

# cd /home

# mkdir newFolder

# echo "Hello world" 1> ./newFolder/hello.txt

# bash

mariadb -h tMariadb -u root --password=$DB_ROOT_PASSWORD < "/home/work_dir/createdb.sql"
