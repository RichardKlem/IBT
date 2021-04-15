#!/bin/bash
mysql < init.sql
mysql < data_tables.sql
mysql < refreshers.sql
mysql < refreshers_new.sql
mysql < materialized_views.sql