LOAD DATA INFILE '/var/lib/mysql-files/cl_status.sql' INTO TABLE cl_status;

LOAD DATA INFILE '/var/lib/mysql-files/cl_environments.sql' INTO TABLE cl_environments;


LOAD DATA INFILE '/var/lib/mysql-files/artifacts.sql' INTO TABLE artifacts;
LOAD DATA INFILE '/var/lib/mysql-files/sources.sql' INTO TABLE sources;
LOAD DATA INFILE '/var/lib/mysql-files/artifacts_ip.sql' INTO TABLE artifacts_ip;
LOAD DATA INFILE '/var/lib/mysql-files/artifacts_session.sql' INTO TABLE artifacts_session;
LOAD DATA INFILE '/var/lib/mysql-files/artifacts_studio.sql' INTO TABLE artifacts_studio;
