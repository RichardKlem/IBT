SET @stmt = CONCAT('CREATE DATABASE ', @db_name, '_old');
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @stmt = CONCAT('CREATE DATABASE ', @db_name, '_new');
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE USER IF NOT EXISTS 'test_user'@'localhost' IDENTIFIED BY '12test5user';

SET @stmt = concat('GRANT ALL PRIVILEGES ON ', @db_name, '_old.* TO \'test_user\'@\'localhost\';');
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @stmt = concat('GRANT ALL PRIVILEGES ON ', @db_name, '_new.* TO \'test_user\'@\'localhost\';');
PREPARE stmt FROM @stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

FLUSH PRIVILEGES;

SET GLOBAL max_allowed_packet = 1024 * 1024 * 16;
