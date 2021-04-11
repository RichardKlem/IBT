delimiter $$
create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__berkelium_by_configuration()
BEGIN
START TRANSACTION;
  DELETE FROM mv_tests_compiler_regression__berkelium_by_configuration;
  INSERT INTO mv_tests_compiler_regression__berkelium_by_configuration (`date`,`version`,`build_id`,`model_name`,`configuration`,`ip_branch`,`failed_tests`,`passed_tests`)
    SELECT
    `artifacts`.`created` AS `Date`,
    `artifacts`.`version` AS `version`,
    `artifacts`.`build` AS `build _id`,
    `tests`.`design_path` AS `model_name`,
    `artifacts_ip`.`configuration` AS `configuration`,
    `sources`.`branch` AS `ip_branch`,
    SUM((CASE
        WHEN (`tests`.`passed` = 0) THEN 1
        ELSE 0
    END)) AS `Failed Tests`,
    SUM((CASE
        WHEN (`tests`.`passed` = 1) THEN 1
        ELSE 0
    END)) AS `Passed Tests`
FROM
    (((`tests`
    JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
    JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
    JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
WHERE
    `artifacts_ip`.`name` = 'codix_berkelium'
        AND `tests`.`tool` = 'compiler'
        AND `tests`.`kind` = 'regression'
GROUP BY `artifacts`.`created` DESC , `artifacts`.`version` , `artifacts`.`build` , `tests`.`design_path` , `artifacts_ip`.`configuration`, `artifacts_ip`.`configuration`,`sources`.`branch`
ORDER BY `artifacts`.`created` DESC , `failed tests` DESC , `passed tests` DESC;
COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__berkelium_fails_links()
BEGIN
START TRANSACTION;
DELETE FROM mv_tests_compiler_regression__berkelium_fails_links;
  INSERT INTO mv_tests_compiler_regression__berkelium_fails_links (`branch`,`date`,`version`,`build_id`,`OS`,`compiler`, `model_name`,`configuration`,`parameters`,`test_status`,`link_full`)
    SELECT
		`sources`.`branch`					 AS `branch`,
        `artifacts`.`created`                AS `date`,
        `artifacts`.`version`                AS `version`,
        `artifacts`.`build`                  AS `build_id`,
        `cl_environments`.`os`               AS `OS`,
        `cl_environments`.`compiler`         AS `compiler`,
		`tests`.`design_path`                AS `model_name`,
        `artifacts_ip`.`configuration`       AS `configuration`,
        `tests`.`parameters`                 AS `parameters`,
		`cl_status`.`description`            AS `test_status`,
        IF((`tests`.`link` <> 'NULL'),
            CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                    REPLACE(`tests`.`link`,
                        'mastermind_data/',
                        '')),
            `tests`.`link`)                  AS `link_full`
    FROM
        ((((((`tests`
        LEFT JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        LEFT JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        LEFT JOIN `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
		LEFT JOIN `cl_environments` ON ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
		LEFT JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
        LEFT JOIN `cl_status` ON  ((`tests`.`status_id` = `cl_status`.`id`)))
    WHERE
		(`tests`.`passed` = 0) AND
		(`tests`.`link` IS NOT NULL) AND
		(`tests`.`studio_id` IS NOT NULL) AND
        (`tests`.`tool` = 'compiler') AND
        (`tests`.`kind` = 'regression') AND
        (`artifacts_ip`.`name` = 'codix_berkelium')
    ORDER BY `artifacts`.`created` DESC;
    COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__berkelium_sum_by_build()
BEGIN
  START TRANSACTION;
  DELETE FROM mv_tests_compiler_regression__berkelium_sum_by_build;
  INSERT INTO mv_tests_compiler_regression__berkelium_sum_by_build (`date`,`version_and_build_id`,`failed_tests_ia`,`passed_tests_ia`,`sum_tests_ia`,`failed_tests_ca`,`passed_tests_ca`,`sum_tests_ca`)
    SELECT
        `artifacts`.`created` AS `date`,
        CONCAT_WS('-',
                `artifacts`.`version`,
                NULL,
                `artifacts`.`build`) AS `build_id`,
        SUM((CASE
            WHEN
                ((`tests`.`passed` = 0)
                    AND (`tests`.`design_path` LIKE '%ia'))
            THEN
                1
            ELSE 0
        END)) AS `failed_tests_ia`,
        SUM((CASE
            WHEN
                ((`tests`.`passed` = 1)
                    AND (`tests`.`design_path` LIKE '%ia'))
            THEN
                1
            ELSE 0
        END)) AS `passed_tests_ia`,
        SUM((CASE
            WHEN
                (((`tests`.`passed` = 1)
                    OR (`tests`.`passed` = 0))
                    AND (`tests`.`design_path` LIKE '%ia'))
            THEN
                1
            ELSE 0
        END)) AS `sum_tests_ia`,
        SUM((CASE
            WHEN
                ((`tests`.`passed` = 0)
                    AND (`tests`.`design_path` LIKE '%ca'))
            THEN
                1
            ELSE 0
        END)) AS `failed_tests_ca`,
        SUM((CASE
            WHEN
                ((`tests`.`passed` = 1)
                    AND (`tests`.`design_path` like '%ca'))
            THEN
                1
            ELSE 0
        END)) AS `passed_tests_ca`,
        SUM((CASE
            WHEN
                (((`tests`.`passed` = 1)
                    OR (`tests`.`passed` = 0))
                    AND (`tests`.`design_path` LIKE '%ca'))
            THEN
                1
            ELSE 0
        END)) AS `sum_tests_ca`
    FROM
        (((`tests`
        LEFT JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        LEFT JOIN `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
        LEFT JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE
        ((`tests`.`tool` = 'compiler')
            AND (`tests`.`kind` = 'regression')
            AND (`artifacts_ip`.`name` = 'codix_berkelium'))
    GROUP BY `artifacts`.`created`, `build_id`;
    COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__codix_by_ip()
BEGIN
	START TRANSACTION;
	DELETE FROM mv_tests_compiler_regression__codix_by_ip;
	INSERT INTO mv_tests_compiler_regression__codix_by_ip (`date`, `version`, `build_id`, `ip_name`, `ip_branch`, `failed_tests`, `passed_tests`)
		select
		    `artifacts`.`created` AS `date`,
		    `artifacts`.`version` AS `version`,
		    `artifacts`.`build` AS `build_id`,
		    `tests`.`design_path` AS `ip_name`,
		    `sources`.`branch` AS `ip_branch`,
		    sum((case when (`tests`.`passed` = 0) then 1 else 0 end)) AS `failed_tests`,
		    sum((case when (`tests`.`passed` = 1) then 1 else 0 end)) AS `passed_tests`
		from
		    (((`tests`
		join `sources` on
		    ((`tests`.`ip_id` = `sources`.`artifact_id`)))
		join `artifacts` on
		    ((`tests`.`studio_id` = `artifacts`.`id`)))
		join `artifacts_ip` on
		    ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
		where
		    ((`artifacts_ip`.`name` like '%codix%')
		    and (not((`artifacts_ip`.`name` like '%helium%')))
		    and (not((`artifacts_ip`.`name` like '%berkelium%')))
		    and (`tests`.`tool` = 'compiler')
		    and (`tests`.`kind` = 'regression'))
		group by
		    `date` desc,
		    `artifacts`.`version`,
		    `artifacts`.`build`,
		    `sources`.`branch`,
		    `tests`.`design_path`
		order by
		    `date` desc,
		    `failed_tests` desc,
		    `passed_tests` desc;
COMMIT;
END $$

create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__codix_fails_links()
BEGIN
START TRANSACTION;
DELETE FROM mv_tests_compiler_regression__codix_fails_links;
  INSERT INTO mv_tests_compiler_regression__codix_fails_links (`date`,`parameters`, `version`,`build_id`,`os`,`compiler`,`ip_name`, `test_status`,`link_full`)
    select
    `artifacts`.`created` AS `date`,
    `tests`.`parameters` AS `parameters`,
    `artifacts`.`version` AS `version`,
    `artifacts`.`build` AS `build_id`,
    `cl_environments`.`os` AS `os`,
    `cl_environments`.`compiler` AS `compiler`,
    `artifacts_ip`.`name` AS `ip_name`,
    `cl_status`.`description` AS `test_status`,
    if((`tests`.`link` <> 'NULL'),
    concat('https://codasip3.codasip.com/~jenkinsdata/', replace(`tests`.`link`, 'mastermind_data/', '')),
    `tests`.`link`) AS `link_full`
	from
	    ((((((`tests`
	left join `artifacts` on
	    ((`tests`.`studio_id` = `artifacts`.`id`)))
	left join `sources` on
	    ((`tests`.`ip_id` = `sources`.`artifact_id`)))
	left join `artifacts_studio` on
	    ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
	left join `cl_environments` on
	    ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
	left join `artifacts_ip` on
	    ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
	left join `cl_status` on
	    ((`tests`.`status_id` = `cl_status`.`id`)))
	where
	    ((`tests`.`passed` = 0)
	    and (`tests`.`link` is not null)
	    and (`tests`.`studio_id` is not null)
	    and (`tests`.`tool` = 'compiler')
	    and (`tests`.`kind` = 'regression')
	    and (`artifacts_ip`.`name` like '%codix%')
	    and (not((`artifacts_ip`.`name` like '%helium%')))
	    and (not((`artifacts_ip`.`name` like '%berkelium%'))))
	order by
	    `artifacts`.`created` desc;
    COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__customer_by_ip()
BEGIN
	START TRANSACTION;
	DELETE FROM mv_tests_compiler_regression__customer_by_ip;
	INSERT INTO mv_tests_compiler_regression__customer_by_ip (`date`, `version`, `build_id`, `ip_name`, `ip_branch`, `failed_tests`, `passed_tests`)
		select
	    `artifacts`.`created` AS `date`,
	    `artifacts`.`version` AS `version`,
	    `artifacts`.`build` AS `build_id`,
	    `tests`.`design_path` AS `ip_name`,
	    `sources`.`branch` AS `ip_branch`,
	    sum((case when (`tests`.`passed` = 0) then 1 else 0 end)) AS `failed_tests`,
	    sum((case when (`tests`.`passed` = 1) then 1 else 0 end)) AS `passed_tests`
		from
		    (((`tests`
		join `sources` on
		    ((`tests`.`ip_id` = `sources`.`artifact_id`)))
		join `artifacts` on
		    ((`tests`.`studio_id` = `artifacts`.`id`)))
		join `artifacts_ip` on
		    ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
		where
		    ((`artifacts_ip`.`name` like '%sigma%')
		    and (`tests`.`tool` = 'compiler')
		    and (`tests`.`kind` = 'regression'))
		group by
		    `artifacts`.`created` desc,
		    `artifacts`.`version`,
		    `artifacts`.`build`,
		    `sources`.`branch`,
		    `tests`.`design_path`
		order by
		    `artifacts`.`created` desc,
		    `failed_tests` desc,
		    `passed_tests` desc;
COMMIT;
END $$

create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__customer_fails_links()
BEGIN
START TRANSACTION;
DELETE FROM mv_tests_compiler_regression__customer_fails_links;
  INSERT INTO mv_tests_compiler_regression__customer_fails_links (`date`,`parameters`, `version`,`build_id`,`os`,`compiler`, `branch`,`ip_name`, `test_status`,`link_full`)
    select
    `artifacts`.`created` AS `date`,
    `tests`.`parameters` AS `parameters`,
    `artifacts`.`version` AS `version`,
    `artifacts`.`build` AS `build_id`,
    `cl_environments`.`os` AS `os`,
    `cl_environments`.`compiler` AS `compiler`,
    `sources`.`branch` AS `branch`,
    `artifacts_ip`.`name` AS `ip_name`,
    `cl_status`.`description` AS `test_status`,
    if((`tests`.`link` <> 'NULL'),
    concat('https://codasip3.codasip.com/~jenkinsdata/', replace(`tests`.`link`, 'mastermind_data/', '')),
    `tests`.`link`) AS `link_full`
	from
	    ((((((`tests`
		left join `artifacts` on
		    ((`tests`.`studio_id` = `artifacts`.`id`)))
		left join `sources` on
		    ((`tests`.`ip_id` = `sources`.`artifact_id`)))
		left join `artifacts_studio` on
		    ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
		left join `cl_environments` on
		    ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
		left join `artifacts_ip` on
		    ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
		left join `cl_status` on
		    ((`tests`.`status_id` = `cl_status`.`id`)))
	where
	    ((`tests`.`passed` = 0)
	    and (`tests`.`link` is not null)
	    and (`tests`.`studio_id` is not null)
	    and (`tests`.`tool` = 'compiler')
	    and (`tests`.`kind` = 'regression')
	    and (`artifacts_ip`.`name` like '%sigma%'))
	order by
	    `artifacts`.`created` desc;
    COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__helium_by_configuration()
BEGIN
  START TRANSACTION;
  DELETE FROM mv_tests_compiler_regression__helium_by_configuration;
  INSERT INTO mv_tests_compiler_regression__helium_by_configuration (`date`,`version`,`build_id`,`ip_name`,`configuration`,`failed_tests`,`passed_tests`)
    SELECT
    `artifacts`.`created` AS `Date`,
    `artifacts`.`version` AS `Version`,
    `artifacts`.`build` AS `Build ID`,
	`tests`.`design_path` AS `IP Name`,
    `artifacts_ip`.`configuration` AS `Configuration`,
    SUM((CASE
        WHEN (`tests`.`passed` = 0) THEN 1
        ELSE 0
    END)) AS `Failed Tests`,
    SUM((CASE
        WHEN (`tests`.`passed` = 1) THEN 1
        ELSE 0
    END)) AS `Passed Tests`
FROM
    (((`tests`
    JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
    JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
    JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
WHERE
    `artifacts_ip`.`name` = 'codix_helium'
        AND `tests`.`tool` = 'compiler'
        AND `tests`.`kind` = 'regression'
GROUP BY `artifacts`.`created` DESC , `artifacts`.`version` , `artifacts`.`build` , `tests`.`design_path` , `artifacts_ip`.`configuration`
ORDER BY `artifacts`.`created` DESC , `failed tests` DESC , `passed tests` DESC;
  COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__helium_fails_links()
BEGIN
START TRANSACTION;
  DELETE FROM mv_tests_compiler_regression__helium_fails_links;
  INSERT INTO mv_tests_compiler_regression__helium_fails_links (`parameters`,`version`,`build_id`,`OS`,`compiler`,`configuration`,`date`, `test_status`,`link_full`)
    SELECT
        `tests`.`parameters` AS `parameters`,
        `artifacts`.`version` AS `version`,
        `artifacts`.`build` AS `build_id`,
        `cl_environments`.`os` AS `OS`,
        `cl_environments`.`compiler` AS `compiler`,
        `artifacts_ip`.`configuration` AS `configuration`,
        DATE_FORMAT(`artifacts`.`created`, '%Y-%m-%d') AS `date`,
		`cl_status`.`description` AS `test_status`,

        IF((`tests`.`link` <> 'NULL'),
            CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                    REPLACE(`tests`.`link`,
                        'mastermind_data/',
                        '')),
            `tests`.`link`) AS `link_full`
    FROM
        ((((((`tests`
        LEFT JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        LEFT JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
        LEFT JOIN `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
		LEFT JOIN `cl_environments` ON ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
		LEFT JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
        LEFT JOIN `cl_status` ON  ((`tests`.`status_id` = `cl_status`.`id`)))
    WHERE
		(`tests`.`passed` = 0) AND
		(`tests`.`link` IS NOT NULL) AND
		(`tests`.`studio_id` IS NOT NULL) AND
        (`tests`.`tool` = 'compiler') AND
        (`tests`.`kind` = 'regression') AND
        (`artifacts_ip`.`name` = 'codix_helium')
    ORDER BY `artifacts`.`created` DESC;
  COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__helium_sum_by_build()
BEGIN
START TRANSACTION;
  DELETE FROM mv_tests_compiler_regression__helium_sum_by_build;
  INSERT INTO mv_tests_compiler_regression__helium_sum_by_build (`date`,`version_and_build_id`,`failed_tests_ia`,`passed_tests_ia`,`sum_tests_ia`,`failed_tests_ca`,`passed_tests_ca`,`sum_tests_ca`)
    SELECT
        `artifacts`.`created` AS `date`,
        CONCAT_WS('-',
                `artifacts`.`version`,
                NULL,
                `artifacts`.`build`) AS `build_id`,
        SUM((CASE
            WHEN
                ((`tests`.`passed` = 0)
                    AND (`tests`.`design_path` LIKE '%ia'))
            THEN
                1
            ELSE 0
        END)) AS `failed_tests_ia`,
        SUM((CASE
            WHEN
                ((`tests`.`passed` = 1)
                    AND (`tests`.`design_path` LIKE '%ia'))
            THEN
                1
            ELSE 0
        END)) AS `passed_tests_ia`,
        SUM((CASE
            WHEN
                (((`tests`.`passed` = 1)
                    OR (`tests`.`passed` = 0))
                    AND (`tests`.`design_path` LIKE '%ia'))
            THEN
                1
            ELSE 0
        END)) AS `sum_tests_ia`,
        SUM((CASE
            WHEN
                ((`tests`.`passed` = 0)
                    AND (`tests`.`design_path` LIKE '%ca'))
            THEN
                1
            ELSE 0
        END)) AS `failed_tests_ca`,
        SUM((CASE
            WHEN
                ((`tests`.`passed` = 1)
                    AND (`tests`.`design_path` LIKE '%ca'))
            THEN
                1
            ELSE 0
        END)) AS `passed_tests_ca`,
        SUM((CASE
            WHEN
                (((`tests`.`passed` = 1)
                    OR (`tests`.`passed` = 0))
                    AND (`tests`.`design_path` LIKE '%ca'))
            THEN
                1
            ELSE 0
        END)) AS `sum_tests_ca`
    FROM
        (((`tests`
        LEFT JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
        LEFT JOIN `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
        LEFT JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
    WHERE
        ((`tests`.`tool` = 'compiler')
            AND (`tests`.`kind` = 'regression')
            AND (`artifacts_ip`.`name` = 'codix_helium'))
    GROUP BY `artifacts`.`created`, `build_id`;
  COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__urisc_by_branch()
BEGIN
	START TRANSACTION;
	DELETE FROM mv_tests_compiler_regression__urisc_by_branch;

	INSERT INTO mv_tests_compiler_regression__urisc_by_branch (`date`,version,build_id,model_name,branch,failed_tests,passed_tests)
	SELECT
		`artifacts`.`created` AS `Date`,
		`artifacts`.`version` AS `version`,
		`artifacts`.`build` AS `revision`,
		`tests`.`design_path` AS `model_name`,
		`sources`.`branch` AS `ip_branch`,
		SUM((CASE
			WHEN (`tests`.`passed` = 0) THEN 1
			ELSE 0
		END)) AS `failed_tests`,
		SUM((CASE
			WHEN (`tests`.`passed` = 1) THEN 1
			ELSE 0
		END)) AS `passed_tests`
	FROM
		(((`tests`
		JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
		JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
		JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
	WHERE `artifacts_ip`.`name` = 'codasip_urisc' AND `tests`.`tool` = 'compiler' AND `tests`.`kind` = 'regression'
	GROUP BY  `artifacts`.`created` DESC , `artifacts`.`version` , `artifacts`.`build` , `sources`.`branch`, `tests`.`design_path`
	ORDER BY  `artifacts`.`created` DESC ,`failed_tests` DESC,`passed_tests` DESC;
	COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__urisc_fails_links()
BEGIN
	START TRANSACTION;
	DELETE FROM mv_tests_compiler_regression__urisc_fails_links;
	INSERT INTO mv_tests_compiler_regression__urisc_fails_links (`parameters`,`version`,`build_id`,`OS`,`compiler`,`branch`, `model_name`,`date`, `test_status`,`link_full`)
	SELECT
		`tests`.`parameters` AS `parameters`,
		`artifacts`.`version` AS `version`,
		`artifacts`.`build` AS `build_id`,
		`cl_environments`.`os` AS `OS`,
		`cl_environments`.`compiler` AS `compiler`,
		`sources`.`branch` AS `branch`,
        		`tests`.`design_path` AS `model_name`,
		`artifacts`.`created` AS `date`,
        `cl_status`.`description` AS `test_status`,
		IF((`tests`.`link` <> 'NULL'),
			CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
					REPLACE(`tests`.`link`,
						'mastermind_data/',
						'')),
			`tests`.`link`) AS `link_full`
	FROM
		((((((`tests`
		LEFT JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
		LEFT JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
		LEFT JOIN `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
		LEFT JOIN `cl_environments` ON ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
		LEFT JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
        LEFT JOIN `cl_status` ON  ((`tests`.`status_id` = `cl_status`.`id`)))
	WHERE
		(`tests`.`passed` = 0) AND
		(`tests`.`link` IS NOT NULL) AND
		(`tests`.`studio_id` IS NOT NULL) AND
		(`tests`.`tool` = 'compiler') AND
		(`tests`.`kind` = 'regression') AND
		(`artifacts_ip`.`name` = 'codasip_urisc')
	ORDER BY `artifacts`.`created` DESC;
	COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__urisc_sum_by_build()
BEGIN
	START TRANSACTION;
	DELETE FROM mv_tests_compiler_regression__urisc_sum_by_build;
	INSERT INTO mv_tests_compiler_regression__urisc_sum_by_build (`date`,`version_and_build_id`,`failed_tests_ia`,`passed_tests_ia`,`sum_tests_ia`,`failed_tests_ca`,`passed_tests_ca`,`sum_tests_ca`)
	 SELECT
		`artifacts`.`created` AS `date`,
		CONCAT_WS('-',`artifacts`.`version`,NULL,`artifacts`.`build`) AS `build_id`,
		SUM((CASE
			WHEN (`tests`.`passed` = 0 AND (`tests`.`design_path` LIKE '%ia')) THEN 1
			ELSE 0
		END)) AS `failed_tests_ia`,
		SUM((CASE
			WHEN (`tests`.`passed` = 1 AND (`tests`.`design_path` LIKE '%ia')) THEN 1
			ELSE 0
		END)) AS `passed_tests_ia`,
		SUM((CASE
			WHEN ((`tests`.`passed` = 1 OR `tests`.`passed` = 0) AND (`tests`.`design_path` LIKE '%ia' )) THEN 1
			ELSE 0
		END)) AS `sum_tests_ia`,
		SUM((CASE
			WHEN (`tests`.`passed` = 0 AND (`tests`.`design_path` LIKE '%ca')) THEN 1
			ELSE 0
		END)) AS `failed_tests_ca`,
		SUM((CASE
			WHEN (`tests`.`passed` = 1 AND (`tests`.`design_path` LIKE '%ca')) THEN 1
			ELSE 0
		END)) AS `passed_tests_ca`,
		SUM((CASE
			WHEN ((`tests`.`passed` = 1 OR `tests`.`passed` = 0) AND (`tests`.`design_path` LIKE '%ca')) THEN 1
			ELSE 0
		END)) AS `sum_tests_ca`

	FROM
		(`tests`
		LEFT JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`))
		LEFT JOIN `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`))
		LEFT JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
	WHERE
		(`tests`.`tool` = 'compiler') AND
		(`tests`.`kind` = 'regression') AND
		(`artifacts_ip`.`name` = 'codasip_urisc')
	GROUP BY `artifacts`.`created`, `build_id`;
	COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__uvliw_by_branch()
BEGIN
	START TRANSACTION;
		DELETE FROM mv_tests_compiler_regression__uvliw_by_branch;

		INSERT INTO mv_tests_compiler_regression__uvliw_by_branch (date, version, build_id, ip_name, branch, failed_tests, passed_tests)
			SELECT
				`artifacts`.`created` AS `Date`,
				`artifacts`.`version` AS `Version`,
				`artifacts`.`build` AS `Revision`,
				`tests`.`design_path` AS `IP Name`,
				`sources`.`branch` AS `IP Branch`,
				SUM((CASE
					WHEN (`tests`.`passed` = 0) THEN 1
					ELSE 0
				END)) AS `Failed Tests`,
				SUM((CASE
					WHEN (`tests`.`passed` = 1) THEN 1
					ELSE 0
				END)) AS `Passed Tests`
			FROM
				(((`tests`
				JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
				JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
				JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
			WHERE `artifacts_ip`.`name` LIKE '%codasip_uvliw%' AND `tests`.`tool` = 'compiler' AND `tests`.`kind` = 'regression'
			GROUP BY  `artifacts`.`created` DESC , `artifacts`.`version` , `artifacts`.`build` , `sources`.`branch`, `tests`.`design_path`
			ORDER BY  `artifacts`.`created` DESC ,`failed tests` DESC,`passed tests` DESC;
    COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__uvliw_fails_links()
BEGIN
	START TRANSACTION;
	DELETE FROM mv_tests_compiler_regression__uvliw_fails_links;
	INSERT INTO mv_tests_compiler_regression__uvliw_fails_links (`parameters`,`version`,`build_id`,`OS`,`compiler`,`branch`,`date`,`test_status`,`link_full`)
		SELECT
			`tests`.`parameters` AS `parameters`,
			`artifacts`.`version` AS `version`,
			`artifacts`.`build` AS `build_id`,
			`cl_environments`.`os` AS `OS`,
			`cl_environments`.`compiler` AS `compiler`,
			`sources`.`branch` AS `branch`,
			`artifacts`.`created` AS `date`,
            `cl_status`.`description` AS `test_status`,
			IF((`tests`.`link` <> 'NULL'),
				CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
						REPLACE(`tests`.`link`,
							'mastermind_data/',
							'')),
				`tests`.`link`) AS `link_full`
		FROM
			((((((`tests`
			INNER JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`)))
			LEFT JOIN `sources` ON ((`tests`.`ip_id` = `sources`.`artifact_id`)))
			LEFT JOIN `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`)))
			LEFT JOIN `cl_environments` ON ((`artifacts_studio`.`environment_id` = `cl_environments`.`id`)))
			LEFT JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
            LEFT JOIN `cl_status` ON  ((`tests`.`status_id` = `cl_status`.`id`)))
		WHERE
			(`tests`.`passed` = 0) AND
			(`tests`.`link` IS NOT NULL) AND
			(`tests`.`studio_id` IS NOT NULL) AND
			(`tests`.`tool` = 'compiler') AND
			(`tests`.`kind` = 'regression') AND
			(`artifacts_ip`.`name` LIKE '%codasip_uvliw')
		ORDER BY `artifacts`.`created` DESC;
	COMMIT;
END $$


create definer = rklem@localhost procedure refresh_mv_tests_compiler_regression__uvliw_sum_by_build()
BEGIN
	START TRANSACTION;
	DELETE FROM mv_tests_compiler_regression__uvliw_sum_by_build;
	INSERT INTO mv_tests_compiler_regression__uvliw_sum_by_build (`date`,`version_and_build_id`,`failed_tests_ia`,`passed_tests_ia`,`sum_tests_ia`,`failed_tests_ca`,`passed_tests_ca`,`sum_tests_ca`)
		 SELECT
			`artifacts`.`created` AS `date`,
			CONCAT_WS('-',`artifacts`.`version`,NULL,`artifacts`.`build`) AS `build_id`,
			SUM((CASE
				WHEN (`tests`.`passed` = 0 AND (`tests`.`design_path` LIKE '%ia')) THEN 1
				ELSE 0
			END)) AS `failed_tests_ia`,
			SUM((CASE
				WHEN (`tests`.`passed` = 1 AND (`tests`.`design_path` LIKE '%ia')) THEN 1
				ELSE 0
			END)) AS `passed_tests_ia`,
			SUM((CASE
				WHEN ((`tests`.`passed` = 1 OR `tests`.`passed` = 0) AND (`tests`.`design_path` LIKE '%ia')) THEN 1
				ELSE 0
			END)) AS `sum_tests_ia`,
			SUM((CASE
				WHEN (`tests`.`passed` = 0 AND (`tests`.`design_path` LIKE '%ca')) THEN 1
				ELSE 0
			END)) AS `failed_tests_ca`,
			SUM((CASE
				WHEN (`tests`.`passed` = 1 AND (`tests`.`design_path` LIKE '%ca')) THEN 1
				ELSE 0
			END)) AS `passed_tests_ca`,
			SUM((CASE
				WHEN ((`tests`.`passed` = 1 OR `tests`.`passed` = 0) AND (`tests`.`design_path` LIKE '%ca')) THEN 1
				ELSE 0
			END)) AS `sum_tests_ca`

		FROM
			(`tests`
			LEFT JOIN `artifacts` ON ((`tests`.`studio_id` = `artifacts`.`id`))
			LEFT JOIN `artifacts_studio` ON ((`tests`.`studio_id` = `artifacts_studio`.`id`))
			LEFT JOIN `artifacts_ip` ON ((`tests`.`ip_id` = `artifacts_ip`.`id`)))
		WHERE
			(`tests`.`tool` = 'compiler') AND
			(`tests`.`kind` = 'regression') AND
			(`artifacts_ip`.`name` LIKE '%codasip_uvliw%')
		GROUP BY `artifacts`.`created`, `build_id`;
	COMMIT;
END $$


drop procedure if exists refresh_wrapper;
create definer = rklem@localhost procedure refresh_wrapper(IN proc1 varchar(100))
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
    execute command_to_exec;

    -- if everything was OK, code is 0, set success msg
    IF code = '00000' THEN
        SET msg = ('successful refresher run');
    END IF;

    START TRANSACTION; -- safe write, when error occurs, undo operation is done
    INSERT INTO `refresh_events_log` (`date_and_time`, `procedure_name`, `mysql_return_code`, `message`)
    SELECT CAST(NOW() as datetime) as 'date and time',
           proc1 as 'procedure name',
           code as 'mysql return code',
           msg as 'message'
    order by `date and time` desc;
    COMMIT; -- push what we have selected
    DEALLOCATE PREPARE command_to_exec;
END $$

delimiter ;