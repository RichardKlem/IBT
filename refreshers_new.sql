DELIMITER $$
CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__berkelium_by_conf()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__berkelium_conf
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__berkelium_conf) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__berkelium_conf WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__berkelium_conf (date, version, build_id, model_name, configuration,
                                                        ip_branch, failed_tests, passed_tests)
SELECT created                                         AS Date,
       version                                         AS version,
       build                                           AS build_id,
       design_path                                     AS model_name,
       configuration                                   AS configuration,
       branch                                          AS ip_branch,
       sum(CASE WHEN passed = 1 THEN count ELSE 0 END) as passed_tests,
       sum(CASE WHEN passed = 0 THEN count ELSE 0 END) as failed_tests
FROM (
         SELECT artifacts.created,
                artifacts.version,
                artifacts.build,
                tests.design_path,
                artifacts_ip.configuration,
                sources.branch,
                passed,
                count(passed) as count
         FROM (((tests_compiler AS tests
             INNER JOIN artifacts USE INDEX (ix_artifacts_created) ON tests.studio_id = artifacts.id)
             INNER JOIN sources ON tests.ip_id = sources.artifact_id)
                  INNER JOIN artifacts_ip ON tests.ip_id = artifacts_ip.id)
         WHERE DATE(artifacts.created) >= @last_date
           AND artifacts_ip.name = 'codix_berkelium'
         GROUP BY created, version, build, design_path, configuration, branch, passed) as t

