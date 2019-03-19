USE tempdb
GO

SELECT
	GETDATE() AS [Tempdb Data Files Space Usage Runtime]
	,(SUM(total_page_count)/128) AS [Datafile Size(MB)]
	,(SUM(allocated_extent_page_count)/128) AS [Used Space(MB)]
	,CAST(SUM(allocated_extent_page_count)*1.0/SUM(total_page_count) AS DECIMAL(5,2)) AS [Used Pct(%)]
	,(SUM(internal_object_reserved_page_count)/128) AS [Internal Objects(MB)]
	,(SUM(user_object_reserved_page_count)/128) AS [User Objects(MB)]
	,(SUM(version_store_reserved_page_count)/128) AS [Version Store(MB)]
FROM sys.dm_db_file_space_usage;

SELECT 
	GETDATE() AS [Tempdb Transaction Log Space Usage Runtime]
	,total_log_size_in_bytes/1024/1024 AS [Transaction Log Size(MB)]
	,used_log_space_in_bytes/1024/1024 AS [Used Space(MB)]
	,CAST(used_log_space_in_percent AS decimal(5,2)) AS [Used Pct(%)]
FROM sys.dm_db_log_space_usage;
GO
