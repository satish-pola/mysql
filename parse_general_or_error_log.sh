#!/bin/bash

#####################################
## Set up log location variables   ##
## 1. Log home (MYSQL_LOG_HOME)    ##
## 2. Log file name (MYSQL_GEN_LOG)##
## 3. Email list (EMAIL_LIST)      ##
#####################################

MYSQL_LOG_HOME="/opt/homebrew/var/mysql" 
MYSQL_GEN_LOG="Satishs-MBP-2.attlocal.net.err"
EMAIL_LIST="email1@intuit.com email2@intuit.com email3@intuit.com"

############## 1. GENERAL LOG OPTION ############################
## Uncomment one of the below "data" if the general log is enabled.
## To simplify the ask, I am just sorting the unauthorized access by name.
## We can also add a date column and group by date and users and find who accessed the system by days, hours, etc...

# With date column
#data=`grep -E "Init\ DB.*Access denied for" $MYSQL_LOG_HOME/$MYSQL_GEN_LOG | awk -F ' ' '{"date -d\"" $1 "\" +%Y-%m-%d" | getline extractdate; print extractdate " " $9 " " $12}' | uniq -c | sort -nr`
# Without date column 
#data=`grep -E "Init\ DB.*Access denied for" $MYSQL_LOG_HOME/$MYSQL_GEN_LOG | awk -F ' ' '{print $9 " " $12}' | uniq -c | sort -nr`

################# 2. ERROR LOG OPTION ###########################
## Use the below if the "access denied" messages are pushed to the error log.
## make sure to use log_error_verbosity=3 in Mysql > 5.7.2 version and log_warnings=2 in <5.7.2 
data=`grep -E "Access denied for user.* to database" $MYSQL_LOG_HOME/$MYSQL_GEN_LOG | awk -F ' ' '{print $10 " " $13}' | uniq -c | sort -nr`

## Here I am using Option:2 and parsing the output. 
while read -r line
do
   violations=`echo "$line" | cut -d" " -f1`
   user=`echo "$line" | cut -d" " -f2`
   database=`echo "$line" | cut -d" " -f3`
   if [[ "$violations" -gt 10 ]]
   then
     echo "User $user violated $violations times to access the database $database" | mail -s "Violation" "$EMAIL_LIST"
   fi
done <<< "$data"
