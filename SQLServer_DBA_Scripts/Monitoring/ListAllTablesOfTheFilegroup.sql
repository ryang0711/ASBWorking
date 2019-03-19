--List all objests in a specified File Group
WITH cte_tables AS
(
SELECT OBJECT_NAME( i."id" ) AS TableName ,
       i."Name" AS IndexName ,
       FILEGROUP_NAME( i.groupid ) AS FileGroupName
FROM sysindexes AS i
WHERE ( i.indid IN ( 0 , 1 ) Or i.indid < 255 ) And -- Tables & indexes only
      OBJECTPROPERTY( i."id" , 'IsUserTable' ) = 1 And -- User tables only
      OBJECTPROPERTY( i."id" , 'IsMSShipped' ) = 0 And -- No system tables
      COALESCE( INDEXPROPERTY( i."id" , i."Name" , 'IsStatistics' ) , 0 ) = 0 And -- No Statistics / Auto-Create stats
      COALESCE( INDEXPROPERTY( i."id" , i."Name" , 'IsHypothetical' ) , 0 ) = 0   -- No Hypothetical statistics
)
SELECT TableName,IndexName,FileGroupName
FROM cte_tables
WHERE FileGroupName=N'SQL_Store'
ORDER BY TableName , IndexName;

--List all table space usage in a specified File Group
WITH cte_tables AS
(
SELECT
	FILEGROUP_NAME(AU.data_space_id) AS FileGroupName,
	OBJECT_NAME(Parti.object_id) AS TableName,
	ind.name AS ClusteredIndexName,
	AU.total_pages/128 AS TotalTableSizeInMB,
	AU.used_pages/128 AS UsedSizeInMB,
	AU.data_pages/128 AS DataSizeInMB
FROM sys.allocation_units AS AU
INNER JOIN sys.partitions AS Parti ON AU.container_id = CASE WHEN AU.type in(1,3) THEN Parti.hobt_id ELSE Parti.partition_id END
LEFT JOIN sys.indexes AS ind ON ind.object_id = Parti.object_id AND ind.index_id = Parti.index_id
)
SELECT * from cte_tables
WHERE FileGroupName=N'SQL_Store'
ORDER BY TotalTableSizeInMB DESC;