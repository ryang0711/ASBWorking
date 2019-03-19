DECLARE @sql_command VARCHAR(5000);

CREATE TABLE #Results (
	[server] NVARCHAR(128), 
	[database_name] NVARCHAR(128), 
	[file_name] NVARCHAR(128), 
	[physical_name] NVARCHAR(260),  
	[file_type] VARCHAR(4), 
	[total_size_mb] INT, 
	[available_space_mb] INT, 
	[growth_units] VARCHAR(15), 
	[max_file_size_mb] INT);

SELECT @sql_command =  
'USE [?] INSERT INTO #Results([server], [database_name], [file_name], [physical_name],  
[file_type], [total_size_mb], [available_space_mb],  
[growth_units], [max_file_size_mb])  
SELECT CONVERT(nvarchar(128), SERVERPROPERTY(''Servername'')), DB_NAME(), 
[name] AS [file_name],  
physical_name AS [physical_name],  
[file_type] =  
CASE type 
WHEN 0 THEN ''Data'''  
+ 
	   'WHEN 1 THEN ''Log''' 
+ 
   'END, 
[total_size_mb] = 
CASE ceiling([size]/128)  
WHEN 0 THEN 1 
ELSE ceiling([size]/128) 
END, 
[available_space_mb] =  
CASE ceiling([size]/128) 
WHEN 0 THEN (1 - CAST(FILEPROPERTY([name], ''SpaceUsed''' + ') as int) /128) 
ELSE (([size]/128) - CAST(FILEPROPERTY([name], ''SpaceUsed''' + ') as int) /128) 
END, 
[growth_units]  =  
CASE [is_percent_growth]  
WHEN 1 THEN CAST([growth] AS varchar(20)) + ''%''' 
+ 
	   'ELSE CAST([growth]/1024*8 AS varchar(20)) + ''Mb''' 
+ 
   'END, 
[max_file_size_mb] =  
CASE [max_size] 
WHEN -1 THEN NULL 
WHEN 268435456 THEN NULL 
ELSE [max_size]/1024*8 
END 
FROM sys.database_files WITH (NOLOCK)
ORDER BY [file_type], [file_id]'; 

EXEC sp_MSforeachdb @sql_command;

SELECT  
   GETDATE() AS [Runtime],
   CAST(T.[database_name] AS VARCHAR(30)) AS [Database Name], 
   --T.[total_size_mb] AS [db_size_mb], 
   --T.[available_space_mb] AS [db_free_mb], 
   --T.[used_space_mb] AS [db_used_mb], 
   --CAST(D.[available_space_mb]*1.0/1024 AS DECIMAL(10,2)) AS [data_free(GB)], 
	   CAST(D.[total_size_mb]*1.0/1024 AS DECIMAL(10,2)) AS [Data File Size (GB)], 
   CAST(D.[used_space_mb]*1.0/1024 AS DECIMAL(10,2)) AS [Data File Used (GB)], 
   CAST(CEILING(CAST(D.[used_space_mb] AS decimal(10,1)) / D.[total_size_mb]*100) AS decimal(5,2)) AS [Data Used Pct (%)],
   --CAST(L.[available_space_mb]*1.0/1024 AS DECIMAL(10,2)) AS [log_free(GB)], 
	   CAST(L.[total_size_mb]*1.0/1024 AS DECIMAL(10,2)) AS [Log File Size (GB)], 
   CAST(L.[used_space_mb]*1.0/1024 AS DECIMAL(10,2)) AS [Log File Used (GB)], 
   CAST(CEILING(CAST(L.[used_space_mb] AS decimal(10,1)) / L.[total_size_mb]*100) AS decimal(5,2)) AS [Log Used Pct (%)] 
FROM  
   ( 
   SELECT [server], [database_name], 
	   SUM([total_size_mb]) AS [total_size_mb], 
	   SUM([available_space_mb]) AS [available_space_mb], 
	   SUM([total_size_mb]-[available_space_mb]) AS [used_space_mb]  
   FROM #Results 
   WHERE database_name not in ('master','model','msdb')
   GROUP BY [server], [database_name] 
   ) AS T 
   INNER JOIN  
   ( 
	   SELECT [server], 
			[database_name], 
			SUM([total_size_mb]) AS [total_size_mb], 
			SUM([available_space_mb]) AS [available_space_mb], 
			SUM([total_size_mb]-[available_space_mb]) AS [used_space_mb]  
	   FROM #Results 
	   WHERE #Results.[file_type] = 'Data' 
	   GROUP BY [server], [database_name] 
   ) AS D ON T.[database_name] = D.[database_name] 
   INNER JOIN 
   ( 
	   SELECT [server],
			[database_name], 
			SUM([total_size_mb]) AS [total_size_mb], 
			SUM([available_space_mb]) AS [available_space_mb], 
			SUM([total_size_mb]-[available_space_mb]) AS [used_space_mb]  
	   FROM #Results 
	   WHERE #Results.[file_type] = 'Log' 
	   GROUP BY [server], [database_name] 
   ) AS L ON T.[database_name] = L.[database_name] 
ORDER BY D.[database_name];

DROP TABLE #Results;
GO