GROUP BY created, version, build, design_path, configuration, branch
ORDER BY created DESC, failed_tests DESC, passed_tests DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__berkelium_links()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__berkelium_links
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__berkelium_links) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__berkelium_links WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__berkelium_links (branch, date, version, build_id, OS, compiler,
                                                         model_name, configuration, parameters, test_status,
                                                         link_full)
    SELECT sources.branch             AS branch,
           artifacts.created          AS date,
           artifacts.version          AS version,
           artifacts.build            AS build_id,
           cl_environments.os         AS OS,
           cl_environments.compiler   AS compiler,
           tests.design_path          AS model_name,
           artifacts_ip.configuration AS configuration,
           tests.parameters           AS parameters,
           cl_status.DESCription      AS test_status,
           CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                 REPLACE(tests.link, 'mastermind_data/',''))           AS link_full
    FROM ((((((tests_compiler AS tests
        INNER JOIN artifacts ON ((tests.studio_id = artifacts.id)))
        INNER JOIN sources ON ((tests.ip_id = sources.artifact_id)))
        INNER JOIN artifacts_studio ON ((tests.studio_id = artifacts_studio.id)))
        INNER JOIN cl_environments ON ((artifacts_studio.environment_id = cl_environments.id)))
        INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
             INNER JOIN cl_status ON ((tests.status_id = cl_status.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          tests.passed = 0 AND
          tests.link IS NOT NULL AND
          artifacts_ip.name = 'codix_berkelium'
    ORDER BY artifacts.created DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__berkelium_sum_by_build()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__berkelium_sum_by_build
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__berkelium_sum_by_build) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__berkelium_sum_by_build WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__berkelium_sum_by_build (date, version_build_id, failed_tests_ia,
                                                                passed_tests_ia, sum_tests_ia, failed_tests_ca,
                                                                passed_tests_ca, sum_tests_ca)
    SELECT artifacts.created          AS date,
           CONCAT_WS('-',
                     artifacts.version,
                     NULL,
                     artifacts.build) AS build_id,
           SUM((CASE
                    WHEN tests.passed = 0 AND tests.design_path = 'codix_berkelium-ia'
                        THEN 1
                    ELSE 0
               END))                  AS failed_tests_ia,
           SUM((CASE
                    WHEN tests.passed = 1 AND tests.design_path = 'codix_berkelium-ia'
                        THEN 1
                    ELSE 0
               END))                  AS passed_tests_ia,
           SUM((CASE
                    WHEN tests.design_path = 'codix_berkelium-ia'
                        THEN 1
                    ELSE 0
               END))                  AS sum_tests_ia,
           SUM((CASE
                    WHEN tests.passed = 0 AND tests.design_path = 'codix_berkelium-ca'
                        THEN 1
                    ELSE 0
               END))                  AS failed_tests_ca,
           SUM((CASE
                    WHEN tests.passed = 1 AND tests.design_path = 'codix_berkelium-ca'
                        THEN 1
                    ELSE 0
               END))                  AS passed_tests_ca,
           SUM((CASE
                    WHEN tests.design_path = 'codix_berkelium-ca'
                        THEN 1
                    ELSE 0
               END))                  AS sum_tests_ca
    FROM (((tests_compiler AS tests
        INNER JOIN artifacts USE INDEX (ix_artifacts_created) ON tests.studio_id = artifacts.id)
        INNER JOIN artifacts_studio ON tests.studio_id = artifacts_studio.id)
             INNER JOIN artifacts_ip ON tests.ip_id = artifacts_ip.id)
    WHERE DATE(artifacts.created) >= @last_date AND
          artifacts_ip.name = 'codix_berkelium'
    GROUP BY artifacts.created, build_id;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__codix_by_ip()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__codix_by_ip
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__codix_by_ip) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__codix_by_ip WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__codix_by_ip (date, version, build_id, ip_name, ip_branch,
                                                     failed_tests, passed_tests)
    SELECT artifacts.created                                     AS date,
           artifacts.version                                     AS version,
           artifacts.build                                       AS build_id,
           tests.design_path                                     AS ip_name,
           sources.branch                                        AS ip_branch,
           sum((CASE WHEN (tests.passed = 0) THEN 1 ELSE 0 END)) AS failed_tests,
           sum((CASE WHEN (tests.passed = 1) THEN 1 ELSE 0 END)) AS passed_tests
    FROM (((tests_compiler AS tests
        INNER JOIN artifacts ON tests.studio_id = artifacts.id)
        INNER JOIN sources ON tests.ip_id = sources.artifact_id)
        INNER JOIN artifacts_ip ON tests.ip_id = artifacts_ip.id)
    WHERE DATE(artifacts.created) >= @last_date AND
          (artifacts_ip.name = 'codix_cobalt' OR artifacts_ip.name = 'codix_titanium')
    GROUP BY artifacts.created,
             artifacts.version,
             artifacts.build,
             sources.branch,
             tests.design_path
    ORDER BY artifacts.created DESC,
             failed_tests DESC,
             passed_tests DESC;
    COMMIT;
END $$

CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__codix_links()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__codix_links
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__codix_links) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__codix_links WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__codix_links (date, parameters, version, build_id, os, compiler,
                                                     ip_name, test_status, link_full)
    SELECT artifacts.created                                   AS date,
           tests.parameters                                    AS parameters,
           artifacts.version                                   AS version,
           artifacts.build                                     AS build_id,
           cl_environments.os                                  AS os,
           cl_environments.compiler                            AS compiler,
           artifacts_ip.name                                   AS ip_name,
           cl_status.DESCription                               AS test_status,
           concat('https://codasip3.codasip.com/~jenkinsdata/',
                  replace(tests.link, 'mastermind_data/', '')) AS link_full
    FROM ((((((
        tests_compiler AS tests
            INNER JOIN artifacts ON tests.studio_id = artifacts.id)
        INNER JOIN sources ON tests.ip_id = sources.artifact_id)
        INNER JOIN artifacts_studio ON tests.studio_id = artifacts_studio.id)
        INNER JOIN cl_environments ON artifacts_studio.environment_id = cl_environments.id)
        INNER JOIN artifacts_ip ON tests.ip_id = artifacts_ip.id)
             INNER JOIN cl_status ON tests.status_id = cl_status.id)
    WHERE DATE(artifacts.created) >= @last_date AND
          tests.passed = 0 AND
          tests.link IS NOT NULL AND
          (artifacts_ip.name = 'codix_cobalt' OR artifacts_ip.name = 'codix_titanium')
    ORDER BY artifacts.created DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__custom_by_ip()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__custom_by_ip
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__custom_by_ip) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__custom_by_ip WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__custom_by_ip (date, version, build_id, ip_name, ip_branch,
                                                      failed_tests, passed_tests)
    SELECT artifacts.created                                     AS date,
           artifacts.version                                     AS version,
           artifacts.build                                       AS build_id,
           tests.design_path                                     AS ip_name,
           sources.branch                                        AS ip_branch,
           sum((CASE WHEN (tests.passed = 0) THEN 1 ELSE 0 END)) AS failed_tests,
           sum((CASE WHEN (tests.passed = 1) THEN 1 ELSE 0 END)) AS passed_tests
    FROM (((tests_compiler AS tests
        INNER JOIN sources ON tests.ip_id = sources.artifact_id)
        INNER JOIN artifacts ON tests.studio_id = artifacts.id)
             INNER JOIN artifacts_ip ON tests.ip_id = artifacts_ip.id)
    WHERE DATE(artifacts.created) >= @last_date AND
          (artifacts_ip.name = 'sigma_dk_bb700' OR artifacts_ip.name = 'sigma_dk_p700')
    GROUP BY artifacts.created,
             artifacts.version,
             artifacts.build,
             sources.branch,
             tests.design_path
    ORDER BY artifacts.created DESC,
             failed_tests DESC,
             passed_tests DESC;
    COMMIT;
