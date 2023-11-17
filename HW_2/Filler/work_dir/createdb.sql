DROP DATABASE IF EXISTS guide;
CREATE DATABASE guide;

USE guide;

CREATE OR REPLACE TABLE main_table(
    name text NOT NULL,
    age int NOT NULL,
    PRIMARY KEY idx_name(name(20))
);

SET GLOBAL local_infile=1;

LOAD DATA LOCAL INFILE './work_dir/data.csv'
INTO TABLE main_table
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- INSERT INTO main_table VALUES ("Jonh", 34);

SELECT * FROM main_table;

-- exit;
