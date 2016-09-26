--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: archive_advisories(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_advisories() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO advisory_archives(advisory_id, identifier, source, platform, patched, affected, unaffected, constraints, title, description, criticality, source_status, related, remediation, reference_ids, osvdb_id, usn_id, dsa_id, rhsa_id, cesa_id, source_text, processed, reported_at, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.identifier, OLD.source, OLD.platform, OLD.patched, OLD.affected, OLD.unaffected, OLD.constraints, OLD.title, OLD.description, OLD.criticality, OLD.source_status, OLD.related, OLD.remediation, OLD.reference_ids, OLD.osvdb_id, OLD.usn_id, OLD.dsa_id, OLD.rhsa_id, OLD.cesa_id, OLD.source_text, OLD.processed, OLD.reported_at, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


--
-- Name: archive_advisory_vulnerabilities(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_advisory_vulnerabilities() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO advisory_vulnerability_archives(advisory_vulnerability_id, advisory_id, vulnerability_id, valid_at, expired_at) VALUES
           (OLD.id, OLD.advisory_id, OLD.vulnerability_id, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


--
-- Name: archive_agent_servers(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_agent_servers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO agent_server_archives(agent_server_id, account_id, agent_release_id, uuid, hostname, uname, name, ip, distro, release, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.account_id, OLD.agent_release_id, OLD.uuid, OLD.hostname, OLD.uname, OLD.name, OLD.ip, OLD.distro, OLD.release, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


--
-- Name: archive_bundled_packages(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_bundled_packages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO bundled_package_archives(bundled_package_id, bundle_id, package_id, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.bundle_id, OLD.package_id, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


--
-- Name: archive_bundles(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_bundles() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO bundle_archives(bundle_id, account_id, agent_server_id, name, path, platform, release, last_crc, being_watched, from_api, deleted_at, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.account_id, OLD.agent_server_id, OLD.name, OLD.path, OLD.platform, OLD.release, OLD.last_crc, OLD.being_watched, OLD.from_api, OLD.deleted_at, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


--
-- Name: archive_packages(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_packages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO package_archives(package_id, platform, release, name, version, source_name, source_version, epoch, arch, filename, checksum, origin, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.platform, OLD.release, OLD.name, OLD.version, OLD.source_name, OLD.source_version, OLD.epoch, OLD.arch, OLD.filename, OLD.checksum, OLD.origin, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


--
-- Name: archive_vulnerabilities(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_vulnerabilities() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO vulnerability_archives(vulnerability_id, platform, title, description, criticality, reference_ids, related, osvdb_id, usn_id, dsa_id, rhsa_id, cesa_id, edited, source, reported_at, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.platform, OLD.title, OLD.description, OLD.criticality, OLD.reference_ids, OLD.related, OLD.osvdb_id, OLD.usn_id, OLD.dsa_id, OLD.rhsa_id, OLD.cesa_id, OLD.edited, OLD.source, OLD.reported_at, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


--
-- Name: archive_vulnerable_dependencies(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_vulnerable_dependencies() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO vulnerable_dependency_archives(vulnerable_dependency_id, vulnerability_id, platform, release, package_name, arch, patched_versions, unaffected_versions, pending, end_of_life, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.vulnerability_id, OLD.platform, OLD.release, OLD.package_name, OLD.arch, OLD.patched_versions, OLD.unaffected_versions, OLD.pending, OLD.end_of_life, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


--
-- Name: archive_vulnerable_packages(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION archive_vulnerable_packages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
       BEGIN
         INSERT INTO vulnerable_package_archives(vulnerable_package_id, package_id, vulnerable_dependency_id, vulnerability_id, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.package_id, OLD.vulnerable_dependency_id, OLD.vulnerability_id, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
         RETURN OLD;
       END;
       $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE accounts (
    id integer NOT NULL,
    email character varying NOT NULL,
    token character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: advisories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE advisories (
    id integer NOT NULL,
    identifier character varying NOT NULL,
    source character varying NOT NULL,
    platform character varying NOT NULL,
    patched jsonb DEFAULT '[]'::jsonb NOT NULL,
    affected jsonb DEFAULT '[]'::jsonb NOT NULL,
    unaffected jsonb DEFAULT '[]'::jsonb NOT NULL,
    constraints jsonb DEFAULT '[]'::jsonb NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    source_status character varying,
    related jsonb DEFAULT '[]'::jsonb NOT NULL,
    remediation text,
    reference_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
    source_text text,
    processed boolean DEFAULT false NOT NULL,
    reported_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: advisories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advisories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advisories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advisories_id_seq OWNED BY advisories.id;


--
-- Name: advisory_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE advisory_archives (
    id integer NOT NULL,
    advisory_id integer NOT NULL,
    identifier character varying NOT NULL,
    source character varying NOT NULL,
    platform character varying NOT NULL,
    patched jsonb DEFAULT '[]'::jsonb NOT NULL,
    affected jsonb DEFAULT '[]'::jsonb NOT NULL,
    unaffected jsonb DEFAULT '[]'::jsonb NOT NULL,
    constraints jsonb DEFAULT '[]'::jsonb NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    source_status character varying,
    related jsonb DEFAULT '[]'::jsonb NOT NULL,
    remediation text,
    reference_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
    source_text text,
    processed boolean DEFAULT false NOT NULL,
    reported_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: advisory_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advisory_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advisory_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advisory_archives_id_seq OWNED BY advisory_archives.id;


--
-- Name: advisory_vulnerabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE advisory_vulnerabilities (
    id integer NOT NULL,
    advisory_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: advisory_vulnerabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advisory_vulnerabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advisory_vulnerabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advisory_vulnerabilities_id_seq OWNED BY advisory_vulnerabilities.id;


--
-- Name: advisory_vulnerability_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE advisory_vulnerability_archives (
    id integer NOT NULL,
    advisory_vulnerability_id integer NOT NULL,
    advisory_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: advisory_vulnerability_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE advisory_vulnerability_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advisory_vulnerability_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advisory_vulnerability_archives_id_seq OWNED BY advisory_vulnerability_archives.id;


--
-- Name: agent_heartbeats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agent_heartbeats (
    id integer NOT NULL,
    agent_server_id integer NOT NULL,
    files text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: agent_heartbeats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agent_heartbeats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_heartbeats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agent_heartbeats_id_seq OWNED BY agent_heartbeats.id;


--
-- Name: agent_received_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agent_received_files (
    id integer NOT NULL,
    account_id integer NOT NULL,
    agent_server_id integer NOT NULL,
    request text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: agent_received_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agent_received_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_received_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agent_received_files_id_seq OWNED BY agent_received_files.id;


--
-- Name: agent_releases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agent_releases (
    id integer NOT NULL,
    version character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: agent_releases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agent_releases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_releases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agent_releases_id_seq OWNED BY agent_releases.id;


--
-- Name: agent_server_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agent_server_archives (
    id integer NOT NULL,
    agent_server_id integer NOT NULL,
    account_id integer,
    agent_release_id integer,
    uuid uuid DEFAULT uuid_generate_v4(),
    hostname character varying,
    uname character varying,
    name character varying,
    ip character varying,
    distro character varying,
    release character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: agent_server_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agent_server_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_server_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agent_server_archives_id_seq OWNED BY agent_server_archives.id;


--
-- Name: agent_servers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE agent_servers (
    id integer NOT NULL,
    account_id integer,
    agent_release_id integer,
    uuid uuid DEFAULT uuid_generate_v4(),
    hostname character varying,
    uname character varying,
    name character varying,
    ip character varying,
    distro character varying,
    release character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: agent_servers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agent_servers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_servers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agent_servers_id_seq OWNED BY agent_servers.id;


--
-- Name: beta_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE beta_users (
    id integer NOT NULL,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: beta_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE beta_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: beta_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE beta_users_id_seq OWNED BY beta_users.id;


--
-- Name: billing_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE billing_plans (
    id integer NOT NULL,
    user_id integer,
    subscription_plan_id integer,
    available_subscription_plans integer[] DEFAULT '{}'::integer[],
    started_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: billing_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE billing_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE billing_plans_id_seq OWNED BY billing_plans.id;


--
-- Name: bundle_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bundle_archives (
    id integer NOT NULL,
    bundle_id integer NOT NULL,
    account_id integer NOT NULL,
    agent_server_id integer,
    name character varying,
    path character varying,
    platform character varying NOT NULL,
    release character varying,
    last_crc bigint,
    being_watched boolean,
    from_api boolean,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: bundle_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bundle_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bundle_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bundle_archives_id_seq OWNED BY bundle_archives.id;


--
-- Name: bundled_package_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bundled_package_archives (
    id integer NOT NULL,
    bundled_package_id integer NOT NULL,
    bundle_id integer NOT NULL,
    package_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: bundled_package_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bundled_package_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bundled_package_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bundled_package_archives_id_seq OWNED BY bundled_package_archives.id;


--
-- Name: bundled_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bundled_packages (
    id integer NOT NULL,
    bundle_id integer NOT NULL,
    package_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: bundled_packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bundled_packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bundled_packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bundled_packages_id_seq OWNED BY bundled_packages.id;


--
-- Name: bundles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bundles (
    id integer NOT NULL,
    account_id integer NOT NULL,
    agent_server_id integer,
    name character varying,
    path character varying,
    platform character varying NOT NULL,
    release character varying,
    last_crc bigint,
    being_watched boolean,
    from_api boolean,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: bundles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bundles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bundles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bundles_id_seq OWNED BY bundles.id;


--
-- Name: email_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE email_messages (
    id integer NOT NULL,
    account_id integer NOT NULL,
    recipients character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    type character varying NOT NULL,
    sent_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: email_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_messages_id_seq OWNED BY email_messages.id;


--
-- Name: feature_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE feature_flags (
    id integer NOT NULL,
    data hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: feature_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feature_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feature_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feature_flags_id_seq OWNED BY feature_flags.id;


--
-- Name: is_it_vuln_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE is_it_vuln_results (
    id integer NOT NULL,
    ident character varying NOT NULL,
    result text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: is_it_vuln_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE is_it_vuln_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: is_it_vuln_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE is_it_vuln_results_id_seq OWNED BY is_it_vuln_results.id;


--
-- Name: log_api_calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE log_api_calls (
    id integer NOT NULL,
    account_id integer,
    action character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: log_api_calls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_api_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_api_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_api_calls_id_seq OWNED BY log_api_calls.id;


--
-- Name: log_bundle_patches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE log_bundle_patches (
    id integer NOT NULL,
    bundle_id integer NOT NULL,
    package_id integer NOT NULL,
    bundled_package_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    vulnerable_dependency_id integer NOT NULL,
    vulnerable_package_id integer NOT NULL,
    supplementary boolean DEFAULT false NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: log_bundle_patches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_bundle_patches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_bundle_patches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_bundle_patches_id_seq OWNED BY log_bundle_patches.id;


--
-- Name: log_bundle_vulnerabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE log_bundle_vulnerabilities (
    id integer NOT NULL,
    bundle_id integer NOT NULL,
    package_id integer NOT NULL,
    bundled_package_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    vulnerable_dependency_id integer NOT NULL,
    vulnerable_package_id integer NOT NULL,
    supplementary boolean DEFAULT false NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: log_bundle_vulnerabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_bundle_vulnerabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_bundle_vulnerabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_bundle_vulnerabilities_id_seq OWNED BY log_bundle_vulnerabilities.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE notifications (
    id integer NOT NULL,
    email_message_id integer NOT NULL,
    log_bundle_vulnerability_id integer,
    log_bundle_patch_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: package_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE package_archives (
    id integer NOT NULL,
    package_id integer NOT NULL,
    platform character varying NOT NULL,
    release character varying,
    name character varying NOT NULL,
    version character varying,
    source_name character varying,
    source_version character varying,
    epoch character varying,
    arch character varying,
    filename character varying,
    checksum character varying,
    origin character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: package_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE package_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: package_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE package_archives_id_seq OWNED BY package_archives.id;


--
-- Name: packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE packages (
    id integer NOT NULL,
    platform character varying NOT NULL,
    release character varying,
    name character varying NOT NULL,
    version character varying,
    source_name character varying,
    source_version character varying,
    epoch character varying,
    arch character varying,
    filename character varying,
    checksum character varying,
    origin character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE packages_id_seq OWNED BY packages.id;


--
-- Name: pre_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pre_users (
    id integer NOT NULL,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    preferred_platform character varying,
    from_isitvuln boolean DEFAULT false
);


--
-- Name: pre_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pre_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pre_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pre_users_id_seq OWNED BY pre_users.id;


--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    job_id bigint NOT NULL,
    job_class text NOT NULL,
    args json DEFAULT '[]'::json NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error text,
    queue text DEFAULT ''::text NOT NULL
);


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE que_jobs IS '3';


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE que_jobs_job_id_seq OWNED BY que_jobs.job_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE subscription_plans (
    id integer NOT NULL,
    value integer,
    unit_value integer,
    "limit" integer,
    label character varying,
    comment character varying,
    "default" boolean DEFAULT false NOT NULL,
    discount boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: subscription_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subscription_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscription_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subscription_plans_id_seq OWNED BY subscription_plans.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying NOT NULL,
    crypted_password character varying,
    salt character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_token_expires_at timestamp without time zone,
    reset_password_email_sent_at timestamp without time zone,
    activation_state character varying,
    activation_token character varying,
    activation_token_expires_at timestamp without time zone,
    last_login_at timestamp without time zone,
    last_logout_at timestamp without time zone,
    last_activity_at timestamp without time zone,
    last_login_from_ip_address character varying,
    failed_logins_count integer DEFAULT 0,
    lock_expires_at timestamp without time zone,
    unlock_token character varying,
    token character varying,
    onboarded boolean DEFAULT false,
    is_admin boolean DEFAULT false NOT NULL,
    beta_signup_source character varying,
    stripe_customer_id character varying,
    name character varying,
    subscription_plan character varying,
    newsletter_email_consent boolean DEFAULT true NOT NULL,
    api_beta boolean DEFAULT false NOT NULL,
    marketing_email_consent boolean DEFAULT true NOT NULL,
    daily_email_consent boolean DEFAULT false NOT NULL,
    datomic_id bigint,
    invoiced_manually boolean DEFAULT false,
    account_id integer NOT NULL,
    agent_token character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vulnerabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vulnerabilities (
    id integer NOT NULL,
    platform character varying NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    reference_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    related jsonb DEFAULT '[]'::jsonb NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
    edited boolean DEFAULT false,
    source character varying,
    reported_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: vulnerabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulnerabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulnerabilities_id_seq OWNED BY vulnerabilities.id;


--
-- Name: vulnerability_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vulnerability_archives (
    id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    platform character varying NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    reference_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    related jsonb DEFAULT '[]'::jsonb NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
    edited boolean DEFAULT false,
    source character varying,
    reported_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: vulnerability_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulnerability_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerability_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulnerability_archives_id_seq OWNED BY vulnerability_archives.id;


--
-- Name: vulnerable_dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vulnerable_dependencies (
    id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    platform character varying NOT NULL,
    release character varying,
    package_name character varying NOT NULL,
    arch character varying,
    patched_versions text[] DEFAULT '{}'::text[] NOT NULL,
    unaffected_versions text[] DEFAULT '{}'::text[] NOT NULL,
    pending boolean DEFAULT false NOT NULL,
    end_of_life boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: vulnerable_dependencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulnerable_dependencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerable_dependencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulnerable_dependencies_id_seq OWNED BY vulnerable_dependencies.id;


--
-- Name: vulnerable_dependency_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vulnerable_dependency_archives (
    id integer NOT NULL,
    vulnerable_dependency_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    platform character varying NOT NULL,
    release character varying,
    package_name character varying NOT NULL,
    arch character varying,
    patched_versions text[] DEFAULT '{}'::text[] NOT NULL,
    unaffected_versions text[] DEFAULT '{}'::text[] NOT NULL,
    pending boolean DEFAULT false NOT NULL,
    end_of_life boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: vulnerable_dependency_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulnerable_dependency_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerable_dependency_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulnerable_dependency_archives_id_seq OWNED BY vulnerable_dependency_archives.id;


--
-- Name: vulnerable_package_archives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vulnerable_package_archives (
    id integer NOT NULL,
    vulnerable_package_id integer NOT NULL,
    package_id integer NOT NULL,
    vulnerable_dependency_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone NOT NULL,
    expired_at timestamp without time zone NOT NULL
);


--
-- Name: vulnerable_package_archives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulnerable_package_archives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerable_package_archives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulnerable_package_archives_id_seq OWNED BY vulnerable_package_archives.id;


--
-- Name: vulnerable_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vulnerable_packages (
    id integer NOT NULL,
    package_id integer NOT NULL,
    vulnerable_dependency_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    valid_at timestamp without time zone DEFAULT now() NOT NULL,
    expired_at timestamp without time zone DEFAULT 'infinity'::timestamp without time zone NOT NULL
);


--
-- Name: vulnerable_packages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vulnerable_packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vulnerable_packages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vulnerable_packages_id_seq OWNED BY vulnerable_packages.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisories ALTER COLUMN id SET DEFAULT nextval('advisories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_archives ALTER COLUMN id SET DEFAULT nextval('advisory_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_vulnerabilities ALTER COLUMN id SET DEFAULT nextval('advisory_vulnerabilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_vulnerability_archives ALTER COLUMN id SET DEFAULT nextval('advisory_vulnerability_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_heartbeats ALTER COLUMN id SET DEFAULT nextval('agent_heartbeats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_received_files ALTER COLUMN id SET DEFAULT nextval('agent_received_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_releases ALTER COLUMN id SET DEFAULT nextval('agent_releases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_server_archives ALTER COLUMN id SET DEFAULT nextval('agent_server_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_servers ALTER COLUMN id SET DEFAULT nextval('agent_servers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY beta_users ALTER COLUMN id SET DEFAULT nextval('beta_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_plans ALTER COLUMN id SET DEFAULT nextval('billing_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundle_archives ALTER COLUMN id SET DEFAULT nextval('bundle_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundled_package_archives ALTER COLUMN id SET DEFAULT nextval('bundled_package_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundled_packages ALTER COLUMN id SET DEFAULT nextval('bundled_packages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundles ALTER COLUMN id SET DEFAULT nextval('bundles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_messages ALTER COLUMN id SET DEFAULT nextval('email_messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feature_flags ALTER COLUMN id SET DEFAULT nextval('feature_flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY is_it_vuln_results ALTER COLUMN id SET DEFAULT nextval('is_it_vuln_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_api_calls ALTER COLUMN id SET DEFAULT nextval('log_api_calls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_bundle_patches ALTER COLUMN id SET DEFAULT nextval('log_bundle_patches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_bundle_vulnerabilities ALTER COLUMN id SET DEFAULT nextval('log_bundle_vulnerabilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY package_archives ALTER COLUMN id SET DEFAULT nextval('package_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY packages ALTER COLUMN id SET DEFAULT nextval('packages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pre_users ALTER COLUMN id SET DEFAULT nextval('pre_users_id_seq'::regclass);


--
-- Name: job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscription_plans ALTER COLUMN id SET DEFAULT nextval('subscription_plans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerabilities ALTER COLUMN id SET DEFAULT nextval('vulnerabilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerability_archives ALTER COLUMN id SET DEFAULT nextval('vulnerability_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_dependencies ALTER COLUMN id SET DEFAULT nextval('vulnerable_dependencies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_dependency_archives ALTER COLUMN id SET DEFAULT nextval('vulnerable_dependency_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_package_archives ALTER COLUMN id SET DEFAULT nextval('vulnerable_package_archives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_packages ALTER COLUMN id SET DEFAULT nextval('vulnerable_packages_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: advisories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisories
    ADD CONSTRAINT advisories_pkey PRIMARY KEY (id);


--
-- Name: advisory_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_archives
    ADD CONSTRAINT advisory_archives_pkey PRIMARY KEY (id);


--
-- Name: advisory_vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_vulnerabilities
    ADD CONSTRAINT advisory_vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: advisory_vulnerability_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY advisory_vulnerability_archives
    ADD CONSTRAINT advisory_vulnerability_archives_pkey PRIMARY KEY (id);


--
-- Name: agent_heartbeats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_heartbeats
    ADD CONSTRAINT agent_heartbeats_pkey PRIMARY KEY (id);


--
-- Name: agent_received_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_received_files
    ADD CONSTRAINT agent_received_files_pkey PRIMARY KEY (id);


--
-- Name: agent_releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_releases
    ADD CONSTRAINT agent_releases_pkey PRIMARY KEY (id);


--
-- Name: agent_server_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_server_archives
    ADD CONSTRAINT agent_server_archives_pkey PRIMARY KEY (id);


--
-- Name: agent_servers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_servers
    ADD CONSTRAINT agent_servers_pkey PRIMARY KEY (id);


--
-- Name: beta_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY beta_users
    ADD CONSTRAINT beta_users_pkey PRIMARY KEY (id);


--
-- Name: billing_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_plans
    ADD CONSTRAINT billing_plans_pkey PRIMARY KEY (id);


--
-- Name: bundle_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundle_archives
    ADD CONSTRAINT bundle_archives_pkey PRIMARY KEY (id);


--
-- Name: bundled_package_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundled_package_archives
    ADD CONSTRAINT bundled_package_archives_pkey PRIMARY KEY (id);


--
-- Name: bundled_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundled_packages
    ADD CONSTRAINT bundled_packages_pkey PRIMARY KEY (id);


--
-- Name: bundles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundles
    ADD CONSTRAINT bundles_pkey PRIMARY KEY (id);


--
-- Name: email_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_messages
    ADD CONSTRAINT email_messages_pkey PRIMARY KEY (id);


--
-- Name: feature_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (id);


--
-- Name: is_it_vuln_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY is_it_vuln_results
    ADD CONSTRAINT is_it_vuln_results_pkey PRIMARY KEY (id);


--
-- Name: log_api_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_api_calls
    ADD CONSTRAINT log_api_calls_pkey PRIMARY KEY (id);


--
-- Name: log_bundle_patches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_bundle_patches
    ADD CONSTRAINT log_bundle_patches_pkey PRIMARY KEY (id);


--
-- Name: log_bundle_vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_bundle_vulnerabilities
    ADD CONSTRAINT log_bundle_vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: package_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY package_archives
    ADD CONSTRAINT package_archives_pkey PRIMARY KEY (id);


--
-- Name: packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packages
    ADD CONSTRAINT packages_pkey PRIMARY KEY (id);


--
-- Name: pre_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pre_users
    ADD CONSTRAINT pre_users_pkey PRIMARY KEY (id);


--
-- Name: que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: vulnerability_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerability_archives
    ADD CONSTRAINT vulnerability_archives_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_dependencies
    ADD CONSTRAINT vulnerable_dependencies_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_dependency_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_dependency_archives
    ADD CONSTRAINT vulnerable_dependency_archives_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_package_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_package_archives
    ADD CONSTRAINT vulnerable_package_archives_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_packages
    ADD CONSTRAINT vulnerable_packages_pkey PRIMARY KEY (id);


--
-- Name: idx_adv_vuln_adv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_adv_vuln_adv ON advisory_vulnerabilities USING btree (advisory_id);


--
-- Name: idx_adv_vuln_adv_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_adv_vuln_adv_ar ON advisory_vulnerability_archives USING btree (advisory_id);


--
-- Name: idx_adv_vuln_vuln; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_adv_vuln_vuln ON advisory_vulnerabilities USING btree (vulnerability_id);


--
-- Name: idx_adv_vuln_vuln_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_adv_vuln_vuln_ar ON advisory_vulnerability_archives USING btree (vulnerability_id);


--
-- Name: idx_advisory_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_advisory_id_ar ON advisory_archives USING btree (advisory_id);


--
-- Name: idx_advisory_vulnerability_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_advisory_vulnerability_id_ar ON advisory_vulnerability_archives USING btree (advisory_vulnerability_id);


--
-- Name: idx_agent_server_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agent_server_id_ar ON agent_server_archives USING btree (agent_server_id);


--
-- Name: idx_bundle_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bundle_id_ar ON bundle_archives USING btree (bundle_id);


--
-- Name: idx_bundled_package_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bundled_package_id_ar ON bundled_package_archives USING btree (bundled_package_id);


--
-- Name: idx_package_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_id_ar ON package_archives USING btree (package_id);


--
-- Name: idx_vulnerability_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vulnerability_id_ar ON vulnerability_archives USING btree (vulnerability_id);


--
-- Name: idx_vulnerable_dependency_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vulnerable_dependency_id_ar ON vulnerable_dependency_archives USING btree (vulnerable_dependency_id);


--
-- Name: idx_vulnerable_package_id_ar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vulnerable_package_id_ar ON vulnerable_package_archives USING btree (vulnerable_package_id);


--
-- Name: index_accounts_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_accounts_on_email ON accounts USING btree (email);


--
-- Name: index_accounts_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_token ON accounts USING btree (token);


--
-- Name: index_advisories_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisories_on_expired_at ON advisories USING btree (expired_at);


--
-- Name: index_advisories_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisories_on_identifier ON advisories USING btree (identifier);


--
-- Name: index_advisories_on_processed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisories_on_processed ON advisories USING btree (processed);


--
-- Name: index_advisories_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisories_on_source ON advisories USING btree (source);


--
-- Name: index_advisories_on_source_and_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_advisories_on_source_and_identifier ON advisories USING btree (source, identifier);


--
-- Name: index_advisories_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisories_on_valid_at ON advisories USING btree (valid_at);


--
-- Name: index_advisory_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_archives_on_expired_at ON advisory_archives USING btree (expired_at);


--
-- Name: index_advisory_archives_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_archives_on_identifier ON advisory_archives USING btree (identifier);


--
-- Name: index_advisory_archives_on_processed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_archives_on_processed ON advisory_archives USING btree (processed);


--
-- Name: index_advisory_archives_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_archives_on_source ON advisory_archives USING btree (source);


--
-- Name: index_advisory_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_archives_on_valid_at ON advisory_archives USING btree (valid_at);


--
-- Name: index_advisory_vulnerabilities_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_vulnerabilities_on_expired_at ON advisory_vulnerabilities USING btree (expired_at);


--
-- Name: index_advisory_vulnerabilities_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_vulnerabilities_on_valid_at ON advisory_vulnerabilities USING btree (valid_at);


--
-- Name: index_advisory_vulnerability_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_vulnerability_archives_on_expired_at ON advisory_vulnerability_archives USING btree (expired_at);


--
-- Name: index_advisory_vulnerability_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advisory_vulnerability_archives_on_valid_at ON advisory_vulnerability_archives USING btree (valid_at);


--
-- Name: index_agent_heartbeats_on_agent_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_heartbeats_on_agent_server_id ON agent_heartbeats USING btree (agent_server_id);


--
-- Name: index_agent_heartbeats_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_heartbeats_on_created_at ON agent_heartbeats USING btree (created_at);


--
-- Name: index_agent_received_files_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_received_files_on_account_id ON agent_received_files USING btree (account_id);


--
-- Name: index_agent_received_files_on_agent_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_received_files_on_agent_server_id ON agent_received_files USING btree (agent_server_id);


--
-- Name: index_agent_releases_on_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_releases_on_version ON agent_releases USING btree (version);


--
-- Name: index_agent_server_archives_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_server_archives_on_account_id ON agent_server_archives USING btree (account_id);


--
-- Name: index_agent_server_archives_on_agent_release_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_server_archives_on_agent_release_id ON agent_server_archives USING btree (agent_release_id);


--
-- Name: index_agent_server_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_server_archives_on_expired_at ON agent_server_archives USING btree (expired_at);


--
-- Name: index_agent_server_archives_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_server_archives_on_uuid ON agent_server_archives USING btree (uuid);


--
-- Name: index_agent_server_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_server_archives_on_valid_at ON agent_server_archives USING btree (valid_at);


--
-- Name: index_agent_servers_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_servers_on_account_id ON agent_servers USING btree (account_id);


--
-- Name: index_agent_servers_on_agent_release_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_servers_on_agent_release_id ON agent_servers USING btree (agent_release_id);


--
-- Name: index_agent_servers_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_servers_on_expired_at ON agent_servers USING btree (expired_at);


--
-- Name: index_agent_servers_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_servers_on_uuid ON agent_servers USING btree (uuid);


--
-- Name: index_agent_servers_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_agent_servers_on_valid_at ON agent_servers USING btree (valid_at);


--
-- Name: index_billing_plans_on_subscription_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_plans_on_subscription_plan_id ON billing_plans USING btree (subscription_plan_id);


--
-- Name: index_billing_plans_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_billing_plans_on_user_id ON billing_plans USING btree (user_id);


--
-- Name: index_bundle_archives_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundle_archives_on_account_id ON bundle_archives USING btree (account_id);


--
-- Name: index_bundle_archives_on_agent_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundle_archives_on_agent_server_id ON bundle_archives USING btree (agent_server_id);


--
-- Name: index_bundle_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundle_archives_on_expired_at ON bundle_archives USING btree (expired_at);


--
-- Name: index_bundle_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundle_archives_on_valid_at ON bundle_archives USING btree (valid_at);


--
-- Name: index_bundled_package_archives_on_bundle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundled_package_archives_on_bundle_id ON bundled_package_archives USING btree (bundle_id);


--
-- Name: index_bundled_package_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundled_package_archives_on_expired_at ON bundled_package_archives USING btree (expired_at);


--
-- Name: index_bundled_package_archives_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundled_package_archives_on_package_id ON bundled_package_archives USING btree (package_id);


--
-- Name: index_bundled_package_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundled_package_archives_on_valid_at ON bundled_package_archives USING btree (valid_at);


--
-- Name: index_bundled_packages_on_bundle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundled_packages_on_bundle_id ON bundled_packages USING btree (bundle_id);


--
-- Name: index_bundled_packages_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundled_packages_on_expired_at ON bundled_packages USING btree (expired_at);


--
-- Name: index_bundled_packages_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundled_packages_on_package_id ON bundled_packages USING btree (package_id);


--
-- Name: index_bundled_packages_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundled_packages_on_valid_at ON bundled_packages USING btree (valid_at);


--
-- Name: index_bundles_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundles_on_account_id ON bundles USING btree (account_id);


--
-- Name: index_bundles_on_account_id_and_agent_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundles_on_account_id_and_agent_server_id ON bundles USING btree (account_id, agent_server_id);


--
-- Name: index_bundles_on_account_id_and_agent_server_id_and_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundles_on_account_id_and_agent_server_id_and_path ON bundles USING btree (account_id, agent_server_id, path);


--
-- Name: index_bundles_on_agent_server_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundles_on_agent_server_id ON bundles USING btree (agent_server_id);


--
-- Name: index_bundles_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundles_on_expired_at ON bundles USING btree (expired_at);


--
-- Name: index_bundles_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bundles_on_valid_at ON bundles USING btree (valid_at);


--
-- Name: index_email_messages_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_messages_on_account_id ON email_messages USING btree (account_id);


--
-- Name: index_email_messages_on_sent_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_messages_on_sent_at ON email_messages USING btree (sent_at);


--
-- Name: index_feature_flags_on_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_feature_flags_on_data ON feature_flags USING btree (data);


--
-- Name: index_is_it_vuln_results_on_ident; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_is_it_vuln_results_on_ident ON is_it_vuln_results USING btree (ident);


--
-- Name: index_log_api_calls_on_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_api_calls_on_action ON log_api_calls USING btree (action);


--
-- Name: index_log_bundle_patches_on_bundle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_patches_on_bundle_id ON log_bundle_patches USING btree (bundle_id);


--
-- Name: index_log_bundle_patches_on_bundled_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_patches_on_bundled_package_id ON log_bundle_patches USING btree (bundled_package_id);


--
-- Name: index_log_bundle_patches_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_patches_on_package_id ON log_bundle_patches USING btree (package_id);


--
-- Name: index_log_bundle_patches_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_patches_on_vulnerability_id ON log_bundle_patches USING btree (vulnerability_id);


--
-- Name: index_log_bundle_patches_on_vulnerable_dependency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_patches_on_vulnerable_dependency_id ON log_bundle_patches USING btree (vulnerable_dependency_id);


--
-- Name: index_log_bundle_patches_on_vulnerable_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_patches_on_vulnerable_package_id ON log_bundle_patches USING btree (vulnerable_package_id);


--
-- Name: index_log_bundle_vulnerabilities_on_bundle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_vulnerabilities_on_bundle_id ON log_bundle_vulnerabilities USING btree (bundle_id);


--
-- Name: index_log_bundle_vulnerabilities_on_bundled_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_vulnerabilities_on_bundled_package_id ON log_bundle_vulnerabilities USING btree (bundled_package_id);


--
-- Name: index_log_bundle_vulnerabilities_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_vulnerabilities_on_package_id ON log_bundle_vulnerabilities USING btree (package_id);


--
-- Name: index_log_bundle_vulnerabilities_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_vulnerabilities_on_vulnerability_id ON log_bundle_vulnerabilities USING btree (vulnerability_id);


--
-- Name: index_log_bundle_vulnerabilities_on_vulnerable_dependency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_vulnerabilities_on_vulnerable_dependency_id ON log_bundle_vulnerabilities USING btree (vulnerable_dependency_id);


--
-- Name: index_log_bundle_vulnerabilities_on_vulnerable_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_bundle_vulnerabilities_on_vulnerable_package_id ON log_bundle_vulnerabilities USING btree (vulnerable_package_id);


--
-- Name: index_notifications_on_email_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_email_message_id ON notifications USING btree (email_message_id);


--
-- Name: index_notifications_on_log_bundle_patch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_log_bundle_patch_id ON notifications USING btree (log_bundle_patch_id);


--
-- Name: index_notifications_on_log_bundle_vulnerability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_log_bundle_vulnerability_id ON notifications USING btree (log_bundle_vulnerability_id);


--
-- Name: index_of_six_kings_LBP; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_of_six_kings_LBP" ON log_bundle_patches USING btree (bundle_id, package_id, bundled_package_id, vulnerability_id, vulnerable_dependency_id, vulnerable_package_id);


--
-- Name: index_of_six_kings_LBV; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_of_six_kings_LBV" ON log_bundle_vulnerabilities USING btree (bundle_id, package_id, bundled_package_id, vulnerability_id, vulnerable_dependency_id, vulnerable_package_id);


--
-- Name: index_package_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_package_archives_on_expired_at ON package_archives USING btree (expired_at);


--
-- Name: index_package_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_package_archives_on_valid_at ON package_archives USING btree (valid_at);


--
-- Name: index_packages_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packages_on_expired_at ON packages USING btree (expired_at);


--
-- Name: index_packages_on_name_and_version_and_platform_and_release; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packages_on_name_and_version_and_platform_and_release ON packages USING btree (name, version, platform, release);


--
-- Name: index_packages_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packages_on_valid_at ON packages USING btree (valid_at);


--
-- Name: index_subscription_plans_on_default; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscription_plans_on_default ON subscription_plans USING btree ("default");


--
-- Name: index_subscription_plans_on_discount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscription_plans_on_discount ON subscription_plans USING btree (discount);


--
-- Name: index_users_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_account_id ON users USING btree (account_id);


--
-- Name: index_users_on_activation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_activation_token ON users USING btree (activation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_last_logout_at_and_last_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_last_logout_at_and_last_activity_at ON users USING btree (last_logout_at, last_activity_at);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);


--
-- Name: index_vulnerabilities_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerabilities_on_expired_at ON vulnerabilities USING btree (expired_at);


--
-- Name: index_vulnerabilities_on_platform; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerabilities_on_platform ON vulnerabilities USING btree (platform);


--
-- Name: index_vulnerabilities_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerabilities_on_valid_at ON vulnerabilities USING btree (valid_at);


--
-- Name: index_vulnerability_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerability_archives_on_expired_at ON vulnerability_archives USING btree (expired_at);


--
-- Name: index_vulnerability_archives_on_platform; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerability_archives_on_platform ON vulnerability_archives USING btree (platform);


--
-- Name: index_vulnerability_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerability_archives_on_valid_at ON vulnerability_archives USING btree (valid_at);


--
-- Name: index_vulnerable_dependencies_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependencies_on_expired_at ON vulnerable_dependencies USING btree (expired_at);


--
-- Name: index_vulnerable_dependencies_on_package_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependencies_on_package_name ON vulnerable_dependencies USING btree (package_name);


--
-- Name: index_vulnerable_dependencies_on_platform; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependencies_on_platform ON vulnerable_dependencies USING btree (platform);


--
-- Name: index_vulnerable_dependencies_on_platform_and_package_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependencies_on_platform_and_package_name ON vulnerable_dependencies USING btree (platform, package_name);


--
-- Name: index_vulnerable_dependencies_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependencies_on_valid_at ON vulnerable_dependencies USING btree (valid_at);


--
-- Name: index_vulnerable_dependencies_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependencies_on_vulnerability_id ON vulnerable_dependencies USING btree (vulnerability_id);


--
-- Name: index_vulnerable_dependency_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependency_archives_on_expired_at ON vulnerable_dependency_archives USING btree (expired_at);


--
-- Name: index_vulnerable_dependency_archives_on_package_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependency_archives_on_package_name ON vulnerable_dependency_archives USING btree (package_name);


--
-- Name: index_vulnerable_dependency_archives_on_platform; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependency_archives_on_platform ON vulnerable_dependency_archives USING btree (platform);


--
-- Name: index_vulnerable_dependency_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependency_archives_on_valid_at ON vulnerable_dependency_archives USING btree (valid_at);


--
-- Name: index_vulnerable_dependency_archives_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_dependency_archives_on_vulnerability_id ON vulnerable_dependency_archives USING btree (vulnerability_id);


--
-- Name: index_vulnerable_package_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_package_archives_on_expired_at ON vulnerable_package_archives USING btree (expired_at);


--
-- Name: index_vulnerable_package_archives_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_package_archives_on_package_id ON vulnerable_package_archives USING btree (package_id);


--
-- Name: index_vulnerable_package_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_package_archives_on_valid_at ON vulnerable_package_archives USING btree (valid_at);


--
-- Name: index_vulnerable_package_archives_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_package_archives_on_vulnerability_id ON vulnerable_package_archives USING btree (vulnerability_id);


--
-- Name: index_vulnerable_package_archives_on_vulnerable_dependency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_package_archives_on_vulnerable_dependency_id ON vulnerable_package_archives USING btree (vulnerable_dependency_id);


--
-- Name: index_vulnerable_packages_on_expired_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_packages_on_expired_at ON vulnerable_packages USING btree (expired_at);


--
-- Name: index_vulnerable_packages_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_packages_on_package_id ON vulnerable_packages USING btree (package_id);


--
-- Name: index_vulnerable_packages_on_valid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_packages_on_valid_at ON vulnerable_packages USING btree (valid_at);


--
-- Name: index_vulnerable_packages_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_packages_on_vulnerability_id ON vulnerable_packages USING btree (vulnerability_id);


--
-- Name: index_vulnerable_packages_on_vulnerable_dependency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vulnerable_packages_on_vulnerable_dependency_id ON vulnerable_packages USING btree (vulnerable_dependency_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: trigger_advisory_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_advisory_archives AFTER DELETE OR UPDATE ON advisories FOR EACH ROW EXECUTE PROCEDURE archive_advisories();


--
-- Name: trigger_advisory_vulnerability_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_advisory_vulnerability_archives AFTER DELETE OR UPDATE ON advisory_vulnerabilities FOR EACH ROW EXECUTE PROCEDURE archive_advisory_vulnerabilities();


--
-- Name: trigger_agent_server_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_agent_server_archives AFTER DELETE OR UPDATE ON agent_servers FOR EACH ROW EXECUTE PROCEDURE archive_agent_servers();


--
-- Name: trigger_bundle_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_bundle_archives AFTER DELETE OR UPDATE ON bundles FOR EACH ROW EXECUTE PROCEDURE archive_bundles();


--
-- Name: trigger_bundled_package_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_bundled_package_archives AFTER DELETE OR UPDATE ON bundled_packages FOR EACH ROW EXECUTE PROCEDURE archive_bundled_packages();


--
-- Name: trigger_package_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_package_archives AFTER DELETE OR UPDATE ON packages FOR EACH ROW EXECUTE PROCEDURE archive_packages();


--
-- Name: trigger_vulnerability_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_vulnerability_archives AFTER DELETE OR UPDATE ON vulnerabilities FOR EACH ROW EXECUTE PROCEDURE archive_vulnerabilities();


--
-- Name: trigger_vulnerable_dependency_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_vulnerable_dependency_archives AFTER DELETE OR UPDATE ON vulnerable_dependencies FOR EACH ROW EXECUTE PROCEDURE archive_vulnerable_dependencies();


--
-- Name: trigger_vulnerable_package_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_vulnerable_package_archives AFTER DELETE OR UPDATE ON vulnerable_packages FOR EACH ROW EXECUTE PROCEDURE archive_vulnerable_packages();


--
-- Name: fk_rails_169d1b409d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_received_files
    ADD CONSTRAINT fk_rails_169d1b409d FOREIGN KEY (agent_server_id) REFERENCES agent_servers(id);


--
-- Name: fk_rails_52f2f7a9e3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_rails_52f2f7a9e3 FOREIGN KEY (log_bundle_vulnerability_id) REFERENCES log_bundle_vulnerabilities(id);


--
-- Name: fk_rails_553559718b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundles
    ADD CONSTRAINT fk_rails_553559718b FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: fk_rails_602d23d9db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_packages
    ADD CONSTRAINT fk_rails_602d23d9db FOREIGN KEY (vulnerability_id) REFERENCES vulnerabilities(id);


--
-- Name: fk_rails_61ac11da2b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_61ac11da2b FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: fk_rails_6c7c501d37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundled_packages
    ADD CONSTRAINT fk_rails_6c7c501d37 FOREIGN KEY (package_id) REFERENCES packages(id);


--
-- Name: fk_rails_7ffd76ae80; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_messages
    ADD CONSTRAINT fk_rails_7ffd76ae80 FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: fk_rails_8318307314; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundled_packages
    ADD CONSTRAINT fk_rails_8318307314 FOREIGN KEY (bundle_id) REFERENCES bundles(id);


--
-- Name: fk_rails_a1b81c819c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_received_files
    ADD CONSTRAINT fk_rails_a1b81c819c FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: fk_rails_b2ed287d75; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_plans
    ADD CONSTRAINT fk_rails_b2ed287d75 FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plans(id);


--
-- Name: fk_rails_e4107b65b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_rails_e4107b65b3 FOREIGN KEY (email_message_id) REFERENCES email_messages(id);


--
-- Name: fk_rails_f0b7c79393; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY billing_plans
    ADD CONSTRAINT fk_rails_f0b7c79393 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_f192ff6aa1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_rails_f192ff6aa1 FOREIGN KEY (log_bundle_patch_id) REFERENCES log_bundle_patches(id);


--
-- Name: fk_rails_fa826b18a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_packages
    ADD CONSTRAINT fk_rails_fa826b18a3 FOREIGN KEY (vulnerable_dependency_id) REFERENCES vulnerable_dependencies(id);


--
-- Name: fk_rails_fca1b65201; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_servers
    ADD CONSTRAINT fk_rails_fca1b65201 FOREIGN KEY (agent_release_id) REFERENCES agent_releases(id);


--
-- Name: fk_rails_fe164d0a00; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_servers
    ADD CONSTRAINT fk_rails_fe164d0a00 FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: fk_rails_ff1c2105ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerable_packages
    ADD CONSTRAINT fk_rails_ff1c2105ae FOREIGN KEY (package_id) REFERENCES packages(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20150125001115');

INSERT INTO schema_migrations (version) VALUES ('20150125165400');

INSERT INTO schema_migrations (version) VALUES ('20150125165401');

INSERT INTO schema_migrations (version) VALUES ('20150125165402');

INSERT INTO schema_migrations (version) VALUES ('20150125165403');

INSERT INTO schema_migrations (version) VALUES ('20150125165404');

INSERT INTO schema_migrations (version) VALUES ('20150220222623');

INSERT INTO schema_migrations (version) VALUES ('20150323004514');

INSERT INTO schema_migrations (version) VALUES ('20150325030540');

INSERT INTO schema_migrations (version) VALUES ('20150325052123');

INSERT INTO schema_migrations (version) VALUES ('20150402202034');

INSERT INTO schema_migrations (version) VALUES ('20150616174305');

INSERT INTO schema_migrations (version) VALUES ('20150624000026');

INSERT INTO schema_migrations (version) VALUES ('20150727222019');

INSERT INTO schema_migrations (version) VALUES ('20150801170157');

INSERT INTO schema_migrations (version) VALUES ('20150801174405');

INSERT INTO schema_migrations (version) VALUES ('20150806003630');

INSERT INTO schema_migrations (version) VALUES ('20150806023953');

INSERT INTO schema_migrations (version) VALUES ('20150813172011');

INSERT INTO schema_migrations (version) VALUES ('20151112220433');

INSERT INTO schema_migrations (version) VALUES ('20151209151358');

INSERT INTO schema_migrations (version) VALUES ('20151217113403');

INSERT INTO schema_migrations (version) VALUES ('20160113220608');

INSERT INTO schema_migrations (version) VALUES ('20160118221733');

INSERT INTO schema_migrations (version) VALUES ('20160410015633');

INSERT INTO schema_migrations (version) VALUES ('20160425184916');

INSERT INTO schema_migrations (version) VALUES ('20160520020913');

INSERT INTO schema_migrations (version) VALUES ('20160520020914');

INSERT INTO schema_migrations (version) VALUES ('20160520023125');

INSERT INTO schema_migrations (version) VALUES ('20160520023126');

INSERT INTO schema_migrations (version) VALUES ('20160520023127');

INSERT INTO schema_migrations (version) VALUES ('20160520174706');

INSERT INTO schema_migrations (version) VALUES ('20160520174707');

INSERT INTO schema_migrations (version) VALUES ('20160520174708');

INSERT INTO schema_migrations (version) VALUES ('20160520174709');

INSERT INTO schema_migrations (version) VALUES ('20160520174805');

INSERT INTO schema_migrations (version) VALUES ('20160522191756');

INSERT INTO schema_migrations (version) VALUES ('20160530195216');

INSERT INTO schema_migrations (version) VALUES ('20160530195217');

INSERT INTO schema_migrations (version) VALUES ('20160602133740');

INSERT INTO schema_migrations (version) VALUES ('20160602134913');

INSERT INTO schema_migrations (version) VALUES ('20160603150414');

INSERT INTO schema_migrations (version) VALUES ('20160604200640');

INSERT INTO schema_migrations (version) VALUES ('20160604200811');

INSERT INTO schema_migrations (version) VALUES ('20160727190901');

INSERT INTO schema_migrations (version) VALUES ('20160728213358');

INSERT INTO schema_migrations (version) VALUES ('20160728213552');

INSERT INTO schema_migrations (version) VALUES ('20160804141716');

INSERT INTO schema_migrations (version) VALUES ('20160805151822');

INSERT INTO schema_migrations (version) VALUES ('20160809220154');

INSERT INTO schema_migrations (version) VALUES ('20160825182745');

INSERT INTO schema_migrations (version) VALUES ('20160924162720');

INSERT INTO schema_migrations (version) VALUES ('20160924205930');

INSERT INTO schema_migrations (version) VALUES ('20160924211127');

