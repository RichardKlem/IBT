#!/bin/bash


DB_NAME="xklemr00_IBT"
DB_NAME_OLD="${DB_NAME}_old"
DB_NAME_NEW="${DB_NAME}_new"

# Creates old and new databases, create new user test_user and grant privileges.
mysql -e"set @db_name = '$DB_NAME'; \. init.sql"
# Create OLD schema tables and procedures
mysql -D $DB_NAME_OLD < data_tables.sql
mysql -D $DB_NAME_OLD < materialized_views.sql
mysql -D $DB_NAME_OLD < refreshers.sql
# Import sample data into OLD schema
mysql -D $DB_NAME_OLD < cl_environments.sql
mysql -D $DB_NAME_OLD < cl_status.sql
mysql -D $DB_NAME_OLD < artifacts.sql
mysql -D $DB_NAME_OLD < sources.sql
mysql -D $DB_NAME_OLD < artifacts_ip.sql
mysql -D $DB_NAME_OLD < artifacts_session.sql
mysql -D $DB_NAME_OLD < artifacts_studio.sql
# Create NEW schema tables and procedures
mysql -D $DB_NAME_NEW < data_tables_new.sql
mysql -D $DB_NAME_NEW < materialized_views.sql
mysql -D $DB_NAME_NEW < refreshers_new.sql

mysql -D $DB_NAME_NEW < cl_environments.sql
mysql -D $DB_NAME_NEW < cl_status.sql
mysql -D $DB_NAME_NEW < artifacts.sql
mysql -D $DB_NAME_NEW < artifacts_ip.sql
mysql -D $DB_NAME_NEW < artifacts_session.sql
mysql -D $DB_NAME_NEW < artifacts_studio.sql

# Choose one:
#   tests_IDmod_100.sql is about 1 million rows,
#   tests_IDmod_1000.sql is about 100k rows.
# Or you can choose full referential data load which has around 30 millions
# rows. This data load is split into smaller files. You can choose how many data you want.
# Note: Full data load took me on my machine about one day to complete.
#mysql -D $DB_NAME_OLD < tests_IDmod_1000.sql  # Took 7 minutes on my machine.
mysql -D $DB_NAME_OLD < tests_IDmod_100.sql

# Transfer data to the new schema.
mysql -D $DB_NAME_OLD < data_model_transfer.sql

# Create indices.
mysql -D $DB_NAME_OLD < create_indices.sql

# Run performance testing.
mysql -D $DB_NAME_OLD < performance_test.sql