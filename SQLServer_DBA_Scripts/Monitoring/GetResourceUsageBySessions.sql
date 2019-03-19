--Run the bellowing query to display sessions which are currently top tempdb space consumers.
exec ASBDBA.BI.sp_WhoIsActive @show_sleeping_spids=1,@get_transaction_info=1,@output_column_list='[dd%][session_id][sql_text][login_name][tran_log%][tran_start_time][open_tran_count][tempdb_current]',@sort_order='[tempdb_current] DESC';

--Run the bellowing query to display top sessions which are using tempdb space aggressively in the last 10 seconds.
exec ASBDBA.BI.sp_WhoIsActive @show_sleeping_spids=1,@get_transaction_info=1,@delta_interval=10,@output_column_list='[dd%][session_id][sql_text][login_name][tran_log%][tran_start_time][open_tran_count][tempdb_current][tempdb_current_delta]',@sort_order='[tempdb_current_delta] DESC';


--Run the bellowing query to display sessions which are top CPU resource consumers in the last 10 seconds.
exec ASBDBA.BI.sp_WhoIsActive @show_sleeping_spids=1,@delta_interval=10,@output_column_list='[dd%][session_id][sql_text][login_name][CPU][CPU_delta][used_memory][reads][writes][status]',@sort_order='[CPU_delta] DESC';

--User Sessions of Top Memory Consumption Queries
EXEC ASBDBA.BI.PlatformMonitoring_DisplayHighMemoryQueries