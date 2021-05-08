CREATE TABLE artifacts
(
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(10) NULL,
    build   VARCHAR(45) NULL,
    CREATEd DATETIME    NULL,
    type    VARCHAR(10) NULL,
    INDEX ix_artifacts_build (build),
    INDEX ix_artifacts_CREATEd (CREATEd),
    INDEX ix_artifacts_type (type),
    INDEX ix_artifacts_version (version)
);


CREATE TABLE artifacts_ip
(
    id            BIGINT      NOT NULL PRIMARY KEY,
    name          VARCHAR(50) NULL,
    configuration VARCHAR(50) NULL,
    CONSTRAINT artifacts_ip_ibfk_1
        FOREIGN KEY (id) REFERENCES artifacts (id)
            ON DELETE CASCADE,
    INDEX ix_artifacts_ip_configuration (configuration),
    INDEX ix_artifacts_ip_name (name)
);


CREATE TABLE cl_environments
(
    id        VARCHAR(10) NOT NULL PRIMARY KEY,
    os        VARCHAR(20) NULL,
    arch      VARCHAR(20) NULL,
    compiler  VARCHAR(20) NULL,
    supported TINYINT(1)  NULL
);

CREATE TABLE cl_status
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(100) NULL,
    description VARCHAR(500) NULL
);

CREATE TABLE artifacts_session
(
    id             BIGINT        NOT NULL PRIMARY KEY,
    command        VARCHAR(1000) NULL,
    duration       INT           NULL,
    node_name      VARCHAR(100)  NULL,
    job_url        VARCHAR(256)  NULL,
    passed         TINYINT(1)    NULL,
    environment_id VARCHAR(10)   NULL,
    status_id      INT           NULL,
    CONSTRAINT artifacts_session_ibfk_1
        FOREIGN KEY (id) REFERENCES artifacts (id)
            ON DELETE CASCADE,
    CONSTRAINT artifacts_session_ibfk_2
        FOREIGN KEY (environment_id) REFERENCES cl_environments (id),
    CONSTRAINT artifacts_session_ibfk_3
        FOREIGN KEY (status_id) REFERENCES cl_status (id)
);


CREATE TABLE artifacts_studio
(
    id             BIGINT      NOT NULL PRIMARY KEY,
    build_number   INT         NULL,
    build_type     VARCHAR(20) NULL,
    status_id      INT         NULL,
    environment_id VARCHAR(10) NULL,
    CONSTRAINT artifacts_studio_ibfk_1
        FOREIGN KEY (id) REFERENCES artifacts (id)
            ON DELETE CASCADE,
    CONSTRAINT artifacts_studio_ibfk_2
        FOREIGN KEY (status_id) REFERENCES cl_status (id),
    CONSTRAINT artifacts_studio_ibfk_3
        FOREIGN KEY (environment_id) REFERENCES cl_environments (id),
    INDEX ix_artifacts_studio_build_number (build_number),
    INDEX ix_artifacts_studio_build_type (build_type)
);


CREATE TABLE sources
(
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    repository  VARCHAR(100) NULL,
    commit      VARCHAR(40)  NULL,
    branch      VARCHAR(100) NULL,
    INDEX ix_sources_branch (branch)
);

CREATE TABLE tests_compiler
(
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)  NULL,
    tool        VARCHAR(30)   NULL,
    kind        VARCHAR(30)   NULL,
    passed      TINYINT(1)    NULL,
    parameters  VARCHAR(250)  NULL,
    design_path VARCHAR(50)   NULL,
    link        VARCHAR(1000) NULL,
    type        VARCHAR(10)   NULL,
    ip_id       BIGINT        NULL,
    studio_id   BIGINT        NULL,
    session_id  BIGINT        NULL,
    status_id   INT           NULL,
    date        DATE          NULL,
    CONSTRAINT tests_ibfk_1
        FOREIGN KEY (ip_id) REFERENCES artifacts (id),
    CONSTRAINT tests_ibfk_2
        FOREIGN KEY (studio_id) REFERENCES artifacts (id),
    CONSTRAINT tests_ibfk_3
        FOREIGN KEY (session_id) REFERENCES artifacts (id),
    CONSTRAINT tests_ibfk_4
        FOREIGN KEY (status_id) REFERENCES cl_status (id),

    INDEX ix_tests_design_path (design_path),
    INDEX ix_tests_kind (kind),
    INDEX ix_tests_name (name),
    INDEX ix_tests_parameters (parameters),
    INDEX ix_tests_tool (tool),
    INDEX ix_tests_type (type),
    INDEX ix_tests_tool_kind (tool, kind),
    INDEX ix_tests_date (date)
);

CREATE TABLE tests_rest
(
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)  NULL,
    tool        VARCHAR(30)   NULL,
    kind        VARCHAR(30)   NULL,
    passed      TINYINT(1)    NULL,
    parameters  VARCHAR(250)  NULL,
    design_path VARCHAR(50)   NULL,
    link        VARCHAR(1000) NULL,
    type        VARCHAR(10)   NULL,
    ip_id       BIGINT        NULL,
    studio_id   BIGINT        NULL,
    session_id  BIGINT        NULL,
    status_id   INT           NULL,
    date        date          NULL,
    CONSTRAINT tests_rest_ibfk_1
        FOREIGN KEY (ip_id) REFERENCES artifacts_ip (id),
    CONSTRAINT tests_rest_ibfk_2
        FOREIGN KEY (studio_id) REFERENCES artifacts_studio (id),
    CONSTRAINT tests_rest_ibfk_3
        FOREIGN KEY (session_id) REFERENCES artifacts_session (id),
    CONSTRAINT tests_rest_ibfk_4
        FOREIGN KEY (status_id) REFERENCES cl_status (id),

    INDEX ix_tests_design_path (design_path),
    INDEX ix_tests_kind (kind),
    INDEX ix_tests_name (name),
    INDEX ix_tests_parameters (parameters),
    INDEX ix_tests_tool (tool),
    INDEX ix_tests_type (type),
    INDEX ix_tests_tool_kind (tool, kind),
    INDEX ix_tests_date (date)
);

CREATE TABLE artifact_source(
    artifact_id     BIGINT,
    source_id BIGINT,
    CONSTRAINT artifact_source_ibfk_1
        FOREIGN KEY (artifact_id) REFERENCES artifacts (id),
    CONSTRAINT artifact_source_ibfk_2
        FOREIGN KEY (source_id) REFERENCES sources (id),
    PRIMARY KEY(artifact_id, source_id),
    INDEX      (source_id, artifact_id)
);