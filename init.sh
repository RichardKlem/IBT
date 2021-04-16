#!/bin/bash
DB_NAME="xklemr00_IBT_test"
# Change database name in init.sql
mysql -e"set @db_name = '$DB_NAME'; \. init.sql"

mysql -D $DB_NAME < data_tables.sql
mysql -D $DB_NAME < refreshers.sql
mysql -D $DB_NAME < refreshers_new.sql
mysql -D $DB_NAME < materialized_views.sql

# Import sample data
mysql -D $DB_NAME < cl_environments.sql
mysql -D $DB_NAME < cl_status.sql
mysql -D $DB_NAME < artifacts.sql
mysql -D $DB_NAME < sources.sql
mysql -D $DB_NAME < artifacts_ip.sql
mysql -D $DB_NAME < artifacts_session.sql
mysql -D $DB_NAME < artifacts_studio.sql
mysql -D $DB_NAME < tests_reduced.sql
