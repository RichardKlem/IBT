delimiter $$
create definer = rklem@localhost event refresh_mv_event on schedule
    every '3' HOUR
        starts '2021-01-01 01:00:00'
    on completion preserve
    enable
    do
    BEGIN
        call refresh_wrapper('refresh_mv_tests_compiler_regression__codix_by_ip');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__codix_fails_links');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__customer_by_ip');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__customer_fails_links');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__berkelium_by_configuration');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__berkelium_fails_links');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__berkelium_sum_by_build');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__helium_by_configuration');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__helium_sum_by_build');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__helium_fails_links');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__urisc_by_branch');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__urisc_sum_by_build');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__urisc_fails_links');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__uvliw_by_branch');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__uvliw_sum_by_build');
        call refresh_wrapper('refresh_mv_tests_compiler_regression__uvliw_fails_links');
    END $$
delimiter ;