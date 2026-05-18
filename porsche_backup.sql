--
-- PostgreSQL database dump
--

\restrict qGOzIyj8SaXNRJg7A4f3qwSqFYBhJqAbDwGkahx8CdT5eQHfpZ85k0JEXiHScN2

-- Dumped from database version 17.6 (Debian 17.6-2.pgdg13+1)
-- Dumped by pg_dump version 17.6 (Debian 17.6-2.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: application; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    workspace_id character varying(64) NOT NULL,
    is_publish boolean NOT NULL,
    name character varying(128) NOT NULL,
    "desc" character varying(512) NOT NULL,
    prologue character varying(40960) NOT NULL,
    dialogue_number integer NOT NULL,
    knowledge_setting jsonb NOT NULL,
    model_setting jsonb NOT NULL,
    model_params_setting jsonb NOT NULL,
    tts_model_params_setting jsonb NOT NULL,
    problem_optimization boolean NOT NULL,
    icon character varying(256) NOT NULL,
    work_flow jsonb NOT NULL,
    type character varying(256) NOT NULL,
    problem_optimization_prompt character varying(102400),
    tts_model_enable boolean NOT NULL,
    stt_model_enable boolean NOT NULL,
    tts_type character varying(20) NOT NULL,
    tts_autoplay boolean NOT NULL,
    stt_autosend boolean NOT NULL,
    clean_time integer NOT NULL,
    publish_time timestamp with time zone,
    file_upload_enable boolean NOT NULL,
    file_upload_setting jsonb NOT NULL,
    model_id uuid,
    stt_model_id uuid,
    tts_model_id uuid,
    user_id uuid,
    folder_id character varying(64) NOT NULL,
    mcp_enable boolean NOT NULL,
    mcp_servers jsonb NOT NULL,
    mcp_source character varying(20) NOT NULL,
    mcp_tool_ids jsonb NOT NULL,
    tool_enable boolean NOT NULL,
    tool_ids jsonb NOT NULL,
    mcp_output_enable boolean NOT NULL,
    stt_model_params_setting jsonb NOT NULL
);


ALTER TABLE public.application OWNER TO root;

--
-- Name: application_access_token; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application_access_token (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    application_id uuid NOT NULL,
    access_token character varying(128) NOT NULL,
    is_active boolean NOT NULL,
    access_num integer NOT NULL,
    white_active boolean NOT NULL,
    white_list character varying(128)[] NOT NULL,
    show_source boolean NOT NULL,
    show_exec boolean NOT NULL,
    authentication boolean NOT NULL,
    authentication_value jsonb NOT NULL,
    language character varying(10)
);


ALTER TABLE public.application_access_token OWNER TO root;

