use xklemr00_IBT_old;
DROP PROCEDURE IF EXISTS test_refreshers;
DELIMITER $$
CREATE PROCEDURE test_refreshers()
BEGIN
    DECLARE v1 INT DEFAULT 10;

    WHILE v1 > 0 DO
        call refresh_wrapper('refresh_mv_compiler_regression__codix_by_ip');
        call refresh_wrapper('refresh_mv_compiler_regression__codix_links');
        call refresh_wrapper('refresh_mv_compiler_regression__custom_by_ip');
        call refresh_wrapper('refresh_mv_compiler_regression__custom_links');
        call refresh_wrapper('refresh_mv_compiler_regression__berkelium_by_conf');
        call refresh_wrapper('refresh_mv_compiler_regression__berkelium_links');
        call refresh_wrapper('refresh_mv_compiler_regression__berkelium_sum_by_build');
        call refresh_wrapper('refresh_mv_compiler_regression__helium_by_conf');
        call refresh_wrapper('refresh_mv_compiler_regression__helium_sum_by_build');
        call refresh_wrapper('refresh_mv_compiler_regression__helium_links');
        call refresh_wrapper('refresh_mv_compiler_regression__urisc_by_branch');
        call refresh_wrapper('refresh_mv_compiler_regression__urisc_sum_by_build');
        call refresh_wrapper('refresh_mv_compiler_regression__urisc_links');
        call refresh_wrapper('refresh_mv_compiler_regression__uvliw_by_branch');
        call refresh_wrapper('refresh_mv_compiler_regression__uvliw_sum_by_build');
        call refresh_wrapper('refresh_mv_compiler_regression__uvliw_links');
        call refresh_wrapper('refresh_mv_debugger_regression__urisc_all');

        SET v1 = v1 - 1;
    END WHILE;
END $$
DELIMITER ;

call test_refreshers();

use xklemr00_IBT_new;
DROP PROCEDURE IF EXISTS test_refreshers;
DELIMITER $$
CREATE PROCEDURE test_refreshers()
BEGIN
    DECLARE v1 INT DEFAULT 10;

    WHILE v1 > 0 DO
        call refresh_wrapper('refresh_new_mv_compiler_regression__codix_by_ip');
        call refresh_wrapper('refresh_new_mv_compiler_regression__codix_links');
        call refresh_wrapper('refresh_new_mv_compiler_regression__custom_by_ip');
        call refresh_wrapper('refresh_new_mv_compiler_regression__custom_links');
        call refresh_wrapper('refresh_new_mv_compiler_regression__berkelium_by_conf');
        call refresh_wrapper('refresh_new_mv_compiler_regression__berkelium_links');
        call refresh_wrapper('refresh_new_mv_compiler_regression__berkelium_sum_by_build');
        call refresh_wrapper('refresh_new_mv_compiler_regression__helium_by_conf');
        call refresh_wrapper('refresh_new_mv_compiler_regression__helium_sum_by_build');
        call refresh_wrapper('refresh_new_mv_compiler_regression__helium_links');
        call refresh_wrapper('refresh_new_mv_compiler_regression__urisc_by_branch');
        call refresh_wrapper('refresh_new_mv_compiler_regression__urisc_sum_by_build');
        call refresh_wrapper('refresh_new_mv_compiler_regression__urisc_links');
        call refresh_wrapper('refresh_new_mv_compiler_regression__uvliw_by_branch');
        call refresh_wrapper('refresh_new_mv_compiler_regression__uvliw_sum_by_build');
        call refresh_wrapper('refresh_new_mv_compiler_regression__uvliw_links');
        call refresh_wrapper('refresh_new_mv_debugger_regression__urisc_all');

        SET v1 = v1 - 1;
    END WHILE;
END $$
DELIMITER ;

call test_refreshers();

# Show aggregated data about procedure duration, these should be the slowest ones.
select REPLACE(REPLACE(procedure_name, 'new_', ''), 'refresh_mv_', '') as procedure_name,
       if(avg(time_to_sec(duration)) < 1, 1, cast(avg(time_to_sec(duration))as UNSIGNED) )  as duration,
       if(procedure_name like '%new%', 'new', 'old') as new
from ((select * from xklemr00_IBT_old.refresh_events_log) UNION (select * from xklemr00_IBT_new.refresh_events_log)) as old_union_new
where REPLACE(REPLACE(procedure_name, 'new_', ''), 'refresh_mv_', '') in (
'compiler_regression__urisc_sum_by_build',
'compiler_regression__urisc_by_branch'
'compiler_regression__berkelium_sum_by_build',
'compiler_regression__berkelium_by_conf',
'compiler_regression__uvliw_sum_by_build',
'compiler_regression__uvliw_by_branch',
'compiler_regression__codix_by_ip',
'compiler_regression__helium_sum_by_build')
group by procedure_name, new
order by duration desc;