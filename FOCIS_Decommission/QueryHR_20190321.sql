declare @psnl varchar(12);
declare @username varchar (20);

--set @psnl = '343896';
set @username = 'andrewgi';

WITH CTE_STAFF_POSN$1 AS
(
SELECT deb.EmployeeCode AS [PSNL_N], 
       deb.PreferredName AS [PRER_NM], 
       deb.LastName AS [SURNAME], 
       deb.UserID AS [USER_ID], 
       dasd.AppointmentStartDate AS [POS_START_D], 
       NULLIF(daed.AppointmentEndDate,'2999-12-31') AS [POS_END_D], 
       fa.FTE AS [FTE_VALUE], 
       dwa.CostCentreCode AS [BRCH_N], 
       dwa.LocationDescription AS [LOC_X], 
       dwap.WorkAreaPositionDescription AS [POS_X], 
       fa.ActiveFlag AS [ACT_F],
	   CASE WHEN GETDATE() BETWEEN dasd.AppointmentStartDate AND daed.AppointmentEndDate
			THEN 1
	        ELSE 0
	        END AS [CURR_PROF_F]
FROM dbo.Fact_Appointment AS fa
     INNER JOIN dbo.Dim_EmployeeBase AS deb ON fa.Dim_Employee_key = deb.Dim_Employee_key
     INNER JOIN dbo.Dim_AppointmentStartDate AS dasd ON fa.Dim_AppointmentStartDate_Key = dasd.Dim_AppointmentStartDate_key
     INNER JOIN dbo.Dim_AppointmentEndDate AS daed ON fa.Dim_AppointmentEndDate_Key = daed.Dim_AppointmentEndDate_key
     INNER JOIN dbo.Dim_WorkArea AS dwa ON fa.Dim_WorkArea_Key = dwa.Dim_WorkArea_Key
     INNER JOIN dbo.Dim_WorkAreaPosition AS dwap ON fa.Dim_WorkAreaPosition_key = dwap.Dim_WorkAreaPosition_key
)
SELECT * FROM CTE_STAFF_POSN$1
-- WHERE [PSNL_N]= @psnl
WHERE [USER_ID]=@username
-- AND (CURR_PROF_F = 1 or [POS_START_D] >= getdate()) /*add this back in if you want to only see the current & future items*/
ORDER BY [POS_START_D];

