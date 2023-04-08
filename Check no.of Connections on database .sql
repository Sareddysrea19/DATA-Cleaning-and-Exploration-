-------------------------------------------------

--To get the server name in sql

Select @@SERVERNAME

--To get the servce name
select @@SERVICENAME
----------------------------------------------------------------------------------------------------
--SQL Server Query to Check Number of Connections on Database

select * from dbo.DEPT

select 
	DB_NAME(DBID) AS DBNAME,
	COUNT(DBID) AS CNT,
	LOGINAME AS LGN
FROM sys.sysprocesses
WHERE DBID>0
GROUP BY DBID,LOGINAME;

Select (DBID) AS TOTAL_CONN
FROM SYS.sysprocesses 
WHERE DBID>0;

SP_WHO2 'ACTIVE' ;

SP_who;


----------------------------------------------SQL SERVER-----------------------------------------------------------------------------
--server type    (Database Engine/Analysis Services/ Reporting Services/Integration Services)
--Server name    (localhost/./pc name/ IP address)
--Authentication (windows/SQL Server Authentication)


-----------------------------------------------------------------------------------Reset sa Password in sql Server---------------------------------------------------------
windows authentication mode 
security->login->sa->properties.    Genaral  password  
                                    status(Login->Enable)
									--------.Restart.............................
              disconnect & connect  use SQL Server Authentivation mode 

----------------------------------------------------------------------------------Create New Login in Sql Server----------------------------------------------------------
 -windows authentication ((Security->Logins->new login->general  login name..(create name)...SQL server authentication set passwords
                                                     ->/Server Roles/.../
													 ->Status-->(enable)
						disconnect & connect  use SQL Server Authentivation mode 

USE MASTER 
GO 
CREATE LOGIN DB WITH PASSWORD ='1234', DEFAULT_DATABASE = MASTER, DEFAULT_LANGUAGE = US_ENGLISH
GO

ALTER LOGIN DB ENABLE
GO

--------------------------------------------------------------------------------- How to enable SQL Authentication in SQL Server------------------------------------
  1. server->properties->Security-->select sql server and windows authentication mode
  2. security->login->sa->properties (general.../ Status-->ENABLE)
  3. RESTART (Disconnect & Connect)  --use SQL Server Authentication
  
  ----------------------------------------------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------Allow remote connections to SQL Server Express---------------------------
  1. Enabling SQL Server to accept remote connection
  2. Adding SQL Server conection port in firewall
      check ip address (run->cmd) 
	                   ipconfig- To show the IP Address of Server(192.168.29.205)

      open Sql Server Configuration Manager->>SQL Server Network Configuration
										                                   ->Protocols for SQLEXPRESS
																		                            -> TCP/IP (enable)
										 - ->>SQL Server Services->SQL Server(SQLEXPRESS)-->RESTART

	  after that open SQL Server Network Configuration->>Protocols for SQLEXPRESS->>TCP/IP->>IP Address
	                                                                                                >>IPALL
	                                       -                                                               -->TCP Dynamic Port - (Dynamic ports can change automatically)  
										                                                                   -->TCP Port - we are using static port (port number - 49170)
																										   Then remove the TCP Dynamic port number 
																										   Apply--OK--OK
										  ->>SQL Server Services->SQL Server(SQLEXPRESS)-->RESTART

	NOW CONFIGURE WINDOWS FIREWALL
	we have to configure windows firewall in Windows firewall we are going to open the  port which we have congigured in sequeal server configuration manager for incoming connection.
	->> computer->view/computer>Open control pannel->>Windows firewall
	                                                   ->>Advanced settings
													                    ->Inbound Rules right side --New Rule
																		                                    -->Port
								   																			     -->Specific local ports  ( 49170 )
   									         Name - (49170SQL)

		[Finally 49170SQL port added]				
		
	In the main server database engine is installed --server name 2	
	now lets go to our another server from whicih we are gijing to  conenct this sequel server data base engine-- server 1

	
		first check the connectivity between both of the machines
		command prompt ping ip address of the remote computer
		               ping 192.168.29.205

Service type   : Database Engine
Server name    : 192.168.29.205,49170 (IP Address of the remote computer, port number of the remote sequel server which we have configured) 
Authentication : SQL Server Authentication
----
This is connect to the remote sequel server using another system(remote connection)   
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------How to Automate  SQL Server Express backups---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Cannot change the name of system system database (master/model/msdb/tempdb)
1.System Data base
2.User defined Database

    database name (e.g. Emp )->properties->>Files-- copy path and paste it run to see the  database location
	      (Emp)       Type  : SQL Server Database Primary Data File
		  (Emp_log)	  Type  : SQL Server Database Transaction Log File


------------------------------------------------------------------------------------------------------------------------------------------------------------
    Primary Key , Foreign Key
1. A Foreign Key in one table points to a PRIMARY KEY in another table.
2 .A Foreign Key can have a different name than the primary key it comes from.
3. The primaruy key used by a foreign key is also known as a parent key.The table where the primary key is from is known as a parent table.
4.The foreign key can be used to make sure that the row in one table have corresponding row in anoter table.
5. Foreign Key can be null, even though priamry key value can"t.
--------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM INFORMATION_SCHEMA.TABLE WHERE TABLE_NAME LIKE 'E%'