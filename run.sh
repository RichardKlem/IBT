#!/bin/bash


echo "_______________start_______________"
DB_NAME="xklemr00_IBT"
DB_NAME_OLD="${DB_NAME}_old"
DB_NAME_NEW="${DB_NAME}_new"

# Creates old and new databases, create new user test_user and grant privileges.
mysql -e"set @db_name = '$DB_NAME'; \. init.sql"
echo " 1/17 Created ${DB_NAME_OLD} and ${DB_NAME_NEW} schemas and user test_user with privileges."
# Create OLD schema tables and procedures
echo " 2/17 Processing OLD schema..."
mysql -D $DB_NAME_OLD < data_tables.sql
echo "     3/17 Created data tables"
mysql -D $DB_NAME_OLD < materialized_views.sql
echo "     4/17 Created materialized views tables"
mysql -D $DB_NAME_OLD < refreshers.sql
echo "     5/17 Created procedures to update materialized views."
# Import sample data into OLD schema
mysql -D $DB_NAME_OLD < cl_environments.sql
mysql -D $DB_NAME_OLD < cl_status.sql
mysql -D $DB_NAME_OLD < artifacts.sql
mysql -D $DB_NAME_OLD < sources.sql
mysql -D $DB_NAME_OLD < artifacts_ip.sql
mysql -D $DB_NAME_OLD < artifacts_session.sql
mysql -D $DB_NAME_OLD < artifacts_studio.sql
echo "     6/17 Inserted data (except tests table)."
echo " 7/17 Processing NEW schema..."
# Create NEW schema tables and procedures
mysql -D $DB_NAME_NEW < data_tables_new.sql
echo "     8/17 Created data tables"
mysql -D $DB_NAME_NEW < materialized_views.sql
echo "     9/17 Created materialized views tables"
mysql -D $DB_NAME_NEW < refreshers_new.sql
echo "    10/17 Created procedures to update materialized views."

mysql -D $DB_NAME_NEW < cl_environments.sql
mysql -D $DB_NAME_NEW < cl_status.sql
mysql -D $DB_NAME_NEW < artifacts.sql
mysql -D $DB_NAME_NEW < artifacts_ip.sql
mysql -D $DB_NAME_NEW < artifacts_session.sql
mysql -D $DB_NAME_NEW < artifacts_studio.sql
echo "    11/17 Inserted data (except tests table)."

# Choose one:
#   tests_IDmod_100.sql is about 1 million rows,
#   tests_IDmod_1000.sql is about 100k rows.
# Or you can choose full referential data load which has around 30 millions
# rows. This data load is split into smaller files. You can choose how many data you want.
# Note: Full data load took me on my machine about one day to complete.
echo "12/17 Inserting tests table data (this will take a while)..."
mysql -D $DB_NAME_OLD < tests_IDmod_1000.sql  # Took 7 minutes on my machine.
#mysql -D $DB_NAME_OLD < tests_IDmod_100.sql  # Took 2 hours on my machine.
echo "13/17 Inserted all data in tests table."


# Transfer data to the new schema.
mysql -D $DB_NAME_OLD < data_model_transfer.sql
echo "14/17 Data model has been transformed."

# Create indices.
mysql -D $DB_NAME_OLD < create_indices.sql
echo "15/17 Created indices on OLD schema table columns."
echo "16/17 Created indices on NEW schema table columns."

echo "17/17 Running performance testing (this will take a while)..."
# Run performance testing.
mysql -D $DB_NAME_OLD < performance_test.sql
echo "________________end________________"