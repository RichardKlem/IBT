insert into xklemr00_IBT_new.sources select id, repository, commit, branch from xklemr00_IBT_old.sources;


insert into xklemr00_IBT_new.artifact_source select a.id, s.id
from xklemr00_IBT_old.sources s inner join xklemr00_IBT_old.artifacts a on s.artifact_id = a.id;

insert into xklemr00_IBT_new.tests_compiler
select id, name, tool, kind, passed, parameters, design_path, link, type, ip_id, studio_id,
       session_id, status_id, null from xklemr00_IBT_old.tests where tool = 'compiler' AND kind = 'regression';

insert into xklemr00_IBT_new.tests_rest
select id, name, tool, kind, passed, parameters, design_path, link, type, ip_id, studio_id,
       session_id, status_id, null from xklemr00_IBT_old.tests where tool != 'compiler' OR kind != 'regression';

UPDATE xklemr00_IBT_new.tests_compiler
SET design_path = REPLACE(design_path, '.', '-');
UPDATE xklemr00_IBT_new.tests_rest
SET design_path = REPLACE(design_path, '.', '-');
