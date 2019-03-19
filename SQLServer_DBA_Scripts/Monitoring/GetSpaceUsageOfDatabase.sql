USE BIODS_Processing;
GO

WITH cte_files AS(
SELECT CONVERT(NVARCHAR(128), SERVERPROPERTY('Servername')) AS [server_name],
       DB_NAME() AS [database_name],
       [name] AS [file_name],
       physical_name AS [physical_name],
       [file_type] = CASE type
                         WHEN 0 THEN
                             'Data'
                         WHEN 1 THEN
                             'Log'
                     END,
       [total_size_mb] = CASE CEILING([size] / 128)
                             WHEN 0 THEN
                                 1
                             ELSE
                                 CEILING([size] / 128)
                         END,
       [available_space_mb] = CASE CEILING([size] / 128)
                                  WHEN 0 THEN
       (1 - CAST(FILEPROPERTY([name], 'SpaceUsed') AS INT) / 128)
                                  ELSE
       (([size] / 128) - CAST(FILEPROPERTY([name], 'SpaceUsed') AS INT) / 128)
                              END,
       [growth_units] = CASE [is_percent_growth]
                            WHEN 1 THEN
                                CAST([growth] AS VARCHAR(20)) + '%'
                            ELSE
                                CAST([growth] / 1024 * 8 AS VARCHAR(20)) + 'Mb'
                        END,
       [max_file_size_mb] = CASE [max_size]
                                WHEN -1 THEN
                                    NULL
                                WHEN 268435456 THEN
                                    NULL
                                ELSE
                                    [max_size] / 1024 * 8
                            END
FROM sys.database_files WITH (NOLOCK))
SELECT [server_name],[database_name],[file_type],
	SUM([total_size_mb]) AS [total_size_mb],SUM([available_space_mb]) AS [available_space_mb],
	CAST(SUM([available_space_mb])*1.0/SUM([total_size_mb])*100 AS DECIMAL(5,2)) AS [available_pct(%)]
FROM cte_files
GROUP BY [server_name],[database_name],[file_type];

-- List details of all physical files of the database
SELECT CONVERT(NVARCHAR(128), SERVERPROPERTY('Servername')) AS [server_name],
       DB_NAME() AS [database_name],
       [name] AS [file_name],
       physical_name AS [physical_name],
       [file_type] = CASE type
                         WHEN 0 THEN
                             'Data'
                         WHEN 1 THEN
                             'Log'
                     END,
       [total_size_mb] = CASE CEILING([size] / 128)
                             WHEN 0 THEN
                                 1
                             ELSE
                                 CEILING([size] / 128)
                         END,
       [available_space_mb] = CASE CEILING([size] / 128)
                                  WHEN 0 THEN
       (1 - CAST(FILEPROPERTY([name], 'SpaceUsed') AS INT) / 128)
                                  ELSE
       (([size] / 128) - CAST(FILEPROPERTY([name], 'SpaceUsed') AS INT) / 128)
                              END,
       [growth_units] = CASE [is_percent_growth]
                            WHEN 1 THEN
                                CAST([growth] AS VARCHAR(20)) + '%'
                            ELSE
                                CAST([growth] / 1024 * 8 AS VARCHAR(20)) + 'Mb'
                        END,
       [max_file_size_mb] = CASE [max_size]
                                WHEN -1 THEN
                                    NULL
                                WHEN 268435456 THEN
                                    NULL
                                ELSE
                                    [max_size] / 1024 * 8
                            END
FROM sys.database_files WITH (NOLOCK)
ORDER BY [file_type],
         [file_id];