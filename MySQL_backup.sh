#!/bin/bash

# Settings

conf=/root/bkpconfig.cnf		# config files
backup_path=/root/sqlbkp		#folder for backups
DATE=`date +"%Y%m%d-%H:%M"`		#folder name format

MYSQL="mysql --defaults-extra-file=$conf --skip-column-names"

# Mysql backup script

mkdir $backup_path 2>/dev/null
mkdir $backup_path/$DATE 2>/dev/null

$MYSQL -e "STOP SLAVE";

if [[ $? == 0 ]]; then

for s in mysql `$MYSQL -e "SHOW DATABASES"`;
    do
        if [[ $s == "sys" ]] || [[ $s == "performance_schema" ]] || [[ $s == "information_schema"  ]]; then
        echo "DataBase $s skipped"
        continue
        fi
        mkdir $backup_path/$DATE/$s 2>/dev/null
                for t in mysql `$MYSQL -e "SHOW TABLES FROM $s"`;
                        do
                            /usr/bin/mysqldump --defaults-extra-file=$conf --master-data=1 $s $t | gzip -1 > $backup_path/$DATE/$s/$t.gz
                        done
    done
        $MYSQL -e "START SLAVE";
fi
