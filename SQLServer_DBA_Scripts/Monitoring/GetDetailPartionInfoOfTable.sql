--Get detail information in each partitions of a table
DECLARE @TableName NVARCHAR(200)= N'[dbo].[CPF_Invoice]';
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object], 
       p.partition_number AS [p#], 
       fg.name AS [filegroup], 
       p.rows, 
       au.total_pages AS pages,
       CASE boundary_value_on_right
           WHEN 1
           THEN 'less than'
           ELSE 'less than or equal to'
       END AS comparison, 
       rv.value, 
       CONVERT(VARCHAR(6), CONVERT(INT, SUBSTRING(au.first_page, 6, 1) + SUBSTRING(au.first_page, 5, 1))) + ':' + CONVERT(VARCHAR(20), CONVERT(INT, SUBSTRING(au.first_page, 4, 1) + SUBSTRING(au.first_page, 3, 1) + SUBSTRING(au.first_page, 2, 1) + SUBSTRING(au.first_page, 1, 1))) AS first_page
FROM sys.partitions p
     INNER JOIN sys.indexes i ON p.object_id = i.object_id
                                 AND p.index_id = i.index_id
     INNER JOIN sys.objects o ON p.object_id = o.object_id
     INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
     INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
     INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id
     INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id
                                                   AND dds.destination_id = p.partition_number
     INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
     LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id
                                                      AND p.partition_number = rv.boundary_id
WHERE i.index_id < 2
      AND o.object_id = OBJECT_ID(@TableName)
ORDER BY p.partition_number;
GO

-- Get the partitioned column
DECLARE @TableName NVARCHAR(200)= N'[dbo].[CPF_Invoice]';
SELECT t.[object_id] AS ObjectID, 
       t.name AS TableName, 
       ic.column_id AS PartitioningColumnID, 
       c.name AS PartitioningColumnName
FROM sys.tables AS t
     JOIN sys.indexes AS i ON t.[object_id] = i.[object_id]
                              AND i.[type] <= 1 -- clustered index or a heap   
     JOIN sys.partition_schemes AS ps ON ps.data_space_id = i.data_space_id
     JOIN sys.index_columns AS ic ON ic.[object_id] = i.[object_id]
                                     AND ic.index_id = i.index_id
                                     AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column   
     JOIN sys.columns AS c ON t.[object_id] = c.[object_id]
                              AND ic.column_id = c.column_id
WHERE t.[object_id] = OBJECT_ID(@TableName);   
GO

-- Get Space Usage information of Partitions of a Table
DECLARE @TableName NVARCHAR(200)= N'[dbo].[CPF_Invoice]';
SELECT DB_NAME() AS 'DatabaseName', 
       OBJECT_NAME(p.OBJECT_ID) AS 'TableName', 
       p.index_id AS 'IndexId',
       CASE
           WHEN p.index_id = 0
           THEN 'HEAP'
           ELSE i.name
       END AS 'IndexName', 
       p.partition_number AS 'PartitionNumber', 
       prv_left.VALUE AS 'LowerBoundary', 
       prv_right.VALUE AS 'UpperBoundary',
       CASE
           WHEN fg.name IS NULL
           THEN ds.name
           ELSE fg.name
       END AS 'FileGroupName', 
       CAST(p.used_page_count * 0.0078125 AS NUMERIC(18, 2)) AS 'UsedPages_MB', 
       CAST(p.in_row_data_page_count * 0.0078125 AS NUMERIC(18, 2)) AS 'DataPages_MB', 
       CAST(p.reserved_page_count * 0.0078125 AS NUMERIC(18, 2)) AS 'ReservedPages_MB',
       CASE
           WHEN p.index_id IN(0, 1)
           THEN p.ROW_COUNT
           ELSE 0
       END AS 'RowCount',
       CASE
           WHEN p.index_id IN(0, 1)
           THEN 'data'
           ELSE 'index'
       END 'Type'
FROM sys.dm_db_partition_stats p
     INNER JOIN sys.indexes i ON i.OBJECT_ID = p.OBJECT_ID
                                 AND i.index_id = p.index_id
     INNER JOIN sys.data_spaces ds ON ds.data_space_id = i.data_space_id
     LEFT OUTER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
     LEFT OUTER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id
                                                        AND dds.destination_id = p.partition_number
     LEFT OUTER JOIN sys.filegroups fg ON fg.data_space_id = dds.data_space_id
     LEFT OUTER JOIN sys.partition_range_values prv_right ON prv_right.function_id = ps.function_id
                                                             AND prv_right.boundary_id = p.partition_number
     LEFT OUTER JOIN sys.partition_range_values prv_left ON prv_left.function_id = ps.function_id
                                                            AND prv_left.boundary_id = p.partition_number - 1
WHERE OBJECTPROPERTY(p.OBJECT_ID, 'ISMSSHipped') = 0
      AND p.OBJECT_ID = OBJECT_ID(@TableName);
