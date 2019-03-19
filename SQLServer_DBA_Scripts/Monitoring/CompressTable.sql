-- check the space usage of a table
EXEC sp_spaceused @objname=N'Sales.OrderTracking'

-- Estimate the size after ROW compression
EXEC sp_estimate_data_compression_savings 
    @schema_name = 'Sales', 
    @object_name = 'OrderTracking', 
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'ROW'

-- Estimate the size after PAGE compression
EXEC sp_estimate_data_compression_savings 
    @schema_name = 'Sales', 
    @object_name = 'OrderTracking', 
    @index_id = NULL, 
    @partition_number = NULL, 
    @data_compression = 'PAGE'


--Compress Index
ALTER INDEX PK_OrderTracking 
        ON Sales.OrderTracking 
        REBUILD PARTITION = ALL 
        WITH (DATA_COMPRESSION = PAGE);

