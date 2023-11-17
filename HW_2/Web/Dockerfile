FROM node:latest

# RUN npm init -y

WORKDIR /home/node/app

COPY ./web_files/main.js /home/node/app
COPY ./web_files/package.json /home/node/app

# RUN npm i -P express
# RUN npm i -P mariadb


RUN npm install -P express mariadb

# COPY ./data.csv /home


# ENTRYPOINT bash /home/work_dir/main.sh

# ENTRYPOINT mariadb -h tMariadb --user root -pps123
