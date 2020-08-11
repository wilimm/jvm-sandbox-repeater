-- -------------------------------------------------------------------
-- -------------------------------------------------------------------
-- It's assumed you've executed database.sql with 'postgres' user.
-- This script is expected to be executed only once after we installed
-- PostgreSQL server. In the shell, execute the following command:
-- "psql athena -f tables.sql"
-- -------------------------------------------------------------------

BEGIN;

SET ROLE content;

CREATE OR REPLACE FUNCTION last_updated()
RETURNS TRIGGER AS $$

BEGIN
    NEW.last_updated = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TABLE mock_server_rule (
    id bigserial NOT NULL PRIMARY KEY,
    enable boolean  NOT NULL,
    service_name varchar(256) NOT NULL,
    request_url varchar(256) NOT NULL,
    headers varchar(256),
    http_method varchar(64) NOT NULL,
    query_params varchar(1024),
    matching_priority int NOT NULL,
    response text NOT NULL
);
CREATE INDEX ON mock_server_rule(request_url);
CREATE INDEX ON mock_server_rule(service_name);

CREATE TABLE record (
    id bigserial NOT NULL PRIMARY KEY,
    gmt_create timestamp with time zone, -- 创建时间
    gmt_record timestamp with time zone, -- 录制时间
    app_name VARCHAR(255) NOT NULL, -- 应用名
    environment VARCHAR(255) NOT NULL, -- 环境信息
    host VARCHAR(36) NOT NULL, -- 机器IP
    trace_id VARCHAR(32) NOT NULL, -- 链路追踪ID
    entrance_desc VARCHAR(2000) NOT NULL, -- 链路追踪ID
    wrapper_record TEXT NOT NULL, -- 记录序列化信息
    request TEXT NOT NULL, -- 请求参数JSON
    response TEXT NOT NULL, -- 返回值JSON
);

CREATE TABLE replay (
    id bigserial NOT NULL PRIMARY KEY,
    gmt_create timestamp with time zone, -- 创建时间
    gmt_modified timestamp with time zone, -- 修改时间
    app_name VARCHAR(255) NOT NULL, -- 应用名
    environment VARCHAR(255) NOT NULL, -- 环境信息
    ip VARCHAR(36) NOT NULL, -- 机器IP
    repeat_id VARCHAR(32) NOT NULL, -- 回放ID
    status smallint NOT NULL, -- 回放状态
    trace_id VARCHAR(32) NOT NULL, -- 链路追踪ID
    cost BIGINT(20)
        COMMENT '回放耗时',
    diff_result     LONGTEXT
        COMMENT 'diff结果',
    response        LONGTEXT
        COMMENT '回放结果',
    mock_invocation LONGTEXT
        COMMENT 'mock过程',
    success         BIT
        COMMENT '是否回放成功',
    record_id       BIGINT(20)
        COMMENT '外键'

)

COMMIT;