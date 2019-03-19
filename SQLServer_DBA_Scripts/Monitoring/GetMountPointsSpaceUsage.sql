DECLARE @sql_command VARCHAR(5000);

set @sql_command = 'powershell.exe -c "Get-WmiObject -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'

--creating a temporary table

CREATE TABLE #diskinfo(line varchar(255));

--inserting disk name, total space and free space value in to temporary table
insert #diskinfo
EXEC xp_cmdshell @sql_command;

WITH cte_disk([drive_path],[free_space(GB)],[total_space(GB)])
AS(
	select rtrim(ltrim(SUBSTRING(line,1,CHARINDEX('|',line) -1))) AS [drive_path],
	round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('%',line)+1,(CHARINDEX('*',line) -1)-CHARINDEX('%',line)) )) as Float) /1024 ,0) AS [free_space(GB)],
	round(cast(rtrim(ltrim(SUBSTRING(line,CHARINDEX('|',line)+1,(CHARINDEX('%',line) -1)-CHARINDEX('|',line)) )) as Float)/1024,0) AS [total_space(GB)]
	from #diskinfo
	WHERE line like '[A-Z][:]%'
)
SELECT [drive_path] AS [Drive Path]
	,[total_space(GB)] AS [Total Size (GB)]
	,[total_space(GB)]-[free_space(GB)] AS [Used Size (GB)]
	,CAST(([total_space(GB)]-[free_space(GB)])*1.0/[total_space(GB)]*100 AS DECIMAL(5,2)) AS [Used Pct (%)]
FROM cte_disk
ORDER BY [drive_path];

DROP TABLE #diskinfo;
GO