--
-- Name: application_api_key; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application_api_key (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    secret_key character varying(1024) NOT NULL,
    workspace_id character varying(64) NOT NULL,
    is_active boolean NOT NULL,
    allow_cross_domain boolean NOT NULL,
    cross_domain_list character varying(128)[] NOT NULL,
    application_id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.application_api_key OWNER TO root;

--
-- Name: application_chat; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application_chat (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    abstract character varying(1024) NOT NULL,
    chat_user_id character varying,
    chat_user_type character varying(64) NOT NULL,
    is_deleted boolean NOT NULL,
    asker jsonb NOT NULL,
    meta jsonb NOT NULL,
    star_num integer NOT NULL,
    trample_num integer NOT NULL,
    chat_record_count integer NOT NULL,
    mark_sum integer NOT NULL,
    application_id uuid NOT NULL
);


ALTER TABLE public.application_chat OWNER TO root;

--
-- Name: application_chat_record; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application_chat_record (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    vote_status character varying(10) NOT NULL,
    problem_text character varying(10240) NOT NULL,
    answer_text character varying(40960) NOT NULL,
    answer_text_list jsonb[] NOT NULL,
    message_tokens integer NOT NULL,
    answer_tokens integer NOT NULL,
    const integer NOT NULL,
    details jsonb NOT NULL,
    improve_paragraph_id_list uuid[] NOT NULL,
    run_time double precision NOT NULL,
    index integer NOT NULL,
    chat_id uuid NOT NULL
);


ALTER TABLE public.application_chat_record OWNER TO root;

--
-- Name: application_chat_user_stats; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application_chat_user_stats (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    chat_user_id uuid NOT NULL,
    chat_user_type character varying(64) NOT NULL,
    access_num integer NOT NULL,
    intraday_access_num integer NOT NULL,
    application_id uuid NOT NULL
);


ALTER TABLE public.application_chat_user_stats OWNER TO root;

--
-- Name: application_folder; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application_folder (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    "desc" character varying(200),
    workspace_id character varying(64) NOT NULL,
    lft integer NOT NULL,
    rght integer NOT NULL,
    tree_id integer NOT NULL,
    level integer NOT NULL,
    parent_id character varying(64),
    user_id uuid,
    CONSTRAINT application_folder_level_check CHECK ((level >= 0)),
    CONSTRAINT application_folder_lft_check CHECK ((lft >= 0)),
    CONSTRAINT application_folder_rght_check CHECK ((rght >= 0)),
    CONSTRAINT application_folder_tree_id_check CHECK ((tree_id >= 0))
);


ALTER TABLE public.application_folder OWNER TO root;

--
-- Name: application_knowledge_mapping; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application_knowledge_mapping (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    application_id uuid NOT NULL,
    knowledge_id uuid NOT NULL
);


ALTER TABLE public.application_knowledge_mapping OWNER TO root;

--
-- Name: application_version; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.application_version (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    name character varying(128) NOT NULL,
    publish_user_id uuid,
    publish_user_name character varying(128) NOT NULL,
    workspace_id character varying(64) NOT NULL,
    application_name character varying(128) NOT NULL,
    "desc" character varying(512) NOT NULL,
    prologue character varying(40960) NOT NULL,
    dialogue_number integer NOT NULL,
    model_id uuid,
    knowledge_setting jsonb NOT NULL,
    model_setting jsonb NOT NULL,
    model_params_setting jsonb NOT NULL,
    tts_model_params_setting jsonb NOT NULL,
    problem_optimization boolean NOT NULL,
    icon character varying(256) NOT NULL,
    work_flow jsonb NOT NULL,
    type character varying(256) NOT NULL,
    problem_optimization_prompt character varying(102400),
    tts_model_id uuid,
    stt_model_id uuid,
    tts_model_enable boolean NOT NULL,
    stt_model_enable boolean NOT NULL,
    tts_type character varying(20) NOT NULL,
    tts_autoplay boolean NOT NULL,
    stt_autosend boolean NOT NULL,
    clean_time integer NOT NULL,
    file_upload_enable boolean NOT NULL,
    file_upload_setting jsonb NOT NULL,
    application_id uuid NOT NULL,
    user_id uuid,
    mcp_enable boolean NOT NULL,
    mcp_servers jsonb NOT NULL,
    mcp_source character varying(20) NOT NULL,
    mcp_tool_ids jsonb NOT NULL,
    tool_enable boolean NOT NULL,
    tool_ids jsonb NOT NULL,
    mcp_output_enable boolean NOT NULL,
    stt_model_params_setting jsonb NOT NULL
);


ALTER TABLE public.application_version OWNER TO root;

--
-- Name: chat_user; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.chat_user (
    id uuid NOT NULL,
    email character varying(254),
    phone character varying(20) NOT NULL,
    nick_name character varying(150) NOT NULL,
    username character varying(150) NOT NULL,
    password character varying(150) NOT NULL,
    source character varying(10) NOT NULL,
    is_active boolean NOT NULL,
    create_time timestamp with time zone,
    update_time timestamp with time zone
);


ALTER TABLE public.chat_user OWNER TO root;

--
-- Name: django_apscheduler_djangojob; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_apscheduler_djangojob (
    id character varying(255) NOT NULL,
    next_run_time timestamp with time zone,
    job_state bytea NOT NULL
);


ALTER TABLE public.django_apscheduler_djangojob OWNER TO root;

--
-- Name: django_apscheduler_djangojobexecution; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_apscheduler_djangojobexecution (
    id bigint NOT NULL,
    status character varying(50) NOT NULL,
    run_time timestamp with time zone NOT NULL,
    duration numeric(15,2),
    finished numeric(15,2),
    exception character varying(1000),
    traceback text,
    job_id character varying(255) NOT NULL
);


ALTER TABLE public.django_apscheduler_djangojobexecution OWNER TO root;

--
-- Name: django_apscheduler_djangojobexecution_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.django_apscheduler_djangojobexecution ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_apscheduler_djangojobexecution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_clockedschedule; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_celery_beat_clockedschedule (
    id integer NOT NULL,
    clocked_time timestamp with time zone NOT NULL
);


ALTER TABLE public.django_celery_beat_clockedschedule OWNER TO root;

--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.django_celery_beat_clockedschedule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_clockedschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_crontabschedule; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_celery_beat_crontabschedule (
    id integer NOT NULL,
    minute character varying(240) NOT NULL,
    hour character varying(96) NOT NULL,
    day_of_week character varying(64) NOT NULL,
    day_of_month character varying(124) NOT NULL,
    month_of_year character varying(64) NOT NULL,
    timezone character varying(63) NOT NULL
);


ALTER TABLE public.django_celery_beat_crontabschedule OWNER TO root;

--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.django_celery_beat_crontabschedule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_crontabschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_intervalschedule; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_celery_beat_intervalschedule (
    id integer NOT NULL,
    every integer NOT NULL,
    period character varying(24) NOT NULL
);


ALTER TABLE public.django_celery_beat_intervalschedule OWNER TO root;

--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.django_celery_beat_intervalschedule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_intervalschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_periodictask; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_celery_beat_periodictask (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    task character varying(200) NOT NULL,
    args text NOT NULL,
    kwargs text NOT NULL,
    queue character varying(200),
    exchange character varying(200),
    routing_key character varying(200),
    expires timestamp with time zone,
    enabled boolean NOT NULL,
    last_run_at timestamp with time zone,
    total_run_count integer NOT NULL,
    date_changed timestamp with time zone NOT NULL,
    description text NOT NULL,
    crontab_id integer,
    interval_id integer,
    solar_id integer,
    one_off boolean NOT NULL,
    start_time timestamp with time zone,
    priority integer,
    headers text NOT NULL,
    clocked_id integer,
    expire_seconds integer,
    CONSTRAINT django_celery_beat_periodictask_expire_seconds_check CHECK ((expire_seconds >= 0)),
    CONSTRAINT django_celery_beat_periodictask_priority_check CHECK ((priority >= 0)),
    CONSTRAINT django_celery_beat_periodictask_total_run_count_check CHECK ((total_run_count >= 0))
);


ALTER TABLE public.django_celery_beat_periodictask OWNER TO root;

--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.django_celery_beat_periodictask ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_periodictask_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_celery_beat_periodictasks; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_celery_beat_periodictasks (
    ident smallint NOT NULL,
    last_update timestamp with time zone NOT NULL
);


ALTER TABLE public.django_celery_beat_periodictasks OWNER TO root;

--
-- Name: django_celery_beat_solarschedule; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_celery_beat_solarschedule (
    id integer NOT NULL,
    event character varying(24) NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL
);


ALTER TABLE public.django_celery_beat_solarschedule OWNER TO root;

--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.django_celery_beat_solarschedule ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_celery_beat_solarschedule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO root;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO root;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: document; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.document (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    name character varying(150) NOT NULL,
    char_length integer NOT NULL,
    status character varying(20) NOT NULL,
    status_meta jsonb NOT NULL,
    is_active boolean NOT NULL,
    type integer NOT NULL,
    hit_handling_method character varying(20) NOT NULL,
    directly_return_similarity double precision NOT NULL,
    meta jsonb NOT NULL,
    knowledge_id uuid NOT NULL
);


ALTER TABLE public.document OWNER TO root;

--
-- Name: document_tag; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.document_tag (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    document_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.document_tag OWNER TO root;

--
-- Name: embedding; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.embedding (
    id character varying(128) NOT NULL,
    source_id character varying(128) NOT NULL,
    source_type character varying(5) NOT NULL,
    is_active boolean NOT NULL,
    embedding public.vector NOT NULL,
    search_vector tsvector NOT NULL,
    meta jsonb NOT NULL,
    document_id uuid NOT NULL,
    knowledge_id uuid NOT NULL,
    paragraph_id uuid NOT NULL
);


ALTER TABLE public.embedding OWNER TO root;

--
-- Name: file; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.file (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    file_name character varying(256) NOT NULL,
    file_size integer NOT NULL,
    sha256_hash character varying NOT NULL,
    source_type character varying NOT NULL,
    source_id character varying NOT NULL,
    loid integer NOT NULL,
    meta jsonb NOT NULL
);


ALTER TABLE public.file OWNER TO root;

--
-- Name: knowledge; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.knowledge (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    name character varying(150) NOT NULL,
    workspace_id character varying(64) NOT NULL,
    "desc" character varying(256) NOT NULL,
    type integer NOT NULL,
    scope character varying(20) NOT NULL,
    file_size_limit integer NOT NULL,
    file_count_limit integer NOT NULL,
    meta jsonb NOT NULL,
    embedding_model_id uuid,
    user_id uuid,
    folder_id character varying(64) NOT NULL
);


ALTER TABLE public.knowledge OWNER TO root;

--
-- Name: knowledge_action; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.knowledge_action (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    state character varying(20) NOT NULL,
    details jsonb NOT NULL,
    run_time double precision NOT NULL,
    meta jsonb NOT NULL,
    knowledge_id uuid NOT NULL
);


ALTER TABLE public.knowledge_action OWNER TO root;

--
-- Name: knowledge_folder; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.knowledge_folder (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    "desc" character varying(200),
    workspace_id character varying(64) NOT NULL,
    lft integer NOT NULL,
    rght integer NOT NULL,
    tree_id integer NOT NULL,
    level integer NOT NULL,
    parent_id character varying(64),
    user_id uuid,
    CONSTRAINT knowledge_folder_level_check CHECK ((level >= 0)),
    CONSTRAINT knowledge_folder_lft_check CHECK ((lft >= 0)),
    CONSTRAINT knowledge_folder_rght_check CHECK ((rght >= 0)),
    CONSTRAINT knowledge_folder_tree_id_check CHECK ((tree_id >= 0))
);


ALTER TABLE public.knowledge_folder OWNER TO root;

--
-- Name: knowledge_workflow; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.knowledge_workflow (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    workspace_id character varying(64) NOT NULL,
    work_flow jsonb NOT NULL,
    is_publish boolean NOT NULL,
    publish_time timestamp with time zone,
    knowledge_id uuid NOT NULL
);


ALTER TABLE public.knowledge_workflow OWNER TO root;

--
-- Name: knowledge_workflow_version; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.knowledge_workflow_version (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    workspace_id character varying(64) NOT NULL,
    work_flow jsonb NOT NULL,
    publish_user_id uuid,
    publish_user_name character varying(128) NOT NULL,
    knowledge_id uuid NOT NULL,
    name character varying(128) NOT NULL
);


ALTER TABLE public.knowledge_workflow_version OWNER TO root;

--
-- Name: log; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.log (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    menu character varying(128) NOT NULL,
    operate character varying(128) NOT NULL,
    operation_object jsonb NOT NULL,
    "user" jsonb NOT NULL,
    status integer NOT NULL,
    ip_address character varying(128) NOT NULL,
    details jsonb NOT NULL,
    workspace_id character varying(64) NOT NULL
);


ALTER TABLE public.log OWNER TO root;

--
-- Name: model; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.model (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    name character varying(128) NOT NULL,
    status character varying(20) NOT NULL,
    model_type character varying(128) NOT NULL,
    model_name character varying(128) NOT NULL,
    provider character varying(128) NOT NULL,
    credential character varying(102400) NOT NULL,
    meta jsonb NOT NULL,
    model_params_form jsonb NOT NULL,
    workspace_id character varying(64) NOT NULL,
    user_id uuid
);


ALTER TABLE public.model OWNER TO root;

--
-- Name: paragraph; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.paragraph (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    content character varying(102400) NOT NULL,
    title character varying(256) NOT NULL,
    status character varying(20) NOT NULL,
    status_meta jsonb NOT NULL,
    hit_num integer NOT NULL,
    is_active boolean NOT NULL,
    "position" integer NOT NULL,
    document_id uuid NOT NULL,
    knowledge_id uuid NOT NULL,
    chunks character varying[] NOT NULL
);


ALTER TABLE public.paragraph OWNER TO root;

--
-- Name: problem; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.problem (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    content character varying(256) NOT NULL,
    hit_num integer NOT NULL,
    knowledge_id uuid NOT NULL
);


ALTER TABLE public.problem OWNER TO root;

--
-- Name: problem_paragraph_mapping; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.problem_paragraph_mapping (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    document_id uuid NOT NULL,
    knowledge_id uuid NOT NULL,
    paragraph_id uuid NOT NULL,
    problem_id uuid NOT NULL
);


ALTER TABLE public.problem_paragraph_mapping OWNER TO root;

--
-- Name: resource_chat_user_authorize; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.resource_chat_user_authorize (
    id uuid NOT NULL,
    workspace_id character varying(64),
    resource_id uuid NOT NULL,
    resource_type character varying NOT NULL,
    is_auth boolean NOT NULL,
    user_id uuid NOT NULL,
    user_group_id character varying(128) NOT NULL
);


ALTER TABLE public.resource_chat_user_authorize OWNER TO root;

--
-- Name: resource_chat_user_group_authorize; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.resource_chat_user_group_authorize (
    id uuid NOT NULL,
    workspace_id character varying(64),
    resource_id uuid NOT NULL,
    resource_type character varying NOT NULL,
    is_auth boolean NOT NULL,
    user_group_id character varying(128) NOT NULL
);


ALTER TABLE public.resource_chat_user_group_authorize OWNER TO root;

--
-- Name: system_setting; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.system_setting (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    type integer NOT NULL,
    meta jsonb NOT NULL
);


ALTER TABLE public.system_setting OWNER TO root;

--
-- Name: tag; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.tag (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    key character varying(64) NOT NULL,
    value character varying(128) NOT NULL,
    knowledge_id uuid NOT NULL
);


ALTER TABLE public.tag OWNER TO root;

--
-- Name: tool; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.tool (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id uuid NOT NULL,
    name character varying(64) NOT NULL,
    "desc" character varying(128) NOT NULL,
    code character varying(102400) NOT NULL,
    input_field_list jsonb NOT NULL,
    init_field_list jsonb NOT NULL,
    icon character varying(256) NOT NULL,
    is_active boolean NOT NULL,
    scope character varying(20) NOT NULL,
    tool_type character varying(20) NOT NULL,
    template_id character varying(128),
    workspace_id character varying(64) NOT NULL,
    init_params character varying(102400),
    label character varying(128),
    user_id uuid,
    folder_id character varying(64) NOT NULL,
    version character varying(64)
);


ALTER TABLE public.tool OWNER TO root;

--
-- Name: tool_folder; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.tool_folder (
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    id character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    "desc" character varying(200),
    workspace_id character varying(64) NOT NULL,
    lft integer NOT NULL,
    rght integer NOT NULL,
    tree_id integer NOT NULL,
    level integer NOT NULL,
    parent_id character varying(64),
    user_id uuid,
    CONSTRAINT tool_folder_level_check CHECK ((level >= 0)),
    CONSTRAINT tool_folder_lft_check CHECK ((lft >= 0)),
    CONSTRAINT tool_folder_rght_check CHECK ((rght >= 0)),
    CONSTRAINT tool_folder_tree_id_check CHECK ((tree_id >= 0))
);


ALTER TABLE public.tool_folder OWNER TO root;

--
-- Name: user; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."user" (
    id uuid NOT NULL,
    email character varying(254),
    phone character varying(20) NOT NULL,
    nick_name character varying(150) NOT NULL,
    username character varying(150) NOT NULL,
    password character varying(150) NOT NULL,
    role character varying(150) NOT NULL,
    source character varying(10) NOT NULL,
    is_active boolean NOT NULL,
    language character varying(10),
    create_time timestamp with time zone,
    update_time timestamp with time zone
);


ALTER TABLE public."user" OWNER TO root;

--
-- Name: user_group; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.user_group (
    id character varying(128) NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.user_group OWNER TO root;

--
-- Name: user_group_relation; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.user_group_relation (
    id uuid NOT NULL,
    group_id character varying(128) NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.user_group_relation OWNER TO root;

--
-- Name: workspace_user_resource_permission; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.workspace_user_resource_permission (
    id uuid NOT NULL,
    workspace_id character varying(128) NOT NULL,
    auth_target_type character varying(128) NOT NULL,
    target character varying(128) NOT NULL,
    auth_type character varying DEFAULT 'ROLE'::character varying NOT NULL,
    permission_list character varying(256)[] NOT NULL,
    create_time timestamp with time zone NOT NULL,
    update_time timestamp with time zone NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE public.workspace_user_resource_permission OWNER TO root;

--
-- Data for Name: application; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application (create_time, update_time, id, workspace_id, is_publish, name, "desc", prologue, dialogue_number, knowledge_setting, model_setting, model_params_setting, tts_model_params_setting, problem_optimization, icon, work_flow, type, problem_optimization_prompt, tts_model_enable, stt_model_enable, tts_type, tts_autoplay, stt_autosend, clean_time, publish_time, file_upload_enable, file_upload_setting, model_id, stt_model_id, tts_model_id, user_id, folder_id, mcp_enable, mcp_servers, mcp_source, mcp_tool_ids, tool_enable, tool_ids, mcp_output_enable, stt_model_params_setting) FROM stdin;
\.


--
-- Data for Name: application_access_token; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application_access_token (create_time, update_time, application_id, access_token, is_active, access_num, white_active, white_list, show_source, show_exec, authentication, authentication_value, language) FROM stdin;
\.


--
-- Data for Name: application_api_key; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application_api_key (create_time, update_time, id, secret_key, workspace_id, is_active, allow_cross_domain, cross_domain_list, application_id, user_id) FROM stdin;
\.


--
-- Data for Name: application_chat; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application_chat (create_time, update_time, id, abstract, chat_user_id, chat_user_type, is_deleted, asker, meta, star_num, trample_num, chat_record_count, mark_sum, application_id) FROM stdin;
\.


--
-- Data for Name: application_chat_record; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application_chat_record (create_time, update_time, id, vote_status, problem_text, answer_text, answer_text_list, message_tokens, answer_tokens, const, details, improve_paragraph_id_list, run_time, index, chat_id) FROM stdin;
\.


--
-- Data for Name: application_chat_user_stats; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application_chat_user_stats (create_time, update_time, id, chat_user_id, chat_user_type, access_num, intraday_access_num, application_id) FROM stdin;
\.


--
-- Data for Name: application_folder; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application_folder (create_time, update_time, id, name, "desc", workspace_id, lft, rght, tree_id, level, parent_id, user_id) FROM stdin;
2026-05-07 15:08:38.542745+08	2026-05-07 15:08:38.542762+08	default	根目录	\N	default	1	2	1	0	\N	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab
\.


--
-- Data for Name: application_knowledge_mapping; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application_knowledge_mapping (create_time, update_time, id, application_id, knowledge_id) FROM stdin;
\.


--
-- Data for Name: application_version; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.application_version (create_time, update_time, id, name, publish_user_id, publish_user_name, workspace_id, application_name, "desc", prologue, dialogue_number, model_id, knowledge_setting, model_setting, model_params_setting, tts_model_params_setting, problem_optimization, icon, work_flow, type, problem_optimization_prompt, tts_model_id, stt_model_id, tts_model_enable, stt_model_enable, tts_type, tts_autoplay, stt_autosend, clean_time, file_upload_enable, file_upload_setting, application_id, user_id, mcp_enable, mcp_servers, mcp_source, mcp_tool_ids, tool_enable, tool_ids, mcp_output_enable, stt_model_params_setting) FROM stdin;
\.


--
-- Data for Name: chat_user; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.chat_user (id, email, phone, nick_name, username, password, source, is_active, create_time, update_time) FROM stdin;
\.


--
-- Data for Name: django_apscheduler_djangojob; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_apscheduler_djangojob (id, next_run_time, job_state) FROM stdin;
clean_chat_log	2026-05-08 00:05:00+08	\\x80059528040000000000007d94288c0776657273696f6e944b018c026964948c0e636c65616e5f636861745f6c6f67948c0466756e63948c2c636f6d6d6f6e2e6a6f622e636c65616e5f636861745f6a6f623a636c65616e5f636861745f6c6f675f6a6f62948c0774726967676572948c1961707363686564756c65722e74726967676572732e63726f6e948c0b43726f6e547269676765729493942981947d942868014b028c0874696d657a6f6e65948c086275696c74696e73948c07676574617474729493948c087a6f6e65696e666f948c085a6f6e65496e666f9493948c095f756e7069636b6c6594869452948c0d417369612f5368616e67686169944b01869452948c0a73746172745f64617465944e8c08656e645f64617465944e8c066669656c6473945d94288c2061707363686564756c65722e74726967676572732e63726f6e2e6669656c6473948c09426173654669656c649493942981947d94288c046e616d65948c0479656172948c0a69735f64656661756c7494888c0b65787072657373696f6e73945d948c2561707363686564756c65722e74726967676572732e63726f6e2e65787072657373696f6e73948c0d416c6c45787072657373696f6e9493942981947d948c0473746570944e7362617562681d8c0a4d6f6e74684669656c649493942981947d942868228c056d6f6e74689468248868255d9468292981947d94682c4e7362617562681d8c0f4461794f664d6f6e74684669656c649493942981947d942868228c036461799468248868255d9468292981947d94682c4e7362617562681d8c095765656b4669656c649493942981947d942868228c047765656b9468248868255d9468292981947d94682c4e7362617562681d8c0e4461794f665765656b4669656c649493942981947d942868228c0b6461795f6f665f7765656b9468248868255d9468292981947d94682c4e7362617562681f2981947d942868228c04686f75729468248968255d9468278c0f52616e676545787072657373696f6e9493942981947d9428682c4e8c056669727374944b008c046c617374944b007562617562681f2981947d942868228c066d696e7574659468248968255d9468522981947d9428682c4e68554b0568564b057562617562681f2981947d942868228c067365636f6e649468248868255d9468522981947d9428682c4e68554b0068564b007562617562658c066a6974746572944e75628c086578656375746f72948c0764656661756c74948c046172677394298c066b7761726773947d9468228c12636c65616e5f636861745f6c6f675f6a6f62948c126d6973666972655f67726163655f74696d65944b018c08636f616c6573636594888c0d6d61785f696e7374616e636573944b018c0d6e6578745f72756e5f74696d65948c086461746574696d65948c086461746574696d65949394430a07ea050800050000000094681886945294752e
clean_debug_file	2026-05-07 15:30:00+08	\\x8005950a040000000000007d94288c0776657273696f6e944b018c026964948c10636c65616e5f64656275675f66696c65948c0466756e63948c30636f6d6d6f6e2e6a6f622e636c65616e5f64656275675f66696c655f6a6f623a636c65616e5f64656275675f66696c65948c0774726967676572948c1961707363686564756c65722e74726967676572732e63726f6e948c0b43726f6e547269676765729493942981947d942868014b028c0874696d657a6f6e65948c086275696c74696e73948c07676574617474729493948c087a6f6e65696e666f948c085a6f6e65496e666f9493948c095f756e7069636b6c6594869452948c0d417369612f5368616e67686169944b01869452948c0a73746172745f64617465944e8c08656e645f64617465944e8c066669656c6473945d94288c2061707363686564756c65722e74726967676572732e63726f6e2e6669656c6473948c09426173654669656c649493942981947d94288c046e616d65948c0479656172948c0a69735f64656661756c7494888c0b65787072657373696f6e73945d948c2561707363686564756c65722e74726967676572732e63726f6e2e65787072657373696f6e73948c0d416c6c45787072657373696f6e9493942981947d948c0473746570944e7362617562681d8c0a4d6f6e74684669656c649493942981947d942868228c056d6f6e74689468248868255d9468292981947d94682c4e7362617562681d8c0f4461794f664d6f6e74684669656c649493942981947d942868228c036461799468248868255d9468292981947d94682c4e7362617562681d8c095765656b4669656c649493942981947d942868228c047765656b9468248868255d9468292981947d94682c4e7362617562681d8c0e4461794f665765656b4669656c649493942981947d942868228c0b6461795f6f665f7765656b9468248868255d9468292981947d94682c4e7362617562681f2981947d942868228c04686f75729468248968255d9468292981947d94682c4e7362617562681f2981947d942868228c066d696e7574659468248968255d9468292981947d94682c4b1e7362617562681f2981947d942868228c067365636f6e649468248968255d9468278c0f52616e676545787072657373696f6e9493942981947d9428682c4e8c056669727374944b008c046c617374944b007562617562658c066a6974746572944e75628c086578656375746f72948c0764656661756c74948c046172677394298c066b7761726773947d94682268038c126d6973666972655f67726163655f74696d65944b018c08636f616c6573636594888c0d6d61785f696e7374616e636573944b018c0d6e6578745f72756e5f74696d65948c086461746574696d65948c086461746574696d65949394430a07ea05070f1e0000000094681886945294752e
access_num_reset	2026-05-08 00:00:00+08	\\x80059543040000000000007d94288c0776657273696f6e944b018c026964948c106163636573735f6e756d5f7265736574948c0466756e63948c3c636f6d6d6f6e2e6a6f622e636c69656e745f6163636573735f6e756d5f6a6f623a636c69656e745f6163636573735f6e756d5f72657365745f6a6f62948c0774726967676572948c1961707363686564756c65722e74726967676572732e63726f6e948c0b43726f6e547269676765729493942981947d942868014b028c0874696d657a6f6e65948c086275696c74696e73948c07676574617474729493948c087a6f6e65696e666f948c085a6f6e65496e666f9493948c095f756e7069636b6c6594869452948c0d417369612f5368616e67686169944b01869452948c0a73746172745f64617465944e8c08656e645f64617465944e8c066669656c6473945d94288c2061707363686564756c65722e74726967676572732e63726f6e2e6669656c6473948c09426173654669656c649493942981947d94288c046e616d65948c0479656172948c0a69735f64656661756c7494888c0b65787072657373696f6e73945d948c2561707363686564756c65722e74726967676572732e63726f6e2e65787072657373696f6e73948c0d416c6c45787072657373696f6e9493942981947d948c0473746570944e7362617562681d8c0a4d6f6e74684669656c649493942981947d942868228c056d6f6e74689468248868255d9468292981947d94682c4e7362617562681d8c0f4461794f664d6f6e74684669656c649493942981947d942868228c036461799468248868255d9468292981947d94682c4e7362617562681d8c095765656b4669656c649493942981947d942868228c047765656b9468248868255d9468292981947d94682c4e7362617562681d8c0e4461794f665765656b4669656c649493942981947d942868228c0b6461795f6f665f7765656b9468248868255d9468292981947d94682c4e7362617562681f2981947d942868228c04686f75729468248968255d9468278c0f52616e676545787072657373696f6e9493942981947d9428682c4e8c056669727374944b008c046c617374944b007562617562681f2981947d942868228c066d696e7574659468248968255d9468522981947d9428682c4e68554b0068564b007562617562681f2981947d942868228c067365636f6e649468248968255d9468522981947d9428682c4e68554b0068564b007562617562658c066a6974746572944e75628c086578656375746f72948c0764656661756c74948c046172677394298c066b7761726773947d9468228c1b636c69656e745f6163636573735f6e756d5f72657365745f6a6f62948c126d6973666972655f67726163655f74696d65944b018c08636f616c6573636594888c0d6d61785f696e7374616e636573944b018c0d6e6578745f72756e5f74696d65948c086461746574696d65948c086461746574696d65949394430a07ea050800000000000094681886945294752e
\.


--
-- Data for Name: django_apscheduler_djangojobexecution; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_apscheduler_djangojobexecution (id, status, run_time, duration, finished, exception, traceback, job_id) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_clockedschedule; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_celery_beat_clockedschedule (id, clocked_time) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_crontabschedule; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_celery_beat_crontabschedule (id, minute, hour, day_of_week, day_of_month, month_of_year, timezone) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_intervalschedule; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_celery_beat_intervalschedule (id, every, period) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_periodictask; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_celery_beat_periodictask (id, name, task, args, kwargs, queue, exchange, routing_key, expires, enabled, last_run_at, total_run_count, date_changed, description, crontab_id, interval_id, solar_id, one_off, start_time, priority, headers, clocked_id, expire_seconds) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_periodictasks; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_celery_beat_periodictasks (ident, last_update) FROM stdin;
\.


--
-- Data for Name: django_celery_beat_solarschedule; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_celery_beat_solarschedule (id, event, latitude, longitude) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	contenttypes	contenttype
2	users	user
3	tools	toolfolder
4	tools	tool
5	knowledge	file
6	knowledge	knowledge
7	knowledge	document
8	knowledge	knowledgefolder
9	knowledge	paragraph
10	knowledge	embedding
11	knowledge	problem
12	knowledge	problemparagraphmapping
13	knowledge	tag
14	knowledge	documenttag
15	knowledge	knowledgeworkflow
16	knowledge	knowledgeworkflowversion
17	knowledge	knowledgeaction
18	system_manage	chatuser
19	system_manage	log
20	system_manage	systemsetting
21	system_manage	usergroup
22	system_manage	usergrouprelation
23	system_manage	workspaceuserresourcepermission
24	system_manage	resourcechatusergroupauthorize
25	system_manage	resourcechatuserauthorize
26	models_provider	model
27	django_celery_beat	crontabschedule
28	django_celery_beat	intervalschedule
29	django_celery_beat	periodictask
30	django_celery_beat	periodictasks
31	django_celery_beat	solarschedule
32	django_celery_beat	clockedschedule
33	application	application
34	application	applicationaccesstoken
35	application	applicationapikey
36	application	applicationfolder
37	application	applicationknowledgemapping
38	application	applicationversion
39	application	chat
40	application	chatrecord
41	application	applicationchatuserstats
42	django_apscheduler	djangojob
43	django_apscheduler	djangojobexecution
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	users	0001_initial	2026-05-07 15:08:36.593302+08
2	system_manage	0001_initial	2026-05-07 15:08:36.714695+08
3	models_provider	0001_initial	2026-05-07 15:08:38.163081+08
4	knowledge	0001_initial	2026-05-07 15:08:38.332202+08
5	application	0001_initial	2026-05-07 15:08:38.647733+08
6	application	0002_application_simple_mcp	2026-05-07 15:08:39.188753+08
7	application	0003_application_stt_model_params_setting_and_more	2026-05-07 15:08:39.265666+08
8	contenttypes	0001_initial	2026-05-07 15:08:39.274486+08
9	contenttypes	0002_remove_content_type_name	2026-05-07 15:08:39.3251+08
10	django_apscheduler	0001_initial	2026-05-07 15:08:39.352706+08
11	django_apscheduler	0002_auto_20180412_0758	2026-05-07 15:08:39.360228+08
12	django_apscheduler	0003_auto_20200716_1632	2026-05-07 15:08:39.400041+08
13	django_apscheduler	0004_auto_20200717_1043	2026-05-07 15:08:39.458196+08
14	django_apscheduler	0005_migrate_name_to_id	2026-05-07 15:08:39.496046+08
15	django_apscheduler	0006_remove_djangojob_name	2026-05-07 15:08:39.501477+08
16	django_apscheduler	0007_auto_20200717_1404	2026-05-07 15:08:39.511707+08
17	django_apscheduler	0008_remove_djangojobexecution_started	2026-05-07 15:08:39.517396+08
18	django_apscheduler	0009_djangojobexecution_unique_job_executions	2026-05-07 15:08:39.523536+08
19	django_celery_beat	0001_initial	2026-05-07 15:08:39.548106+08
20	django_celery_beat	0002_auto_20161118_0346	2026-05-07 15:08:39.560215+08
21	django_celery_beat	0003_auto_20161209_0049	2026-05-07 15:08:39.569228+08
22	django_celery_beat	0004_auto_20170221_0000	2026-05-07 15:08:39.574148+08
23	django_celery_beat	0005_add_solarschedule_events_choices	2026-05-07 15:08:39.579443+08
24	django_celery_beat	0006_auto_20180322_0932	2026-05-07 15:08:39.621052+08
25	django_celery_beat	0007_auto_20180521_0826	2026-05-07 15:08:39.642504+08
26	django_celery_beat	0008_auto_20180914_1922	2026-05-07 15:08:39.681845+08
27	django_celery_beat	0006_auto_20180210_1226	2026-05-07 15:08:39.705503+08
28	django_celery_beat	0006_periodictask_priority	2026-05-07 15:08:39.717066+08
29	django_celery_beat	0009_periodictask_headers	2026-05-07 15:08:39.7288+08
30	django_celery_beat	0010_auto_20190429_0326	2026-05-07 15:08:40.062112+08
31	django_celery_beat	0011_auto_20190508_0153	2026-05-07 15:08:40.080929+08
32	django_celery_beat	0012_periodictask_expire_seconds	2026-05-07 15:08:40.094433+08
33	django_celery_beat	0013_auto_20200609_0727	2026-05-07 15:08:40.107743+08
34	django_celery_beat	0014_remove_clockedschedule_enabled	2026-05-07 15:08:40.115443+08
35	django_celery_beat	0015_edit_solarschedule_events_choices	2026-05-07 15:08:40.120905+08
36	django_celery_beat	0016_alter_crontabschedule_timezone	2026-05-07 15:08:40.132901+08
37	django_celery_beat	0017_alter_crontabschedule_month_of_year	2026-05-07 15:08:40.142962+08
38	django_celery_beat	0018_improve_crontab_helptext	2026-05-07 15:08:40.153035+08
39	django_celery_beat	0019_alter_periodictasks_options	2026-05-07 15:08:40.156463+08
40	knowledge	0002_alter_file_source_type	2026-05-07 15:08:40.204097+08
41	knowledge	0003_tag_documenttag	2026-05-07 15:08:40.305875+08
42	knowledge	0004_alter_document_type_alter_knowledge_type_and_more	2026-05-07 15:08:40.485847+08
43	knowledge	0005_knowledgeaction	2026-05-07 15:08:40.524186+08
44	knowledge	0006_paragraph_chunks	2026-05-07 15:08:40.548701+08
45	knowledge	0007_remove_knowledgeworkflowversion_workflow_and_more	2026-05-07 15:08:40.5965+08
46	tools	0001_initial	2026-05-07 15:08:40.756708+08
47	system_manage	0002_refresh_collation_reindex	2026-05-07 15:08:41.004687+08
48	system_manage	0003_alter_workspaceuserresourcepermission_target	2026-05-07 15:08:41.104818+08
49	system_manage	0004_alter_systemsetting_type_and_more	2026-05-07 15:08:41.18331+08
50	tools	0002_alter_tool_tool_type	2026-05-07 15:08:41.201378+08
51	tools	0003_alter_tool_template_id	2026-05-07 15:08:41.248839+08
52	tools	0004_alter_tool_tool_type	2026-05-07 15:08:41.273676+08
\.


--
-- Data for Name: document; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.document (create_time, update_time, id, name, char_length, status, status_meta, is_active, type, hit_handling_method, directly_return_similarity, meta, knowledge_id) FROM stdin;
\.


--
-- Data for Name: document_tag; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.document_tag (create_time, update_time, id, document_id, tag_id) FROM stdin;
\.


--
-- Data for Name: embedding; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.embedding (id, source_id, source_type, is_active, embedding, search_vector, meta, document_id, knowledge_id, paragraph_id) FROM stdin;
\.


--
-- Data for Name: file; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.file (create_time, update_time, id, file_name, file_size, sha256_hash, source_type, source_id, loid, meta) FROM stdin;
\.


--
-- Data for Name: knowledge; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.knowledge (create_time, update_time, id, name, workspace_id, "desc", type, scope, file_size_limit, file_count_limit, meta, embedding_model_id, user_id, folder_id) FROM stdin;
\.


--
-- Data for Name: knowledge_action; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.knowledge_action (create_time, update_time, id, state, details, run_time, meta, knowledge_id) FROM stdin;
\.


--
-- Data for Name: knowledge_folder; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.knowledge_folder (create_time, update_time, id, name, "desc", workspace_id, lft, rght, tree_id, level, parent_id, user_id) FROM stdin;
2026-05-07 15:08:38.265454+08	2026-05-07 15:08:38.26547+08	default	根目录	\N	default	1	2	1	0	\N	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab
\.


--
-- Data for Name: knowledge_workflow; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.knowledge_workflow (create_time, update_time, id, workspace_id, work_flow, is_publish, publish_time, knowledge_id) FROM stdin;
\.


--
-- Data for Name: knowledge_workflow_version; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.knowledge_workflow_version (create_time, update_time, id, workspace_id, work_flow, publish_user_id, publish_user_name, knowledge_id, name) FROM stdin;
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.log (create_time, update_time, id, menu, operate, operation_object, "user", status, ip_address, details, workspace_id) FROM stdin;
2026-05-07 15:12:11.411226+08	2026-05-07 15:12:11.411263+08	019e0147-9e92-7d21-89a6-a38187e3a6c2	User management	Log in	{"name": "admin"}	{"username": "admin"}	500	192.168.65.1	{"body": {"captcha": "", "password": "Porsch***************3...", "username": "admin", "email_code": "", "encryptedData": "XUwdUMrzajyxU0h03besOT7TJ18CPVYB0o6wm4WcKn1y0fO98sk4MhWWoi6TC0FTodT6r/8eYOxy4ocvi5qir4VxiaBDwWJlGCpHLsRYyvoYfeIHX29/UBa1Lnq4ZfDmqzAe8vsLMlMR6Afz6KbZhWXBykbT/qcB5eZ9bvt6kV2HIQ0zxd+delaT1QlVX1ZLVOeR549p3A28iW1Z7BXUji6ONfCaDh8ElpOvMk0FapaL2VlAuS32bH6F4R853k/W8xjuoz7qfdrWMkTz1InGSkqHoeiYeHXKTOYm+YuHPmWX1b7VSyzhXOK26ixvg6mn2QMj58eLsgh9vsBPzoXZlg=="}, "path": "/admin/api/user/login", "query": {}}	None
2026-05-07 15:12:21.340373+08	2026-05-07 15:12:21.340425+08	019e0147-c55b-7690-a048-b93a55c17ac7	User management	Log in	{"name": "admin"}	{"username": "admin"}	200	192.168.65.1	{"body": {"captcha": "9klt", "password": "Porsch***************23..", "username": "admin", "email_code": "", "encryptedData": "WwHTZgkx7exvJfTtv2DGGGHH+bpsdIfThs2pprZjX2xg5Ck7QdbVR1rB0H79ym2U27UDlQkSz7eL6mMkzuyM9+qe3b5V2/hgxtje0Id5AdBK84FNLa07YFZD0jq8xY1ARPoQhcM6CESNnBqlKrrT4jC3HehohaGCcoKsxbHuokomAHVrc6DSFM9hs4XV5VRFThEGl0yPH4Vf6kZyrxPbrI1+4hOdXQWBamXjtP2o1FHCOMPN4vgMdMb8r9pU0F+yPSfhd9jLK0cVC2oCaDMjt49YZgk/PsNf5mITZYUjtTHLtJxAmVAs9gES7FGxUSG73T2LoUoBDFZJVNSUH0jUIw=="}, "path": "/admin/api/user/login", "query": {}}	None
2026-05-07 15:12:28.948744+08	2026-05-07 15:12:28.948764+08	019e0147-e314-7623-bc3f-4272372984c4	User management	Modify current user password	{"name": "admin"}	{"id": "f0dd8f71-e4ee-11ee-8c84-a8a1595801ab", "role": "ADMIN", "email": "", "phone": "", "username": "admin", "nick_name": "系统管理员"}	200	192.168.65.1	{"body": {"password": "Porsch***************3...", "re_password": "Porsch***************3..."}, "path": "/admin/api/user/current/reset_password", "query": {}}	None
2026-05-07 15:12:30.957071+08	2026-05-07 15:12:30.957188+08	019e0147-eaec-7323-8900-f8a6de57e295	User management	Log in	{"name": "admin"}	{"username": "admin"}	200	192.168.65.1	{"body": {"captcha": "", "password": "Porsch***************3...", "username": "admin", "email_code": "", "encryptedData": "WDLT4pab5F13twB+Dg6q0iRpkAmU3tJLs5Avn1LbaD7LqyCcJ7QAhPeFD0KVXekj4ZJMFxmq92festUSeRBn1DUsPr2zGNcb/nBZWr6jb6XhSZGvSsc8spD6axWrqeVZ2kAK3Vhm8e93YWiYDWJkzo0NIsLFJPd2VSM6km9Kzs9dFdkgU5v5k2C3MK87/avuGUrM/n4w6DHBQkDljGh+uh+9r84vVQ1dg3crVF7NclC0oIKwRp71JW9EeZWYFyrheJCA0j/rfvbS4FGGjSm1nCS333vQB+VJAVRLuoSMVvgMmeRcelQcWECC4ZZpbgzdebd/1NEMFjzqNw3mIK5Exw=="}, "path": "/admin/api/user/login", "query": {}}	None
\.


--
-- Data for Name: model; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.model (create_time, update_time, id, name, status, model_type, model_name, provider, credential, meta, model_params_form, workspace_id, user_id) FROM stdin;
2026-05-07 15:08:38.145303+08	2026-05-07 15:08:38.145318+08	42f63a3d-427e-11ef-b3ec-a8a1595801ab	porsche-embedding	SUCCESS	EMBEDDING	/opt/porsche-app/model/embedding/shibing624_text2vec-base-chinese	model_local_provider	QgMowpm+0uzW6DoD5tS9L3gujWq+jgg1Efr4k+ux1BDzCTfnf10MtEQpgTt5t5MR2H5KZjOBBZu8pcSc3PJ5o3ddGFJFBtmKQ2vdpG9wbXy3gUuJYm1BzVmRlgKq34vhTC/lpsOV9KZHQejnyRCCuvJMZ43Vq4nSPgoV98O4mmkb/arNbIcLdRDM2leuemjBtJvbfs5JLigk2b2Qw5ya5TgYZ98YRNpwD9+tGpasvMibuRzsbtxastoawcP0mJmS7ZoNKAy5N6EStEyakuS4V+hOy/BCHks+rb3crb0F7WWuywP4CsLH+nxfLB5cHW8dwcWAWdmF6/JWS66IYnffYA==	{}	[]	default	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab
\.


--
-- Data for Name: paragraph; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.paragraph (create_time, update_time, id, content, title, status, status_meta, hit_num, is_active, "position", document_id, knowledge_id, chunks) FROM stdin;
\.


--
-- Data for Name: problem; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.problem (create_time, update_time, id, content, hit_num, knowledge_id) FROM stdin;
\.


--
-- Data for Name: problem_paragraph_mapping; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.problem_paragraph_mapping (create_time, update_time, id, document_id, knowledge_id, paragraph_id, problem_id) FROM stdin;
\.


--
-- Data for Name: resource_chat_user_authorize; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.resource_chat_user_authorize (id, workspace_id, resource_id, resource_type, is_auth, user_id, user_group_id) FROM stdin;
\.


--
-- Data for Name: resource_chat_user_group_authorize; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.resource_chat_user_group_authorize (id, workspace_id, resource_id, resource_type, is_auth, user_group_id) FROM stdin;
\.


--
-- Data for Name: system_setting; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.system_setting (create_time, update_time, type, meta) FROM stdin;
2026-05-07 15:08:38.140052+08	2026-05-07 15:08:38.140075+08	1	{"key": "-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkDHUuc6nEwA8snJwBEq8\\nu135++i8I8ksiMq5EuHnvd20xj1rPbN2VOAJXn27+olg8uF5rD1s6dCHlxrSwpXX\\nCP9wfWpwgrqtPwHRVRynT+WtZdGyoMrQVQca0tm9C1Gs4qWDBAhkqvCL5HOokzla\\nqhQldhT6Y90LCm0MBPvnZ1iqjcYkEV3hJQ4DjwchvXQNGFY5ZDzEVIh3ZGvSHgVk\\n0NkInidmvKTEMEgIlSHbUWfsTJsVGl6Ws77QfMSm0Z2SBDgBg3yVh7ruz/4BPeiM\\n0G3cBFM7X3VD6VtUFk4pGzwqjkqJOrMAbTIdEUursviE3bwrs3ObPVDkZME0GVVu\\nowIDAQAB\\n-----END PUBLIC KEY-----", "value": "-----BEGIN ENCRYPTED PRIVATE KEY-----\\nMIIFJTBPBgkqhkiG9w0BBQ0wQjAhBgkrBgEEAdpHBAswFAQIr7Q9qScHxQgCAkAA\\nAgEIAgEBMB0GCWCGSAFlAwQBAgQQMlNVrrDz2ef1V5Rt1b2lygSCBNC1BrAlYN8f\\nq2LOUgttQC1K/3IIjrNQEQkp0/MY1wXcCoZ2jaZ4Pd/10gQDLTWDxfytn8lJluoY\\nO1yFb4VPuHfX8YEJiu7GIrw+YLfRIjI0CqlEINomWnvoPAdXbYGVeEJiweaUSe+i\\n7eYcv/FyEhXJFS8ovMDdYY4rB8b6YBPIQopRAkN4exHI+MmIPGf0gjDbQQPw2N0N\\ng/nKqB83Cs1ECYzfc5El5xXWipJ0VpuoyU52DjIgCNYuMKDwHhIjmTTVgF/Yz0DN\\nACQXklAE/P7g0UoIobGBgtU22sDEetnz6W76xOXxUIL3FY2UVGY9lCZ8Zs0DrSDh\\n7LEANWJBpBQ6QaOrNgNM9SvLKx1GbS5uQdSUVLBrJ3c1ml2Uymi9uqGe2gt/VDvM\\n7+gWpTbDnBcq3ankpjX/o9sfr3gdtsENbio1sIuLpiBHJFzyCjFO+vtVuM+x48CH\\nuxiw1XHvVQdDLtbqqPrJew9L7VqMbqCogueOerJH7Xod0pX1I3+uqhdsMOdd2uak\\ngnkblF8TGF9ccYgN9EqqPB3msLnDoeLVH0rNMnR8PXtcjuBrmkF1tarB1zk3zCNa\\niw8/tnIx1OPJUUjuap3Aa7ZoPtJvrZvGYeBhVnQ9xQ/YSyJ8yMDjkXWaRDBWDjq5\\n3wlXyFynuV6GymCEdFqxPvEgjHNTfPO2Apewkg+kqof5+CpvyFTN5mgRCqii80Jj\\nr4437pjzusIIsh0Sd5xzJsezP4UJ3oQxU252018HXJwuJ4+bOLEnprkD8N7dBnDp\\ncgPkAFhG7iGeEVRPFB1V8eWeX0+L87POqrjvYwdyu0u85FWMr5NmJWF1xsSX9LRV\\nCMFANmUB1IVaDZMqbGLHP7yfthoAbCzJFuedro03DUADn9xL2BwqT43BAHVg9ln9\\n6JOMileUcRVCOMl+3aQT9D0LUHmSNsdR9EAd9zjTYjXo9HUFMbzb71c48sX74o/u\\nVI2CVha3S+zrHcvfu/luC23z/IuERr8Bf4SK765b98aGOZkUH6ELrU3w0laxryoV\\nzolJ39wHY+XOq73Py+IzMkttkXAQ0Y40qjoba8ND2ch7fpibuqWYFN6fTylcYOSk\\nXNxJJUnakQJY/O0i6yUMnHmZnkSzd2m92zCoL+to9f3Ozh6OYQcAPgRyfrNGWDt2\\neUcB4bsgxy+HYIE+TCwN5wvNN2wZoopOjz4oYc/Q/62qONWCw4DJ8MYFKBHG6gxA\\nNJmeajt165VPzhfkIqfiWqDIpIyS/FQvGGJKenXbmiAJG+UMu5MeCj1E/b8ehWF/\\n+GJdjB7DomW4rRTFu45UEGuxiPcowwUejtqOy7glxeYEQWAXQNYVXLUvz1yFiGfA\\nEjCQLsOl+HtuudeYM8uZakcLcXNzGd/VPMNNt5KMMC56z/7P+VDVOztCov8jdVVL\\nibQKxu4cLHECL2YDdNT6bnwTDcuGYL5mg/UWyaL7q5pK0X65zwmqaUZqk7BMkIWk\\ncW1pzsEsvzPXqhe9unqrUc8RMCofeh0+hs05CLPzqgIXBRAjNRdH6UpKQPM4KO8J\\nnN7hLY1S7L1dWs5ZRNFTshpcMscD93T7OtpprVdks+iV2geT6RD7b4LJV+6DZ19G\\nchkpLpnnhdy4mWPmoCDuUVupQvr0eIq4xg==\\n-----END ENCRYPTED PRIVATE KEY-----"}
\.


--
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.tag (create_time, update_time, id, key, value, knowledge_id) FROM stdin;
\.


--
-- Data for Name: tool; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.tool (create_time, update_time, id, name, "desc", code, input_field_list, init_field_list, icon, is_active, scope, tool_type, template_id, workspace_id, init_params, label, user_id, folder_id, version) FROM stdin;
2025-03-10 14:20:35.945414+08	2025-03-10 17:19:23.608026+08	c75cb48e-fd77-11ef-84d2-5618c4394482	博查搜索	从博查搜索任何信息和网页URL	def bocha_search(query, apikey):\n    import requests\n    import json\n    url = "https://api.bochaai.com/v1/web-search"\n    payload = json.dumps({\n        "query": query,\n        "summary": True,\n        "count": 8\n    })\n\n    headers = {\n        "Authorization": "Bearer " + apikey, #鉴权参数，示例：Bearer xxxxxx，API KEY请先前往博查AI开放平台（https://open.bochaai.com）> API KEY 管理中获取。\n        "Content-Type": "application/json"\n    }\n\n    response = requests.request("POST", url, headers=headers, data=payload)\n    if response.status_code == 200:\n        return response.json()\n    else:\n        raise Exception(f"API请求失败: {response.status_code}, 错误信息: {response.text}")\n        return (response.text)	[{"name": "query", "type": "string", "source": "reference", "is_required": true}]	[{"attrs": {"type": "password", "maxlength": 200, "minlength": 1, "show-password": true, "show-word-limit": true}, "field": "apikey", "label": "API Key", "required": true, "input_type": "PasswordInput", "props_info": {"rules": [{"message": "API Key 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "API Key 长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}]	./tool/bochaai/icon.png	t	INTERNAL	INTERNAL	\N	None		web_search	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab	default	\N
2025-02-26 11:36:48.187286+08	2025-03-11 15:23:46.123972+08	e89ad2ae-f3f2-11ef-ad09-0242ac110002	Google Search	Google Web Search	def google_search(query, apikey, cx):\n    import requests\n    import json\n    url = "https://customsearch.googleapis.com/customsearch/v1"\n    params = {\n        "q": query,\n        "key": apikey,\n        "cx": cx,\n        "num": 10,  # 每次最多返回10条\n    }\n\n    response = requests.get(url, params=params)\n    if response.status_code == 200:\n        return response.json()\n    else:\n        raise Exception(f"API请求失败: {response.status_code}, 错误信息: {response.text}")\n        return (response.text)	[{"name": "query", "type": "string", "source": "reference", "is_required": true}]	[{"attrs": {"type": "password", "maxlength": 200, "minlength": 1, "show-password": true, "show-word-limit": true}, "field": "apikey", "label": "API Key", "required": true, "input_type": "PasswordInput", "props_info": {"rules": [{"message": "API Key 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "API Key 长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}, {"attrs": {"maxlength": 200, "minlength": 1, "show-word-limit": true}, "field": "cx", "label": "cx", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "cx 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "cx长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}]	./tool/google_search/icon.png	t	INTERNAL	INTERNAL	\N	None		web_search	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab	default	\N
2025-02-25 15:44:40.141515+08	2025-03-11 14:33:53.248495+08	5e912f00-f34c-11ef-8a9c-5618c4394482	LangSearch	A Web Search tool supporting natural language search\n	\ndef langsearch(query, apikey):\n    import json\n    import requests\n\n    url = "https://api.langsearch.com/v1/web-search"\n    payload = json.dumps({\n        "query": query,\n        "summary": True,\n        "freshness": "noLimit",\n        "livecrawl": True,\n        "count": 20\n    })\n    headers = {\n        "Authorization": apikey,\n        "Content-Type": "application/json"\n    }\n    # key从官网申请 https://langsearch.com/\n    response = requests.request("POST", url, headers=headers, data=payload)\n    if response.status_code == 200:\n        return response.json()\n    else:\n        raise Exception(f"API请求失败: {response.status_code}, 错误信息: {response.text}")\n        return (response.text)	[{"name": "query", "type": "string", "source": "reference", "is_required": true}]	[{"attrs": {"type": "password", "maxlength": 200, "minlength": 1, "show-password": true, "show-word-limit": true}, "field": "apikey", "label": "API Key", "required": true, "input_type": "PasswordInput", "props_info": {"rules": [{"message": "API Key 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "API Key 长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}]	./tool/langsearch/icon.png	t	INTERNAL	INTERNAL	\N	None		web_search	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab	default	\N
2025-03-17 16:16:32.626245+08	2025-03-17 16:16:32.626308+08	22c21b76-0308-11f0-9694-5618c4394482	MySQL 查询	一个连接MySQL数据库执行SQL查询的工具	\ndef query_mysql(host,port, user, password, database, sql):\n    import pymysql\n    import json\n    from pymysql.cursors import DictCursor\n    from datetime import datetime, date\n\n    def default_serializer(obj):\n        from decimal import Decimal\n        if isinstance(obj, (datetime, date)):\n            return obj.isoformat()  # 将 datetime/date 转换为 ISO 格式字符串\n        elif isinstance(obj, Decimal):\n            return float(obj)  # 将 Decimal 转换为 float\n        raise TypeError(f"Type {type(obj)} not serializable")\n\n    try:\n        # 创建连接\n        db = pymysql.connect(\n            host=host,\n            port=int(port),\n            user=user,\n            password=password,\n            database=database,\n            cursorclass=DictCursor  # 使用字典游标\n        )\n\n        # 使用 cursor() 方法创建一个游标对象 cursor\n        cursor = db.cursor()\n\n        # 使用 execute() 方法执行 SQL 查询\n        cursor.execute(sql)\n\n        # 使用 fetchall() 方法获取所有数据\n        data = cursor.fetchall()\n\n        # 处理 bytes 类型的数据\n        for row in data:\n            for key, value in row.items():\n                if isinstance(value, bytes):\n                    row[key] = value.decode("utf-8")  # 转换为字符串\n\n        # 将数据序列化为 JSON\n        json_data = json.dumps(data, default=default_serializer, ensure_ascii=False)\n        return json_data\n\n        # 关闭数据库连接\n        db.close()\n\n    except Exception as e:\n        print(f"Error while connecting to MySQL: {e}")\n        raise e	[{"name": "sql", "type": "string", "source": "reference", "is_required": true}]	[{"attrs": {"maxlength": 200, "minlength": 1, "show-word-limit": true}, "field": "host", "label": "host", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "host 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "host长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}, {"attrs": {"maxlength": 20, "minlength": 1, "show-word-limit": true}, "field": "port", "label": "port", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "port 为必填属性", "required": true}, {"max": 20, "min": 1, "message": "port长度在 1 到 20 个字符", "trigger": "blur"}]}, "default_value": "3306", "show_default_value": false}, {"attrs": {"maxlength": 200, "minlength": 1, "show-word-limit": true}, "field": "user", "label": "user", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "user 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "user长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "root", "show_default_value": false}, {"attrs": {"type": "password", "maxlength": 200, "minlength": 1, "show-password": true, "show-word-limit": true}, "field": "password", "label": "password", "required": true, "input_type": "PasswordInput", "props_info": {"rules": [{"message": "password 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "password长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}, {"attrs": {"maxlength": 200, "minlength": 1, "show-word-limit": true}, "field": "database", "label": "database", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "database 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "database长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}]	./tool/mysql/icon.png	t	INTERNAL	INTERNAL	\N	None	\N	database_search	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab	default	\N
2025-03-17 15:37:54.620836+08	2025-03-17 15:37:54.620887+08	bd1e8b88-0302-11f0-87bb-5618c4394482	PostgreSQL 查询	一个连接PostgreSQL数据库执行SQL查询的工具	\ndef queryPgSQL(database, user, password, host, port, query):\n    import psycopg2\n    import json\n    from datetime import datetime\n\n    # 自定义 JSON 序列化函数\n    def default_serializer(obj):\n        from decimal import Decimal\n        if isinstance(obj, datetime):\n            return obj.isoformat()  # 将 datetime 转换为 ISO 格式字符串\n        elif isinstance(obj, Decimal):\n            return float(obj)  # 将 Decimal 转换为 float\n        raise TypeError(f"Type {type(obj)} not serializable")\n\n    # 数据库连接信息\n    conn_params = {\n        "dbname": database,\n        "user": user,\n        "password": password,\n        "host": host,\n        "port": port\n    }\n    try:\n        # 建立连接\n        conn = psycopg2.connect(**conn_params)\n        print("连接成功！")\n        # 创建游标对象\n        cursor = conn.cursor()\n        # 执行查询语句\n        cursor.execute(query)\n        # 获取查询结果\n        rows = cursor.fetchall()\n        # 处理 bytes 类型的数据\n        columns = [desc[0] for desc in cursor.description]\n        result = [dict(zip(columns, row)) for row in rows]\n        # 转换为 JSON 格式\n        json_result = json.dumps(result, default=default_serializer, ensure_ascii=False)\n        return json_result\n    except Exception as e:\n        print(f"发生错误：{e}")\n        raise e\n    finally:\n        # 关闭游标和连接\n        if cursor:\n            cursor.close()\n        if conn:\n            conn.close()	[{"name": "query", "type": "string", "source": "reference", "is_required": true}]	[{"attrs": {"maxlength": 200, "minlength": 1, "show-word-limit": true}, "field": "host", "label": "host", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "host 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "host长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}, {"attrs": {"maxlength": 20, "minlength": 1, "show-word-limit": true}, "field": "port", "label": "port", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "port 为必填属性", "required": true}, {"max": 20, "min": 1, "message": "port长度在 1 到 20 个字符", "trigger": "blur"}]}, "default_value": "5432", "show_default_value": false}, {"attrs": {"maxlength": 200, "minlength": 1, "show-word-limit": true}, "field": "user", "label": "user", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "user 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "user长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "root", "show_default_value": false}, {"attrs": {"type": "password", "maxlength": 200, "minlength": 1, "show-password": true, "show-word-limit": true}, "field": "password", "label": "password", "required": true, "input_type": "PasswordInput", "props_info": {"rules": [{"message": "password 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "password长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}, {"attrs": {"maxlength": 200, "minlength": 1, "show-word-limit": true}, "field": "database", "label": "database", "required": true, "input_type": "TextInput", "props_info": {"rules": [{"message": "database 为必填属性", "required": true}, {"max": 200, "min": 1, "message": "database长度在 1 到 200 个字符", "trigger": "blur"}]}, "default_value": "x", "show_default_value": false}]	./tool/postgresql/icon.png	t	INTERNAL	INTERNAL	\N	None	\N	database_search	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab	default	\N
\.


--
-- Data for Name: tool_folder; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.tool_folder (create_time, update_time, id, name, "desc", workspace_id, lft, rght, tree_id, level, parent_id, user_id) FROM stdin;
2026-05-07 15:08:40.67992+08	2026-05-07 15:08:40.679934+08	default	根目录	\N	default	1	2	1	0	\N	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."user" (id, email, phone, nick_name, username, password, role, source, is_active, language, create_time, update_time) FROM stdin;
f0dd8f71-e4ee-11ee-8c84-a8a1595801ab			系统管理员	admin	067b6bac6977b23a91cc803a0c38c4ca	ADMIN	LOCAL	t	\N	2026-05-07 15:08:36.56937+08	2026-05-07 15:08:36.5694+08
\.


--
-- Data for Name: user_group; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.user_group (id, name) FROM stdin;
\.


--
-- Data for Name: user_group_relation; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.user_group_relation (id, group_id, user_id) FROM stdin;
\.


--
-- Data for Name: workspace_user_resource_permission; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.workspace_user_resource_permission (id, workspace_id, auth_target_type, target, auth_type, permission_list, create_time, update_time, user_id) FROM stdin;
019e0144-68fe-7510-94a8-c6de1f39b1dc	default	APPLICATION	default	RESOURCE_PERMISSION_GROUP	{VIEW,MANAGE}	2026-05-07 15:08:41.100537+08	2026-05-07 15:08:41.100551+08	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab
019e0144-6903-7971-bc1b-0610282c2e75	default	TOOL	default	RESOURCE_PERMISSION_GROUP	{VIEW,MANAGE}	2026-05-07 15:08:41.100663+08	2026-05-07 15:08:41.100671+08	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab
019e0144-6905-77d2-bd26-bd8e30b04081	default	KNOWLEDGE	default	RESOURCE_PERMISSION_GROUP	{VIEW,MANAGE}	2026-05-07 15:08:41.100694+08	2026-05-07 15:08:41.1007+08	f0dd8f71-e4ee-11ee-8c84-a8a1595801ab
\.


--
-- Name: django_apscheduler_djangojobexecution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.django_apscheduler_djangojobexecution_id_seq', 1, false);


--
-- Name: django_celery_beat_clockedschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.django_celery_beat_clockedschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_crontabschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.django_celery_beat_crontabschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_intervalschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.django_celery_beat_intervalschedule_id_seq', 1, false);


--
-- Name: django_celery_beat_periodictask_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.django_celery_beat_periodictask_id_seq', 1, false);


--
-- Name: django_celery_beat_solarschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.django_celery_beat_solarschedule_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 43, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 52, true);


--
-- Name: application_access_token application_access_token_access_token_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_access_token
    ADD CONSTRAINT application_access_token_access_token_key UNIQUE (access_token);


--
-- Name: application_access_token application_access_token_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_access_token
    ADD CONSTRAINT application_access_token_pkey PRIMARY KEY (application_id);


--
-- Name: application_api_key application_api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_api_key
    ADD CONSTRAINT application_api_key_pkey PRIMARY KEY (id);


--
-- Name: application_api_key application_api_key_secret_key_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_api_key
    ADD CONSTRAINT application_api_key_secret_key_key UNIQUE (secret_key);


--
-- Name: application_chat application_chat_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_chat
    ADD CONSTRAINT application_chat_pkey PRIMARY KEY (id);


--
-- Name: application_chat_record application_chat_record_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_chat_record
    ADD CONSTRAINT application_chat_record_pkey PRIMARY KEY (id);


--
-- Name: application_chat_user_stats application_chat_user_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_chat_user_stats
    ADD CONSTRAINT application_chat_user_stats_pkey PRIMARY KEY (id);


--
-- Name: application_folder application_folder_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_folder
    ADD CONSTRAINT application_folder_pkey PRIMARY KEY (id);


--
-- Name: application_knowledge_mapping application_knowledge_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_knowledge_mapping
    ADD CONSTRAINT application_knowledge_mapping_pkey PRIMARY KEY (id);


--
-- Name: application application_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_pkey PRIMARY KEY (id);


--
-- Name: application_version application_version_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_version
    ADD CONSTRAINT application_version_pkey PRIMARY KEY (id);


--
-- Name: chat_user chat_user_nick_name_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.chat_user
    ADD CONSTRAINT chat_user_nick_name_key UNIQUE (nick_name);


--
-- Name: chat_user chat_user_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.chat_user
    ADD CONSTRAINT chat_user_pkey PRIMARY KEY (id);


--
-- Name: chat_user chat_user_username_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.chat_user
    ADD CONSTRAINT chat_user_username_key UNIQUE (username);


--
-- Name: django_apscheduler_djangojob django_apscheduler_djangojob_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_apscheduler_djangojob
    ADD CONSTRAINT django_apscheduler_djangojob_pkey PRIMARY KEY (id);


--
-- Name: django_apscheduler_djangojobexecution django_apscheduler_djangojobexecution_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_apscheduler_djangojobexecution
    ADD CONSTRAINT django_apscheduler_djangojobexecution_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_clockedschedule django_celery_beat_clockedschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_clockedschedule
    ADD CONSTRAINT django_celery_beat_clockedschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_crontabschedule django_celery_beat_crontabschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_crontabschedule
    ADD CONSTRAINT django_celery_beat_crontabschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_intervalschedule django_celery_beat_intervalschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_intervalschedule
    ADD CONSTRAINT django_celery_beat_intervalschedule_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_periodictask django_celery_beat_periodictask_name_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_periodictask_name_key UNIQUE (name);


--
-- Name: django_celery_beat_periodictask django_celery_beat_periodictask_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_periodictask_pkey PRIMARY KEY (id);


--
-- Name: django_celery_beat_periodictasks django_celery_beat_periodictasks_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_periodictasks
    ADD CONSTRAINT django_celery_beat_periodictasks_pkey PRIMARY KEY (ident);


--
-- Name: django_celery_beat_solarschedule django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule
    ADD CONSTRAINT django_celery_beat_solar_event_latitude_longitude_ba64999a_uniq UNIQUE (event, latitude, longitude);


--
-- Name: django_celery_beat_solarschedule django_celery_beat_solarschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_solarschedule
    ADD CONSTRAINT django_celery_beat_solarschedule_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: document document_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_pkey PRIMARY KEY (id);


--
-- Name: document_tag document_tag_document_id_tag_id_55f500a6_uniq; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.document_tag
    ADD CONSTRAINT document_tag_document_id_tag_id_55f500a6_uniq UNIQUE (document_id, tag_id);


--
-- Name: document_tag document_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.document_tag
    ADD CONSTRAINT document_tag_pkey PRIMARY KEY (id);


--
-- Name: embedding embedding_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.embedding
    ADD CONSTRAINT embedding_pkey PRIMARY KEY (id);


--
-- Name: file file_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.file
    ADD CONSTRAINT file_pkey PRIMARY KEY (id);


--
-- Name: knowledge_action knowledge_action_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.knowledge_action
    ADD CONSTRAINT knowledge_action_pkey PRIMARY KEY (id);


--
-- Name: knowledge_folder knowledge_folder_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.knowledge_folder
    ADD CONSTRAINT knowledge_folder_pkey PRIMARY KEY (id);


--
-- Name: knowledge knowledge_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.knowledge
    ADD CONSTRAINT knowledge_pkey PRIMARY KEY (id);


--
-- Name: knowledge_workflow knowledge_workflow_knowledge_id_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.knowledge_workflow
    ADD CONSTRAINT knowledge_workflow_knowledge_id_key UNIQUE (knowledge_id);


--
-- Name: knowledge_workflow knowledge_workflow_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.knowledge_workflow
    ADD CONSTRAINT knowledge_workflow_pkey PRIMARY KEY (id);


--
-- Name: knowledge_workflow_version knowledge_workflow_version_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.knowledge_workflow_version
    ADD CONSTRAINT knowledge_workflow_version_pkey PRIMARY KEY (id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: model model_name_workspace_id_68e244ba_uniq; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.model
    ADD CONSTRAINT model_name_workspace_id_68e244ba_uniq UNIQUE (name, workspace_id);


--
-- Name: model model_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.model
    ADD CONSTRAINT model_pkey PRIMARY KEY (id);


--
-- Name: paragraph paragraph_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.paragraph
    ADD CONSTRAINT paragraph_pkey PRIMARY KEY (id);


--
-- Name: problem_paragraph_mapping problem_paragraph_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.problem_paragraph_mapping
    ADD CONSTRAINT problem_paragraph_mapping_pkey PRIMARY KEY (id);


--
-- Name: problem problem_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.problem
    ADD CONSTRAINT problem_pkey PRIMARY KEY (id);


--
-- Name: resource_chat_user_authorize resource_chat_user_autho_user_group_id_resource_t_7fc1cc94_uniq; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.resource_chat_user_authorize
    ADD CONSTRAINT resource_chat_user_autho_user_group_id_resource_t_7fc1cc94_uniq UNIQUE (user_group_id, resource_type, resource_id, user_id);


--
-- Name: resource_chat_user_authorize resource_chat_user_authorize_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.resource_chat_user_authorize
    ADD CONSTRAINT resource_chat_user_authorize_pkey PRIMARY KEY (id);


--
-- Name: resource_chat_user_group_authorize resource_chat_user_group_authorize_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.resource_chat_user_group_authorize
    ADD CONSTRAINT resource_chat_user_group_authorize_pkey PRIMARY KEY (id);


--
-- Name: resource_chat_user_group_authorize resource_chat_user_group_user_group_id_resource_t_5eccc9b0_uniq; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.resource_chat_user_group_authorize
    ADD CONSTRAINT resource_chat_user_group_user_group_id_resource_t_5eccc9b0_uniq UNIQUE (user_group_id, resource_type, resource_id);


--
-- Name: system_setting system_setting_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.system_setting
    ADD CONSTRAINT system_setting_pkey PRIMARY KEY (type);


--
-- Name: tag tag_knowledge_id_key_value_eb5f0e5d_uniq; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_knowledge_id_key_value_eb5f0e5d_uniq UNIQUE (knowledge_id, key, value);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: tool_folder tool_folder_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tool_folder
    ADD CONSTRAINT tool_folder_pkey PRIMARY KEY (id);


--
-- Name: tool tool_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tool
    ADD CONSTRAINT tool_pkey PRIMARY KEY (id);


--
-- Name: django_apscheduler_djangojobexecution unique_job_executions; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_apscheduler_djangojobexecution
    ADD CONSTRAINT unique_job_executions UNIQUE (job_id, run_time);


--
-- Name: user user_email_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_email_key UNIQUE (email);


--
-- Name: user_group user_group_name_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_group
    ADD CONSTRAINT user_group_name_key UNIQUE (name);


--
-- Name: user_group user_group_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_group
    ADD CONSTRAINT user_group_pkey PRIMARY KEY (id);


--
-- Name: user_group_relation user_group_relation_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_group_relation
    ADD CONSTRAINT user_group_relation_pkey PRIMARY KEY (id);


--
-- Name: user user_nick_name_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_nick_name_key UNIQUE (nick_name);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user user_username_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);


--
-- Name: workspace_user_resource_permission workspace_user_resource__workspace_id_user_id_aut_692d4734_uniq; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.workspace_user_resource_permission
    ADD CONSTRAINT workspace_user_resource__workspace_id_user_id_aut_692d4734_uniq UNIQUE (workspace_id, user_id, auth_target_type, target);


--
-- Name: workspace_user_resource_permission workspace_user_resource_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.workspace_user_resource_permission
    ADD CONSTRAINT workspace_user_resource_permission_pkey PRIMARY KEY (id);


--
-- Name: application_access_token_access_token_3823531a_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_access_token_access_token_3823531a_like ON public.application_access_token USING btree (access_token varchar_pattern_ops);


--
-- Name: application_access_token_create_time_64979b17; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_access_token_create_time_64979b17 ON public.application_access_token USING btree (create_time);


--
-- Name: application_access_token_update_time_8e6632af; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_access_token_update_time_8e6632af ON public.application_access_token USING btree (update_time);


--
-- Name: application_api_key_application_id_376d9a01; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_api_key_application_id_376d9a01 ON public.application_api_key USING btree (application_id);


--
-- Name: application_api_key_create_time_0013df4c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_api_key_create_time_0013df4c ON public.application_api_key USING btree (create_time);


--
-- Name: application_api_key_secret_key_fd1b76e9_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_api_key_secret_key_fd1b76e9_like ON public.application_api_key USING btree (secret_key varchar_pattern_ops);


--
-- Name: application_api_key_update_time_ce7b0d9b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_api_key_update_time_ce7b0d9b ON public.application_api_key USING btree (update_time);


--
-- Name: application_api_key_user_id_e9e85f1b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_api_key_user_id_e9e85f1b ON public.application_api_key USING btree (user_id);


--
-- Name: application_api_key_workspace_id_01fbdbc0; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_api_key_workspace_id_01fbdbc0 ON public.application_api_key USING btree (workspace_id);


--
-- Name: application_api_key_workspace_id_01fbdbc0_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_api_key_workspace_id_01fbdbc0_like ON public.application_api_key USING btree (workspace_id varchar_pattern_ops);


--
-- Name: application_applica_1652ba_idx; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_applica_1652ba_idx ON public.application_chat_user_stats USING btree (application_id, chat_user_id);


--
-- Name: application_chat_application_id_0c9f6b90; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_application_id_0c9f6b90 ON public.application_chat USING btree (application_id);


--
-- Name: application_chat_create_time_ebb5f9d3; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_create_time_ebb5f9d3 ON public.application_chat USING btree (create_time);


--
-- Name: application_chat_record_chat_id_21aeb7ef; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_record_chat_id_21aeb7ef ON public.application_chat_record USING btree (chat_id);


--
-- Name: application_chat_record_create_time_8878f099; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_record_create_time_8878f099 ON public.application_chat_record USING btree (create_time);


--
-- Name: application_chat_record_update_time_32fb05dc; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_record_update_time_32fb05dc ON public.application_chat_record USING btree (update_time);


--
-- Name: application_chat_update_time_f9735fce; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_update_time_f9735fce ON public.application_chat USING btree (update_time);


--
-- Name: application_chat_user_stats_application_id_2080bbf7; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_user_stats_application_id_2080bbf7 ON public.application_chat_user_stats USING btree (application_id);


--
-- Name: application_chat_user_stats_create_time_32742378; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_user_stats_create_time_32742378 ON public.application_chat_user_stats USING btree (create_time);


--
-- Name: application_chat_user_stats_update_time_0e9f4d3b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_chat_user_stats_update_time_0e9f4d3b ON public.application_chat_user_stats USING btree (update_time);


--
-- Name: application_create_time_ee39f1ea; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_create_time_ee39f1ea ON public.application USING btree (create_time);


--
-- Name: application_folder_create_time_69889312; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_create_time_69889312 ON public.application_folder USING btree (create_time);


--
-- Name: application_folder_id_0d598f52; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_id_0d598f52 ON public.application USING btree (folder_id);


--
-- Name: application_folder_id_0d598f52_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_id_0d598f52_like ON public.application USING btree (folder_id varchar_pattern_ops);


--
-- Name: application_folder_id_bdb97e27_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_id_bdb97e27_like ON public.application_folder USING btree (id varchar_pattern_ops);


--
-- Name: application_folder_name_d221e0c2; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_name_d221e0c2 ON public.application_folder USING btree (name);


--
-- Name: application_folder_name_d221e0c2_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_name_d221e0c2_like ON public.application_folder USING btree (name varchar_pattern_ops);


--
-- Name: application_folder_parent_id_b82d1c52; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_parent_id_b82d1c52 ON public.application_folder USING btree (parent_id);


--
-- Name: application_folder_parent_id_b82d1c52_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_parent_id_b82d1c52_like ON public.application_folder USING btree (parent_id varchar_pattern_ops);


--
-- Name: application_folder_tree_id_e467c15b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_tree_id_e467c15b ON public.application_folder USING btree (tree_id);


--
-- Name: application_folder_update_time_078e64d2; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_update_time_078e64d2 ON public.application_folder USING btree (update_time);


--
-- Name: application_folder_user_id_45def139; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_user_id_45def139 ON public.application_folder USING btree (user_id);


--
-- Name: application_folder_workspace_id_753461f7; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_workspace_id_753461f7 ON public.application_folder USING btree (workspace_id);


--
-- Name: application_folder_workspace_id_753461f7_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_folder_workspace_id_753461f7_like ON public.application_folder USING btree (workspace_id varchar_pattern_ops);


--
-- Name: application_knowledge_mapping_application_id_784ccbaf; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_knowledge_mapping_application_id_784ccbaf ON public.application_knowledge_mapping USING btree (application_id);


--
-- Name: application_knowledge_mapping_create_time_b5b82de1; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_knowledge_mapping_create_time_b5b82de1 ON public.application_knowledge_mapping USING btree (create_time);


--
-- Name: application_knowledge_mapping_knowledge_id_767ec6f1; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_knowledge_mapping_knowledge_id_767ec6f1 ON public.application_knowledge_mapping USING btree (knowledge_id);


--
-- Name: application_knowledge_mapping_update_time_5d8dc346; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_knowledge_mapping_update_time_5d8dc346 ON public.application_knowledge_mapping USING btree (update_time);


--
-- Name: application_model_id_e80b5b34; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_model_id_e80b5b34 ON public.application USING btree (model_id);


--
-- Name: application_name_b2d4898f; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_name_b2d4898f ON public.application USING btree (name);


--
-- Name: application_name_b2d4898f_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_name_b2d4898f_like ON public.application USING btree (name varchar_pattern_ops);


--
-- Name: application_stt_model_id_10e736db; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_stt_model_id_10e736db ON public.application USING btree (stt_model_id);


--
-- Name: application_tts_model_id_63215f2e; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_tts_model_id_63215f2e ON public.application USING btree (tts_model_id);


--
-- Name: application_update_time_1ef68ba2; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_update_time_1ef68ba2 ON public.application USING btree (update_time);


--
-- Name: application_user_id_e0323977; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_user_id_e0323977 ON public.application USING btree (user_id);


--
-- Name: application_version_application_id_ee35744a; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_version_application_id_ee35744a ON public.application_version USING btree (application_id);


--
-- Name: application_version_create_time_d37c6d5c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_version_create_time_d37c6d5c ON public.application_version USING btree (create_time);


--
-- Name: application_version_update_time_c6e2da69; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_version_update_time_c6e2da69 ON public.application_version USING btree (update_time);


--
-- Name: application_version_user_id_61a6abb2; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_version_user_id_61a6abb2 ON public.application_version USING btree (user_id);


--
-- Name: application_version_workspace_id_cc3b81bf; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_version_workspace_id_cc3b81bf ON public.application_version USING btree (workspace_id);


--
-- Name: application_version_workspace_id_cc3b81bf_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_version_workspace_id_cc3b81bf_like ON public.application_version USING btree (workspace_id varchar_pattern_ops);


--
-- Name: application_workspace_id_43da6674; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_workspace_id_43da6674 ON public.application USING btree (workspace_id);


--
-- Name: application_workspace_id_43da6674_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX application_workspace_id_43da6674_like ON public.application USING btree (workspace_id varchar_pattern_ops);


--
-- Name: chat_user_create_time_04d18e13; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_create_time_04d18e13 ON public.chat_user USING btree (create_time);


--
-- Name: chat_user_email_9db37d4b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_email_9db37d4b ON public.chat_user USING btree (email);


--
-- Name: chat_user_email_9db37d4b_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_email_9db37d4b_like ON public.chat_user USING btree (email varchar_pattern_ops);


--
-- Name: chat_user_is_active_c3391505; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_is_active_c3391505 ON public.chat_user USING btree (is_active);


--
-- Name: chat_user_nick_name_9f856cf5_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_nick_name_9f856cf5_like ON public.chat_user USING btree (nick_name varchar_pattern_ops);


--
-- Name: chat_user_source_4957074b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_source_4957074b ON public.chat_user USING btree (source);


--
-- Name: chat_user_source_4957074b_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_source_4957074b_like ON public.chat_user USING btree (source varchar_pattern_ops);


--
-- Name: chat_user_update_time_d6b6010c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_update_time_d6b6010c ON public.chat_user USING btree (update_time);


--
-- Name: chat_user_username_7c2763ef_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX chat_user_username_7c2763ef_like ON public.chat_user USING btree (username varchar_pattern_ops);


--
-- Name: django_apscheduler_djangojob_next_run_time_2f022619; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX django_apscheduler_djangojob_next_run_time_2f022619 ON public.django_apscheduler_djangojob USING btree (next_run_time);


--
-- Name: django_apscheduler_djangojobexecution_job_id_daf5090a; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX django_apscheduler_djangojobexecution_job_id_daf5090a ON public.django_apscheduler_djangojobexecution USING btree (job_id);


--
-- Name: django_apscheduler_djangojobexecution_run_time_16edd96b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX django_apscheduler_djangojobexecution_run_time_16edd96b ON public.django_apscheduler_djangojobexecution USING btree (run_time);


--
-- Name: django_celery_beat_periodictask_clocked_id_47a69f82; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX django_celery_beat_periodictask_clocked_id_47a69f82 ON public.django_celery_beat_periodictask USING btree (clocked_id);


--
-- Name: django_celery_beat_periodictask_crontab_id_d3cba168; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX django_celery_beat_periodictask_crontab_id_d3cba168 ON public.django_celery_beat_periodictask USING btree (crontab_id);


--
-- Name: django_celery_beat_periodictask_interval_id_a8ca27da; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX django_celery_beat_periodictask_interval_id_a8ca27da ON public.django_celery_beat_periodictask USING btree (interval_id);


--
-- Name: django_celery_beat_periodictask_name_265a36b7_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX django_celery_beat_periodictask_name_265a36b7_like ON public.django_celery_beat_periodictask USING btree (name varchar_pattern_ops);


--
-- Name: django_celery_beat_periodictask_solar_id_a87ce72c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX django_celery_beat_periodictask_solar_id_a87ce72c ON public.django_celery_beat_periodictask USING btree (solar_id);


--
-- Name: document_create_time_5168c411; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_create_time_5168c411 ON public.document USING btree (create_time);


--
-- Name: document_is_active_ab67f847; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_is_active_ab67f847 ON public.document USING btree (is_active);


--
-- Name: document_knowledge_id_419c566f; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_knowledge_id_419c566f ON public.document USING btree (knowledge_id);


--
-- Name: document_name_8eb44882; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_name_8eb44882 ON public.document USING btree (name);


--
-- Name: document_name_8eb44882_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_name_8eb44882_like ON public.document USING btree (name varchar_pattern_ops);


--
-- Name: document_status_a4cf573b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_status_a4cf573b ON public.document USING btree (status);


--
-- Name: document_status_a4cf573b_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_status_a4cf573b_like ON public.document USING btree (status varchar_pattern_ops);


--
-- Name: document_tag_create_time_4ef5590c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_tag_create_time_4ef5590c ON public.document_tag USING btree (create_time);


--
-- Name: document_tag_document_id_953cb93d; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_tag_document_id_953cb93d ON public.document_tag USING btree (document_id);


--
-- Name: document_tag_tag_id_acaa7b3b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_tag_tag_id_acaa7b3b ON public.document_tag USING btree (tag_id);


--
-- Name: document_tag_update_time_2c460bdf; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_tag_update_time_2c460bdf ON public.document_tag USING btree (update_time);


--
-- Name: document_type_7fb9c2c3; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_type_7fb9c2c3 ON public.document USING btree (type);


--
-- Name: document_update_time_4e517386; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX document_update_time_4e517386 ON public.document USING btree (update_time);


--
-- Name: embedding_document_id_3c89d1f3; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX embedding_document_id_3c89d1f3 ON public.embedding USING btree (document_id);


--
-- Name: embedding_id_f61adc5f_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX embedding_id_f61adc5f_like ON public.embedding USING btree (id varchar_pattern_ops);


--
-- Name: embedding_knowledge_id_00e08fa7; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX embedding_knowledge_id_00e08fa7 ON public.embedding USING btree (knowledge_id);


--
-- Name: embedding_paragraph_id_9f39681c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX embedding_paragraph_id_9f39681c ON public.embedding USING btree (paragraph_id);


--
-- Name: embedding_source_id_60f7e2f4; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX embedding_source_id_60f7e2f4 ON public.embedding USING btree (source_id);


--
-- Name: embedding_source_id_60f7e2f4_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX embedding_source_id_60f7e2f4_like ON public.embedding USING btree (source_id varchar_pattern_ops);


--
-- Name: embedding_source_type_23488528; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX embedding_source_type_23488528 ON public.embedding USING btree (source_type);


--
-- Name: embedding_source_type_23488528_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX embedding_source_type_23488528_like ON public.embedding USING btree (source_type varchar_pattern_ops);


--
-- Name: file_create_time_940439ad; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX file_create_time_940439ad ON public.file USING btree (create_time);


--
-- Name: file_source_id_f68d803c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX file_source_id_f68d803c ON public.file USING btree (source_id);


--
-- Name: file_source_id_f68d803c_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX file_source_id_f68d803c_like ON public.file USING btree (source_id varchar_pattern_ops);


--
-- Name: file_source_type_aae7b5e3; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX file_source_type_aae7b5e3 ON public.file USING btree (source_type);


--
-- Name: file_source_type_aae7b5e3_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX file_source_type_aae7b5e3_like ON public.file USING btree (source_type varchar_pattern_ops);


--
-- Name: file_update_time_e55a692a; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX file_update_time_e55a692a ON public.file USING btree (update_time);


--
-- Name: knowledge_action_create_time_e8782fff; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_action_create_time_e8782fff ON public.knowledge_action USING btree (create_time);


--
-- Name: knowledge_action_knowledge_id_8c71df84; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_action_knowledge_id_8c71df84 ON public.knowledge_action USING btree (knowledge_id);


--
-- Name: knowledge_action_update_time_b7da00ac; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_action_update_time_b7da00ac ON public.knowledge_action USING btree (update_time);


--
-- Name: knowledge_create_time_73058bbd; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_create_time_73058bbd ON public.knowledge USING btree (create_time);


--
-- Name: knowledge_embedding_model_id_d8ebfba0; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_embedding_model_id_d8ebfba0 ON public.knowledge USING btree (embedding_model_id);


--
-- Name: knowledge_folder_create_time_9f79917a; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_create_time_9f79917a ON public.knowledge_folder USING btree (create_time);


--
-- Name: knowledge_folder_id_c2644e2c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_id_c2644e2c ON public.knowledge USING btree (folder_id);


--
-- Name: knowledge_folder_id_c2644e2c_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_id_c2644e2c_like ON public.knowledge USING btree (folder_id varchar_pattern_ops);


--
-- Name: knowledge_folder_id_d2636e62_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_id_d2636e62_like ON public.knowledge_folder USING btree (id varchar_pattern_ops);


--
-- Name: knowledge_folder_name_ab2c51ae; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_name_ab2c51ae ON public.knowledge_folder USING btree (name);


--
-- Name: knowledge_folder_name_ab2c51ae_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_name_ab2c51ae_like ON public.knowledge_folder USING btree (name varchar_pattern_ops);


--
-- Name: knowledge_folder_parent_id_88bfda49; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_parent_id_88bfda49 ON public.knowledge_folder USING btree (parent_id);


--
-- Name: knowledge_folder_parent_id_88bfda49_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_parent_id_88bfda49_like ON public.knowledge_folder USING btree (parent_id varchar_pattern_ops);


--
-- Name: knowledge_folder_tree_id_a575de4c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_tree_id_a575de4c ON public.knowledge_folder USING btree (tree_id);


--
-- Name: knowledge_folder_update_time_14aa2e30; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_update_time_14aa2e30 ON public.knowledge_folder USING btree (update_time);


--
-- Name: knowledge_folder_user_id_48c7f505; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_user_id_48c7f505 ON public.knowledge_folder USING btree (user_id);


--
-- Name: knowledge_folder_workspace_id_23488b49; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_workspace_id_23488b49 ON public.knowledge_folder USING btree (workspace_id);


--
-- Name: knowledge_folder_workspace_id_23488b49_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_folder_workspace_id_23488b49_like ON public.knowledge_folder USING btree (workspace_id varchar_pattern_ops);


--
-- Name: knowledge_name_41f67f24; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_name_41f67f24 ON public.knowledge USING btree (name);


--
-- Name: knowledge_name_41f67f24_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_name_41f67f24_like ON public.knowledge USING btree (name varchar_pattern_ops);


--
-- Name: knowledge_scope_c8877d39; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_scope_c8877d39 ON public.knowledge USING btree (scope);


--
-- Name: knowledge_scope_c8877d39_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_scope_c8877d39_like ON public.knowledge USING btree (scope varchar_pattern_ops);


--
-- Name: knowledge_type_7a89fb9d; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_type_7a89fb9d ON public.knowledge USING btree (type);


--
-- Name: knowledge_update_time_588f12b8; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_update_time_588f12b8 ON public.knowledge USING btree (update_time);


--
-- Name: knowledge_user_id_18293b47; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_user_id_18293b47 ON public.knowledge USING btree (user_id);


--
-- Name: knowledge_workflow_create_time_3d79e7e6; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_create_time_3d79e7e6 ON public.knowledge_workflow USING btree (create_time);


--
-- Name: knowledge_workflow_is_publish_74629d52; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_is_publish_74629d52 ON public.knowledge_workflow USING btree (is_publish);


--
-- Name: knowledge_workflow_update_time_1036d552; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_update_time_1036d552 ON public.knowledge_workflow USING btree (update_time);


--
-- Name: knowledge_workflow_version_create_time_10b25ccb; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_version_create_time_10b25ccb ON public.knowledge_workflow_version USING btree (create_time);


--
-- Name: knowledge_workflow_version_knowledge_id_34bf3175; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_version_knowledge_id_34bf3175 ON public.knowledge_workflow_version USING btree (knowledge_id);


--
-- Name: knowledge_workflow_version_update_time_3f96de1d; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_version_update_time_3f96de1d ON public.knowledge_workflow_version USING btree (update_time);


--
-- Name: knowledge_workflow_version_workspace_id_d4df3903; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_version_workspace_id_d4df3903 ON public.knowledge_workflow_version USING btree (workspace_id);


--
-- Name: knowledge_workflow_version_workspace_id_d4df3903_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_version_workspace_id_d4df3903_like ON public.knowledge_workflow_version USING btree (workspace_id varchar_pattern_ops);


--
-- Name: knowledge_workflow_workspace_id_79c20e29; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_workspace_id_79c20e29 ON public.knowledge_workflow USING btree (workspace_id);


--
-- Name: knowledge_workflow_workspace_id_79c20e29_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workflow_workspace_id_79c20e29_like ON public.knowledge_workflow USING btree (workspace_id varchar_pattern_ops);


--
-- Name: knowledge_workspace_id_795138c3; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workspace_id_795138c3 ON public.knowledge USING btree (workspace_id);


--
-- Name: knowledge_workspace_id_795138c3_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX knowledge_workspace_id_795138c3_like ON public.knowledge USING btree (workspace_id varchar_pattern_ops);


--
-- Name: log_create_time_44520a52; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX log_create_time_44520a52 ON public.log USING btree (create_time);


--
-- Name: log_operate_bb4f8ada; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX log_operate_bb4f8ada ON public.log USING btree (operate);


--
-- Name: log_operate_bb4f8ada_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX log_operate_bb4f8ada_like ON public.log USING btree (operate varchar_pattern_ops);


--
-- Name: log_status_77474674; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX log_status_77474674 ON public.log USING btree (status);


--
-- Name: log_update_time_a65e7f1e; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX log_update_time_a65e7f1e ON public.log USING btree (update_time);


--
-- Name: log_workspace_id_3f8e9902; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX log_workspace_id_3f8e9902 ON public.log USING btree (workspace_id);


--
-- Name: log_workspace_id_3f8e9902_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX log_workspace_id_3f8e9902_like ON public.log USING btree (workspace_id varchar_pattern_ops);


--
-- Name: model_create_time_c34d0337; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_create_time_c34d0337 ON public.model USING btree (create_time);


--
-- Name: model_model_name_c1d139d8; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_model_name_c1d139d8 ON public.model USING btree (model_name);


--
-- Name: model_model_name_c1d139d8_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_model_name_c1d139d8_like ON public.model USING btree (model_name varchar_pattern_ops);


--
-- Name: model_model_type_b693061b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_model_type_b693061b ON public.model USING btree (model_type);


--
-- Name: model_model_type_b693061b_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_model_type_b693061b_like ON public.model USING btree (model_type varchar_pattern_ops);


--
-- Name: model_name_1f9cfbc9; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_name_1f9cfbc9 ON public.model USING btree (name);


--
-- Name: model_name_1f9cfbc9_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_name_1f9cfbc9_like ON public.model USING btree (name varchar_pattern_ops);


--
-- Name: model_provider_cdbe3bf6; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_provider_cdbe3bf6 ON public.model USING btree (provider);


--
-- Name: model_provider_cdbe3bf6_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_provider_cdbe3bf6_like ON public.model USING btree (provider varchar_pattern_ops);


--
-- Name: model_status_e8e46844; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_status_e8e46844 ON public.model USING btree (status);


--
-- Name: model_status_e8e46844_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_status_e8e46844_like ON public.model USING btree (status varchar_pattern_ops);


--
-- Name: model_update_time_11b3490c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_update_time_11b3490c ON public.model USING btree (update_time);


--
-- Name: model_user_id_a841bfc8; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_user_id_a841bfc8 ON public.model USING btree (user_id);


--
-- Name: model_workspace_id_1edf80e5; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_workspace_id_1edf80e5 ON public.model USING btree (workspace_id);


--
-- Name: model_workspace_id_1edf80e5_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX model_workspace_id_1edf80e5_like ON public.model USING btree (workspace_id varchar_pattern_ops);


--
-- Name: paragraph_create_time_521ed7f0; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_create_time_521ed7f0 ON public.paragraph USING btree (create_time);


--
-- Name: paragraph_document_id_2e0722cc; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_document_id_2e0722cc ON public.paragraph USING btree (document_id);


--
-- Name: paragraph_is_active_d6ea683a; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_is_active_d6ea683a ON public.paragraph USING btree (is_active);


--
-- Name: paragraph_knowledge_id_4adce37e; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_knowledge_id_4adce37e ON public.paragraph USING btree (knowledge_id);


--
-- Name: paragraph_position_00aa9a2f; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_position_00aa9a2f ON public.paragraph USING btree ("position");


--
-- Name: paragraph_status_ebef6bfe; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_status_ebef6bfe ON public.paragraph USING btree (status);


--
-- Name: paragraph_status_ebef6bfe_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_status_ebef6bfe_like ON public.paragraph USING btree (status varchar_pattern_ops);


--
-- Name: paragraph_title_57663bca; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_title_57663bca ON public.paragraph USING btree (title);


--
-- Name: paragraph_title_57663bca_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_title_57663bca_like ON public.paragraph USING btree (title varchar_pattern_ops);


--
-- Name: paragraph_update_time_0e8da622; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX paragraph_update_time_0e8da622 ON public.paragraph USING btree (update_time);


--
-- Name: problem_content_93727706; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_content_93727706 ON public.problem USING btree (content);


--
-- Name: problem_content_93727706_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_content_93727706_like ON public.problem USING btree (content varchar_pattern_ops);


--
-- Name: problem_create_time_3a2d1421; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_create_time_3a2d1421 ON public.problem USING btree (create_time);


--
-- Name: problem_knowledge_id_656d8e09; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_knowledge_id_656d8e09 ON public.problem USING btree (knowledge_id);


--
-- Name: problem_paragraph_mapping_create_time_30dae711; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_paragraph_mapping_create_time_30dae711 ON public.problem_paragraph_mapping USING btree (create_time);


--
-- Name: problem_paragraph_mapping_document_id_74b9f617; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_paragraph_mapping_document_id_74b9f617 ON public.problem_paragraph_mapping USING btree (document_id);


--
-- Name: problem_paragraph_mapping_knowledge_id_84e4e42a; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_paragraph_mapping_knowledge_id_84e4e42a ON public.problem_paragraph_mapping USING btree (knowledge_id);


--
-- Name: problem_paragraph_mapping_paragraph_id_f0be2e98; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_paragraph_mapping_paragraph_id_f0be2e98 ON public.problem_paragraph_mapping USING btree (paragraph_id);


--
-- Name: problem_paragraph_mapping_problem_id_937b9858; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_paragraph_mapping_problem_id_937b9858 ON public.problem_paragraph_mapping USING btree (problem_id);


--
-- Name: problem_paragraph_mapping_update_time_677e4106; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_paragraph_mapping_update_time_677e4106 ON public.problem_paragraph_mapping USING btree (update_time);


--
-- Name: problem_update_time_16392c6e; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX problem_update_time_16392c6e ON public.problem USING btree (update_time);


--
-- Name: resource_chat_user_authorize_resource_id_efef323e; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_authorize_resource_id_efef323e ON public.resource_chat_user_authorize USING btree (resource_id);


--
-- Name: resource_chat_user_authorize_resource_type_dfd85ed2; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_authorize_resource_type_dfd85ed2 ON public.resource_chat_user_authorize USING btree (resource_type);


--
-- Name: resource_chat_user_authorize_resource_type_dfd85ed2_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_authorize_resource_type_dfd85ed2_like ON public.resource_chat_user_authorize USING btree (resource_type varchar_pattern_ops);


--
-- Name: resource_chat_user_authorize_user_group_id_5f3021d3; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_authorize_user_group_id_5f3021d3 ON public.resource_chat_user_authorize USING btree (user_group_id);


--
-- Name: resource_chat_user_authorize_user_group_id_5f3021d3_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_authorize_user_group_id_5f3021d3_like ON public.resource_chat_user_authorize USING btree (user_group_id varchar_pattern_ops);


--
-- Name: resource_chat_user_authorize_user_id_326419b7; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_authorize_user_id_326419b7 ON public.resource_chat_user_authorize USING btree (user_id);


--
-- Name: resource_chat_user_authorize_workspace_id_515407f9; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_authorize_workspace_id_515407f9 ON public.resource_chat_user_authorize USING btree (workspace_id);


--
-- Name: resource_chat_user_authorize_workspace_id_515407f9_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_authorize_workspace_id_515407f9_like ON public.resource_chat_user_authorize USING btree (workspace_id varchar_pattern_ops);


--
-- Name: resource_chat_user_group_authorize_resource_id_25ffb4f9; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_group_authorize_resource_id_25ffb4f9 ON public.resource_chat_user_group_authorize USING btree (resource_id);


--
-- Name: resource_chat_user_group_authorize_resource_type_91c5cda5; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_group_authorize_resource_type_91c5cda5 ON public.resource_chat_user_group_authorize USING btree (resource_type);


--
-- Name: resource_chat_user_group_authorize_resource_type_91c5cda5_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_group_authorize_resource_type_91c5cda5_like ON public.resource_chat_user_group_authorize USING btree (resource_type varchar_pattern_ops);


--
-- Name: resource_chat_user_group_authorize_user_group_id_3798efb8; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_group_authorize_user_group_id_3798efb8 ON public.resource_chat_user_group_authorize USING btree (user_group_id);


--
-- Name: resource_chat_user_group_authorize_user_group_id_3798efb8_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_group_authorize_user_group_id_3798efb8_like ON public.resource_chat_user_group_authorize USING btree (user_group_id varchar_pattern_ops);


--
-- Name: resource_chat_user_group_authorize_workspace_id_b75c61b5; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_group_authorize_workspace_id_b75c61b5 ON public.resource_chat_user_group_authorize USING btree (workspace_id);


--
-- Name: resource_chat_user_group_authorize_workspace_id_b75c61b5_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX resource_chat_user_group_authorize_workspace_id_b75c61b5_like ON public.resource_chat_user_group_authorize USING btree (workspace_id varchar_pattern_ops);


--
-- Name: system_setting_create_time_7c21ded3; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX system_setting_create_time_7c21ded3 ON public.system_setting USING btree (create_time);


--
-- Name: system_setting_update_time_a3d325d1; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX system_setting_update_time_a3d325d1 ON public.system_setting USING btree (update_time);


--
-- Name: tag_create_time_36d78b7c; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tag_create_time_36d78b7c ON public.tag USING btree (create_time);


--
-- Name: tag_key_08a35336; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tag_key_08a35336 ON public.tag USING btree (key);


--
-- Name: tag_key_08a35336_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tag_key_08a35336_like ON public.tag USING btree (key varchar_pattern_ops);


--
-- Name: tag_knowled_cba590_idx; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tag_knowled_cba590_idx ON public.tag USING btree (knowledge_id, key);


--
-- Name: tag_knowledge_id_5816b5de; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tag_knowledge_id_5816b5de ON public.tag USING btree (knowledge_id);


--
-- Name: tag_update_time_928c2700; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tag_update_time_928c2700 ON public.tag USING btree (update_time);


--
-- Name: tag_value_0d236690; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tag_value_0d236690 ON public.tag USING btree (value);


--
-- Name: tag_value_0d236690_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tag_value_0d236690_like ON public.tag USING btree (value varchar_pattern_ops);


--
-- Name: tool_create_time_e0880b81; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_create_time_e0880b81 ON public.tool USING btree (create_time);


--
-- Name: tool_folder_create_time_2a019328; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_create_time_2a019328 ON public.tool_folder USING btree (create_time);


--
-- Name: tool_folder_id_940ad233_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_id_940ad233_like ON public.tool_folder USING btree (id varchar_pattern_ops);


--
-- Name: tool_folder_id_ecc041f8; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_id_ecc041f8 ON public.tool USING btree (folder_id);


--
-- Name: tool_folder_id_ecc041f8_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_id_ecc041f8_like ON public.tool USING btree (folder_id varchar_pattern_ops);


--
-- Name: tool_folder_name_d6438754; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_name_d6438754 ON public.tool_folder USING btree (name);


--
-- Name: tool_folder_name_d6438754_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_name_d6438754_like ON public.tool_folder USING btree (name varchar_pattern_ops);


--
-- Name: tool_folder_parent_id_cbcf6a00; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_parent_id_cbcf6a00 ON public.tool_folder USING btree (parent_id);


--
-- Name: tool_folder_parent_id_cbcf6a00_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_parent_id_cbcf6a00_like ON public.tool_folder USING btree (parent_id varchar_pattern_ops);


--
-- Name: tool_folder_tree_id_60fc41dd; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_tree_id_60fc41dd ON public.tool_folder USING btree (tree_id);


--
-- Name: tool_folder_update_time_ba9be14e; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_update_time_ba9be14e ON public.tool_folder USING btree (update_time);


--
-- Name: tool_folder_user_id_be38331b; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_user_id_be38331b ON public.tool_folder USING btree (user_id);


--
-- Name: tool_folder_workspace_id_20b66b15; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_workspace_id_20b66b15 ON public.tool_folder USING btree (workspace_id);


--
-- Name: tool_folder_workspace_id_20b66b15_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_folder_workspace_id_20b66b15_like ON public.tool_folder USING btree (workspace_id varchar_pattern_ops);


--
-- Name: tool_is_active_f3d326d1; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_is_active_f3d326d1 ON public.tool USING btree (is_active);


--
-- Name: tool_label_66e517a8; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_label_66e517a8 ON public.tool USING btree (label);


--
-- Name: tool_label_66e517a8_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_label_66e517a8_like ON public.tool USING btree (label varchar_pattern_ops);


--
-- Name: tool_name_ec029465; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_name_ec029465 ON public.tool USING btree (name);


--
-- Name: tool_name_ec029465_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_name_ec029465_like ON public.tool USING btree (name varchar_pattern_ops);


--
-- Name: tool_scope_6387be58; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_scope_6387be58 ON public.tool USING btree (scope);


--
-- Name: tool_scope_6387be58_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_scope_6387be58_like ON public.tool USING btree (scope varchar_pattern_ops);


--
-- Name: tool_template_id_717d147f; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_template_id_717d147f ON public.tool USING btree (template_id);


--
-- Name: tool_tool_type_204cdc98; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_tool_type_204cdc98 ON public.tool USING btree (tool_type);


--
-- Name: tool_tool_type_204cdc98_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_tool_type_204cdc98_like ON public.tool USING btree (tool_type varchar_pattern_ops);


--
-- Name: tool_update_time_2e4efd57; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_update_time_2e4efd57 ON public.tool USING btree (update_time);


--
-- Name: tool_user_id_fd36dfa4; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_user_id_fd36dfa4 ON public.tool USING btree (user_id);


--
-- Name: tool_workspace_id_bf0fd790; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_workspace_id_bf0fd790 ON public.tool USING btree (workspace_id);


--
-- Name: tool_workspace_id_bf0fd790_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX tool_workspace_id_bf0fd790_like ON public.tool USING btree (workspace_id varchar_pattern_ops);


--
-- Name: user_create_time_d69e5f54; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_create_time_d69e5f54 ON public."user" USING btree (create_time);


--
-- Name: user_email_54dc62b2_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_email_54dc62b2_like ON public."user" USING btree (email varchar_pattern_ops);


--
-- Name: user_group_id_9e420a50_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_group_id_9e420a50_like ON public.user_group USING btree (id varchar_pattern_ops);


--
-- Name: user_group_name_d36097b4_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_group_name_d36097b4_like ON public.user_group USING btree (name varchar_pattern_ops);


--
-- Name: user_group_relation_group_id_8ee53fb6; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_group_relation_group_id_8ee53fb6 ON public.user_group_relation USING btree (group_id);


--
-- Name: user_group_relation_group_id_8ee53fb6_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_group_relation_group_id_8ee53fb6_like ON public.user_group_relation USING btree (group_id varchar_pattern_ops);


--
-- Name: user_group_relation_user_id_0a38580e; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_group_relation_user_id_0a38580e ON public.user_group_relation USING btree (user_id);


--
-- Name: user_is_active_74579245; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_is_active_74579245 ON public."user" USING btree (is_active);


--
-- Name: user_nick_name_580ea5e6_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_nick_name_580ea5e6_like ON public."user" USING btree (nick_name varchar_pattern_ops);


--
-- Name: user_phone_fcd7f7da; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_phone_fcd7f7da ON public."user" USING btree (phone);


--
-- Name: user_phone_fcd7f7da_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_phone_fcd7f7da_like ON public."user" USING btree (phone varchar_pattern_ops);


--
-- Name: user_source_51744f77; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_source_51744f77 ON public."user" USING btree (source);


--
-- Name: user_source_51744f77_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_source_51744f77_like ON public."user" USING btree (source varchar_pattern_ops);


--
-- Name: user_update_time_ccf08206; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_update_time_ccf08206 ON public."user" USING btree (update_time);


--
-- Name: user_username_cf016618_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX user_username_cf016618_like ON public."user" USING btree (username varchar_pattern_ops);


--
-- Name: workspace_user_resource__auth_target_type_33deef7a_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource__auth_target_type_33deef7a_like ON public.workspace_user_resource_permission USING btree (auth_target_type varchar_pattern_ops);


--
-- Name: workspace_user_resource_permission_auth_target_type_33deef7a; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_auth_target_type_33deef7a ON public.workspace_user_resource_permission USING btree (auth_target_type);


--
-- Name: workspace_user_resource_permission_auth_type_43a49931; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_auth_type_43a49931 ON public.workspace_user_resource_permission USING btree (auth_type);


--
-- Name: workspace_user_resource_permission_auth_type_43a49931_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_auth_type_43a49931_like ON public.workspace_user_resource_permission USING btree (auth_type varchar_pattern_ops);


--
-- Name: workspace_user_resource_permission_create_time_d3397f88; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_create_time_d3397f88 ON public.workspace_user_resource_permission USING btree (create_time);


--
-- Name: workspace_user_resource_permission_target_d0c6532f; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_target_d0c6532f ON public.workspace_user_resource_permission USING btree (target);


--
-- Name: workspace_user_resource_permission_update_time_f944478e; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_update_time_f944478e ON public.workspace_user_resource_permission USING btree (update_time);


--
-- Name: workspace_user_resource_permission_user_id_623d7674; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_user_id_623d7674 ON public.workspace_user_resource_permission USING btree (user_id);


--
-- Name: workspace_user_resource_permission_workspace_id_6d34f020; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_workspace_id_6d34f020 ON public.workspace_user_resource_permission USING btree (workspace_id);


--
-- Name: workspace_user_resource_permission_workspace_id_6d34f020_like; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX workspace_user_resource_permission_workspace_id_6d34f020_like ON public.workspace_user_resource_permission USING btree (workspace_id varchar_pattern_ops);


--
-- Name: application_access_token application_access_t_application_id_d90b8cec_fk_applicati; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_access_token
    ADD CONSTRAINT application_access_t_application_id_d90b8cec_fk_applicati FOREIGN KEY (application_id) REFERENCES public.application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_api_key application_api_key_application_id_376d9a01_fk_application_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_api_key
    ADD CONSTRAINT application_api_key_application_id_376d9a01_fk_application_id FOREIGN KEY (application_id) REFERENCES public.application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_api_key application_api_key_user_id_e9e85f1b_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_api_key
    ADD CONSTRAINT application_api_key_user_id_e9e85f1b_fk_user_id FOREIGN KEY (user_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_chat application_chat_application_id_0c9f6b90_fk_application_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_chat
    ADD CONSTRAINT application_chat_application_id_0c9f6b90_fk_application_id FOREIGN KEY (application_id) REFERENCES public.application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_chat_record application_chat_record_chat_id_21aeb7ef_fk_application_chat_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_chat_record
    ADD CONSTRAINT application_chat_record_chat_id_21aeb7ef_fk_application_chat_id FOREIGN KEY (chat_id) REFERENCES public.application_chat(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_chat_user_stats application_chat_use_application_id_2080bbf7_fk_applicati; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_chat_user_stats
    ADD CONSTRAINT application_chat_use_application_id_2080bbf7_fk_applicati FOREIGN KEY (application_id) REFERENCES public.application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application application_folder_id_0d598f52_fk_application_folder_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application
    ADD CONSTRAINT application_folder_id_0d598f52_fk_application_folder_id FOREIGN KEY (folder_id) REFERENCES public.application_folder(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_folder application_folder_parent_id_b82d1c52_fk_application_folder_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_folder
    ADD CONSTRAINT application_folder_parent_id_b82d1c52_fk_application_folder_id FOREIGN KEY (parent_id) REFERENCES public.application_folder(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_knowledge_mapping application_knowledg_application_id_784ccbaf_fk_applicati; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_knowledge_mapping
    ADD CONSTRAINT application_knowledg_application_id_784ccbaf_fk_applicati FOREIGN KEY (application_id) REFERENCES public.application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_knowledge_mapping application_knowledg_knowledge_id_767ec6f1_fk_knowledge; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_knowledge_mapping
    ADD CONSTRAINT application_knowledg_knowledge_id_767ec6f1_fk_knowledge FOREIGN KEY (knowledge_id) REFERENCES public.knowledge(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: application_version application_version_application_id_ee35744a_fk_application_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.application_version
    ADD CONSTRAINT application_version_application_id_ee35744a_fk_application_id FOREIGN KEY (application_id) REFERENCES public.application(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_apscheduler_djangojobexecution django_apscheduler_djangojobexecution_job_id_daf5090a_fk; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_apscheduler_djangojobexecution
    ADD CONSTRAINT django_apscheduler_djangojobexecution_job_id_daf5090a_fk FOREIGN KEY (job_id) REFERENCES public.django_apscheduler_djangojob(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_clocked_id_47a69f82_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_clocked_id_47a69f82_fk_django_ce FOREIGN KEY (clocked_id) REFERENCES public.django_celery_beat_clockedschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_crontab_id_d3cba168_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_crontab_id_d3cba168_fk_django_ce FOREIGN KEY (crontab_id) REFERENCES public.django_celery_beat_crontabschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_interval_id_a8ca27da_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_interval_id_a8ca27da_fk_django_ce FOREIGN KEY (interval_id) REFERENCES public.django_celery_beat_intervalschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_celery_beat_periodictask django_celery_beat_p_solar_id_a87ce72c_fk_django_ce; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.django_celery_beat_periodictask
    ADD CONSTRAINT django_celery_beat_p_solar_id_a87ce72c_fk_django_ce FOREIGN KEY (solar_id) REFERENCES public.django_celery_beat_solarschedule(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: document document_knowledge_id_419c566f_fk_knowledge_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.document
    ADD CONSTRAINT document_knowledge_id_419c566f_fk_knowledge_id FOREIGN KEY (knowledge_id) REFERENCES public.knowledge(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: knowledge knowledge_folder_id_c2644e2c_fk_knowledge_folder_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.knowledge
    ADD CONSTRAINT knowledge_folder_id_c2644e2c_fk_knowledge_folder_id FOREIGN KEY (folder_id) REFERENCES public.knowledge_folder(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: knowledge_folder knowledge_folder_parent_id_88bfda49_fk_knowledge_folder_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.knowledge_folder
    ADD CONSTRAINT knowledge_folder_parent_id_88bfda49_fk_knowledge_folder_id FOREIGN KEY (parent_id) REFERENCES public.knowledge_folder(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: paragraph paragraph_knowledge_id_4adce37e_fk_knowledge_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.paragraph
    ADD CONSTRAINT paragraph_knowledge_id_4adce37e_fk_knowledge_id FOREIGN KEY (knowledge_id) REFERENCES public.knowledge(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: resource_chat_user_authorize resource_chat_user_a_user_group_id_5f3021d3_fk_user_grou; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.resource_chat_user_authorize
    ADD CONSTRAINT resource_chat_user_a_user_group_id_5f3021d3_fk_user_grou FOREIGN KEY (user_group_id) REFERENCES public.user_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: resource_chat_user_authorize resource_chat_user_authorize_user_id_326419b7_fk_chat_user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.resource_chat_user_authorize
    ADD CONSTRAINT resource_chat_user_authorize_user_id_326419b7_fk_chat_user_id FOREIGN KEY (user_id) REFERENCES public.chat_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: resource_chat_user_group_authorize resource_chat_user_g_user_group_id_3798efb8_fk_user_grou; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.resource_chat_user_group_authorize
    ADD CONSTRAINT resource_chat_user_g_user_group_id_3798efb8_fk_user_grou FOREIGN KEY (user_group_id) REFERENCES public.user_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tool tool_folder_id_ecc041f8_fk_tool_folder_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tool
    ADD CONSTRAINT tool_folder_id_ecc041f8_fk_tool_folder_id FOREIGN KEY (folder_id) REFERENCES public.tool_folder(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tool_folder tool_folder_parent_id_cbcf6a00_fk_tool_folder_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tool_folder
    ADD CONSTRAINT tool_folder_parent_id_cbcf6a00_fk_tool_folder_id FOREIGN KEY (parent_id) REFERENCES public.tool_folder(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_group_relation user_group_relation_group_id_8ee53fb6_fk_user_group_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_group_relation
    ADD CONSTRAINT user_group_relation_group_id_8ee53fb6_fk_user_group_id FOREIGN KEY (group_id) REFERENCES public.user_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_group_relation user_group_relation_user_id_0a38580e_fk_chat_user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.user_group_relation
    ADD CONSTRAINT user_group_relation_user_id_0a38580e_fk_chat_user_id FOREIGN KEY (user_id) REFERENCES public.chat_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: workspace_user_resource_permission workspace_user_resource_permission_user_id_623d7674_fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.workspace_user_resource_permission
    ADD CONSTRAINT workspace_user_resource_permission_user_id_623d7674_fk_user_id FOREIGN KEY (user_id) REFERENCES public."user"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

\unrestrict qGOzIyj8SaXNRJg7A4f3qwSqFYBhJqAbDwGkahx8CdT5eQHfpZ85k0JEXiHScN2

