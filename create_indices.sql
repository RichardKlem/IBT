# This script create meaningful indices on both schemas.
use xklemr00_IBT_old;

CREATE INDEX ix_artifacts_build ON artifacts (build);
CREATE INDEX ix_artifacts_created ON artifacts (created);
CREATE INDEX ix_artifacts_type ON artifacts (type);
CREATE INDEX ix_artifacts_version ON artifacts (version);

CREATE INDEX ix_artifacts_ip_configuration ON artifacts_ip (configuration);
CREATE INDEX ix_artifacts_ip_name ON artifacts_ip (name);

CREATE INDEX ix_artifacts_studio_build_number ON artifacts_studio (build_number);
CREATE INDEX ix_artifacts_studio_build_type ON artifacts_studio (build_type);

CREATE INDEX ix_sources_branch ON sources (branch);

CREATE INDEX ix_tests_design_path ON tests (design_path);
CREATE INDEX ix_tests_kind ON tests (kind);
CREATE INDEX ix_tests_name ON tests (name);
CREATE INDEX ix_tests_parameters ON tests (parameters);
CREATE INDEX ix_tests_tool ON tests (tool);
CREATE INDEX ix_tests_type ON tests (type);


use xklemr00_IBT_new;

CREATE INDEX ix_artifacts_build ON artifacts (build);
CREATE INDEX ix_artifacts_created ON artifacts (created);
CREATE INDEX ix_artifacts_type ON artifacts (type);
CREATE INDEX ix_artifacts_version ON artifacts (version);

CREATE INDEX ix_artifacts_ip_configuration ON artifacts_ip (configuration);
CREATE INDEX ix_artifacts_ip_name ON artifacts_ip (name);

CREATE INDEX ix_artifacts_studio_build_number ON artifacts_studio (build_number);
CREATE INDEX ix_artifacts_studio_build_type ON artifacts_studio (build_type);

CREATE INDEX ix_sources_branch ON sources (branch);

CREATE INDEX ix_tests_compiler_design_path ON tests_compiler (design_path);
CREATE INDEX ix_tests_compiler_kind ON tests_compiler (kind);
CREATE INDEX ix_tests_compiler_name ON tests_compiler (name);
CREATE INDEX ix_tests_compiler_parameters ON tests_compiler (parameters);
CREATE INDEX ix_tests_compiler_tool ON tests_compiler (tool);
CREATE INDEX ix_tests_compiler_type ON tests_compiler (type);
CREATE INDEX ix_tests_compiler_tool_kind ON tests_compiler (tool, kind);
CREATE INDEX ix_tests_compiler_date ON tests_compiler (date);

CREATE INDEX ix_tests_rest_design_path ON tests_rest (design_path);
CREATE INDEX ix_tests_rest_kind ON tests_rest (kind);
CREATE INDEX ix_tests_rest_name ON tests_rest (name);
CREATE INDEX ix_tests_rest_parameters ON tests_rest (parameters);
CREATE INDEX ix_tests_rest_tool ON tests_rest (tool);
CREATE INDEX ix_tests_rest_type ON tests_rest (type);
CREATE INDEX ix_tests_rest_tool_kind ON tests_rest (tool, kind);
CREATE INDEX ix_tests_rest_date ON tests_rest (date);

CREATE INDEX ix_artifact_source_source_id_artifact_id ON artifact_source (source_id, artifact_id);
