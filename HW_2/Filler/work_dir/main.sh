#!/bin/bash

# cd /home

# mkdir newFolder

# echo "Hello world" 1> ./newFolder/hello.txt

# ls /home/work_dir

mariadb -h mariadb -u root --password=$DB_ROOT_PASSWORD < "/home/work_dir/createdb.sql"

# bash