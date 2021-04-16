use xklemr00_IBT;


create table mv_compiler_regression__berkelium_conf
(
	id int unsigned auto_increment
		primary key,
	date datetime not null,
	version varchar(128) not null,
	build_id varchar(128) not null,
	configuration varchar(128) not null,
	failed_tests int not null,
	passed_tests int not null,
	model_name varchar(128) not null,
	ip_branch varchar(100) null
);

create table mv_compiler_regression__berkelium_links
(
	id int auto_increment
		primary key,
	branch varchar(100) null,
	parameters varchar(250) null,
	version varchar(10) null,
	build_id varchar(45) null,
	model_name varchar(128) null,
	OS varchar(20) null,
	compiler varchar(20) null,
	configuration varchar(100) null,
	date datetime null,
	link_full varchar(1000) null,
	test_status varchar(64) null
);

create table mv_compiler_regression__berkelium_sum_by_build
(
	id int auto_increment
		primary key,
	date datetime null,
	version_build_id varchar(100) not null,
	failed_tests_ia int not null,
	passed_tests_ia int not null,
	sum_tests_ia int not null,
	failed_tests_ca int not null,
	passed_tests_ca int not null,
	sum_tests_ca int not null
);

create table mv_compiler_regression__codix_by_ip
(
	id int auto_increment
		primary key,
	date datetime null,
	version varchar(10) null,
	build_id varchar(45) null,
	ip_name varchar(50) null,
	ip_branch varchar(100) null,
	failed_tests int not null,
	passed_tests int not null
);

create table mv_compiler_regression__codix_links
(
	id int auto_increment
		primary key,
	date datetime null,
	parameters varchar(250) null,
	version varchar(10) null,
	build_id varchar(45) null,
	os varchar(20) null,
	compiler varchar(20) null,
	ip_name varchar(50) null,
	test_status varchar(500) null,
	link_full varchar(1000) null
);

create table mv_compiler_regression__custom_by_ip
(
	id int auto_increment
		primary key,
	date datetime null,
	version varchar(10) null,
	build_id varchar(45) null,
	ip_name varchar(50) null,
	ip_branch varchar(100) null,
	failed_tests int not null,
	passed_tests int not null
);

create table mv_compiler_regression__custom_links
(
	id int auto_increment
		primary key,
	date datetime null,
	parameters varchar(250) null,
	version varchar(10) null,
	build_id varchar(45) null,
	os varchar(20) null,
	compiler varchar(20) null,
	branch varchar(100) null,
	ip_name varchar(50) null,
	test_status varchar(500) null,
	link_full varchar(1000) null
);

create table mv_compiler_regression__helium_by_conf
(
	id int unsigned auto_increment
		primary key,
	date datetime not null,
	version varchar(128) not null,
	build_id varchar(128) not null,
	configuration varchar(128) not null,
	failed_tests int not null,
	passed_tests int not null,
	ip_name varchar(128) not null
);

create table mv_compiler_regression__helium_links
(
	id int auto_increment
		primary key,
	parameters varchar(250) null,
	version varchar(10) not null,
	build_id varchar(45) not null,
	OS varchar(45) not null,
	compiler varchar(10) null,
	configuration varchar(100) null,
	date varchar(10) not null,
	link_full text not null,
	test_status varchar(64) null
);

create table mv_compiler_regression__helium_sum_by_build
(
	id int auto_increment
		primary key,
	date datetime null,
	version_build_id varchar(100) not null,
	failed_tests_ia int not null,
	passed_tests_ia int not null,
	sum_tests_ia int not null,
	failed_tests_ca int not null,
	passed_tests_ca int not null,
	sum_tests_ca int not null
);

create table mv_compiler_regression__urisc_by_branch
(
	id int unsigned auto_increment
		primary key,
	date datetime not null,
	version varchar(128) not null,
	build_id varchar(128) not null,
	branch varchar(128) not null,
	model_name varchar(128) not null,
	failed_tests int not null,
	passed_tests int not null
);

create table mv_compiler_regression__urisc_links
(
	id int auto_increment
		primary key,
	date datetime not null,
	version varchar(10) not null,
	build_id varchar(45) not null,
	OS varchar(45) not null,
	compiler varchar(10) null,
	branch varchar(100) null,
	model_name varchar(128) null,
	parameters varchar(250) null,
	test_status varchar(64) null,
	link_full text not null
);

create table mv_compiler_regression__urisc_sum_by_build
(
	id int auto_increment
		primary key,
	date datetime null,
	version_build_id varchar(100) not null,
	failed_tests_ia int not null,
	passed_tests_ia int not null,
	sum_tests_ia int not null,
	failed_tests_ca int not null,
	passed_tests_ca int not null,
	sum_tests_ca int not null
);

create table mv_compiler_regression__uvliw_by_branch
(
	id int unsigned auto_increment
		primary key,
	date datetime not null,
	version varchar(128) not null,
	build_id varchar(128) not null,
	branch varchar(128) not null,
	failed_tests int not null,
	passed_tests int not null,
	ip_name varchar(128) not null
);

create table mv_compiler_regression__uvliw_links
(
	id int auto_increment
		primary key,
	parameters varchar(250) null,
	version varchar(10) not null,
	build_id varchar(45) not null,
	OS varchar(45) not null,
	compiler varchar(10) null,
	branch varchar(100) null,
	date datetime not null,
	link_full text not null,
	test_status varchar(64) null
);

create table mv_compiler_regression__uvliw_sum_by_build
(
	id int auto_increment
		primary key,
	date datetime null,
	version_build_id varchar(100) not null,
	failed_tests_ia int not null,
	passed_tests_ia int not null,
	sum_tests_ia int not null,
	failed_tests_ca int not null,
	passed_tests_ca int not null,
	sum_tests_ca int not null
);


create table refresh_events_log
(
	id int auto_increment
		primary key,
	date_and_time datetime null,
	procedure_name varchar(100) null,
	mysql_return_code int null,
	message text null,
	duration time(6)
);

create index ix_refresh_events_log_build
	on refresh_events_log (date_and_time);

create index ix_refresh_events_log_created
	on refresh_events_log (procedure_name);