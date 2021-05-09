CREATE DATABASE xklemr00_IBT_old;
CREATE DATABASE xklemr00_IBT_new;

CREATE USER IF NOT EXISTS 'test_user'@'localhost' IDENTIFIED BY '12test5user';

GRANT ALL PRIVILEGES ON xklemr00_IBT_old.* TO test_user@localhost;
GRANT ALL PRIVILEGES ON xklemr00_IBT_new.* TO test_user@localhost;
FLUSH PRIVILEGES;

SET GLOBAL max_allowed_packet = 1024 * 1024 * 16;