END $$

CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__custom_links()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__custom_links
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__custom_links) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__custom_links WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__custom_links (date, parameters, version, build_id, os, compiler,
                                                      branch, ip_name, test_status, link_full)
    SELECT artifacts.created                                   AS date,
           tests.parameters                                    AS parameters,
           artifacts.version                                   AS version,
           artifacts.build                                     AS build_id,
           cl_environments.os                                  AS os,
           cl_environments.compiler                            AS compiler,
           sources.branch                                      AS branch,
           artifacts_ip.name                                   AS ip_name,
           cl_status.DESCription                               AS test_status,
           concat('https://codasip3.codasip.com/~jenkinsdata/',
                  replace(tests.link, 'mastermind_data/', '')) AS link_full
    FROM ((((((tests_compiler AS tests
        INNER JOIN artifacts ON tests.studio_id = artifacts.id)
        INNER JOIN sources ON tests.ip_id = sources.artifact_id)
        INNER JOIN artifacts_studio ON tests.studio_id = artifacts_studio.id)
        INNER JOIN cl_environments ON artifacts_studio.environment_id = cl_environments.id)
        INNER JOIN artifacts_ip ON tests.ip_id = artifacts_ip.id)
        INNER JOIN cl_status ON tests.status_id = cl_status.id)
    WHERE DATE(artifacts.created) >= @last_date AND
          tests.passed = 0 AND
          tests.link IS NOT NULL AND
          (artifacts_ip.name = 'sigma_dk_bb700' OR artifacts_ip.name = 'sigma_dk_p700')
    ORDER BY artifacts.created DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__helium_by_conf()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__helium_by_conf
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__helium_by_conf) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__helium_by_conf WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__helium_by_conf (date, version, build_id, ip_name, configuration,
                                                        failed_tests, passed_tests)
    SELECT artifacts.created          AS date,
           artifacts.version          AS Version,
           artifacts.build            AS build_id,
           tests.design_path          AS ip_name,
           artifacts_ip.configuration AS Configuration,
           SUM((CASE
                    WHEN (tests.passed = 0) THEN 1
                    ELSE 0
               END))                  AS failed_tests,
           SUM((CASE
                    WHEN (tests.passed = 1) THEN 1
                    ELSE 0
               END))                  AS passed_tests
    FROM (((tests_compiler AS tests
        INNER JOIN sources ON ((tests.ip_id = sources.artifact_id)))
        INNER JOIN artifacts ON ((tests.studio_id = artifacts.id)))
             INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          artifacts_ip.name = 'codix_helium'
    GROUP BY artifacts.created, artifacts.version, artifacts.build, tests.design_path,
             artifacts_ip.configuration
    ORDER BY artifacts.created DESC, failed_tests DESC, passed_tests DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__helium_links()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__helium_links
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__helium_links) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__helium_links WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__helium_links (parameters, version, build_id, OS, compiler,
                                                      configuration, date, test_status, link_full)
    SELECT tests.parameters           AS parameters,
           artifacts.version          AS version,
           artifacts.build            AS build_id,
           cl_environments.os         AS OS,
           cl_environments.compiler   AS compiler,
           artifacts_ip.configuration AS configuration,
           DATE(artifacts.created)    AS date,
           cl_status.DESCription      AS test_status,
           CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                  REPLACE(tests.link,
                          'mastermind_data/',
                          ''))        AS link_full
    FROM ((((((tests_compiler AS tests
        INNER JOIN artifacts ON ((tests.studio_id = artifacts.id)))
        INNER JOIN sources ON ((tests.ip_id = sources.artifact_id)))
        INNER JOIN artifacts_studio ON ((tests.studio_id = artifacts_studio.id)))
        INNER JOIN cl_environments ON ((artifacts_studio.environment_id = cl_environments.id)))
        INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
        INNER JOIN cl_status ON ((tests.status_id = cl_status.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          (tests.passed = 0)
      AND (tests.link IS NOT NULL)
      AND (artifacts_ip.name = 'codix_helium')
    ORDER BY artifacts.created DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__helium_sum_by_build()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__helium_sum_by_build
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__helium_sum_by_build) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__helium_sum_by_build WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__helium_sum_by_build (date, version_build_id, failed_tests_ia,
                                                             passed_tests_ia, sum_tests_ia, failed_tests_ca,
                                                             passed_tests_ca, sum_tests_ca)
    SELECT artifacts.created          AS date,
           CONCAT_WS('-',
                     artifacts.version,
                     NULL,
                     artifacts.build) AS build_id,
           SUM(CASE
                   WHEN tests.passed = 0 AND tests.design_path = 'codix_helium-ia'
                       THEN 1
                   ELSE 0
               END)                   AS failed_tests_ia,
           SUM((CASE
                    WHEN
                        ((tests.passed = 1)
                            AND
                         tests.design_path = 'codix_helium-ia')
                        THEN
                        1
                    ELSE 0
               END))                  AS passed_tests_ia,
           SUM((CASE
                    WHEN
                        tests.design_path = 'codix_helium-ia'
                        THEN
                        1
                    ELSE 0
               END))                  AS sum_tests_ia,
           SUM((CASE
                    WHEN ((tests.passed = 0) AND tests.design_path = 'codix_helium-ca') THEN 1
                    ELSE 0 END))                  AS failed_tests_ca,
           SUM(CASE
                   WHEN tests.passed = 1 AND tests.design_path = 'codix_helium-ca' THEN 1
                   ELSE 0 END)                   AS passed_tests_ca,
           SUM(CASE
                   WHEN tests.design_path = 'codix_helium-ca' THEN 1
                   ELSE 0 END)                   AS sum_tests_ca
    FROM (((tests_compiler AS tests
        INNER JOIN artifacts ON ((tests.studio_id = artifacts.id)))
        INNER JOIN artifacts_studio ON ((tests.studio_id = artifacts_studio.id)))
             INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          artifacts_ip.name = 'codix_helium'
    GROUP BY artifacts.created, build_id;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__urisc_by_branch()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__urisc_by_branch
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__urisc_by_branch) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__urisc_by_branch WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__urisc_by_branch (date, version, build_id, model_name, branch, failed_tests,
                                                         passed_tests)
    SELECT artifacts.created AS date,
           artifacts.version AS version,
           artifacts.build   AS build_id,
           tests.design_path AS model_name,
           sources.branch    AS ip_branch,
           SUM((CASE
                    WHEN (tests.passed = 0) THEN 1
                    ELSE 0
               END))         AS failed_tests,
           SUM((CASE
                    WHEN (tests.passed = 1) THEN 1
                    ELSE 0
               END))         AS passed_tests
    FROM (((tests_compiler AS tests
        INNER JOIN sources ON ((tests.ip_id = sources.artifact_id)))
        INNER JOIN artifacts USE INDEX (ix_artifacts_created) ON ((tests.studio_id = artifacts.id)))
             INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          artifacts_ip.name = 'codasip_urisc'
    GROUP BY artifacts.created, artifacts.version, artifacts.build, sources.branch,
             tests.design_path
    ORDER BY artifacts.created DESC, failed_tests DESC, passed_tests DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__urisc_links()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__urisc_links
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__urisc_links) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__urisc_links WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__urisc_links (parameters, version, build_id, OS, compiler, branch,
                                                     model_name, date, test_status, link_full)
    SELECT tests.parameters         AS parameters,
           artifacts.version        AS version,
           artifacts.build          AS build_id,
           cl_environments.os       AS OS,
           cl_environments.compiler AS compiler,
           sources.branch           AS branch,
           tests.design_path        AS model_name,
           artifacts.created        AS date,
           cl_status.DESCription    AS test_status,
           CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                  REPLACE(tests.link,
                          'mastermind_data/',
                          ''))      AS link_full
    FROM ((((((tests_compiler AS tests
        INNER JOIN artifacts ON ((tests.studio_id = artifacts.id)))
        INNER JOIN sources ON ((tests.ip_id = sources.artifact_id)))
        INNER JOIN artifacts_studio ON ((tests.studio_id = artifacts_studio.id)))
        INNER JOIN cl_environments ON ((artifacts_studio.environment_id = cl_environments.id)))
        INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
             INNER JOIN cl_status ON ((tests.status_id = cl_status.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          tests.passed = 0
      AND (tests.link IS NOT NULL)
      AND (artifacts_ip.name = 'codasip_urisc')
    ORDER BY artifacts.created DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__urisc_sum_by_build()
BEGIN
    START TRANSACTION;
    -- Get the day of the latest records.
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__urisc_sum_by_build
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__urisc_sum_by_build) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__urisc_sum_by_build WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__urisc_sum_by_build (date, version_build_id, failed_tests_ia,
                                                            passed_tests_ia, sum_tests_ia, failed_tests_ca,
                                                            passed_tests_ca, sum_tests_ca)

    SELECT created             AS date,
           build_id,
           sum(CASE
                   WHEN passed = 0 AND design_path = 'codasip_urisc-ia' THEN count
                   ELSE 0 END) AS failed_ia,
           sum(CASE
                   WHEN passed = 1 AND design_path = 'codasip_urisc-ia' THEN count
                   ELSE 0 END) AS passed_ia,
           sum(CASE
                   WHEN design_path = 'codasip_urisc-ia' THEN count
                   ELSE 0 END) AS total_ia,
           sum(CASE
                   WHEN passed = 0 AND design_path = 'codasip_urisc-ca' THEN count
                   ELSE 0 END) AS failed_ca,
           sum(CASE
                   WHEN passed = 1 AND design_path = 'codasip_urisc-ca' THEN count
                   ELSE 0 END) AS passed_ca,
           sum(CASE
                   WHEN design_path = 'codasip_urisc-ca' THEN count
                   ELSE 0 END) AS total_ca

    FROM (SELECT artifacts.created,
                 CONCAT_WS('-', artifacts.version, NULL, artifacts.build) AS build_id,
                 design_path,
                 passed,
                 count(passed)                                            AS count
          FROM (tests_compiler tests
                   INNER JOIN
               artifacts USE INDEX (ix_artifacts_created) ON ((tests.studio_id = artifacts.id))
                   INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
          WHERE DATE(artifacts.created) >= @last_date
            AND artifacts_ip.name = 'codasip_urisc'
          GROUP BY artifacts.created, build_id, design_path, passed) AS t
    GROUP BY created, build_id;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__uvliw_by_branch()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__uvliw_by_branch
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__uvliw_by_branch) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__uvliw_by_branch WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__uvliw_by_branch (date, version, build_id, ip_name, branch, failed_tests, passed_tests)
    SELECT artifacts.created AS date,
           artifacts.version AS version,
           artifacts.build   AS build_id,
           tests.design_path AS ip_name,
           sources.branch    AS ip_branch,
           SUM((CASE
                    WHEN (tests.passed = 0) THEN 1
                    ELSE 0
               END))         AS failed_tests,
           SUM((CASE
                    WHEN (tests.passed = 1) THEN 1
                    ELSE 0
               END))         AS passed_tests
    FROM (((tests_compiler AS tests
        INNER JOIN sources ON ((tests.ip_id = sources.artifact_id)))
        INNER JOIN artifacts USE INDEX (ix_artifacts_created) ON ((tests.studio_id = artifacts.id)))
             INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          artifacts_ip.name = 'codasip_uvliw'
    GROUP BY artifacts.created, artifacts.version, artifacts.build, sources.branch,
             tests.design_path
    ORDER BY artifacts.created DESC, failed_tests DESC, passed_tests DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__uvliw_links()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__uvliw_links
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__uvliw_links) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__uvliw_links WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__uvliw_links (parameters, version, build_id, OS, compiler, branch,
                                                     date, test_status, link_full)
    SELECT tests.parameters         AS parameters,
           artifacts.version        AS version,
           artifacts.build          AS build_id,
           cl_environments.os       AS OS,
           cl_environments.compiler AS compiler,
           sources.branch           AS branch,
           artifacts.created        AS date,
           cl_status.DESCription    AS test_status,

           CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                  REPLACE(tests.link,
                          'mastermind_data/',
                          ''))      AS link_full
    FROM ((((((tests_compiler AS tests
        INNER JOIN artifacts ON ((tests.studio_id = artifacts.id)))
        INNER JOIN sources ON ((tests.ip_id = sources.artifact_id)))
        INNER JOIN artifacts_studio ON ((tests.studio_id = artifacts_studio.id)))
        INNER JOIN cl_environments ON ((artifacts_studio.environment_id = cl_environments.id)))
        INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
             INNER JOIN cl_status ON ((tests.status_id = cl_status.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          tests.passed = 0
      AND (tests.link IS NOT NULL)
      AND (artifacts_ip.name LIKE 'codasip_uvliw')
    ORDER BY artifacts.created DESC;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_compiler_regression__uvliw_sum_by_build()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_compiler_regression__uvliw_sum_by_build
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_compiler_regression__uvliw_sum_by_build) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_compiler_regression__uvliw_sum_by_build WHERE DATE(date) >= @last_date;
    INSERT INTO mv_compiler_regression__uvliw_sum_by_build (date, version_build_id, failed_tests_ia,
                                                            passed_tests_ia, sum_tests_ia, failed_tests_ca,
                                                            passed_tests_ca, sum_tests_ca)
    SELECT artifacts.created                                        AS date,
           CONCAT_WS('-', artifacts.version, NULL, artifacts.build) AS build_id,
           SUM((CASE
                    WHEN (tests.passed = 0 AND tests.design_path = 'codasip_uvliw-ia')
                        THEN 1
                    ELSE 0
               END))                                                AS failed_tests_ia,
           SUM((CASE
                    WHEN (tests.passed = 1 AND tests.design_path = 'codasip_uvliw-ia')
                        THEN 1
                    ELSE 0
               END))                                                AS passed_tests_ia,
           SUM((CASE
                    WHEN tests.design_path = 'codasip_uvliw-ia' THEN 1
                    ELSE 0
               END))                                                AS sum_tests_ia,
           SUM((CASE
                    WHEN (tests.passed = 0 AND tests.design_path = 'codasip_uvliw-ca')
                        THEN 1
                    ELSE 0
               END))                                                AS failed_tests_ca,
           SUM((CASE
                    WHEN (tests.passed = 1 AND tests.design_path = 'codasip_uvliw-ca')
                        THEN 1
                    ELSE 0
               END))                                                AS passed_tests_ca,
           SUM((CASE
                    WHEN tests.design_path = 'codasip_uvliw-ca' THEN 1
                    ELSE 0
               END))                                                AS sum_tests_ca

    FROM (tests_compiler AS tests
             INNER JOIN artifacts USE INDEX (ix_artifacts_created) ON ((tests.studio_id = artifacts.id))
             INNER JOIN artifacts_studio ON ((tests.studio_id = artifacts_studio.id))
             INNER JOIN artifacts_ip ON ((tests.ip_id = artifacts_ip.id)))
    WHERE DATE(artifacts.created) >= @last_date AND
          artifacts_ip.name LIKE 'codasip_uvliw'
    GROUP BY artifacts.created, build_id;
    COMMIT;
END $$


CREATE
    definer = test_user@localhost PROCEDURE refresh_new_mv_debugger_regression__urisc_all()
BEGIN
    START TRANSACTION;
    SET @last_date = (SELECT MAX(DATE(date))
                      FROM mv_debugger_regression__urisc_all
                      WHERE DATE(date) >
                            (SELECT MAX(DATE(date)) FROM mv_debugger_regression__urisc_all) - INTERVAL 1 DAY);
    -- If no records are in the table, THEN set date of the latest record to the very past date.
    IF @last_date is null THEN
        SET @last_date = '2012-12-31';
    END IF;
    DELETE FROM mv_debugger_regression__urisc_all WHERE DATE(date) >= @last_date;
    INSERT INTO mv_debugger_regression__urisc_all (passed, parameters, design_path, name, version, build_id,
                                                         command, OS, compiler, branch, date, test_status, link_full)
    SELECT tests.passed              AS passed,
           tests.parameters          AS parameters,
           tests.design_path         AS design_path,
           tests.name                AS name,
           artifacts.version         AS version,
           artifacts.build           AS build_id,
           artifacts_session.command AS command,
           cl_environments.os        AS OS,
           cl_environments.compiler  AS compiler,
           sources.branch            AS branch,
           artifacts.created         AS date,
           cl_status.DESCription     AS test_status,
              CONCAT('https://codasip3.codasip.com/~jenkinsdata/',
                     REPLACE(tests.link,
                             'mastermind_data/',
                             ''))         AS link_full
    FROM (((((((tests_rest AS tests
        INNER JOIN artifacts USE INDEX (ix_artifacts_created) ON tests.studio_id = artifacts.id)
        INNER JOIN sources ON tests.ip_id = sources.artifact_id)
        INNER JOIN artifacts_session ON tests.session_id = artifacts_session.id)
        INNER JOIN artifacts_studio ON tests.studio_id = artifacts_studio.id)
        INNER JOIN cl_environments ON artifacts_studio.environment_id = cl_environments.id)
        INNER JOIN artifacts_ip ON tests.ip_id = artifacts_ip.id)
        INNER JOIN cl_status ON tests.status_id = cl_status.id)
    WHERE DATE(artifacts.created) >= @last_date AND
          artifacts_ip.name = 'codasip_urisc' AND
          tests.tool = 'debugger' AND
          tests.kind = 'regression'
    ORDER BY artifacts.created DESC;
    COMMIT;
END $$


# REFRESH WRAPPER PROCEDURE:
# Wrapper PROCEDURE to gather and log information about every MV refresher call.
DROP PROCEDURE IF exists refresh_wrapper;
CREATE
    definer = test_user@localhost PROCEDURE refresh_wrapper(IN proc1 varchar(100))
BEGIN
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE continue HANDLER FOR SQLEXCEPTION

        -- Following block catches return code and message.
        BEGIN
            GET DIAGNOSTICS CONDITION 1 code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        END;

    -- Create command.
    SET @command = CONCAT('call ', proc1, '();');
    PREPARE command_to_exec FROM @command;

    SET @start_time = now();
    execute command_to_exec;
    SET @duration = timediff(now(), @start_time);

    -- IF everything was OK, code is 0, set success msg
    IF code = '00000' THEN
        SET msg = ('successful refresher run');
    END IF;

    START TRANSACTION;
    INSERT INTO refresh_events_log (date_and_time, PROCEDURE_name, mysql_return_code, message, duration)
    SELECT CAST(NOW() AS datetime) AS 'date and time',
           proc1                   AS 'PROCEDURE name',
           code                    AS 'mysql return code',
           msg                     AS 'message',
           @duration               AS 'duration'
    ORDER BY 'date and time' DESC;
    COMMIT; -- Push what we have selected.
    DEALLOCATE PREPARE command_to_exec;
END $$

DELIMITER ;