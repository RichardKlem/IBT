-- Show execution user and the real/actual user;
select user(); select current_user();

-- Show privileges
SELECT host,user,Grant_priv,Super_priv FROM mysql.user;
SELECT * FROM mysql.user where User = 'rklem';
-- Update privileges etc.
UPDATE mysql.user SET Grant_priv='Y' WHERE User='rklem';
FLUSH PRIVILEGES;

-- Show installed plugins
SHOW PLUGINS;

-- Enable profiling
SET SESSION profiling = 1;
-- Set profiling history size
SET @@profiling_history_size = 100;

-- Show profiling info with query ID
SHOW PROFILES;
-- Use query ID to show more info about query
SELECT * FROM INFORMATION_SCHEMA.PROFILING WHERE QUERY_ID = 109;

-- Show table information like rows etc.
show table status like 'mv%';

-- Disable foreign keys check
SET FOREIGN_KEY_CHECKS = 1;

-- SQL modes
SELECT @@SQL_MODE;
SET SQL_MODE ='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
SET SQL_MODE ='';

-- Average duration of procedure
select procedure_name, sec_to_time(avg(time_to_sec(xklemr00_IBT.refresh_events_log.duration)))
from refresh_events_log
group by procedure_name;