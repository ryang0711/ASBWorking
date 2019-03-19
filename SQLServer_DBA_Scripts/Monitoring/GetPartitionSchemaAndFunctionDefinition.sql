-- List the Partition Schema name and Function name of a specified table
SELECT ps.Name AS PartitionScheme, 
       pf.name AS PartitionFunction, 
       fg.name AS FileGroupName
FROM sys.indexes i
     JOIN sys.partitions p ON i.object_id = p.object_id
                              AND i.index_id = p.index_id
     JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
     JOIN sys.partition_functions pf ON pf.function_id = ps.function_id
     JOIN sys.allocation_units au ON au.container_id = p.hobt_id
     JOIN sys.filegroups fg ON fg.data_space_id = au.data_space_id
WHERE i.object_id = OBJECT_ID('[dbo].[RCU_FinancialData]');

-- Get functions boundary definitions of a specified Partition Function
SELECT f.name AS NameHere, 
       f.type_desc AS TypeHere, 
       (CASE
            WHEN f.boundary_value_on_right = 0
            THEN 'LEFT'
            ELSE 'Right'
        END) AS LeftORRightHere, 
       v.value, 
       v.boundary_id, 
       t.name
FROM sys.partition_functions f
     INNER JOIN sys.partition_range_values v ON f.function_id = v.function_id
     INNER JOIN sys.partition_parameters p ON f.function_id = p.function_id
     INNER JOIN sys.types t ON t.system_type_id = p.system_type_id
WHERE f.name = N'function_RCU_DataStore';