insert into dep_test_new.sources select id, repository, commit, branch from dep_test_old.sources;


insert into dep_test_new.artifact_source select a.id, s.id
from dep_test_old.sources s inner join dep_test_old.artifacts a on s.artifact_id = a.id;

insert into dep_test_new.tests_compiler
select id, name, tool, kind, passed, parameters, design_path, link, type, ip_id, studio_id,
       session_id, status_id, null from dep_test_old.tests where tool = 'compiler' AND kind = 'regression';

insert into dep_test_new.tests_rest
select id, name, tool, kind, passed, parameters, design_path, link, type, ip_id, studio_id,
       session_id, status_id, null from dep_test_old.tests where tool != 'compiler' OR kind != 'regression';

UPDATE dep_test_new.tests_compiler
SET design_path = REPLACE(design_path, '.', '-');
UPDATE dep_test_new.tests_rest
SET design_path = REPLACE(design_path, '.', '-');
