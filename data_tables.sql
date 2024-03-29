create table artifacts
(
    id      bigint auto_increment primary key,
    version varchar(10) null,
    build   varchar(45) null,
    created datetime    null,
    type    varchar(10) null
);


create table artifacts_ip
(
    id            bigint      not null primary key,
    name          varchar(50) null,
    configuration varchar(50) null,
    constraint artifacts_ip_ibfk_1
        foreign key (id) references artifacts (id)
            on delete cascade
);


create table cl_environments
(
    id        varchar(10) not null primary key,
    os        varchar(20) null,
    arch      varchar(20) null,
    compiler  varchar(20) null,
    supported tinyint(1)  null
);


create table cl_status
(
    id          int auto_increment primary key,
    code        varchar(100) null,
    description varchar(500) null
);


create table artifacts_session
(
    id             bigint        not null primary key,
    command        varchar(1000) null,
    duration       int           null,
    node_name      varchar(100)  null,
    job_url        varchar(256)  null,
    passed         tinyint(1)    null,
    environment_id varchar(10)   null,
    status_id      int           null,
    constraint artifacts_session_ibfk_1
        foreign key (id) references artifacts (id)
            on delete cascade,
    constraint artifacts_session_ibfk_2
        foreign key (environment_id) references cl_environments (id),
    constraint artifacts_session_ibfk_3
        foreign key (status_id) references cl_status (id)
);


create table artifacts_studio
(
    id             bigint      not null primary key,
    build_number   int         null,
    build_type     varchar(20) null,
    status_id      int         null,
    environment_id varchar(10) null,
    constraint artifacts_studio_ibfk_1
        foreign key (id) references artifacts (id)
            on delete cascade,
    constraint artifacts_studio_ibfk_2
        foreign key (status_id) references cl_status (id),
    constraint artifacts_studio_ibfk_3
        foreign key (environment_id) references cl_environments (id)
);


create table sources
(
    id          bigint auto_increment primary key,
    repository  varchar(100) null,
    commit      varchar(40)  null,
    branch      varchar(100) null,
    artifact_id bigint       null,
    constraint sources_ibfk_1
        foreign key (artifact_id) references artifacts (id)
            on delete cascade
);


create table tests
(
    id          bigint auto_increment primary key,
    name        varchar(100)  null,
    tool        varchar(30)   null,
    kind        varchar(30)   null,
    passed      tinyint(1)    null,
    parameters  varchar(250)  null,
    design_path varchar(50)   null,
    link        varchar(1000) null,
    type        varchar(10)   null,
    ip_id       bigint        null,
    studio_id   bigint        null,
    session_id  bigint        null,
    status_id   int           null,
    constraint tests_ibfk_1
        foreign key (ip_id) references artifacts (id),
    constraint tests_ibfk_2
        foreign key (studio_id) references artifacts (id),
    constraint tests_ibfk_3
        foreign key (session_id) references artifacts (id),
    constraint tests_ibfk_4
        foreign key (status_id) references cl_status (id)
);
