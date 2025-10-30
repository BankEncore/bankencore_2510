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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: alloc_party_profile_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.alloc_party_profile_number() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  base bigint;
  seq7 text;
  yy   text := to_char(CURRENT_DATE, 'YY');
  body text;
  candidate text;
BEGIN
  LOOP
    base := nextval('seq_party_serial');

    IF base > 9999999 THEN
      -- set to 1000 so nextval() -> 1001
      PERFORM setval('seq_party_serial', 1000, false);
      base := nextval('seq_party_serial');
    END IF;

    seq7 := lpad(base::text, 7, '0');        -- 7-digit, zero-padded
    body := seq7 || yy;                       -- 9 digits: seq(7) + year(2)
    candidate := body || util_luhn_checksum(body)::text; -- 10th is Luhn

    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM parties_parties WHERE profile_number = candidate
    );
  END LOOP;

  RETURN candidate; -- always 10 digits
END$$;


--
-- Name: set_party_profile_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_party_profile_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.profile_number IS NULL OR NEW.profile_number = '' THEN
    NEW.profile_number := alloc_party_profile_number();
  END IF;
  RETURN NEW;
END$$;


--
-- Name: util_luhn_checksum(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.util_luhn_checksum(num_text text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
  sum int := 0; d int; dbl boolean := false; c char;
BEGIN
  -- compute check digit for the given string of digits
  FOR i IN REVERSE length(num_text)..1 LOOP
    c := substr(num_text, i, 1);
    d := (c)::int;
    IF dbl THEN d := d*2; IF d>9 THEN d := d-9; END IF; END IF;
    sum := sum + d;
    dbl := NOT dbl;
  END LOOP;
  RETURN (10 - (sum % 10)) % 10;
END$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audits (
    id bigint NOT NULL,
    request_uuid uuid,
    auditable_type character varying,
    auditable_id bigint,
    associated_type character varying,
    associated_id bigint,
    user_type character varying,
    user_id bigint,
    username character varying,
    action character varying NOT NULL,
    audited_changes jsonb DEFAULT '{}'::jsonb NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    comment character varying,
    remote_address character varying,
    auditable_name character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audits_id_seq OWNED BY public.audits.id;


--
-- Name: branch_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branch_memberships (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    branch_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: branch_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.branch_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branch_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.branch_memberships_id_seq OWNED BY public.branch_memberships.id;


--
-- Name: branches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branches (
    id bigint NOT NULL,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(16) NOT NULL,
    name character varying(120) NOT NULL,
    status integer,
    "{inactive: 0, active: 1}" integer,
    time_zone character varying NOT NULL,
    address_1 character varying,
    address_2 character varying,
    city character varying,
    region_code character varying(10),
    postal_code character varying(16),
    country_alpha2 character varying(2) NOT NULL,
    phone character varying(32),
    fax character varying(32),
    email character varying,
    operating_hours jsonb DEFAULT '{}'::jsonb NOT NULL,
    latitude numeric(9,6),
    longitude numeric(9,6),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_branches_status CHECK ((status = ANY (ARRAY[0, 1])))
);


--
-- Name: branches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.branches_id_seq OWNED BY public.branches.id;


--
-- Name: parties_disclosures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_disclosures (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    disclosure_type_code character varying NOT NULL,
    ack_type_code character varying,
    acknowledged_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: parties_disclosures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_disclosures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_disclosures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_disclosures_id_seq OWNED BY public.parties_disclosures.id;


--
-- Name: parties_email_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_email_addresses (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    email_type_code character varying NOT NULL,
    email character varying,
    verified_at timestamp without time zone,
    preferred boolean DEFAULT false NOT NULL,
    valid_from date,
    valid_to date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_parties_email_addresses_valid_range CHECK (((valid_from IS NULL) OR (valid_to IS NULL) OR (valid_from <= valid_to)))
);


--
-- Name: parties_email_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_email_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_email_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_email_addresses_id_seq OWNED BY public.parties_email_addresses.id;


--
-- Name: parties_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_identities (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    identity_type_code character varying NOT NULL,
    number character varying,
    issuing_country character varying,
    system_region_id bigint,
    issuer_name character varying,
    issued_on date,
    expires_on date,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: parties_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_identities_id_seq OWNED BY public.parties_identities.id;


--
-- Name: parties_individuals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_individuals (
    party_id bigint NOT NULL,
    residence_country character varying,
    birth_date date,
    gender_code character varying,
    marital_status_code character varying,
    immigration_status_code character varying,
    education_level_code character varying,
    home_ownership_code character varying,
    race_code character varying,
    employment_type_code character varying,
    occupation_code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: parties_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_names (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    name_type_code character varying NOT NULL,
    full_name character varying,
    family_name character varying,
    given_name character varying,
    middle_name character varying,
    prefix_code character varying,
    suffix_code character varying,
    preferred boolean DEFAULT false NOT NULL,
    valid_from date,
    valid_to date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_parties_names_valid_range CHECK (((valid_from IS NULL) OR (valid_to IS NULL) OR (valid_from <= valid_to)))
);


--
-- Name: parties_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_names_id_seq OWNED BY public.parties_names.id;


--
-- Name: parties_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_organizations (
    party_id bigint NOT NULL,
    established_on date,
    residence_country character varying,
    organization_type_code character varying,
    system_naics_code_id bigint,
    tax_exempt_code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: parties_parties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_parties (
    id bigint NOT NULL,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_number character varying NOT NULL,
    relationship_to_institution_code character varying DEFAULT 'customer'::character varying NOT NULL,
    preferred_party_name_id bigint,
    established_on date DEFAULT CURRENT_DATE NOT NULL,
    withholding_option_code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: parties_parties_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_parties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_parties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_parties_id_seq OWNED BY public.parties_parties.id;


--
-- Name: parties_phones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_phones (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    phone_type_code character varying NOT NULL,
    e164 character varying,
    verified_at timestamp without time zone,
    preferred boolean DEFAULT false NOT NULL,
    valid_from date,
    valid_to date,
    invalid_reason character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_parties_phones_valid_range CHECK (((valid_from IS NULL) OR (valid_to IS NULL) OR (valid_from <= valid_to)))
);


--
-- Name: parties_phones_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_phones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_phones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_phones_id_seq OWNED BY public.parties_phones.id;


--
-- Name: parties_postal_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_postal_addresses (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    address_use_code character varying,
    address_type_code character varying,
    line1 character varying,
    line2 character varying,
    line3 character varying,
    line4 character varying,
    city character varying,
    system_region_id bigint,
    postal_code character varying,
    country character varying,
    preferred boolean DEFAULT false NOT NULL,
    valid_from date,
    valid_to date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_parties_postal_addresses_valid_range CHECK (((valid_from IS NULL) OR (valid_to IS NULL) OR (valid_from <= valid_to)))
);


--
-- Name: parties_postal_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_postal_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_postal_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_postal_addresses_id_seq OWNED BY public.parties_postal_addresses.id;


--
-- Name: parties_relationships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_relationships (
    id bigint NOT NULL,
    source_party_id bigint NOT NULL,
    target_party_id bigint NOT NULL,
    relationship_type_code character varying NOT NULL,
    ownership_percent numeric(5,2),
    status_code character varying,
    valid_from date,
    valid_to date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_party_rel_not_self CHECK ((source_party_id <> target_party_id)),
    CONSTRAINT chk_valid_range_rel CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_from <= valid_to)))
);


--
-- Name: parties_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_relationships_id_seq OWNED BY public.parties_relationships.id;


--
-- Name: parties_secret_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_secret_data (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    secret_type character varying NOT NULL,
    secret_value character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: parties_secret_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_secret_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_secret_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_secret_data_id_seq OWNED BY public.parties_secret_data.id;


--
-- Name: parties_tax_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_tax_ids (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    tax_id_type_code character varying NOT NULL,
    value character varying NOT NULL,
    country character varying,
    b_notice1_sent_on date,
    b_notice2_sent_on date,
    w8_signed_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: parties_tax_ids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_tax_ids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_tax_ids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_tax_ids_id_seq OWNED BY public.parties_tax_ids.id;


--
-- Name: parties_web_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parties_web_addresses (
    id bigint NOT NULL,
    party_id bigint NOT NULL,
    url character varying,
    preferred boolean DEFAULT false NOT NULL,
    valid_from date,
    valid_to date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_parties_web_addresses_valid_range CHECK (((valid_from IS NULL) OR (valid_to IS NULL) OR (valid_from <= valid_to)))
);


--
-- Name: parties_web_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parties_web_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parties_web_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parties_web_addresses_id_seq OWNED BY public.parties_web_addresses.id;


--
-- Name: payments_ach_routings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments_ach_routings (
    id bigint NOT NULL,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL,
    routing_number character varying(9) NOT NULL,
    customer_name character varying(36) NOT NULL,
    city character varying(25),
    state_code character varying(2),
    servicing_frb_number character varying(9),
    office_code character varying(1),
    record_type_code character varying(1),
    institution_status_code character varying(1),
    data_view_code character varying(1),
    new_routing_number character varying(9),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    address character varying(36),
    zip_code character varying(10),
    phone_number character varying(20),
    notes text,
    us_treasury boolean DEFAULT false NOT NULL,
    us_postal_service boolean DEFAULT false NOT NULL,
    federal_reserve_bank boolean DEFAULT false NOT NULL,
    on_us boolean DEFAULT false NOT NULL,
    special_handling boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN payments_ach_routings.address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.address IS 'Delivery address';


--
-- Name: COLUMN payments_ach_routings.zip_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.zip_code IS 'ZIP code';


--
-- Name: COLUMN payments_ach_routings.phone_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.phone_number IS 'Contact phone, digits only';


--
-- Name: COLUMN payments_ach_routings.notes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.notes IS 'Freeform notes';


--
-- Name: COLUMN payments_ach_routings.us_treasury; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.us_treasury IS 'ACH number is U.S. Treasury payment';


--
-- Name: COLUMN payments_ach_routings.us_postal_service; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.us_postal_service IS 'ACH number is U.S. Postal Service money order';


--
-- Name: COLUMN payments_ach_routings.federal_reserve_bank; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.federal_reserve_bank IS 'Federal Reserve Bank flag';


--
-- Name: COLUMN payments_ach_routings.on_us; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.on_us IS '"On-us" account';


--
-- Name: COLUMN payments_ach_routings.special_handling; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payments_ach_routings.special_handling IS 'Docs require special handling';


--
-- Name: payments_ach_routings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_ach_routings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_ach_routings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_ach_routings_id_seq OWNED BY public.payments_ach_routings.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id bigint NOT NULL,
    key character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id bigint NOT NULL,
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: role_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_permissions_id_seq OWNED BY public.role_permissions.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    key character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: seq_party_serial; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_party_serial
    START WITH 1001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_countries (
    id bigint NOT NULL,
    alpha2 character varying(2) NOT NULL,
    alpha3 character varying(3) NOT NULL,
    "numeric" character varying(3) NOT NULL,
    iso_short_name text NOT NULL,
    iso_long_name text,
    dialing_prefix text,
    postal_code_required boolean DEFAULT true NOT NULL,
    postal_code_regex text,
    address_format text,
    currency_primary_code character varying(3),
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: system_countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_countries_id_seq OWNED BY public.system_countries.id;


--
-- Name: system_country_currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_country_currencies (
    id bigint NOT NULL,
    country_alpha2 character varying(2) NOT NULL,
    currency_code character varying(3) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    legal_tender boolean DEFAULT true NOT NULL,
    valid_from date,
    valid_to date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_scc_valid_window CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_from <= valid_to)))
);


--
-- Name: system_country_currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_country_currencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_country_currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_country_currencies_id_seq OWNED BY public.system_country_currencies.id;


--
-- Name: system_currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_currencies (
    id bigint NOT NULL,
    code character varying(3) NOT NULL,
    "numeric" character varying(3) NOT NULL,
    name character varying NOT NULL,
    full_name character varying,
    minor_units integer DEFAULT 2 NOT NULL,
    symbol character varying,
    unicode_codepoint integer,
    active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    CONSTRAINT chk_currency_minor_units CHECK ((minor_units = ANY (ARRAY[0, 1, 2, 3])))
);


--
-- Name: system_currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_currencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_currencies_id_seq OWNED BY public.system_currencies.id;


--
-- Name: system_naics_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_naics_codes (
    id bigint NOT NULL,
    code character varying NOT NULL,
    title character varying NOT NULL,
    description text,
    parent_code character varying,
    level integer NOT NULL,
    version character varying DEFAULT '2022'::character varying NOT NULL,
    sector character varying(2),
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: system_naics_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_naics_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_naics_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_naics_codes_id_seq OWNED BY public.system_naics_codes.id;


--
-- Name: system_reference_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_reference_lists (
    id bigint NOT NULL,
    key character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL
);


--
-- Name: system_reference_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_reference_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_reference_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_reference_lists_id_seq OWNED BY public.system_reference_lists.id;


--
-- Name: system_reference_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_reference_values (
    id bigint NOT NULL,
    reference_list_id bigint NOT NULL,
    code character varying NOT NULL,
    name character varying NOT NULL,
    short_name character varying,
    description text,
    sort_index integer DEFAULT 50 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    external_code character varying,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    valid_from date,
    valid_to date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: system_reference_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_reference_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_reference_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_reference_values_id_seq OWNED BY public.system_reference_values.id;


--
-- Name: system_regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_regions (
    id bigint NOT NULL,
    country_alpha2 character varying(2) NOT NULL,
    region_code character varying(10) NOT NULL,
    name character varying NOT NULL,
    kind character varying NOT NULL,
    iso_code character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: system_regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_regions_id_seq OWNED BY public.system_regions.id;


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp(6) without time zone,
    last_sign_in_at timestamp(6) without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    confirmation_sent_at timestamp(6) without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp(6) without time zone,
    first_name character varying(100) DEFAULT ''::character varying NOT NULL,
    last_name character varying(100) DEFAULT ''::character varying NOT NULL,
    display_name character varying(150),
    locale character varying(10),
    phone_e164 character varying(20),
    time_zone character varying(50) DEFAULT 'UTC'::character varying NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    mfa_enabled boolean DEFAULT false NOT NULL,
    terms_accepted_at timestamp(6) without time zone,
    preferences jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: audits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits ALTER COLUMN id SET DEFAULT nextval('public.audits_id_seq'::regclass);


--
-- Name: branch_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_memberships ALTER COLUMN id SET DEFAULT nextval('public.branch_memberships_id_seq'::regclass);


--
-- Name: branches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches ALTER COLUMN id SET DEFAULT nextval('public.branches_id_seq'::regclass);


--
-- Name: parties_disclosures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_disclosures ALTER COLUMN id SET DEFAULT nextval('public.parties_disclosures_id_seq'::regclass);


--
-- Name: parties_email_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_email_addresses ALTER COLUMN id SET DEFAULT nextval('public.parties_email_addresses_id_seq'::regclass);


--
-- Name: parties_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_identities ALTER COLUMN id SET DEFAULT nextval('public.parties_identities_id_seq'::regclass);


--
-- Name: parties_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_names ALTER COLUMN id SET DEFAULT nextval('public.parties_names_id_seq'::regclass);


--
-- Name: parties_parties id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_parties ALTER COLUMN id SET DEFAULT nextval('public.parties_parties_id_seq'::regclass);


--
-- Name: parties_phones id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_phones ALTER COLUMN id SET DEFAULT nextval('public.parties_phones_id_seq'::regclass);


--
-- Name: parties_postal_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_postal_addresses ALTER COLUMN id SET DEFAULT nextval('public.parties_postal_addresses_id_seq'::regclass);


--
-- Name: parties_relationships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_relationships ALTER COLUMN id SET DEFAULT nextval('public.parties_relationships_id_seq'::regclass);


--
-- Name: parties_secret_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_secret_data ALTER COLUMN id SET DEFAULT nextval('public.parties_secret_data_id_seq'::regclass);


--
-- Name: parties_tax_ids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_tax_ids ALTER COLUMN id SET DEFAULT nextval('public.parties_tax_ids_id_seq'::regclass);


--
-- Name: parties_web_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_web_addresses ALTER COLUMN id SET DEFAULT nextval('public.parties_web_addresses_id_seq'::regclass);


--
-- Name: payments_ach_routings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments_ach_routings ALTER COLUMN id SET DEFAULT nextval('public.payments_ach_routings_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: role_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions ALTER COLUMN id SET DEFAULT nextval('public.role_permissions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: system_countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_countries ALTER COLUMN id SET DEFAULT nextval('public.system_countries_id_seq'::regclass);


--
-- Name: system_country_currencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_country_currencies ALTER COLUMN id SET DEFAULT nextval('public.system_country_currencies_id_seq'::regclass);


--
-- Name: system_currencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_currencies ALTER COLUMN id SET DEFAULT nextval('public.system_currencies_id_seq'::regclass);


--
-- Name: system_naics_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_naics_codes ALTER COLUMN id SET DEFAULT nextval('public.system_naics_codes_id_seq'::regclass);


--
-- Name: system_reference_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_reference_lists ALTER COLUMN id SET DEFAULT nextval('public.system_reference_lists_id_seq'::regclass);


--
-- Name: system_reference_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_reference_values ALTER COLUMN id SET DEFAULT nextval('public.system_reference_values_id_seq'::regclass);


--
-- Name: system_regions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_regions ALTER COLUMN id SET DEFAULT nextval('public.system_regions_id_seq'::regclass);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: branch_memberships branch_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_memberships
    ADD CONSTRAINT branch_memberships_pkey PRIMARY KEY (id);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: parties_disclosures parties_disclosures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_disclosures
    ADD CONSTRAINT parties_disclosures_pkey PRIMARY KEY (id);


--
-- Name: parties_email_addresses parties_email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_email_addresses
    ADD CONSTRAINT parties_email_addresses_pkey PRIMARY KEY (id);


--
-- Name: parties_identities parties_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_identities
    ADD CONSTRAINT parties_identities_pkey PRIMARY KEY (id);


--
-- Name: parties_names parties_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_names
    ADD CONSTRAINT parties_names_pkey PRIMARY KEY (id);


--
-- Name: parties_parties parties_parties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_parties
    ADD CONSTRAINT parties_parties_pkey PRIMARY KEY (id);


--
-- Name: parties_phones parties_phones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_phones
    ADD CONSTRAINT parties_phones_pkey PRIMARY KEY (id);


--
-- Name: parties_postal_addresses parties_postal_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_postal_addresses
    ADD CONSTRAINT parties_postal_addresses_pkey PRIMARY KEY (id);


--
-- Name: parties_relationships parties_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_relationships
    ADD CONSTRAINT parties_relationships_pkey PRIMARY KEY (id);


--
-- Name: parties_secret_data parties_secret_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_secret_data
    ADD CONSTRAINT parties_secret_data_pkey PRIMARY KEY (id);


--
-- Name: parties_tax_ids parties_tax_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_tax_ids
    ADD CONSTRAINT parties_tax_ids_pkey PRIMARY KEY (id);


--
-- Name: parties_web_addresses parties_web_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_web_addresses
    ADD CONSTRAINT parties_web_addresses_pkey PRIMARY KEY (id);


--
-- Name: payments_ach_routings payments_ach_routings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments_ach_routings
    ADD CONSTRAINT payments_ach_routings_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: system_countries system_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_countries
    ADD CONSTRAINT system_countries_pkey PRIMARY KEY (id);


--
-- Name: system_country_currencies system_country_currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_country_currencies
    ADD CONSTRAINT system_country_currencies_pkey PRIMARY KEY (id);


--
-- Name: system_currencies system_currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_currencies
    ADD CONSTRAINT system_currencies_pkey PRIMARY KEY (id);


--
-- Name: system_naics_codes system_naics_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_naics_codes
    ADD CONSTRAINT system_naics_codes_pkey PRIMARY KEY (id);


--
-- Name: system_reference_lists system_reference_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_reference_lists
    ADD CONSTRAINT system_reference_lists_pkey PRIMARY KEY (id);


--
-- Name: system_reference_values system_reference_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_reference_values
    ADD CONSTRAINT system_reference_values_pkey PRIMARY KEY (id);


--
-- Name: system_regions system_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_regions
    ADD CONSTRAINT system_regions_pkey PRIMARY KEY (id);


--
-- Name: parties_names uq_parties_names_id_party; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_names
    ADD CONSTRAINT uq_parties_names_id_party UNIQUE (id, party_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: associated_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX associated_index ON public.audits USING btree (associated_type, associated_id);


--
-- Name: auditable_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auditable_index ON public.audits USING btree (auditable_type, auditable_id, version);


--
-- Name: idx_party_rel_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_party_rel_key ON public.parties_relationships USING btree (source_party_id, target_party_id, relationship_type_code);


--
-- Name: idx_scc_on_country_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_scc_on_country_currency ON public.system_country_currencies USING btree (country_alpha2, currency_code);


--
-- Name: idx_srv_on_list_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_srv_on_list_code ON public.system_reference_values USING btree (reference_list_id, code);


--
-- Name: idx_unique_preferred_address_per_party; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_unique_preferred_address_per_party ON public.parties_postal_addresses USING btree (party_id) WHERE (preferred = true);


--
-- Name: idx_unique_preferred_name_per_party; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_unique_preferred_name_per_party ON public.parties_names USING btree (party_id) WHERE (preferred = true);


--
-- Name: idx_unique_preferred_phone_per_party; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_unique_preferred_phone_per_party ON public.parties_phones USING btree (party_id) WHERE (preferred = true);


--
-- Name: idx_unique_preferred_web_per_party; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_unique_preferred_web_per_party ON public.parties_web_addresses USING btree (party_id) WHERE (preferred = true);


--
-- Name: idx_unique_taxid_per_party_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_unique_taxid_per_party_type ON public.parties_tax_ids USING btree (party_id, tax_id_type_code, value);


--
-- Name: index_audits_on_request_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_request_uuid ON public.audits USING btree (request_uuid);


--
-- Name: index_branch_memberships_on_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_branch_memberships_on_branch_id ON public.branch_memberships USING btree (branch_id);


--
-- Name: index_branch_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_branch_memberships_on_user_id ON public.branch_memberships USING btree (user_id);


--
-- Name: index_branch_memberships_on_user_id_and_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branch_memberships_on_user_id_and_branch_id ON public.branch_memberships USING btree (user_id, branch_id);


--
-- Name: index_branches_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_on_code ON public.branches USING btree (code);


--
-- Name: index_branches_on_country_alpha2_and_region_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_branches_on_country_alpha2_and_region_code ON public.branches USING btree (country_alpha2, region_code);


--
-- Name: index_branches_on_public_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_on_public_id ON public.branches USING btree (public_id);


--
-- Name: index_branches_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_branches_on_status ON public.branches USING btree (status);


--
-- Name: index_parties_disclosures_on_ack_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_disclosures_on_ack_type_code ON public.parties_disclosures USING btree (ack_type_code);


--
-- Name: index_parties_disclosures_on_disclosure_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_disclosures_on_disclosure_type_code ON public.parties_disclosures USING btree (disclosure_type_code);


--
-- Name: index_parties_disclosures_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_disclosures_on_party_id ON public.parties_disclosures USING btree (party_id);


--
-- Name: index_parties_email_addresses_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_email_addresses_on_party_id ON public.parties_email_addresses USING btree (party_id);


--
-- Name: index_parties_identities_on_expires_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_identities_on_expires_on ON public.parties_identities USING btree (expires_on);


--
-- Name: index_parties_identities_on_identity_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_identities_on_identity_type_code ON public.parties_identities USING btree (identity_type_code);


--
-- Name: index_parties_identities_on_metadata; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_identities_on_metadata ON public.parties_identities USING gin (metadata);


--
-- Name: index_parties_identities_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_identities_on_party_id ON public.parties_identities USING btree (party_id);


--
-- Name: index_parties_individuals_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_parties_individuals_on_party_id ON public.parties_individuals USING btree (party_id);


--
-- Name: index_parties_individuals_on_residence_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_individuals_on_residence_country ON public.parties_individuals USING btree (residence_country);


--
-- Name: index_parties_names_on_name_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_names_on_name_type_code ON public.parties_names USING btree (name_type_code);


--
-- Name: index_parties_names_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_names_on_party_id ON public.parties_names USING btree (party_id);


--
-- Name: index_parties_names_on_preferred; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_names_on_preferred ON public.parties_names USING btree (preferred);


--
-- Name: index_parties_organizations_on_organization_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_organizations_on_organization_type_code ON public.parties_organizations USING btree (organization_type_code);


--
-- Name: index_parties_organizations_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_parties_organizations_on_party_id ON public.parties_organizations USING btree (party_id);


--
-- Name: index_parties_organizations_on_system_naics_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_organizations_on_system_naics_code_id ON public.parties_organizations USING btree (system_naics_code_id);


--
-- Name: index_parties_organizations_on_tax_exempt_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_organizations_on_tax_exempt_code ON public.parties_organizations USING btree (tax_exempt_code);


--
-- Name: index_parties_parties_on_preferred_party_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_parties_on_preferred_party_name_id ON public.parties_parties USING btree (preferred_party_name_id);


--
-- Name: index_parties_parties_on_profile_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_parties_parties_on_profile_number ON public.parties_parties USING btree (profile_number);


--
-- Name: index_parties_parties_on_public_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_parties_parties_on_public_id ON public.parties_parties USING btree (public_id);


--
-- Name: index_parties_parties_on_relationship_to_institution_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_parties_on_relationship_to_institution_code ON public.parties_parties USING btree (relationship_to_institution_code);


--
-- Name: index_parties_parties_on_withholding_option_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_parties_on_withholding_option_code ON public.parties_parties USING btree (withholding_option_code);


--
-- Name: index_parties_phones_on_e164; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_phones_on_e164 ON public.parties_phones USING btree (e164);


--
-- Name: index_parties_phones_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_phones_on_party_id ON public.parties_phones USING btree (party_id);


--
-- Name: index_parties_phones_on_phone_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_phones_on_phone_type_code ON public.parties_phones USING btree (phone_type_code);


--
-- Name: index_parties_postal_addresses_on_address_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_postal_addresses_on_address_type_code ON public.parties_postal_addresses USING btree (address_type_code);


--
-- Name: index_parties_postal_addresses_on_address_use_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_postal_addresses_on_address_use_code ON public.parties_postal_addresses USING btree (address_use_code);


--
-- Name: index_parties_postal_addresses_on_country; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_postal_addresses_on_country ON public.parties_postal_addresses USING btree (country);


--
-- Name: index_parties_postal_addresses_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_postal_addresses_on_party_id ON public.parties_postal_addresses USING btree (party_id);


--
-- Name: index_parties_postal_addresses_on_system_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_postal_addresses_on_system_region_id ON public.parties_postal_addresses USING btree (system_region_id);


--
-- Name: index_parties_relationships_on_status_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_relationships_on_status_code ON public.parties_relationships USING btree (status_code);


--
-- Name: index_parties_secret_data_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_secret_data_on_party_id ON public.parties_secret_data USING btree (party_id);


--
-- Name: index_parties_secret_data_on_party_id_and_secret_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_parties_secret_data_on_party_id_and_secret_type ON public.parties_secret_data USING btree (party_id, secret_type);


--
-- Name: index_parties_tax_ids_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_tax_ids_on_party_id ON public.parties_tax_ids USING btree (party_id);


--
-- Name: index_parties_tax_ids_on_tax_id_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_tax_ids_on_tax_id_type_code ON public.parties_tax_ids USING btree (tax_id_type_code);


--
-- Name: index_parties_web_addresses_on_party_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_web_addresses_on_party_id ON public.parties_web_addresses USING btree (party_id);


--
-- Name: index_parties_web_addresses_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_parties_web_addresses_on_url ON public.parties_web_addresses USING btree (url);


--
-- Name: index_payments_ach_routings_on_public_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payments_ach_routings_on_public_id ON public.payments_ach_routings USING btree (public_id);


--
-- Name: index_payments_ach_routings_on_routing_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payments_ach_routings_on_routing_number ON public.payments_ach_routings USING btree (routing_number);


--
-- Name: index_permissions_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_key ON public.permissions USING btree (key);


--
-- Name: index_role_permissions_on_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_role_permissions_on_permission_id ON public.role_permissions USING btree (permission_id);


--
-- Name: index_role_permissions_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_role_permissions_on_role_id ON public.role_permissions USING btree (role_id);


--
-- Name: index_role_permissions_on_role_id_and_permission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_role_permissions_on_role_id_and_permission_id ON public.role_permissions USING btree (role_id, permission_id);


--
-- Name: index_roles_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_key ON public.roles USING btree (key);


--
-- Name: index_system_countries_on_alpha2; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_countries_on_alpha2 ON public.system_countries USING btree (alpha2);


--
-- Name: index_system_countries_on_alpha3; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_countries_on_alpha3 ON public.system_countries USING btree (alpha3);


--
-- Name: index_system_countries_on_currency_primary_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_countries_on_currency_primary_code ON public.system_countries USING btree (currency_primary_code);


--
-- Name: index_system_countries_on_numeric; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_countries_on_numeric ON public.system_countries USING btree ("numeric");


--
-- Name: index_system_currencies_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_currencies_on_code ON public.system_currencies USING btree (code);


--
-- Name: index_system_currencies_on_numeric; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_currencies_on_numeric ON public.system_currencies USING btree ("numeric");


--
-- Name: index_system_naics_codes_on_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_naics_codes_on_level ON public.system_naics_codes USING btree (level);


--
-- Name: index_system_naics_codes_on_parent_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_naics_codes_on_parent_code ON public.system_naics_codes USING btree (parent_code);


--
-- Name: index_system_naics_codes_on_version_and_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_naics_codes_on_version_and_code ON public.system_naics_codes USING btree (version, code);


--
-- Name: index_system_reference_lists_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_reference_lists_on_key ON public.system_reference_lists USING btree (key);


--
-- Name: index_system_reference_values_on_reference_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_system_reference_values_on_reference_list_id ON public.system_reference_values USING btree (reference_list_id);


--
-- Name: index_system_regions_on_country_alpha2_and_region_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_regions_on_country_alpha2_and_region_code ON public.system_regions USING btree (country_alpha2, region_code);


--
-- Name: index_system_regions_on_iso_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_system_regions_on_iso_code ON public.system_regions USING btree (iso_code);


--
-- Name: index_user_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_roles_on_role_id ON public.user_roles USING btree (role_id);


--
-- Name: index_user_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_roles_on_user_id ON public.user_roles USING btree (user_id);


--
-- Name: index_user_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_roles_on_user_id_and_role_id ON public.user_roles USING btree (user_id, role_id);


--
-- Name: index_users_on_display_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_display_name ON public.users USING btree (display_name);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_locale; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_locale ON public.users USING btree (locale);


--
-- Name: index_users_on_public_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_public_id ON public.users USING btree (public_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: uq_email_addresses_one_preferred; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_email_addresses_one_preferred ON public.parties_email_addresses USING btree (party_id) WHERE preferred;


--
-- Name: uq_names_one_preferred; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_names_one_preferred ON public.parties_names USING btree (party_id) WHERE preferred;


--
-- Name: uq_phones_one_preferred; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_phones_one_preferred ON public.parties_phones USING btree (party_id) WHERE preferred;


--
-- Name: uq_postal_addresses_one_preferred; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_postal_addresses_one_preferred ON public.parties_postal_addresses USING btree (party_id) WHERE preferred;


--
-- Name: uq_web_addresses_one_preferred; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_web_addresses_one_preferred ON public.parties_web_addresses USING btree (party_id) WHERE preferred;


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_index ON public.audits USING btree (user_id, user_type);


--
-- Name: parties_parties trg_parties_profile_number; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_parties_profile_number BEFORE INSERT ON public.parties_parties FOR EACH ROW EXECUTE FUNCTION public.set_party_profile_number();


--
-- Name: parties_parties fk_pref_name_same_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_parties
    ADD CONSTRAINT fk_pref_name_same_party FOREIGN KEY (preferred_party_name_id, id) REFERENCES public.parties_names(id, party_id) ON UPDATE RESTRICT ON DELETE SET NULL;


--
-- Name: parties_individuals fk_rails_03d4df860d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_individuals
    ADD CONSTRAINT fk_rails_03d4df860d FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: system_country_currencies fk_rails_09c0ac7dfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_country_currencies
    ADD CONSTRAINT fk_rails_09c0ac7dfb FOREIGN KEY (country_alpha2) REFERENCES public.system_countries(alpha2);


--
-- Name: parties_email_addresses fk_rails_14bb43975b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_email_addresses
    ADD CONSTRAINT fk_rails_14bb43975b FOREIGN KEY (party_id) REFERENCES public.parties_parties(id) NOT VALID;


--
-- Name: parties_names fk_rails_14d86ebea2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_names
    ADD CONSTRAINT fk_rails_14d86ebea2 FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: parties_individuals fk_rails_151353a1f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_individuals
    ADD CONSTRAINT fk_rails_151353a1f2 FOREIGN KEY (residence_country) REFERENCES public.system_countries(alpha2);


--
-- Name: parties_organizations fk_rails_1c6bd07b62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_organizations
    ADD CONSTRAINT fk_rails_1c6bd07b62 FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: branch_memberships fk_rails_28f4e56388; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_memberships
    ADD CONSTRAINT fk_rails_28f4e56388 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: parties_relationships fk_rails_3021ae14b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_relationships
    ADD CONSTRAINT fk_rails_3021ae14b8 FOREIGN KEY (target_party_id) REFERENCES public.parties_parties(id);


--
-- Name: user_roles fk_rails_318345354e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fk_rails_318345354e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_roles fk_rails_3369e0d5fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fk_rails_3369e0d5fc FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: branches fk_rails_37f38cb276; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT fk_rails_37f38cb276 FOREIGN KEY (country_alpha2) REFERENCES public.system_countries(alpha2);


--
-- Name: parties_postal_addresses fk_rails_3c05e6a1fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_postal_addresses
    ADD CONSTRAINT fk_rails_3c05e6a1fd FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: parties_organizations fk_rails_3e80b4ff10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_organizations
    ADD CONSTRAINT fk_rails_3e80b4ff10 FOREIGN KEY (system_naics_code_id) REFERENCES public.system_naics_codes(id);


--
-- Name: role_permissions fk_rails_439e640a3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT fk_rails_439e640a3f FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- Name: parties_web_addresses fk_rails_4fc80a6ab6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_web_addresses
    ADD CONSTRAINT fk_rails_4fc80a6ab6 FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: parties_identities fk_rails_583a3c9612; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_identities
    ADD CONSTRAINT fk_rails_583a3c9612 FOREIGN KEY (issuing_country) REFERENCES public.system_countries(alpha2);


--
-- Name: parties_postal_addresses fk_rails_5e1f514e56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_postal_addresses
    ADD CONSTRAINT fk_rails_5e1f514e56 FOREIGN KEY (country) REFERENCES public.system_countries(alpha2);


--
-- Name: role_permissions fk_rails_60126080bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT fk_rails_60126080bd FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: parties_phones fk_rails_6f268a5105; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_phones
    ADD CONSTRAINT fk_rails_6f268a5105 FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: system_country_currencies fk_rails_74d816ce42; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_country_currencies
    ADD CONSTRAINT fk_rails_74d816ce42 FOREIGN KEY (currency_code) REFERENCES public.system_currencies(code);


--
-- Name: parties_identities fk_rails_7975a8b155; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_identities
    ADD CONSTRAINT fk_rails_7975a8b155 FOREIGN KEY (system_region_id) REFERENCES public.system_regions(id);


--
-- Name: branch_memberships fk_rails_8ac7ac3012; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branch_memberships
    ADD CONSTRAINT fk_rails_8ac7ac3012 FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: parties_organizations fk_rails_91f8daba78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_organizations
    ADD CONSTRAINT fk_rails_91f8daba78 FOREIGN KEY (residence_country) REFERENCES public.system_countries(alpha2);


--
-- Name: parties_identities fk_rails_a1853841b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_identities
    ADD CONSTRAINT fk_rails_a1853841b3 FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: parties_relationships fk_rails_a2a13f0c6e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_relationships
    ADD CONSTRAINT fk_rails_a2a13f0c6e FOREIGN KEY (source_party_id) REFERENCES public.parties_parties(id);


--
-- Name: system_reference_values fk_rails_b10be554c9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_reference_values
    ADD CONSTRAINT fk_rails_b10be554c9 FOREIGN KEY (reference_list_id) REFERENCES public.system_reference_lists(id);


--
-- Name: parties_disclosures fk_rails_ca32e8951c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_disclosures
    ADD CONSTRAINT fk_rails_ca32e8951c FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: parties_secret_data fk_rails_e5c07d4a7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_secret_data
    ADD CONSTRAINT fk_rails_e5c07d4a7b FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: parties_postal_addresses fk_rails_e647acabc6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_postal_addresses
    ADD CONSTRAINT fk_rails_e647acabc6 FOREIGN KEY (system_region_id) REFERENCES public.system_regions(id);


--
-- Name: parties_tax_ids fk_rails_f12449a867; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_tax_ids
    ADD CONSTRAINT fk_rails_f12449a867 FOREIGN KEY (party_id) REFERENCES public.parties_parties(id);


--
-- Name: system_regions fk_rails_f66794c4c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_regions
    ADD CONSTRAINT fk_rails_f66794c4c4 FOREIGN KEY (country_alpha2) REFERENCES public.system_countries(alpha2);


--
-- Name: parties_tax_ids fk_rails_f8a3f7bb6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parties_tax_ids
    ADD CONSTRAINT fk_rails_f8a3f7bb6b FOREIGN KEY (country) REFERENCES public.system_countries(alpha2);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20251028024533'),
('20251028021305'),
('20251028014613'),
('20251028014550'),
('20251028012942'),
('20251027192346'),
('20251027143526'),
('20251027143525'),
('20251027143520'),
('20251027143519'),
('20251027143513'),
('20251027143505'),
('20251027143502'),
('20251027143501'),
('20251027143453'),
('20251027143452'),
('20251027143441'),
('20251027143434'),
('20251027143429'),
('20251027143428'),
('20251027143423'),
('20251027143416'),
('20251027143412'),
('20251027143411'),
('20251027143407'),
('20251027143406'),
('20251027143358'),
('20251025214122'),
('20251023020533'),
('20251022050135'),
('20251017022102');

