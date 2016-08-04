--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


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
         INSERT INTO advisory_archives(advisory_id, queued_advisory_id, identifier, package_platform, package_names, affected_arches, affected_releases, patched_versions, unaffected_versions, title, description, criticality, cve_ids, osvdb_id, usn_id, dsa_id, rhsa_id, cesa_id, source, reported_at, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.queued_advisory_id, OLD.identifier, OLD.package_platform, OLD.package_names, OLD.affected_arches, OLD.affected_releases, OLD.patched_versions, OLD.unaffected_versions, OLD.title, OLD.description, OLD.criticality, OLD.cve_ids, OLD.osvdb_id, OLD.usn_id, OLD.dsa_id, OLD.rhsa_id, OLD.cesa_id, OLD.source, OLD.reported_at, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
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
         INSERT INTO package_archives(package_id, name, source_name, platform, release, version, version_release, platform, epoch, arch, filename, checksum, origin, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.name, OLD.source_name, OLD.platform, OLD.release, OLD.version, OLD.version_release, OLD.platform, OLD.epoch, OLD.arch, OLD.filename, OLD.checksum, OLD.origin, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
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
         INSERT INTO vulnerability_archives(vulnerability_id, package_platform, title, description, criticality, cve_ids, osvdb_id, usn_id, dsa_id, rhsa_id, cesa_id, source, reported_at, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.package_platform, OLD.title, OLD.description, OLD.criticality, OLD.cve_ids, OLD.osvdb_id, OLD.usn_id, OLD.dsa_id, OLD.rhsa_id, OLD.cesa_id, OLD.source, OLD.reported_at, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
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
         INSERT INTO vulnerable_dependency_archives(vulnerable_dependency_id, vulnerability_id, package_platform, package_name, affected_arches, affected_releases, patched_versions, unaffected_versions, created_at, updated_at, valid_at, expired_at) VALUES
           (OLD.id, OLD.vulnerability_id, OLD.package_platform, OLD.package_name, OLD.affected_arches, OLD.affected_releases, OLD.patched_versions, OLD.unaffected_versions, OLD.created_at, OLD.updated_at, OLD.valid_at, CURRENT_TIMESTAMP);
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
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    email character varying,
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
-- Name: advisories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advisories (
    id integer NOT NULL,
    queued_advisory_id integer NOT NULL,
    identifier character varying NOT NULL,
    package_platform character varying NOT NULL,
    package_names character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    affected_arches character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    affected_releases character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    patched_versions text[] DEFAULT '{}'::text[] NOT NULL,
    unaffected_versions text[] DEFAULT '{}'::text[] NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    cve_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
    source character varying,
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
-- Name: advisory_archives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advisory_archives (
    id integer NOT NULL,
    advisory_id integer NOT NULL,
    queued_advisory_id integer NOT NULL,
    identifier character varying NOT NULL,
    package_platform character varying NOT NULL,
    package_names character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    affected_arches character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    affected_releases character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    patched_versions text[] DEFAULT '{}'::text[] NOT NULL,
    unaffected_versions text[] DEFAULT '{}'::text[] NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    cve_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
    source character varying,
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
-- Name: advisory_vulnerabilities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: advisory_vulnerability_archives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: agent_heartbeats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: agent_received_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: agent_releases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: agent_servers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    last_heartbeat timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: bundle_archives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: bundled_package_archives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: bundled_packages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: bundles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: email_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: log_bundle_patches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_bundle_patches (
    id integer NOT NULL,
    bundle_id integer NOT NULL,
    package_id integer NOT NULL,
    bundled_package_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    vulnerable_dependency_id integer NOT NULL,
    vulnerable_package_id integer NOT NULL,
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
-- Name: log_bundle_vulnerabilities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_bundle_vulnerabilities (
    id integer NOT NULL,
    bundle_id integer NOT NULL,
    package_id integer NOT NULL,
    bundled_package_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    vulnerable_dependency_id integer NOT NULL,
    vulnerable_package_id integer NOT NULL,
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
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: package_archives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE package_archives (
    id integer NOT NULL,
    package_id integer NOT NULL,
    name character varying NOT NULL,
    source_name character varying,
    platform character varying,
    release character varying,
    version character varying,
    version_release character varying,
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
-- Name: packages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE packages (
    id integer NOT NULL,
    name character varying NOT NULL,
    source_name character varying,
    platform character varying,
    release character varying,
    version character varying,
    version_release character varying,
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
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: queued_advisories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE queued_advisories (
    id integer NOT NULL,
    identifier character varying NOT NULL,
    package_platform character varying NOT NULL,
    package_names character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    affected_arches character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    affected_releases character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    patched_versions text[] DEFAULT '{}'::text[] NOT NULL,
    unaffected_versions text[] DEFAULT '{}'::text[] NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    cve_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
    source character varying,
    reported_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: queued_advisories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE queued_advisories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: queued_advisories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE queued_advisories_id_seq OWNED BY queued_advisories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: vulnerabilities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vulnerabilities (
    id integer NOT NULL,
    package_platform character varying NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    cve_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
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
-- Name: vulnerability_archives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vulnerability_archives (
    id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    package_platform character varying NOT NULL,
    title character varying,
    description text,
    criticality character varying,
    cve_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    osvdb_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
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
-- Name: vulnerable_dependencies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vulnerable_dependencies (
    id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    package_platform character varying NOT NULL,
    package_name character varying NOT NULL,
    affected_arches character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    affected_releases character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    patched_versions text[] DEFAULT '{}'::text[] NOT NULL,
    unaffected_versions text[] DEFAULT '{}'::text[] NOT NULL,
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
-- Name: vulnerable_dependency_archives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vulnerable_dependency_archives (
    id integer NOT NULL,
    vulnerable_dependency_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    package_platform character varying NOT NULL,
    package_name character varying NOT NULL,
    affected_arches character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    affected_releases character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    patched_versions text[] DEFAULT '{}'::text[] NOT NULL,
    unaffected_versions text[] DEFAULT '{}'::text[] NOT NULL,
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
-- Name: vulnerable_package_archives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: vulnerable_packages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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

ALTER TABLE ONLY agent_servers ALTER COLUMN id SET DEFAULT nextval('agent_servers_id_seq'::regclass);


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
-- Name: job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY queued_advisories ALTER COLUMN id SET DEFAULT nextval('queued_advisories_id_seq'::regclass);


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
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: advisories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advisories
    ADD CONSTRAINT advisories_pkey PRIMARY KEY (id);


--
-- Name: advisory_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advisory_archives
    ADD CONSTRAINT advisory_archives_pkey PRIMARY KEY (id);


--
-- Name: advisory_vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advisory_vulnerabilities
    ADD CONSTRAINT advisory_vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: advisory_vulnerability_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advisory_vulnerability_archives
    ADD CONSTRAINT advisory_vulnerability_archives_pkey PRIMARY KEY (id);


--
-- Name: agent_heartbeats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agent_heartbeats
    ADD CONSTRAINT agent_heartbeats_pkey PRIMARY KEY (id);


--
-- Name: agent_received_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agent_received_files
    ADD CONSTRAINT agent_received_files_pkey PRIMARY KEY (id);


--
-- Name: agent_releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agent_releases
    ADD CONSTRAINT agent_releases_pkey PRIMARY KEY (id);


--
-- Name: agent_servers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agent_servers
    ADD CONSTRAINT agent_servers_pkey PRIMARY KEY (id);


--
-- Name: bundle_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bundle_archives
    ADD CONSTRAINT bundle_archives_pkey PRIMARY KEY (id);


--
-- Name: bundled_package_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bundled_package_archives
    ADD CONSTRAINT bundled_package_archives_pkey PRIMARY KEY (id);


--
-- Name: bundled_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bundled_packages
    ADD CONSTRAINT bundled_packages_pkey PRIMARY KEY (id);


--
-- Name: bundles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bundles
    ADD CONSTRAINT bundles_pkey PRIMARY KEY (id);


--
-- Name: email_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_messages
    ADD CONSTRAINT email_messages_pkey PRIMARY KEY (id);


--
-- Name: log_bundle_patches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_bundle_patches
    ADD CONSTRAINT log_bundle_patches_pkey PRIMARY KEY (id);


--
-- Name: log_bundle_vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY log_bundle_vulnerabilities
    ADD CONSTRAINT log_bundle_vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: package_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY package_archives
    ADD CONSTRAINT package_archives_pkey PRIMARY KEY (id);


--
-- Name: packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY packages
    ADD CONSTRAINT packages_pkey PRIMARY KEY (id);


--
-- Name: que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: queued_advisories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY queued_advisories
    ADD CONSTRAINT queued_advisories_pkey PRIMARY KEY (id);


--
-- Name: vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: vulnerability_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulnerability_archives
    ADD CONSTRAINT vulnerability_archives_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulnerable_dependencies
    ADD CONSTRAINT vulnerable_dependencies_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_dependency_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulnerable_dependency_archives
    ADD CONSTRAINT vulnerable_dependency_archives_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_package_archives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulnerable_package_archives
    ADD CONSTRAINT vulnerable_package_archives_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulnerable_packages
    ADD CONSTRAINT vulnerable_packages_pkey PRIMARY KEY (id);


--
-- Name: idx_adv_vuln_adv; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_adv_vuln_adv ON advisory_vulnerabilities USING btree (advisory_id);


--
-- Name: idx_adv_vuln_adv_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_adv_vuln_adv_ar ON advisory_vulnerability_archives USING btree (advisory_id);


--
-- Name: idx_adv_vuln_vuln; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_adv_vuln_vuln ON advisory_vulnerabilities USING btree (vulnerability_id);


--
-- Name: idx_adv_vuln_vuln_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_adv_vuln_vuln_ar ON advisory_vulnerability_archives USING btree (vulnerability_id);


--
-- Name: idx_advisory_id_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_advisory_id_ar ON advisory_archives USING btree (advisory_id);


--
-- Name: idx_advisory_vulnerability_id_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_advisory_vulnerability_id_ar ON advisory_vulnerability_archives USING btree (advisory_vulnerability_id);


--
-- Name: idx_bundle_id_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_bundle_id_ar ON bundle_archives USING btree (bundle_id);


--
-- Name: idx_bundled_package_id_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_bundled_package_id_ar ON bundled_package_archives USING btree (bundled_package_id);


--
-- Name: idx_package_id_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_package_id_ar ON package_archives USING btree (package_id);


--
-- Name: idx_vulnerability_id_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_vulnerability_id_ar ON vulnerability_archives USING btree (vulnerability_id);


--
-- Name: idx_vulnerable_dependency_id_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_vulnerable_dependency_id_ar ON vulnerable_dependency_archives USING btree (vulnerable_dependency_id);


--
-- Name: idx_vulnerable_package_id_ar; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_vulnerable_package_id_ar ON vulnerable_package_archives USING btree (vulnerable_package_id);


--
-- Name: index_advisories_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisories_on_expired_at ON advisories USING btree (expired_at);


--
-- Name: index_advisories_on_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisories_on_identifier ON advisories USING btree (identifier);


--
-- Name: index_advisories_on_queued_advisory_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisories_on_queued_advisory_id ON advisories USING btree (queued_advisory_id);


--
-- Name: index_advisories_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisories_on_valid_at ON advisories USING btree (valid_at);


--
-- Name: index_advisory_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisory_archives_on_expired_at ON advisory_archives USING btree (expired_at);


--
-- Name: index_advisory_archives_on_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisory_archives_on_identifier ON advisory_archives USING btree (identifier);


--
-- Name: index_advisory_archives_on_queued_advisory_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisory_archives_on_queued_advisory_id ON advisory_archives USING btree (queued_advisory_id);


--
-- Name: index_advisory_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisory_archives_on_valid_at ON advisory_archives USING btree (valid_at);


--
-- Name: index_advisory_vulnerabilities_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisory_vulnerabilities_on_expired_at ON advisory_vulnerabilities USING btree (expired_at);


--
-- Name: index_advisory_vulnerabilities_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisory_vulnerabilities_on_valid_at ON advisory_vulnerabilities USING btree (valid_at);


--
-- Name: index_advisory_vulnerability_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisory_vulnerability_archives_on_expired_at ON advisory_vulnerability_archives USING btree (expired_at);


--
-- Name: index_advisory_vulnerability_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advisory_vulnerability_archives_on_valid_at ON advisory_vulnerability_archives USING btree (valid_at);


--
-- Name: index_agent_heartbeats_on_agent_server_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_agent_heartbeats_on_agent_server_id ON agent_heartbeats USING btree (agent_server_id);


--
-- Name: index_agent_received_files_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_agent_received_files_on_account_id ON agent_received_files USING btree (account_id);


--
-- Name: index_agent_received_files_on_agent_server_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_agent_received_files_on_agent_server_id ON agent_received_files USING btree (agent_server_id);


--
-- Name: index_agent_releases_on_version; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_agent_releases_on_version ON agent_releases USING btree (version);


--
-- Name: index_agent_servers_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_agent_servers_on_account_id ON agent_servers USING btree (account_id);


--
-- Name: index_agent_servers_on_agent_release_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_agent_servers_on_agent_release_id ON agent_servers USING btree (agent_release_id);


--
-- Name: index_agent_servers_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_agent_servers_on_uuid ON agent_servers USING btree (uuid);


--
-- Name: index_bundle_archives_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundle_archives_on_account_id ON bundle_archives USING btree (account_id);


--
-- Name: index_bundle_archives_on_agent_server_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundle_archives_on_agent_server_id ON bundle_archives USING btree (agent_server_id);


--
-- Name: index_bundle_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundle_archives_on_expired_at ON bundle_archives USING btree (expired_at);


--
-- Name: index_bundle_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundle_archives_on_valid_at ON bundle_archives USING btree (valid_at);


--
-- Name: index_bundled_package_archives_on_bundle_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_package_archives_on_bundle_id ON bundled_package_archives USING btree (bundle_id);


--
-- Name: index_bundled_package_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_package_archives_on_expired_at ON bundled_package_archives USING btree (expired_at);


--
-- Name: index_bundled_package_archives_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_package_archives_on_package_id ON bundled_package_archives USING btree (package_id);


--
-- Name: index_bundled_package_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_package_archives_on_valid_at ON bundled_package_archives USING btree (valid_at);


--
-- Name: index_bundled_packages_on_bundle_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_packages_on_bundle_id ON bundled_packages USING btree (bundle_id);


--
-- Name: index_bundled_packages_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_packages_on_expired_at ON bundled_packages USING btree (expired_at);


--
-- Name: index_bundled_packages_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_packages_on_package_id ON bundled_packages USING btree (package_id);


--
-- Name: index_bundled_packages_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_packages_on_valid_at ON bundled_packages USING btree (valid_at);


--
-- Name: index_bundles_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundles_on_account_id ON bundles USING btree (account_id);


--
-- Name: index_bundles_on_account_id_and_agent_server_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundles_on_account_id_and_agent_server_id ON bundles USING btree (account_id, agent_server_id);


--
-- Name: index_bundles_on_account_id_and_agent_server_id_and_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundles_on_account_id_and_agent_server_id_and_path ON bundles USING btree (account_id, agent_server_id, path);


--
-- Name: index_bundles_on_agent_server_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundles_on_agent_server_id ON bundles USING btree (agent_server_id);


--
-- Name: index_bundles_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundles_on_expired_at ON bundles USING btree (expired_at);


--
-- Name: index_bundles_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundles_on_valid_at ON bundles USING btree (valid_at);


--
-- Name: index_email_messages_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_email_messages_on_account_id ON email_messages USING btree (account_id);


--
-- Name: index_email_messages_on_sent_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_email_messages_on_sent_at ON email_messages USING btree (sent_at);


--
-- Name: index_log_bundle_patches_on_bundle_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_patches_on_bundle_id ON log_bundle_patches USING btree (bundle_id);


--
-- Name: index_log_bundle_patches_on_bundled_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_patches_on_bundled_package_id ON log_bundle_patches USING btree (bundled_package_id);


--
-- Name: index_log_bundle_patches_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_patches_on_package_id ON log_bundle_patches USING btree (package_id);


--
-- Name: index_log_bundle_patches_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_patches_on_vulnerability_id ON log_bundle_patches USING btree (vulnerability_id);


--
-- Name: index_log_bundle_patches_on_vulnerable_dependency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_patches_on_vulnerable_dependency_id ON log_bundle_patches USING btree (vulnerable_dependency_id);


--
-- Name: index_log_bundle_patches_on_vulnerable_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_patches_on_vulnerable_package_id ON log_bundle_patches USING btree (vulnerable_package_id);


--
-- Name: index_log_bundle_vulnerabilities_on_bundle_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_vulnerabilities_on_bundle_id ON log_bundle_vulnerabilities USING btree (bundle_id);


--
-- Name: index_log_bundle_vulnerabilities_on_bundled_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_vulnerabilities_on_bundled_package_id ON log_bundle_vulnerabilities USING btree (bundled_package_id);


--
-- Name: index_log_bundle_vulnerabilities_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_vulnerabilities_on_package_id ON log_bundle_vulnerabilities USING btree (package_id);


--
-- Name: index_log_bundle_vulnerabilities_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_vulnerabilities_on_vulnerability_id ON log_bundle_vulnerabilities USING btree (vulnerability_id);


--
-- Name: index_log_bundle_vulnerabilities_on_vulnerable_dependency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_vulnerabilities_on_vulnerable_dependency_id ON log_bundle_vulnerabilities USING btree (vulnerable_dependency_id);


--
-- Name: index_log_bundle_vulnerabilities_on_vulnerable_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_vulnerabilities_on_vulnerable_package_id ON log_bundle_vulnerabilities USING btree (vulnerable_package_id);


--
-- Name: index_notifications_on_email_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_email_message_id ON notifications USING btree (email_message_id);


--
-- Name: index_notifications_on_log_bundle_patch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_log_bundle_patch_id ON notifications USING btree (log_bundle_patch_id);


--
-- Name: index_notifications_on_log_bundle_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_log_bundle_vulnerability_id ON notifications USING btree (log_bundle_vulnerability_id);


--
-- Name: index_of_six_kings_LBP; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_of_six_kings_LBP" ON log_bundle_patches USING btree (bundle_id, package_id, bundled_package_id, vulnerability_id, vulnerable_dependency_id, vulnerable_package_id);


--
-- Name: index_of_six_kings_LBV; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_of_six_kings_LBV" ON log_bundle_vulnerabilities USING btree (bundle_id, package_id, bundled_package_id, vulnerability_id, vulnerable_dependency_id, vulnerable_package_id);


--
-- Name: index_package_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_package_archives_on_expired_at ON package_archives USING btree (expired_at);


--
-- Name: index_package_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_package_archives_on_valid_at ON package_archives USING btree (valid_at);


--
-- Name: index_packages_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_packages_on_expired_at ON packages USING btree (expired_at);


--
-- Name: index_packages_on_name_and_version_and_platform_and_release; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_packages_on_name_and_version_and_platform_and_release ON packages USING btree (name, version, platform, release);


--
-- Name: index_packages_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_packages_on_valid_at ON packages USING btree (valid_at);


--
-- Name: index_queued_advisories_on_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_queued_advisories_on_identifier ON queued_advisories USING btree (identifier);


--
-- Name: index_vulnerabilities_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerabilities_on_expired_at ON vulnerabilities USING btree (expired_at);


--
-- Name: index_vulnerabilities_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerabilities_on_valid_at ON vulnerabilities USING btree (valid_at);


--
-- Name: index_vulnerability_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerability_archives_on_expired_at ON vulnerability_archives USING btree (expired_at);


--
-- Name: index_vulnerability_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerability_archives_on_valid_at ON vulnerability_archives USING btree (valid_at);


--
-- Name: index_vulnerable_dependencies_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_dependencies_on_expired_at ON vulnerable_dependencies USING btree (expired_at);


--
-- Name: index_vulnerable_dependencies_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_dependencies_on_valid_at ON vulnerable_dependencies USING btree (valid_at);


--
-- Name: index_vulnerable_dependency_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_dependency_archives_on_expired_at ON vulnerable_dependency_archives USING btree (expired_at);


--
-- Name: index_vulnerable_dependency_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_dependency_archives_on_valid_at ON vulnerable_dependency_archives USING btree (valid_at);


--
-- Name: index_vulnerable_package_archives_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_package_archives_on_expired_at ON vulnerable_package_archives USING btree (expired_at);


--
-- Name: index_vulnerable_package_archives_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_package_archives_on_package_id ON vulnerable_package_archives USING btree (package_id);


--
-- Name: index_vulnerable_package_archives_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_package_archives_on_valid_at ON vulnerable_package_archives USING btree (valid_at);


--
-- Name: index_vulnerable_package_archives_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_package_archives_on_vulnerability_id ON vulnerable_package_archives USING btree (vulnerability_id);


--
-- Name: index_vulnerable_package_archives_on_vulnerable_dependency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_package_archives_on_vulnerable_dependency_id ON vulnerable_package_archives USING btree (vulnerable_dependency_id);


--
-- Name: index_vulnerable_packages_on_expired_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_packages_on_expired_at ON vulnerable_packages USING btree (expired_at);


--
-- Name: index_vulnerable_packages_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_packages_on_package_id ON vulnerable_packages USING btree (package_id);


--
-- Name: index_vulnerable_packages_on_valid_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_packages_on_valid_at ON vulnerable_packages USING btree (valid_at);


--
-- Name: index_vulnerable_packages_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_packages_on_vulnerability_id ON vulnerable_packages USING btree (vulnerability_id);


--
-- Name: index_vulnerable_packages_on_vulnerable_dependency_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_packages_on_vulnerable_dependency_id ON vulnerable_packages USING btree (vulnerable_dependency_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
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
-- Name: fk_rails_8a94ac142c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundles
    ADD CONSTRAINT fk_rails_8a94ac142c FOREIGN KEY (agent_server_id) REFERENCES agent_servers(id);


--
-- Name: fk_rails_a1b81c819c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_received_files
    ADD CONSTRAINT fk_rails_a1b81c819c FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: fk_rails_d5389f475f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY agent_heartbeats
    ADD CONSTRAINT fk_rails_d5389f475f FOREIGN KEY (agent_server_id) REFERENCES agent_servers(id);


--
-- Name: fk_rails_e4107b65b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_rails_e4107b65b3 FOREIGN KEY (email_message_id) REFERENCES email_messages(id);


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

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20160520020913');

INSERT INTO schema_migrations (version) VALUES ('20160520020914');

INSERT INTO schema_migrations (version) VALUES ('20160520023124');

INSERT INTO schema_migrations (version) VALUES ('20160520023125');

INSERT INTO schema_migrations (version) VALUES ('20160520023126');

INSERT INTO schema_migrations (version) VALUES ('20160520023127');

INSERT INTO schema_migrations (version) VALUES ('20160520174706');

INSERT INTO schema_migrations (version) VALUES ('20160520174707');

INSERT INTO schema_migrations (version) VALUES ('20160520174708');

INSERT INTO schema_migrations (version) VALUES ('20160520174709');

INSERT INTO schema_migrations (version) VALUES ('20160520174805');

INSERT INTO schema_migrations (version) VALUES ('20160522191756');

INSERT INTO schema_migrations (version) VALUES ('20160604200640');

INSERT INTO schema_migrations (version) VALUES ('20160604200811');

INSERT INTO schema_migrations (version) VALUES ('20160727190901');

INSERT INTO schema_migrations (version) VALUES ('20160728213358');

INSERT INTO schema_migrations (version) VALUES ('20160728213552');

INSERT INTO schema_migrations (version) VALUES ('20160804141716');

