insert into tests_rest
select * from tests where tool != 'compiler' OR kind != 'regression';

UPDATE tests_compiler
SET design_path = REPLACE(design_path, '.', '-');
UPDATE tests_rest
SET design_path = REPLACE(design_path, '.', '-');