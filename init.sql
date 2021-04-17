set @stmt = concat('create database ', @db_name);
prepare stmt from @stmt;
execute stmt;
deallocate prepare stmt;


set @stmt = concat('grant all privileges on ', @db_name, '.* to \'rklem\'@\'localhost\';');
prepare stmt from @stmt;
execute stmt;
deallocate prepare stmt;

set GLOBAL max_allowed_packet = 1024*1024*16;
# CREATE USER if not exists 'test_user'@'localhost' IDENTIFIED BY '12test5user';
