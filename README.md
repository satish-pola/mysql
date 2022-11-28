# mysql

Ways to capture the unauthorized users:

      MySQL spits out an "Access denied" message, depending on the type of logging enabled, to error/general/audit log in a few different scenarios.  

		a. Username exists in the MySQL instance, but the User/Client entered the wrong password. 
			Example: 
			   2022-11-23T16:34:01.389541Z 18332616 [Note] Access denied for user 'root'@'localhost' (using password: YES)
			   
		b. Hacker/Security team tests the instance with anonymous users or with some random usernames. In this case, the username does not exist in the instance. 
		    Example:
				2022-11-23T16:36:40.398471Z 18333266 [Note] Access denied for user 'sample'@'localhost' (using password: YES)
				2022-11-23T16:36:53.165942Z 18333339 [Note] Access denied for user 'sample'@'localhost' (using password: NO)
				
		c. Client/User tries to enter the instance without a password for an auth-enabled username. 
				
		d. A legit user tries to access a database on which he/she/app user doesn't have grants.
			Example:
				2022-11-23T16:35:20.393856Z 18332965 [Note] Access denied for user 'db_monitor'@'%' to database 'sys'


For this task, let's focus on "A legit user tries to access a database on which he/she/app user doesn't have grants".  As mentioned above, we can capture the unauthorized users in three different logs namely General log, Error log, and Audit logs. 

Option 1 (general log):
When using the general log, it logs the access violations as shown below. 

	2022-11-23T03:22:42.692781Z        40 Init DB   Access denied for user 'test'@'%' to database 'sys'
	2022-11-23T03:22:42.693183Z        40 Quit
	2022-11-23T03:23:03.084212Z        41 Connect   test@localhost on  using Socket
	
	mysql> show variables like '%general%';
	+------------------+-----------------------------------------------+
	| Variable_name    | Value                                         |
	+------------------+-----------------------------------------------+
	| general_log      | OFF                                           |
	| general_log_file | /ngs/app/iand/mysql_db/mysql/ma-iand-dn83.log |
	+------------------+-----------------------------------------------+
	2 rows in set (0.00 sec)


Option 2 (Error log): 
General log usually provides more information than the required. To capture the unauthorized users, we can enable error option with the combination of log_error_verbosity=3. 
 
	mysql> show variables like '%log_error_verbosity%';
	+---------------------+-------+
	| Variable_name       | Value |
	+---------------------+-------+
	| log_error_verbosity | 2     |
	+---------------------+-------+
	1 row in set (0.01 sec)

	mysql> set global log_error_verbosity=3;
	Query OK, 0 rows affected (0.00 sec)

	mysql> show variables like '%log_error%';
	+----------------------------+----------------------------------------+
	| Variable_name              | Value                                  |
	+----------------------------+----------------------------------------+
	| binlog_error_action        | ABORT_SERVER                           |
	| log_error                  | ./Satishs-MBP-2.attlocal.net.err       |
	| log_error_services         | log_filter_internal; log_sink_internal |
	| log_error_suppression_list |                                        |
	| log_error_verbosity        | 3                                      |
	+----------------------------+----------------------------------------+
	5 rows in set (0.01 sec)

Option 3 (Audit log):
If the audit is in use, I would prefer JSON format as it is easy to parse the log and find unauthorized users. 

	{"audit_record":{"name":"Init 	DB","record":"8_2022-11-23T03:47:29","timestamp":"2022-11-  23T03:55:11Z","command_class":"error","connection_id":"9","status":1044,"sqltext":"","user"	:"test[test] @ localhost []","host":"localhost","os_user":"","ip":"","db":""}}


For both option 1 & 2, use parse_general_or_error_log.sh to capture the unauthorized users. 

For option 3, use parse_audit.py. 

Tested both the scripts on percona-server (8.0.29-21). If you are using other mysql flavors, make sure to change the awk column numbers in "parse_general_or_error_log.sh" to parse the log correctly. 

Example log format in percona-server (8.0.29-21):

2022-11-28T04:32:25.031306Z 9 [Note] [MY-010914] [Server] Access denied for user 'sample'@'%' to database 'sys'
2022-11-28T04:32:47.202101Z 10 [Note] [MY-010926] [Server] Access denied for user 'sample1'@'localhost' (using password: YES)
2022-11-28T04:36:36.085752Z 11 [Note] [MY-010914] [Server] Access denied for user 'test'@'%' to database 'sys'
2022-11-28T04:51:31.464042Z 12 [Note] [MY-010914] [Server] Access denied for user 'test'@'%' to database 'sys'
2022-11-28T05:18:02.339165Z 13 [Note] [MY-010914] [Server] Access denied for user 'test'@'%' to database 'sys'
2022-11-28T05:18:11.324637Z 14 [Note] [MY-010914] [Server] Access denied for user 'test'@'%' to database 'performance_schema'
