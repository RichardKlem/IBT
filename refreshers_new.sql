delimiter $$
create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__berkelium_by_conf()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__berkelium_conf;
    INSERT INTO mv_compiler_regression__berkelium_conf (`date`, `version`, `build_id`, `model_name`, `configuration`,
                                                        `ip_branch`, `failed_tests`, `passed_tests`)
    SELECT `artifacts`.`created`          AS `Date`,
           `artifacts`.`version`          AS `version`,
           `artifacts`.`build`            AS `build _id`,
           `tests`.`design_path`          AS `model_name`,
           `artifacts_ip`.`configuration` AS `configuration`,
           `sources`.`branch`             AS `ip_branch`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 0) THEN 1
                    ELSE 0
               END))                      AS `Failed Tests`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 1) THEN 1
                    ELSE 0
               END))                      AS `Passed Tests`
    FROM (((`tests`
        INNER JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        INNER JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
             INNER JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE `artifacts_ip`.`name` = 'codix_berkelium'
      AND `tests`.`tool` = 'compiler'
      AND `tests`.`kind` = 'regression'
    GROUP BY `artifacts`.`created`, `artifacts`.`version`, `artifacts`.`build`, `tests`.`design_path`,
             `artifacts_ip`.`configuration`, `artifacts_ip`.`configuration`, `sources`.`branch`
    ORDER BY `artifacts`.`created` DESC, `failed tests` DESC, `passed tests` DESC;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__berkelium_links()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__berkelium_links;
    INSERT INTO mv_compiler_regression__berkelium_links (`branch`, `date`, `version`, `build_id`, `OS`, `compiler`,
                                                         `model_name`, `configuration`, `parameters`, `test_status`,
                                                         `link_full`)
    SELECT `sources`.`branch`             AS `branch`,
           `artifacts`.`created`          AS `date`,
           `artifacts`.`version`          AS `version`,
           `artifacts`.`build`            AS `build_id`,
           `cl_environments`.`os`         AS `OS`,
           `cl_environments`.`compiler`   AS `compiler`,
           `tests`.`design_path`          AS `model_name`,
           `artifacts_ip`.`configuration` AS `configuration`,
           `tests`.`parameters`           AS `parameters`,
           `cl_status`.`description`      AS `test_status`,
           IF((`tests`.`link` is not null),
              CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                     REPLACE(`tests`.`link`,
                             'mastermind_data/',
                             '')),
              `tests`.`link`)             AS `link_full`
    FROM ((((((`tests`
        inner join `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        inner join `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        inner join `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
        inner join `cl_environments` ON ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
        inner join `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
             inner join `cl_status` ON ((`tests`.`status_id` = `cl_status`.`id`)))
    WHERE (`tests`.`passed` = 0)
      AND (`tests`.`link` IS NOT NULL)
      AND (`tests`.`studio_id` IS NOT NULL)
      AND (`tests`.`tool` = 'compiler')
      AND (`tests`.`kind` = 'regression')
      AND (`artifacts_ip`.`name` = 'codix_berkelium')
    ORDER BY `artifacts`.`created` DESC;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__berkelium_sum_by_build()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__berkelium_sum_by_build;
    INSERT INTO mv_compiler_regression__berkelium_sum_by_build (`date`, `version_build_id`, `failed_tests_ia`,
                                                                `passed_tests_ia`, `sum_tests_ia`, `failed_tests_ca`,
                                                                `passed_tests_ca`, `sum_tests_ca`)
    SELECT `artifacts`.`created`          AS `date`,
           CONCAT_WS('-',
                     `artifacts`.`version`,
                     NULL,
                     `artifacts`.`build`) AS `build_id`,
           SUM((CASE
                    WHEN
                        ((`tests`.`passed` = 0)
                            AND
                         (`tests`.`design_path` = 'codix_berkelium.ia' OR `tests`.`design_path` = 'codix_berkelium-ia'))
                        THEN
                        1
                    ELSE 0
               END))                      AS `failed_tests_ia`,
           SUM((CASE
                    WHEN
                        ((`tests`.`passed` = 1)
                            AND
                         (`tests`.`design_path` = 'codix_berkelium.ia' OR `tests`.`design_path` = 'codix_berkelium-ia'))
                        THEN
                        1
                    ELSE 0
               END))                      AS `passed_tests_ia`,
           SUM((CASE
                    WHEN
                            `tests`.`design_path` = 'codix_berkelium.ia' OR `tests`.`design_path` = 'codix_berkelium-ia'
                        THEN
                        1
                    ELSE 0
               END))                      AS `sum_tests_ia`,
           SUM((CASE
                    WHEN
                        ((`tests`.`passed` = 0)
                            AND
                         (`tests`.`design_path` = 'codix_berkelium.ca' OR `tests`.`design_path` = 'codix_berkelium-ca'))
                        THEN
                        1
                    ELSE 0
               END))                      AS `failed_tests_ca`,
           SUM((CASE
                    WHEN
                        ((`tests`.`passed` = 1)
                            AND
                         (`tests`.`design_path` = 'codix_berkelium.ca' OR `tests`.`design_path` = 'codix_berkelium-ca'))
                        THEN
                        1
                    ELSE 0
               END))                      AS `passed_tests_ca`,
           SUM((CASE
                    WHEN
                            `tests`.`design_path` = 'codix_berkelium.ca' OR `tests`.`design_path` = 'codix_berkelium-ca'
                        THEN
                        1
                    ELSE 0
               END))                      AS `sum_tests_ca`
    FROM (((`tests`
        inner join `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        inner join `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
             inner join `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE ((`tests`.`tool` = 'compiler')
        AND (`tests`.`kind` = 'regression')
        AND (`artifacts_ip`.`name` = 'codix_berkelium'))
    GROUP BY `artifacts`.`created`, `build_id`;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__codix_by_ip()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__codix_by_ip;
    INSERT INTO mv_compiler_regression__codix_by_ip (`date`, `version`, `build_id`, `ip_name`, `ip_branch`,
                                                     `failed_tests`, `passed_tests`)
    select `artifacts`.`created`                                     AS `date`,
           `artifacts`.`version`                                     AS `version`,
           `artifacts`.`build`                                       AS `build_id`,
           `tests`.`design_path`                                     AS `ip_name`,
           `sources`.`branch`                                        AS `ip_branch`,
           sum((case when (`tests`.`passed` = 0) then 1 else 0 end)) AS `failed_tests`,
           sum((case when (`tests`.`passed` = 1) then 1 else 0 end)) AS `passed_tests`
    from (((`tests`
        INNER join `sources` on
            ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        INNER join `artifacts` on
            ((`tests`.`studio_id` = `artifacts`.`id`)))
             INNER join `artifacts_ip` on
        ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    where ((`artifacts_ip`.`name` = 'codix_cobalt' OR `artifacts_ip`.`name` = 'codix_titanium') and
           `tests`.`tool` = 'compiler' and
           `tests`.`kind` = 'regression')
    group by `date`,
             `artifacts`.`version`,
             `artifacts`.`build`,
             `sources`.`branch`,
             `tests`.`design_path`
    order by `date` desc,
             `failed_tests` desc,
             `passed_tests` desc;
    COMMIT;
END $$

create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__codix_links()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__codix_links;
    INSERT INTO mv_compiler_regression__codix_links (`date`, `parameters`, `version`, `build_id`, `os`, `compiler`,
                                                     `ip_name`, `test_status`, `link_full`)
    select `artifacts`.`created`        AS `date`,
           `tests`.`parameters`         AS `parameters`,
           `artifacts`.`version`        AS `version`,
           `artifacts`.`build`          AS `build_id`,
           `cl_environments`.`os`       AS `os`,
           `cl_environments`.`compiler` AS `compiler`,
           `artifacts_ip`.`name`        AS `ip_name`,
           `cl_status`.`description`    AS `test_status`,
           if((`tests`.`link` is not null),
              concat('https://codasip3.codasip.com/~jenkinsdata/', replace(`tests`.`link`, 'mastermind_data/', '')),
              `tests`.`link`)           AS `link_full`
    from ((((((`tests`
        inner join `artifacts` on
            ((`tests`.`studio_id` = `artifacts`.`id`)))
        inner join `sources` on
            ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        inner join `artifacts_studio` on
            ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
        inner join `cl_environments` on
            ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
        inner join `artifacts_ip` on
            ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
             inner join `cl_status` on
        ((`tests`.`status_id` = `cl_status`.`id`)))
    where (`tests`.`passed` = 0)
      and (`tests`.`link` is not null)
      and (`tests`.`studio_id` is not null)
      and (`tests`.`tool` = 'compiler')
      and (`tests`.`kind` = 'regression')
      and (`artifacts_ip`.`name` = 'codix_cobalt' OR `artifacts_ip`.`name` = 'codix_titanium')
    order by `artifacts`.`created` desc;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__custom_by_ip()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__custom_by_ip;
    INSERT INTO mv_compiler_regression__custom_by_ip (`date`, `version`, `build_id`, `ip_name`, `ip_branch`,
                                                      `failed_tests`, `passed_tests`)
    select `artifacts`.`created`                                     AS `date`,
           `artifacts`.`version`                                     AS `version`,
           `artifacts`.`build`                                       AS `build_id`,
           `tests`.`design_path`                                     AS `ip_name`,
           `sources`.`branch`                                        AS `ip_branch`,
           sum((case when (`tests`.`passed` = 0) then 1 else 0 end)) AS `failed_tests`,
           sum((case when (`tests`.`passed` = 1) then 1 else 0 end)) AS `passed_tests`
    from (((`tests`
        INNER join `sources` on
            ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        INNER join `artifacts` on
            ((`tests`.`studio_id` = `artifacts`.`id`)))
             INNER join `artifacts_ip` on
        ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    where ((`artifacts_ip`.`name` = 'sigma_dk_bb700' OR artifacts_ip.name = 'sigma_dk_p700')
        and (`tests`.`tool` = 'compiler')
        and (`tests`.`kind` = 'regression'))
    group by `artifacts`.`created` desc,
             `artifacts`.`version`,
             `artifacts`.`build`,
             `sources`.`branch`,
             `tests`.`design_path`
    order by `artifacts`.`created` desc,
             `failed_tests` desc,
             `passed_tests` desc;
    COMMIT;
END $$

create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__custom_links()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__custom_links;
    INSERT INTO mv_compiler_regression__custom_links (`date`, `parameters`, `version`, `build_id`, `os`, `compiler`,
                                                      `branch`, `ip_name`, `test_status`, `link_full`)
    select `artifacts`.`created`        AS `date`,
           `tests`.`parameters`         AS `parameters`,
           `artifacts`.`version`        AS `version`,
           `artifacts`.`build`          AS `build_id`,
           `cl_environments`.`os`       AS `os`,
           `cl_environments`.`compiler` AS `compiler`,
           `sources`.`branch`           AS `branch`,
           `artifacts_ip`.`name`        AS `ip_name`,
           `cl_status`.`description`    AS `test_status`,
           if((`tests`.`link` is not null),
              concat('https://codasip3.codasip.com/~jenkinsdata/', replace(`tests`.`link`, 'mastermind_data/', '')),
              `tests`.`link`)           AS `link_full`
    from ((((((`tests`
        inner join `artifacts` on
            ((`tests`.`studio_id` = `artifacts`.`id`)))
        inner join `sources` on
            ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        inner join `artifacts_studio` on
            ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
        inner join `cl_environments` on
            ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
        inner join `artifacts_ip` on
            ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
             inner join `cl_status` on
        ((`tests`.`status_id` = `cl_status`.`id`)))
    where ((`tests`.`passed` = 0)
        and (`tests`.`link` is not null)
        and (`tests`.`studio_id` is not null)
        and (`tests`.`tool` = 'compiler')
        and (`tests`.`kind` = 'regression')
        and (`artifacts_ip`.`name` = 'sigma_dk_bb700' OR artifacts_ip.name = 'sigma_dk_p700'))
    order by `artifacts`.`created` desc;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__helium_by_conf()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__helium_by_conf;
    INSERT INTO mv_compiler_regression__helium_by_conf (`date`, `version`, `build_id`, `ip_name`, `configuration`,
                                                        `failed_tests`, `passed_tests`)
    SELECT `artifacts`.`created`          AS `Date`,
           `artifacts`.`version`          AS `Version`,
           `artifacts`.`build`            AS `Build ID`,
           `tests`.`design_path`          AS `IP Name`,
           `artifacts_ip`.`configuration` AS `Configuration`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 0) THEN 1
                    ELSE 0
               END))                      AS `Failed Tests`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 1) THEN 1
                    ELSE 0
               END))                      AS `Passed Tests`
    FROM (((`tests`
        INNER JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        INNER JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
             INNER JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE `artifacts_ip`.`name` = 'codix_helium'
      AND `tests`.`tool` = 'compiler'
      AND `tests`.`kind` = 'regression'
    GROUP BY `artifacts`.`created` DESC, `artifacts`.`version`, `artifacts`.`build`, `tests`.`design_path`,
             `artifacts_ip`.`configuration`
    ORDER BY `artifacts`.`created` DESC, `failed tests` DESC, `passed tests` DESC;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__helium_links()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__helium_links;
    INSERT INTO mv_compiler_regression__helium_links (`parameters`, `version`, `build_id`, `OS`, `compiler`,
                                                      `configuration`, `date`, `test_status`, `link_full`)
    SELECT `tests`.`parameters`                           AS `parameters`,
           `artifacts`.`version`                          AS `version`,
           `artifacts`.`build`                            AS `build_id`,
           `cl_environments`.`os`                         AS `OS`,
           `cl_environments`.`compiler`                   AS `compiler`,
           `artifacts_ip`.`configuration`                 AS `configuration`,
           DATE_FORMAT(`artifacts`.`created`, '%Y-%m-%d') AS `date`,
           `cl_status`.`description`                      AS `test_status`,

           IF((`tests`.`link` is not null),
              CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                     REPLACE(`tests`.`link`,
                             'mastermind_data/',
                             '')),
              `tests`.`link`)                             AS `link_full`
    FROM ((((((`tests`
        inner join `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        inner join `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        inner join `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
        inner join `cl_environments` ON ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
        inner join `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
             inner join `cl_status` ON ((`tests`.`status_id` = `cl_status`.`id`)))
    WHERE (`tests`.`passed` = 0)
      AND (`tests`.`link` IS NOT NULL)
      AND (`tests`.`studio_id` IS NOT NULL)
      AND (`tests`.`tool` = 'compiler')
      AND (`tests`.`kind` = 'regression')
      AND (`artifacts_ip`.`name` = 'codix_helium')
    ORDER BY `artifacts`.`created` DESC;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__helium_sum_by_build()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__helium_sum_by_build;
    INSERT INTO mv_compiler_regression__helium_sum_by_build (`date`, `version_build_id`, `failed_tests_ia`,
                                                             `passed_tests_ia`, `sum_tests_ia`, `failed_tests_ca`,
                                                             `passed_tests_ca`, `sum_tests_ca`)
    SELECT `artifacts`.`created`          AS `date`,
           CONCAT_WS('-',
                     `artifacts`.`version`,
                     NULL,
                     `artifacts`.`build`) AS `build_id`,
           SUM((CASE
                    WHEN
                        ((`tests`.`passed` = 0)
                            AND
                         (`tests`.`design_path` = 'codix_helium.ia' OR `tests`.`design_path` = 'codix_helium-ia'))
                        THEN
                        1
                    ELSE 0
               END))                      AS `failed_tests_ia`,
           SUM((CASE
                    WHEN
                        ((`tests`.`passed` = 1)
                            AND
                         (`tests`.`design_path` = 'codix_helium.ia' OR `tests`.`design_path` = 'codix_helium-ia'))
                        THEN
                        1
                    ELSE 0
               END))                      AS `passed_tests_ia`,
           SUM((CASE
                    WHEN
                            `tests`.`design_path` = 'codix_helium.ia' OR `tests`.`design_path` = 'codix_helium-ia'
                        THEN
                        1
                    ELSE 0
               END))                      AS `sum_tests_ia`,
           SUM((CASE
                    WHEN
                        ((`tests`.`passed` = 0)
                            AND
                         (`tests`.`design_path` = 'codix_helium.ca' OR `tests`.`design_path` = 'codix_helium-ca'))
                        THEN
                        1
                    ELSE 0
               END))                      AS `failed_tests_ca`,
           SUM((CASE
                    WHEN
                        ((`tests`.`passed` = 1)
                            AND
                         (`tests`.`design_path` = 'codix_helium.ca' OR `tests`.`design_path` = 'codix_helium-ca'))
                        THEN
                        1
                    ELSE 0
               END))                      AS `passed_tests_ca`,
           SUM((CASE
                    WHEN
                            `tests`.`design_path` = 'codix_helium.ca' OR `tests`.`design_path` = 'codix_helium-ca'
                        THEN
                        1
                    ELSE 0
               END))                      AS `sum_tests_ca`
    FROM (((`tests`
        inner join `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        inner join `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
             inner join `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE ((`tests`.`tool` = 'compiler')
        AND (`tests`.`kind` = 'regression')
        AND (`artifacts_ip`.`name` = 'codix_helium'))
    GROUP BY `artifacts`.`created`, `build_id`;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__urisc_by_branch()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__urisc_by_branch;

    INSERT INTO mv_compiler_regression__urisc_by_branch (`date`, version, build_id, model_name, branch, failed_tests,
                                                         passed_tests)
    SELECT `artifacts`.`created` AS `Date`,
           `artifacts`.`version` AS `version`,
           `artifacts`.`build`   AS `revision`,
           `tests`.`design_path` AS `model_name`,
           `sources`.`branch`    AS `ip_branch`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 0) THEN 1
                    ELSE 0
               END))             AS `failed_tests`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 1) THEN 1
                    ELSE 0
               END))             AS `passed_tests`
    FROM (((`tests`
        INNER JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        INNER JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
             INNER JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE `artifacts_ip`.`name` = 'codasip_urisc'
      AND `tests`.`tool` = 'compiler'
      AND `tests`.`kind` = 'regression'
    GROUP BY `artifacts`.`created` DESC, `artifacts`.`version`, `artifacts`.`build`, `sources`.`branch`,
             `tests`.`design_path`
    ORDER BY `artifacts`.`created` DESC, `failed_tests` DESC, `passed_tests` DESC;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__urisc_links()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__urisc_links;
    INSERT INTO mv_compiler_regression__urisc_links (`parameters`, `version`, `build_id`, `OS`, `compiler`, `branch`,
                                                     `model_name`, `date`, `test_status`, `link_full`)
    SELECT `tests`.`parameters`         AS `parameters`,
           `artifacts`.`version`        AS `version`,
           `artifacts`.`build`          AS `build_id`,
           `cl_environments`.`os`       AS `OS`,
           `cl_environments`.`compiler` AS `compiler`,
           `sources`.`branch`           AS `branch`,
           `tests`.`design_path`        AS `model_name`,
           `artifacts`.`created`        AS `date`,
           `cl_status`.`description`    AS `test_status`,
           IF((`tests`.`link` is not null),
              CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                     REPLACE(`tests`.`link`,
                             'mastermind_data/',
                             '')),
              `tests`.`link`)           AS `link_full`
    FROM ((((((`tests`
        inner join `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        inner join `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        inner join `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
        inner join `cl_environments` ON ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
        inner join `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
             inner join `cl_status` ON ((`tests`.`status_id` = `cl_status`.`id`)))
    WHERE (`tests`.`passed` = 0)
      AND (`tests`.`link` IS NOT NULL)
      AND (`tests`.`studio_id` IS NOT NULL)
      AND (`tests`.`tool` = 'compiler')
      AND (`tests`.`kind` = 'regression')
      AND (`artifacts_ip`.`name` = 'codasip_urisc')
    ORDER BY `artifacts`.`created` DESC;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__urisc_sum_by_build()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__urisc_sum_by_build;
    INSERT INTO mv_compiler_regression__urisc_sum_by_build (`date`, `version_build_id`, `failed_tests_ia`,
                                                            `passed_tests_ia`, `sum_tests_ia`, `failed_tests_ca`,
                                                            `passed_tests_ca`, `sum_tests_ca`)
    select created                                                                                                   as `date`,
           build_id,
           sum(case
                   when passed = 0 and (design_path = 'codasip_urisc.ia' OR design_path = 'codasip_urisc-ia') then count
                   else 0 end)                                                                                       as failed_ia,
           sum(case
                   when passed = 1 and (design_path = 'codasip_urisc.ia' OR design_path = 'codasip_urisc-ia') then count
                   else 0 end)                                                                                       as passed_ia,
           sum(case
                   when design_path = 'codasip_urisc.ia' OR design_path = 'codasip_urisc-ia' then count
                   else 0 end)                                                                                       as total_ia,
           sum(case
                   when passed = 0 and (design_path = 'codasip_urisc.ca' OR design_path = 'codasip_urisc-ca') then count
                   else 0 end)                                                                                       as failed_ca,
           sum(case
                   when passed = 1 and (design_path = 'codasip_urisc.ca' OR design_path = 'codasip_urisc-ca') then count
                   else 0 end)                                                                                       as passed_ca,
           sum(case
                   when design_path = 'codasip_urisc.ca' OR design_path = 'codasip_urisc-ca' then count
                   else 0 end)                                                                                       as total_ca

    from (SELECT artifacts.created,
                 CONCAT_WS('-', artifacts.version, NULL, artifacts.build) AS build_id,
                 design_path,
                 passed,
                 count(passed)                                            as `count`
          FROM (`tests`
                   inner join
               `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`))
                   inner join `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
          WHERE `tests`.`tool` = 'compiler'
            AND `tests`.`kind` = 'regression'
            AND `artifacts_ip`.`name` = 'codasip_urisc'
          GROUP BY artifacts.created, build_id, design_path, passed) as t
    group by created, build_id;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__uvliw_by_branch()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__uvliw_by_branch;

    INSERT INTO mv_compiler_regression__uvliw_by_branch (date, version, build_id, ip_name, branch, failed_tests, passed_tests)
    SELECT `artifacts`.`created` AS `Date`,
           `artifacts`.`version` AS `Version`,
           `artifacts`.`build`   AS `Revision`,
           `tests`.`design_path` AS `IP Name`,
           `sources`.`branch`    AS `IP Branch`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 0) THEN 1
                    ELSE 0
               END))             AS `Failed Tests`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 1) THEN 1
                    ELSE 0
               END))             AS `Passed Tests`
    FROM (((`tests`
        INNER JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        INNER JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
             INNER JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE `artifacts_ip`.`name` = 'codasip_uvliw'
      AND `tests`.`tool` = 'compiler'
      AND `tests`.`kind` = 'regression'
    GROUP BY `artifacts`.`created` DESC, `artifacts`.`version`, `artifacts`.`build`, `sources`.`branch`,
             `tests`.`design_path`
    ORDER BY `artifacts`.`created` DESC, `failed tests` DESC, `passed tests` DESC;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__uvliw_links()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__uvliw_links;
    INSERT INTO mv_compiler_regression__uvliw_links (`parameters`, `version`, `build_id`, `OS`, `compiler`, `branch`,
                                                     `date`, `test_status`, `link_full`)
    SELECT `tests`.`parameters`         AS `parameters`,
           `artifacts`.`version`        AS `version`,
           `artifacts`.`build`          AS `build_id`,
           `cl_environments`.`os`       AS `OS`,
           `cl_environments`.`compiler` AS `compiler`,
           `sources`.`branch`           AS `branch`,
           `artifacts`.`created`        AS `date`,
           `cl_status`.`description`    AS `test_status`,
           IF((`tests`.`link` is not null),
              CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                     REPLACE(`tests`.`link`,
                             'mastermind_data/',
                             '')),
              `tests`.`link`)           AS `link_full`
    FROM ((((((`tests`
        INNER JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        inner join `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        inner join `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
        inner join `cl_environments` ON ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
        inner join `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
             inner join `cl_status` ON ((`tests`.`status_id` = `cl_status`.`id`)))
    WHERE (`tests`.`passed` = 0)
      AND (`tests`.`link` IS NOT NULL)
      AND (`tests`.`tool` = 'compiler')
      AND (`tests`.`kind` = 'regression')
      AND (`artifacts_ip`.`name` LIKE 'codasip_uvliw')
    ORDER BY `artifacts`.`created` DESC;
    COMMIT;
END $$


create
    definer = rklem@localhost procedure refresh_new_mv_compiler_regression__uvliw_sum_by_build()
BEGIN
    START TRANSACTION;
    truncate mv_compiler_regression__uvliw_sum_by_build;
    INSERT INTO mv_compiler_regression__uvliw_sum_by_build (`date`, `version_build_id`, `failed_tests_ia`,
                                                            `passed_tests_ia`, `sum_tests_ia`, `failed_tests_ca`,
                                                            `passed_tests_ca`, `sum_tests_ca`)
    SELECT `artifacts`.`created`                                            AS `date`,
           CONCAT_WS('-', `artifacts`.`version`, NULL, `artifacts`.`build`) AS `build_id`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 0 AND
                          (`tests`.`design_path` = 'codasip_uvliw.ia' OR `tests`.`design_path` = 'codasip_uvliw-ia'))
                        THEN 1
                    ELSE 0
               END))                                                        AS `failed_tests_ia`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 1 AND
                          (`tests`.`design_path` = 'codasip_uvliw.ia' OR `tests`.`design_path` = 'codasip_uvliw-ia'))
                        THEN 1
                    ELSE 0
               END))                                                        AS `passed_tests_ia`,
           SUM((CASE
                    WHEN `tests`.`design_path` = 'codasip_uvliw.ia' OR `tests`.`design_path` = 'codasip_uvliw-ia' THEN 1
                    ELSE 0
               END))                                                        AS `sum_tests_ia`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 0 AND
                          (`tests`.`design_path` = 'codasip_uvliw.ca' OR `tests`.`design_path` = 'codasip_uvliw-ca'))
                        THEN 1
                    ELSE 0
               END))                                                        AS `failed_tests_ca`,
           SUM((CASE
                    WHEN (`tests`.`passed` = 1 AND
                          (`tests`.`design_path` = 'codasip_uvliw.ca' OR `tests`.`design_path` = 'codasip_uvliw-ca'))
                        THEN 1
                    ELSE 0
               END))                                                        AS `passed_tests_ca`,
           SUM((CASE
                    WHEN `tests`.`design_path` = 'codasip_uvliw.ca' OR `tests`.`design_path` = 'codasip_uvliw-ca' THEN 1
                    ELSE 0
               END))                                                        AS `sum_tests_ca`

    FROM (`tests`
             inner join `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`))
             inner join `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`))
             inner join `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE (`tests`.`tool` = 'compiler')
      AND (`tests`.`kind` = 'regression')
      AND (`artifacts_ip`.`name` LIKE 'codasip_uvliw')
    GROUP BY `artifacts`.`created`, `build_id`;
    COMMIT;
END $$


drop procedure if exists refresh_wrapper;
create
    definer = rklem@localhost procedure refresh_wrapper(IN proc1 varchar(100))
BEGIN
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE continue HANDLER FOR SQLEXCEPTION

        -- following block catches return code and message
        BEGIN
            GET DIAGNOSTICS CONDITION 1 code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;

    -- make command
    SET @command = CONCAT('call ', proc1, '();');
    PREPARE command_to_exec FROM @command;

    set @start_time = now();
    execute command_to_exec;
    set @duration = timediff(now(), @start_time);

    -- if everything was OK, code is 0, set success msg
    IF code = '00000' THEN
        SET msg = ('successful refresher run');
    END IF;

    START TRANSACTION; -- safe write, when error occurs, undo operation is done
    INSERT INTO `refresh_events_log` (`date_and_time`, `procedure_name`, `mysql_return_code`, `message`, `duration`)
    SELECT CAST(NOW() as datetime) as 'date and time',
           proc1                   as 'procedure name',
           code                    as 'mysql return code',
           msg                     as 'message',
           @duration               as 'duration'
    order by `date and time` desc;
    COMMIT; -- push what we have selected
    DEALLOCATE PREPARE command_to_exec;
END $$

delimiter ;