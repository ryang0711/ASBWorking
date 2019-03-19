-- Get all tables/indexes which are not compressed.
SELECT DISTINCT
    s.name AS [SchemaName],
    t.name AS [TableName}],
    i.name AS [IndexName],
    i.type_desc AS [TypeDescription],
    i.index_id,
    p.partition_number,
    p.rows
FROM sys.tables t
LEFT JOIN sys.indexes i
ON t.object_id = i.object_id
JOIN sys.schemas s
ON t.schema_id = s.schema_id
LEFT JOIN sys.partitions p
ON i.index_id = p.index_id
    AND t.object_id = p.object_id
WHERE t.type = 'U' 
  AND p.data_compression_desc = 'NONE'
ORDER BY p.rows desc;


-- Get all indexes of a specified table which are not compressed.
SELECT DISTINCT
    s.name AS [SchemaName],
    t.name AS [TableName}],
    i.name AS [IndexName],
    i.type_desc [TypeDescription],
    i.index_id,
    p.partition_number,
    p.rows
FROM sys.tables t
LEFT JOIN sys.indexes i
ON t.object_id = i.object_id
JOIN sys.schemas s
ON t.schema_id = s.schema_id
LEFT JOIN sys.partitions p
ON i.index_id = p.index_id
    AND t.object_id = p.object_id
WHERE t.name=N'OrderTracking' 
 AND t.type = 'U' 
  AND p.data_compression_desc = 'NONE'
ORDER BY p.rows desc;