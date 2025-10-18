--
-- PostgreSQL database dump
--

\restrict dJudghjKQ9EB102Ga50gXCqn3tRjwhmU0nnEW7rcRuRMXAtamaVN1DQlg0XQYuZ

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: bankencore
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO bankencore;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: bankencore
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO bankencore;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: bankencore
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO bankencore;

--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: bankencore
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2025-10-16 18:35:51.300527	2025-10-16 18:35:51.30053
schema_sha1	9c6777daaa6ce85cc74b26c38000144a7834a947	2025-10-16 18:35:51.309469	2025-10-16 18:35:51.309472
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: bankencore
--

COPY public.schema_migrations (version) FROM stdin;
0
\.


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: bankencore
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: bankencore
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- PostgreSQL database dump complete
--

\unrestrict dJudghjKQ9EB102Ga50gXCqn3tRjwhmU0nnEW7rcRuRMXAtamaVN1DQlg0XQYuZ

