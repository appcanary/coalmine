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


SET search_path = public, pg_catalog;

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
    name character varying,
    path character varying,
    platform character varying NOT NULL,
    release character varying,
    last_crc bigint,
    from_api boolean,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: log_bundle_patches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE log_bundle_patches (
    id integer NOT NULL,
    bundle_id integer NOT NULL,
    package_id integer NOT NULL,
    bundled_package_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    vulnerable_package_id integer NOT NULL,
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
    vulnerable_package_id integer NOT NULL,
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
-- Name: packages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE packages (
    id integer NOT NULL,
    name character varying NOT NULL,
    source_name character varying,
    platform character varying,
    release character varying,
    version character varying,
    artifact character varying,
    epoch character varying,
    arch character varying,
    filename character varying,
    checksum character varying,
    origin character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    package_name character varying NOT NULL,
    package_platform character varying NOT NULL,
    title character varying,
    reported_at timestamp without time zone,
    description text,
    criticality character varying,
    patched_versions text[] DEFAULT '{}'::text[],
    unaffected_versions text[] DEFAULT '{}'::text[],
    cve_id character varying,
    usn_id character varying,
    dsa_id character varying,
    rhsa_id character varying,
    cesa_id character varying,
    source character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: vulnerable_packages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vulnerable_packages (
    id integer NOT NULL,
    package_id integer NOT NULL,
    vulnerability_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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

ALTER TABLE ONLY log_bundle_patches ALTER COLUMN id SET DEFAULT nextval('log_bundle_patches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_bundle_vulnerabilities ALTER COLUMN id SET DEFAULT nextval('log_bundle_vulnerabilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY packages ALTER COLUMN id SET DEFAULT nextval('packages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY vulnerabilities ALTER COLUMN id SET DEFAULT nextval('vulnerabilities_id_seq'::regclass);


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
-- Name: packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY packages
    ADD CONSTRAINT packages_pkey PRIMARY KEY (id);


--
-- Name: vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: vulnerable_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vulnerable_packages
    ADD CONSTRAINT vulnerable_packages_pkey PRIMARY KEY (id);


--
-- Name: index_bundled_package_archives_on_bundle_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_package_archives_on_bundle_id ON bundled_package_archives USING btree (bundle_id);


--
-- Name: index_bundled_package_archives_on_bundled_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bundled_package_archives_on_bundled_package_id ON bundled_package_archives USING btree (bundled_package_id);


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
-- Name: index_log_bundle_vulnerabilities_on_vulnerable_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_log_bundle_vulnerabilities_on_vulnerable_package_id ON log_bundle_vulnerabilities USING btree (vulnerable_package_id);


--
-- Name: index_of_five_kings_LBP; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_of_five_kings_LBP" ON log_bundle_patches USING btree (bundle_id, package_id, bundled_package_id, vulnerability_id, vulnerable_package_id);


--
-- Name: index_of_five_kings_LBV; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_of_five_kings_LBV" ON log_bundle_vulnerabilities USING btree (bundle_id, package_id, bundled_package_id, vulnerability_id, vulnerable_package_id);


--
-- Name: index_packages_on_name_and_version_and_platform_and_release; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_packages_on_name_and_version_and_platform_and_release ON packages USING btree (name, version, platform, release);


--
-- Name: index_vulnerable_packages_on_package_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_packages_on_package_id ON vulnerable_packages USING btree (package_id);


--
-- Name: index_vulnerable_packages_on_vulnerability_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vulnerable_packages_on_vulnerability_id ON vulnerable_packages USING btree (vulnerability_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: trigger_bundled_package_archives; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_bundled_package_archives AFTER DELETE OR UPDATE ON bundled_packages FOR EACH ROW EXECUTE PROCEDURE archive_bundled_packages();


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
-- Name: fk_rails_8318307314; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bundled_packages
    ADD CONSTRAINT fk_rails_8318307314 FOREIGN KEY (bundle_id) REFERENCES bundles(id);


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

INSERT INTO schema_migrations (version) VALUES ('20160520023126');

INSERT INTO schema_migrations (version) VALUES ('20160520174709');

INSERT INTO schema_migrations (version) VALUES ('20160520174805');

INSERT INTO schema_migrations (version) VALUES ('20160522191756');

INSERT INTO schema_migrations (version) VALUES ('20160604200640');

INSERT INTO schema_migrations (version) VALUES ('20160604200811');

