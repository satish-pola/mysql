# mysql

DATA CAPTURE:
============
How do we capture the data?
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

