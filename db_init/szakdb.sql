--
-- PostgreSQL database dump
--

\restrict rgJutODtBz3kn3Q8bjzxOzRFunOjceodn9sHRdPtoLAuCiJ4GhLRbZLWk9IwpwD

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2026-05-12 09:47:20

SET statement_timeout = 0;
SET lock_timeout = 0;
--SET idle_in_transaction_session_timeout = 0;
--SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16472)
-- Name: colors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.colors (
    major smallint NOT NULL,
    id smallint CONSTRAINT "FilterColor_key_not_null" NOT NULL,
    color_codes text[] NOT NULL,
    name text NOT NULL,
    user_id integer NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    CONSTRAINT name_length_check CHECK ((char_length(name) <= 50))
);


--
-- TOC entry 5004 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE colors; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.colors IS 'Ez tartalmazza a szűrőkhöz kapcsolatos fő csoportos tábla részhez tartozó kategóriákat azok kredit értékét és színkódját tartalmazza.';


--
-- TOC entry 224 (class 1259 OID 16498)
-- Name: fac_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.colors ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.fac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 219 (class 1259 OID 16407)
-- Name: majors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.majors (
    id smallint NOT NULL,
    major_name text NOT NULL,
    syllabus_year smallint[],
    category text[],
    max_credit smallint[] NOT NULL,
    type text[] NOT NULL,
    accepted_percentage smallint DEFAULT 70,
    CONSTRAINT check_array_lengths CHECK ((cardinality(type) = cardinality(max_credit))),
    CONSTRAINT check_percentage_range CHECK (((accepted_percentage >= 0) AND (accepted_percentage <= 100))),
    CONSTRAINT major_name_min_length CHECK ((char_length(TRIM(BOTH FROM major_name)) >= 2))
);


--
-- TOC entry 223 (class 1259 OID 16497)
-- Name: majors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.majors ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.majors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 16448)
-- Name: subject_major; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subject_major (
    subject_code text NOT NULL,
    major_id smallint NOT NULL,
    recommended_semester smallint NOT NULL,
    syllabus_year smallint NOT NULL,
    category text NOT NULL,
    type text NOT NULL,
    id integer NOT NULL,
    CONSTRAINT check_semester_range CHECK (((recommended_semester >= 0) AND (recommended_semester <= 14)))
);


--
-- TOC entry 225 (class 1259 OID 16501)
-- Name: subject_major_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subject_major_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5005 (class 0 OID 0)
-- Dependencies: 225
-- Name: subject_major_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subject_major_id_seq OWNED BY public.subject_major.id;


--
-- TOC entry 220 (class 1259 OID 16440)
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subjects (
    code text CONSTRAINT "Subjects_code_not_null" NOT NULL,
    name text NOT NULL,
    credit smallint NOT NULL,
    CONSTRAINT check_credit_range CHECK (((credit >= 0) AND (credit <= 36))),
    CONSTRAINT check_name_not_empty CHECK ((char_length(TRIM(BOTH FROM name)) > 0))
);


--
-- TOC entry 228 (class 1259 OID 16575)
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    user_id integer NOT NULL,
    token text NOT NULL,
    type character varying(50) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    id bigint NOT NULL,
    CONSTRAINT valid_token_types CHECK ((length((type)::text) > 0))
);


--
-- TOC entry 231 (class 1259 OID 17210)
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5006 (class 0 OID 0)
-- Dependencies: 231
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- TOC entry 230 (class 1259 OID 17016)
-- Name: user_saves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_saves (
    id integer NOT NULL,
    user_id integer NOT NULL,
    slot_number smallint NOT NULL,
    save_name character varying(100) NOT NULL,
    save_data jsonb NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    major_id integer NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 17015)
-- Name: user_saves_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_saves_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5007 (class 0 OID 0)
-- Dependencies: 229
-- Name: user_saves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_saves_id_seq OWNED BY public.user_saves.id;


--
-- TOC entry 227 (class 1259 OID 16518)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    role text DEFAULT 'user'::text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT email_must_be_valid CHECK ((email ~~ '%@%'::text)),
    CONSTRAINT valid_roles CHECK ((role = ANY (ARRAY['user'::text, 'admin'::text])))
);


--
-- TOC entry 226 (class 1259 OID 16517)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5008 (class 0 OID 0)
-- Dependencies: 226
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4785 (class 2604 OID 16502)
-- Name: subject_major id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_major ALTER COLUMN id SET DEFAULT nextval('public.subject_major_id_seq'::regclass);


--
-- TOC entry 4792 (class 2604 OID 17211)
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- TOC entry 4793 (class 2604 OID 17019)
-- Name: user_saves id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_saves ALTER COLUMN id SET DEFAULT nextval('public.user_saves_id_seq'::regclass);


--
-- TOC entry 4787 (class 2604 OID 16521)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4989 (class 0 OID 16472)
-- Dependencies: 222
-- Data for Name: colors; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.colors OVERRIDING SYSTEM VALUE VALUES (2, 8, '{#22d016,#f52424,#0209cf,#d4f047,#d72bda}', 'Szépek', 1, true);
INSERT INTO public.colors OVERRIDING SYSTEM VALUE VALUES (52, 16, '{#c70000,#1baada,#c4e425,#eb1e1e}', 'asfas', 1, true);
INSERT INTO public.colors OVERRIDING SYSTEM VALUE VALUES (54, 17, '{#1dd33b,#d08c16,#2c90ce,#ece651}', 'Nagyon szép', 1, true);


--
-- TOC entry 4986 (class 0 OID 16407)
-- Dependencies: 219
-- Data for Name: majors; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.majors OVERRIDING SYSTEM VALUE VALUES (2, 'Mérnökinformatikus', '{2010,2015,2017,2020,2023,2025}', '{Kötelező,"Kötelezően választható","Szabadon válaszott"}', '{20,15,15,15,15}', '{"Természettudományi ismeretek","Gazdasági és humán ismeretek","Számítógép ismeretek","Információs rendszerek ismeretek","Számítástechnikai és programozási ismeretek"}', 70);
INSERT INTO public.majors OVERRIDING SYSTEM VALUE VALUES (54, 'GazdInfo', '{2025}', '{Kötelező,Választható,"Szabadon választható",Testnevelés,"Idegen nyelv"}', '{20,15,15,15}', '{"Természettudományi ismeretek","Gazdasági és humán ismeretek","Számítástechnikai és programozási ismeretek","Információs rendszerek ismeretek"}', 70);
INSERT INTO public.majors OVERRIDING SYSTEM VALUE VALUES (52, 'asf', '{2025}', '{K,V,S,T,I}', '{0,0,0,0}', '{"Természettudományi ismeretek","Gazdasági és humán ismeretek","Számítástechnikai és programozási ismeretek","Információs rendszerek ismeretek"}', 70);
INSERT INTO public.majors OVERRIDING SYSTEM VALUE VALUES (53, 'lele', '{2025}', '{K,V,S,T,I}', '{0,0,0,0}', '{"Természettudományi ismeretek","Gazdasági és humán ismeretek","Számítástechnikai és programozási ismeretek","Információs rendszerek ismeretek"}', 80);
INSERT INTO public.majors OVERRIDING SYSTEM VALUE VALUES (1, 'Gazdaságinformatikus', '{2010,2015,2017,2020,2023,2025}', '{Kötelező,"Kötelezően választható","Szabadon válaszott"}', '{20,15,15,15}', '{"Természettudományi ismeretek","Gazdasági és humán ismeretek","Információs rendszerek ismeretek","Számítástechnikai és programozási ismeretek"}', 70);


--
-- TOC entry 4988 (class 0 OID 16448)
-- Dependencies: 221
-- Data for Name: subject_major; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.subject_major VALUES ('GKNB_MSTM065', 2, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1053);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM077', 2, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1054);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM064', 2, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1055);
INSERT INTO public.subject_major VALUES ('GKNB_INTM112', 2, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1056);
INSERT INTO public.subject_major VALUES ('GKNB_INTM110', 2, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1057);
INSERT INTO public.subject_major VALUES ('GKNB_INTM111', 2, 1, 2023, 'K', 'Természettudományi ismeretek', 1058);
INSERT INTO public.subject_major VALUES ('GKNB_INTM116', 2, 2, 2023, 'K', 'Gazdasági és humán ismeretek', 1059);
INSERT INTO public.subject_major VALUES ('GKNB_INTM118', 2, 2, 2023, 'K', 'Természettudományi ismeretek', 1060);
INSERT INTO public.subject_major VALUES ('NGB_MA001_2', 1, 2, 2010, 'K', 'Természettudományi ismeretek', 358);
INSERT INTO public.subject_major VALUES ('NGB_MA001_2', 2, 2, 2010, 'K', 'Természettudományi ismeretek', 743);
INSERT INTO public.subject_major VALUES ('GKNB_INTM117', 2, 2, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1061);
INSERT INTO public.subject_major VALUES ('GKNB_INTM114', 2, 2, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1062);
INSERT INTO public.subject_major VALUES ('GKNB_INTM115', 2, 2, 2023, 'K', 'Természettudományi ismeretek', 1063);
INSERT INTO public.subject_major VALUES ('GKNB_INTM120', 2, 3, 2023, 'K', 'Természettudományi ismeretek', 1064);
INSERT INTO public.subject_major VALUES ('GKNB_INTM121', 2, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1065);
INSERT INTO public.subject_major VALUES ('GKNB_INTM122', 2, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1066);
INSERT INTO public.subject_major VALUES ('GKNB_INTM119', 2, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1067);
INSERT INTO public.subject_major VALUES ('GKNB_INTM123', 2, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1068);
INSERT INTO public.subject_major VALUES ('GKNB_INTM125', 2, 4, 2023, 'K', 'Természettudományi ismeretek', 1069);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM087', 2, 4, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1070);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM045', 2, 4, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1071);
INSERT INTO public.subject_major VALUES ('GKNB_INTM124', 2, 4, 2023, 'K', 'Természettudományi ismeretek', 1072);
INSERT INTO public.subject_major VALUES ('GKNB_INTM126', 2, 5, 2023, 'K', 'Információs rendszerek ismeretek', 1073);
INSERT INTO public.subject_major VALUES ('GKNB_INTM128', 2, 5, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1074);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM054', 2, 5, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1075);
INSERT INTO public.subject_major VALUES ('GKNB_INTM129', 2, 6, 2023, 'K', 'Természettudományi ismeretek', 1076);
INSERT INTO public.subject_major VALUES ('GKNB_TATM038', 2, 6, 2023, 'K', 'Információs rendszerek ismeretek', 1077);
INSERT INTO public.subject_major VALUES ('GKNB_INTM160', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1078);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM055', 2, 0, 2023, 'V', 'Információs rendszerek ismeretek', 1079);
INSERT INTO public.subject_major VALUES ('GKNB_INTM138', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1080);
INSERT INTO public.subject_major VALUES ('MENB_BÉTM120', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1081);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM054', 2, 0, 2023, 'V', 'Információs rendszerek ismeretek', 1082);
INSERT INTO public.subject_major VALUES ('GKNB_INTM133', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1083);
INSERT INTO public.subject_major VALUES ('DKNB_APTM053', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1084);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM060', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1085);
INSERT INTO public.subject_major VALUES ('GKNB_INTM151', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1086);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM001', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 964);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM078', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 965);
INSERT INTO public.subject_major VALUES ('GKNB_KVTM029', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 966);
INSERT INTO public.subject_major VALUES ('GKNB_INTM157', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1087);
INSERT INTO public.subject_major VALUES ('GKNB_INTM135', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1088);
INSERT INTO public.subject_major VALUES ('GKNB_INTM052', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 967);
INSERT INTO public.subject_major VALUES ('AJNB_TVTM002', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 968);
INSERT INTO public.subject_major VALUES ('GKNB_INTM145', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1089);
INSERT INTO public.subject_major VALUES ('GKNB_INTM154', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1090);
INSERT INTO public.subject_major VALUES ('GKNB_INTM090', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 970);
INSERT INTO public.subject_major VALUES ('GKNB_INTM161', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1091);
INSERT INTO public.subject_major VALUES ('GKNB_INTM162', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1092);
INSERT INTO public.subject_major VALUES ('GKNB_INTM134', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1093);
INSERT INTO public.subject_major VALUES ('GKNB_INTM155', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1094);
INSERT INTO public.subject_major VALUES ('GKNB_INTM164', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1095);
INSERT INTO public.subject_major VALUES ('NGB_IT023_1', 1, 1, 2010, 'S', 'Gazdasági és humán ismeretek', 401);
INSERT INTO public.subject_major VALUES ('NGB_IT023_2', 1, 1, 2010, 'S', 'Gazdasági és humán ismeretek', 402);
INSERT INTO public.subject_major VALUES ('GKNB_INTM035', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 981);
INSERT INTO public.subject_major VALUES ('NGB_IT023_1', 2, 1, 2010, 'S', 'Gazdasági és humán ismeretek', 786);
INSERT INTO public.subject_major VALUES ('NGB_IT023_2', 2, 1, 2010, 'S', 'Gazdasági és humán ismeretek', 787);
INSERT INTO public.subject_major VALUES ('GKNB_INTM047', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 982);
INSERT INTO public.subject_major VALUES ('GKNB_INTM048', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 983);
INSERT INTO public.subject_major VALUES ('NGB_MT001_2', 1, 1, 2010, 'S', 'Gazdasági és humán ismeretek', 408);
INSERT INTO public.subject_major VALUES ('GKNB_INTM036', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 984);
INSERT INTO public.subject_major VALUES ('GKNB_INTM149', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1096);
INSERT INTO public.subject_major VALUES ('GKNB_INTM139', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1097);
INSERT INTO public.subject_major VALUES ('NGB_MT001_2', 2, 1, 2010, 'S', 'Gazdasági és humán ismeretek', 793);
INSERT INTO public.subject_major VALUES ('GKNB_INTM132', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1098);
INSERT INTO public.subject_major VALUES ('GKNB_INTM131', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1099);
INSERT INTO public.subject_major VALUES ('GKNB_INTM130', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1100);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM029', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 988);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM028', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 989);
INSERT INTO public.subject_major VALUES ('GKNB_INTM147', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1101);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM030', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 991);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM007', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 992);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM061', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1102);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM031', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 993);
INSERT INTO public.subject_major VALUES ('GKNB_INTM152', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1103);
INSERT INTO public.subject_major VALUES ('GKNB_INTM137', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1104);
INSERT INTO public.subject_major VALUES ('GKNB_INTM148', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1105);
INSERT INTO public.subject_major VALUES ('GKNB_INTM150', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1106);
INSERT INTO public.subject_major VALUES ('GKNB_INTM153', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1107);
INSERT INTO public.subject_major VALUES ('GKNB_INTM159', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1108);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM014', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 995);
INSERT INTO public.subject_major VALUES ('GKNB_INTM136', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1109);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM080', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 997);
INSERT INTO public.subject_major VALUES ('NGB_IN021_1', 1, 5, 2010, 'V', 'Számítástechnikai és programozási ismeretek', 434);
INSERT INTO public.subject_major VALUES ('NGB_IN028_1', 1, 5, 2010, 'V', 'Számítástechnikai és programozási ismeretek', 435);
INSERT INTO public.subject_major VALUES ('GKNB_INTM142', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1110);
INSERT INTO public.subject_major VALUES ('NGB_IN021_1', 2, 5, 2010, 'V', 'Számítástechnikai és programozási ismeretek', 819);
INSERT INTO public.subject_major VALUES ('NGB_IN028_1', 2, 5, 2010, 'V', 'Számítástechnikai és programozási ismeretek', 820);
INSERT INTO public.subject_major VALUES ('GKNB_INTM041', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 998);
INSERT INTO public.subject_major VALUES ('GKNB_INTM141', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1111);
INSERT INTO public.subject_major VALUES ('GKNB_INTM140', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1112);
INSERT INTO public.subject_major VALUES ('GKNB_INTM156', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1113);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM032', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1001);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM077', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1002);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM033', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1004);
INSERT INTO public.subject_major VALUES ('GKNB_INTM088', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1005);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM007', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1006);
INSERT INTO public.subject_major VALUES ('GKNB_INTM144', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1114);
INSERT INTO public.subject_major VALUES ('GKNB_INTM089', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1008);
INSERT INTO public.subject_major VALUES ('GKNB_INTM143', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1115);
INSERT INTO public.subject_major VALUES ('GKNB_INTM113', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1009);
INSERT INTO public.subject_major VALUES ('GKNB_INTM049', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1010);
INSERT INTO public.subject_major VALUES ('GKNB_INTM050', 2, 0, 2023, 'V', 'Természettudományi ismeretek', 1011);
INSERT INTO public.subject_major VALUES ('GKNB_INTM051', 2, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 1012);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM100', 2, 0, 2023, 'S', 'Természettudományi ismeretek', 942);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM024', 2, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 943);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM034', 2, 0, 2023, 'S', 'Információs rendszerek ismeretek', 944);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM041', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 945);
INSERT INTO public.subject_major VALUES ('AKNB_TTTM202', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 946);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM033', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 947);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM248', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 949);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM026', 2, 0, 2023, 'S', 'Természettudományi ismeretek', 950);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM017', 2, 0, 2023, 'S', 'Természettudományi ismeretek', 951);
INSERT INTO public.subject_major VALUES ('NGB_IN032_1', 1, 5, 2010, 'V', 'Számítástechnikai és programozási ismeretek', 467);
INSERT INTO public.subject_major VALUES ('NGB_IN032_2', 1, 5, 2010, 'V', 'Számítástechnikai és programozási ismeretek', 468);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM024', 2, 0, 2023, 'S', 'Információs rendszerek ismeretek', 952);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM197', 2, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 953);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM085', 2, 0, 2023, 'S', 'Információs rendszerek ismeretek', 954);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM025', 2, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 955);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM026', 2, 0, 2023, 'S', 'Információs rendszerek ismeretek', 956);
INSERT INTO public.subject_major VALUES ('EKNB_KETM032', 2, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 957);
INSERT INTO public.subject_major VALUES ('NGB_AU091_1', 1, 5, 2010, 'D', 'Gazdasági és humán ismeretek', 475);
INSERT INTO public.subject_major VALUES ('NGB_IN091_1', 1, 5, 2010, 'D', 'Információs rendszerek ismeretek', 476);
INSERT INTO public.subject_major VALUES ('NGB_TA091_1', 1, 5, 2010, 'D', 'Gazdasági és humán ismeretek', 477);
INSERT INTO public.subject_major VALUES ('NGB_FI091_1', 1, 5, 2010, 'D', 'Számítástechnikai és programozási ismeretek', 478);
INSERT INTO public.subject_major VALUES ('NGB_MA091_1', 1, 5, 2010, 'D', 'Információs rendszerek ismeretek', 479);
INSERT INTO public.subject_major VALUES ('NGB_IN032_1', 2, 5, 2010, 'V', 'Számítástechnikai és programozási ismeretek', 852);
INSERT INTO public.subject_major VALUES ('NGB_MA091_2', 1, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 481);
INSERT INTO public.subject_major VALUES ('NGB_TA091_2', 1, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 482);
INSERT INTO public.subject_major VALUES ('NGB_AU091_2', 1, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 483);
INSERT INTO public.subject_major VALUES ('NGB_FI091_2', 1, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 484);
INSERT INTO public.subject_major VALUES ('NGB_IN091_2', 1, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 485);
INSERT INTO public.subject_major VALUES ('NGB_IN032_2', 2, 5, 2010, 'V', 'Számítástechnikai és programozási ismeretek', 853);
INSERT INTO public.subject_major VALUES ('AKNB_BHTM164', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 958);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM186', 2, 0, 2023, 'S', 'Információs rendszerek ismeretek', 960);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM002', 2, 0, 2023, 'T', 'Számítástechnikai és programozási ismeretek', 1017);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM004', 2, 0, 2023, 'T', 'Gazdasági és humán ismeretek', 1018);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM003', 2, 0, 2023, 'T', 'Gazdasági és humán ismeretek', 1019);
INSERT INTO public.subject_major VALUES ('NGB_AU091_1', 2, 5, 2010, 'D', 'Gazdasági és humán ismeretek', 860);
INSERT INTO public.subject_major VALUES ('NGB_IN091_1', 2, 5, 2010, 'D', 'Információs rendszerek ismeretek', 861);
INSERT INTO public.subject_major VALUES ('NGB_TA091_1', 2, 5, 2010, 'D', 'Gazdasági és humán ismeretek', 862);
INSERT INTO public.subject_major VALUES ('NGB_FI091_1', 2, 5, 2010, 'D', 'Számítástechnikai és programozási ismeretek', 863);
INSERT INTO public.subject_major VALUES ('N_TS03', 1, 1, 2010, 'T', 'Gazdasági és humán ismeretek', 497);
INSERT INTO public.subject_major VALUES ('N_TS02', 1, 1, 2010, 'T', 'Gazdasági és humán ismeretek', 498);
INSERT INTO public.subject_major VALUES ('N_TS04', 1, 1, 2010, 'T', 'Gazdasági és humán ismeretek', 499);
INSERT INTO public.subject_major VALUES ('NGB_MA091_1', 2, 5, 2010, 'D', 'Információs rendszerek ismeretek', 864);
INSERT INTO public.subject_major VALUES ('NGB_MA091_2', 2, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 866);
INSERT INTO public.subject_major VALUES ('N_TS01', 1, 1, 2010, 'T', 'Gazdasági és humán ismeretek', 504);
INSERT INTO public.subject_major VALUES ('NGB_SZ001_1', 1, 1, 2015, 'K', 'Gazdasági és humán ismeretek', 355);
INSERT INTO public.subject_major VALUES ('NGB_MA001_1', 1, 1, 2015, 'K', 'Gazdasági és humán ismeretek', 350);
INSERT INTO public.subject_major VALUES ('NGB_IN014_1', 1, 1, 2015, 'K', 'Gazdasági és humán ismeretek', 505);
INSERT INTO public.subject_major VALUES ('NGB_AK001_1', 1, 1, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 351);
INSERT INTO public.subject_major VALUES ('NGB_IN001_1', 1, 1, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 352);
INSERT INTO public.subject_major VALUES ('NGB_IN004_1', 1, 1, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 361);
INSERT INTO public.subject_major VALUES ('NGB_TA001_1', 1, 1, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 353);
INSERT INTO public.subject_major VALUES ('NGB_FI001_1', 1, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 356);
INSERT INTO public.subject_major VALUES ('NGB_JE001_1', 1, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 357);
INSERT INTO public.subject_major VALUES ('NGB_MA002_2', 1, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 506);
INSERT INTO public.subject_major VALUES ('NGB_IN001_2', 1, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 359);
INSERT INTO public.subject_major VALUES ('NGB_IN002_1', 1, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 360);
INSERT INTO public.subject_major VALUES ('NGB_IN006_1', 1, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 371);
INSERT INTO public.subject_major VALUES ('NGB_SV001_1', 1, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 369);
INSERT INTO public.subject_major VALUES ('NGB_IN002_2', 1, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 363);
INSERT INTO public.subject_major VALUES ('NGB_IN001_3', 1, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 364);
INSERT INTO public.subject_major VALUES ('NGB_IN005_1', 1, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 362);
INSERT INTO public.subject_major VALUES ('NGB_MA007_1', 1, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 367);
INSERT INTO public.subject_major VALUES ('NGB_AU001_1', 1, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 354);
INSERT INTO public.subject_major VALUES ('NGB_IN008_1', 1, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 366);
INSERT INTO public.subject_major VALUES ('NGB_IN085_1', 1, 4, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 448);
INSERT INTO public.subject_major VALUES ('NGB_IN003_1', 1, 4, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 372);
INSERT INTO public.subject_major VALUES ('NGB_MA001_3', 1, 4, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 368);
INSERT INTO public.subject_major VALUES ('NGB_IN010_1', 1, 4, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 370);
INSERT INTO public.subject_major VALUES ('NGB_KJ001_1', 1, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 378);
INSERT INTO public.subject_major VALUES ('NGB_IN011_1', 1, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 376);
INSERT INTO public.subject_major VALUES ('NGB_TA002_1', 1, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 365);
INSERT INTO public.subject_major VALUES ('NGB_MA006_1', 1, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 375);
INSERT INTO public.subject_major VALUES ('NGB_IN015_1', 1, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 507);
INSERT INTO public.subject_major VALUES ('NGB_SZ005_1', 1, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 381);
INSERT INTO public.subject_major VALUES ('NGB_IN007_1', 1, 6, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 374);
INSERT INTO public.subject_major VALUES ('NGB_IN092_1', 1, 6, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 480);
INSERT INTO public.subject_major VALUES ('NGB_SV002_1', 1, 6, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 380);
INSERT INTO public.subject_major VALUES ('NGB_IN092_2', 1, 7, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 486);
INSERT INTO public.subject_major VALUES ('NGB_IN013_1', 1, 7, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 382);
INSERT INTO public.subject_major VALUES ('NGB_IN084_1', 1, 5, 2015, 'V', 'Természettudományi ismeretek', 430);
INSERT INTO public.subject_major VALUES ('NGB_SZ011_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 431);
INSERT INTO public.subject_major VALUES ('NGB_IN080_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 389);
INSERT INTO public.subject_major VALUES ('NGB_IN022_1', 1, 5, 2015, 'V', 'Természettudományi ismeretek', 432);
INSERT INTO public.subject_major VALUES ('NGB_IN027_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 433);
INSERT INTO public.subject_major VALUES ('NGB_IN047_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 436);
INSERT INTO public.subject_major VALUES ('NGB_IN037_1', 1, 5, 2015, 'V', 'Természettudományi ismeretek', 437);
INSERT INTO public.subject_major VALUES ('NGB_IN026_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 438);
INSERT INTO public.subject_major VALUES ('NGB_IN044_1', 1, 5, 2015, 'V', 'Természettudományi ismeretek', 439);
INSERT INTO public.subject_major VALUES ('NGB_IN083_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 440);
INSERT INTO public.subject_major VALUES ('NGB_IN046_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 441);
INSERT INTO public.subject_major VALUES ('NGB_IN087_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 442);
INSERT INTO public.subject_major VALUES ('NGB_IN045_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 443);
INSERT INTO public.subject_major VALUES ('NGB_MA014_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 444);
INSERT INTO public.subject_major VALUES ('NGB_MA020_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 445);
INSERT INTO public.subject_major VALUES ('NGB_IN035_1', 1, 5, 2015, 'V', 'Természettudományi ismeretek', 446);
INSERT INTO public.subject_major VALUES ('NGB_IN082_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 447);
INSERT INTO public.subject_major VALUES ('NGB_AU017_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 449);
INSERT INTO public.subject_major VALUES ('NGB_IN025_1', 1, 5, 2015, 'V', 'Természettudományi ismeretek', 450);
INSERT INTO public.subject_major VALUES ('NGB_IN030_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 451);
INSERT INTO public.subject_major VALUES ('NGB_IN038_1', 1, 5, 2015, 'V', 'Információs rendszerek ismeretek', 452);
INSERT INTO public.subject_major VALUES ('NGB_IN034_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 453);
INSERT INTO public.subject_major VALUES ('NGB_IN036_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 454);
INSERT INTO public.subject_major VALUES ('NGB_SZ012_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 455);
INSERT INTO public.subject_major VALUES ('NGB_SZ014_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 456);
INSERT INTO public.subject_major VALUES ('NGB_IN033_1', 1, 5, 2015, 'V', 'Természettudományi ismeretek', 457);
INSERT INTO public.subject_major VALUES ('NGB_SZ007_1', 1, 5, 2015, 'V', 'Természettudományi ismeretek', 458);
INSERT INTO public.subject_major VALUES ('NGB_SZ007_2', 1, 5, 2015, 'V', 'Információs rendszerek ismeretek', 459);
INSERT INTO public.subject_major VALUES ('NGB_AU018_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 460);
INSERT INTO public.subject_major VALUES ('NGB_IN012_1', 1, 5, 2015, 'V', 'Információs rendszerek ismeretek', 379);
INSERT INTO public.subject_major VALUES ('NGB_SZ013_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 461);
INSERT INTO public.subject_major VALUES ('NGB_IN009_1', 1, 5, 2015, 'V', 'Információs rendszerek ismeretek', 373);
INSERT INTO public.subject_major VALUES ('NGB_IN086_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 462);
INSERT INTO public.subject_major VALUES ('NGB_IN040_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 463);
INSERT INTO public.subject_major VALUES ('NGB_SZ017_1', 1, 5, 2015, 'V', 'Információs rendszerek ismeretek', 508);
INSERT INTO public.subject_major VALUES ('NGB_IN031_1', 1, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 464);
INSERT INTO public.subject_major VALUES ('NGB_IN024_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 465);
INSERT INTO public.subject_major VALUES ('NGB_IN088_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 509);
INSERT INTO public.subject_major VALUES ('NGB_IN039_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 466);
INSERT INTO public.subject_major VALUES ('NGB_IN029_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 469);
INSERT INTO public.subject_major VALUES ('NGB_IN029_2', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 470);
INSERT INTO public.subject_major VALUES ('NGB_SZ009_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 471);
INSERT INTO public.subject_major VALUES ('NGB_SZ009_2', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 472);
INSERT INTO public.subject_major VALUES ('NGB_IN010_2', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 377);
INSERT INTO public.subject_major VALUES ('NGB_IN023_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 473);
INSERT INTO public.subject_major VALUES ('NGB_IN023_2', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 474);
INSERT INTO public.subject_major VALUES ('NGB_IN016_1', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 510);
INSERT INTO public.subject_major VALUES ('NGB_IN016_2', 1, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 511);
INSERT INTO public.subject_major VALUES ('NGB_TT006_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 383);
INSERT INTO public.subject_major VALUES ('NGB_SZ016_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 384);
INSERT INTO public.subject_major VALUES ('NGB_IT003_2', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 385);
INSERT INTO public.subject_major VALUES ('NGB_IT003_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 386);
INSERT INTO public.subject_major VALUES ('NGB_KV037_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 387);
INSERT INTO public.subject_major VALUES ('NGB_TT007_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 388);
INSERT INTO public.subject_major VALUES ('NGB_MT003_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 390);
INSERT INTO public.subject_major VALUES ('NGB_AK004_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 391);
INSERT INTO public.subject_major VALUES ('NGB_FI005_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 392);
INSERT INTO public.subject_major VALUES ('NGB_ET005_3', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 393);
INSERT INTO public.subject_major VALUES ('NGB_TT001_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 394);
INSERT INTO public.subject_major VALUES ('NGB_TT001_2', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 395);
INSERT INTO public.subject_major VALUES ('NGB_IN043_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 396);
INSERT INTO public.subject_major VALUES ('NGB_TA011_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 397);
INSERT INTO public.subject_major VALUES ('NGB_IN042_1', 1, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 398);
INSERT INTO public.subject_major VALUES ('NGB_SV003_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 399);
INSERT INTO public.subject_major VALUES ('NGB_MT026_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 400);
INSERT INTO public.subject_major VALUES ('NGB_SV004_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 403);
INSERT INTO public.subject_major VALUES ('NGB_AG019_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 404);
INSERT INTO public.subject_major VALUES ('NGB_SM075_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 405);
INSERT INTO public.subject_major VALUES ('NGB_SE015_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 406);
INSERT INTO public.subject_major VALUES ('NGB_AG012_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 407);
INSERT INTO public.subject_major VALUES ('NGB_MT001_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 409);
INSERT INTO public.subject_major VALUES ('NGB_MA008_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 410);
INSERT INTO public.subject_major VALUES ('NGB_TT003_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 411);
INSERT INTO public.subject_major VALUES ('NGB_IN041_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 412);
INSERT INTO public.subject_major VALUES ('NGB_MT002_2', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 413);
INSERT INTO public.subject_major VALUES ('NGB_MT002_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 414);
INSERT INTO public.subject_major VALUES ('NGB_SZ015_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 415);
INSERT INTO public.subject_major VALUES ('NGB_MT006_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 416);
INSERT INTO public.subject_major VALUES ('NGB_AU016_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 417);
INSERT INTO public.subject_major VALUES ('NGB_AU016_2', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 418);
INSERT INTO public.subject_major VALUES ('NGB_TT005_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 419);
INSERT INTO public.subject_major VALUES ('NGB_SM001_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 420);
INSERT INTO public.subject_major VALUES ('NGB_SM001_2', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 421);
INSERT INTO public.subject_major VALUES ('NGB_MT005_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 422);
INSERT INTO public.subject_major VALUES ('NGB_SV050_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 423);
INSERT INTO public.subject_major VALUES ('NGB_FI012_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 424);
INSERT INTO public.subject_major VALUES ('NGB_FI012_2', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 425);
INSERT INTO public.subject_major VALUES ('NGB_AG008_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 426);
INSERT INTO public.subject_major VALUES ('NGB_SM044_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 427);
INSERT INTO public.subject_major VALUES ('NGB_KO042_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 428);
INSERT INTO public.subject_major VALUES ('NGB_KA001_1', 1, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 429);
INSERT INTO public.subject_major VALUES ('NGB_TS001_2', 1, 1, 2015, 'T', 'Számítástechnikai és programozási ismeretek', 500);
INSERT INTO public.subject_major VALUES ('NGB_TS001_4', 1, 1, 2015, 'T', 'Számítástechnikai és programozási ismeretek', 501);
INSERT INTO public.subject_major VALUES ('NGB_TS001_3', 1, 1, 2015, 'T', 'Számítástechnikai és programozási ismeretek', 502);
INSERT INTO public.subject_major VALUES ('NGB_TS001_1', 1, 1, 2015, 'T', 'Számítástechnikai és programozási ismeretek', 503);
INSERT INTO public.subject_major VALUES ('NGB_IT024_1', 1, 2, 2015, 'I', 'Természettudományi ismeretek', 487);
INSERT INTO public.subject_major VALUES ('NGB_IT024_2', 1, 2, 2015, 'I', 'Gazdasági és humán ismeretek', 488);
INSERT INTO public.subject_major VALUES ('NGB_IT039_1', 1, 2, 2015, 'I', 'Számítástechnikai és programozási ismeretek', 489);
INSERT INTO public.subject_major VALUES ('NGB_IT039_2', 1, 2, 2015, 'I', 'Természettudományi ismeretek', 490);
INSERT INTO public.subject_major VALUES ('NGB_IT039_3', 1, 2, 2015, 'I', 'Számítástechnikai és programozási ismeretek', 491);
INSERT INTO public.subject_major VALUES ('NGB_IT039_4', 1, 2, 2015, 'I', 'Számítástechnikai és programozási ismeretek', 492);
INSERT INTO public.subject_major VALUES ('NGB_IT001_2', 1, 2, 2015, 'I', 'Természettudományi ismeretek', 493);
INSERT INTO public.subject_major VALUES ('NGB_IT001_1', 1, 2, 2015, 'I', 'Gazdasági és humán ismeretek', 494);
INSERT INTO public.subject_major VALUES ('NGB_IT034_1', 1, 2, 2015, 'I', 'Természettudományi ismeretek', 495);
INSERT INTO public.subject_major VALUES ('NGB_IT034_2', 1, 2, 2015, 'I', 'Számítástechnikai és programozási ismeretek', 496);
INSERT INTO public.subject_major VALUES ('NGB_TA091_2', 2, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 867);
INSERT INTO public.subject_major VALUES ('NGB_AU091_2', 2, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 868);
INSERT INTO public.subject_major VALUES ('NGB_FI091_2', 2, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 869);
INSERT INTO public.subject_major VALUES ('NGB_IN091_2', 2, 7, 2010, 'D', 'Gazdasági és humán ismeretek', 870);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM001', 2, 0, 2023, 'T', 'Gazdasági és humán ismeretek', 1020);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM012', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1039);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM013', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1040);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM017', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1041);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM031', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1042);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM016', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1043);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM030', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1044);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM015', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1045);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM027', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1046);
INSERT INTO public.subject_major VALUES ('GKNB_INTM024', 1, 3, 2017, 'K', 'Számítástechnikai és programozási ismeretek', 525);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM014', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1047);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM026', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1048);
INSERT INTO public.subject_major VALUES ('N_TS03', 2, 1, 2010, 'T', 'Gazdasági és humán ismeretek', 882);
INSERT INTO public.subject_major VALUES ('GKNB_INTM003', 1, 4, 2017, 'K', 'Információs rendszerek ismeretek', 529);
INSERT INTO public.subject_major VALUES ('N_TS02', 2, 1, 2010, 'T', 'Gazdasági és humán ismeretek', 883);
INSERT INTO public.subject_major VALUES ('N_TS04', 2, 1, 2010, 'T', 'Gazdasági és humán ismeretek', 884);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM019', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1049);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM029', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1050);
INSERT INTO public.subject_major VALUES ('N_TS01', 2, 1, 2010, 'T', 'Gazdasági és humán ismeretek', 889);
INSERT INTO public.subject_major VALUES ('NGB_SZ001_1', 2, 1, 2015, 'K', 'Gazdasági és humán ismeretek', 740);
INSERT INTO public.subject_major VALUES ('NGB_MA001_1', 2, 1, 2015, 'K', 'Gazdasági és humán ismeretek', 735);
INSERT INTO public.subject_major VALUES ('NGB_IN014_1', 2, 1, 2015, 'K', 'Gazdasági és humán ismeretek', 890);
INSERT INTO public.subject_major VALUES ('NGB_AK001_1', 2, 1, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 736);
INSERT INTO public.subject_major VALUES ('NGB_IN001_1', 2, 1, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 737);
INSERT INTO public.subject_major VALUES ('NGB_IN004_1', 2, 1, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 746);
INSERT INTO public.subject_major VALUES ('MKNB_DSTM006', 1, 0, 2017, 'S', 'Gazdasági és humán ismeretek', 543);
INSERT INTO public.subject_major VALUES ('NGB_TA001_1', 2, 1, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 738);
INSERT INTO public.subject_major VALUES ('NGB_FI001_1', 2, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 741);
INSERT INTO public.subject_major VALUES ('NGB_JE001_1', 2, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 742);
INSERT INTO public.subject_major VALUES ('NGB_MA002_2', 2, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 891);
INSERT INTO public.subject_major VALUES ('NGB_IN001_2', 2, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 744);
INSERT INTO public.subject_major VALUES ('NGB_IN002_1', 2, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 745);
INSERT INTO public.subject_major VALUES ('NGB_IN006_1', 2, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 756);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM045', 1, 0, 2017, 'S', 'Gazdasági és humán ismeretek', 551);
INSERT INTO public.subject_major VALUES ('NGB_SV001_1', 2, 2, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 754);
INSERT INTO public.subject_major VALUES ('NGB_IN002_2', 2, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 748);
INSERT INTO public.subject_major VALUES ('NGB_IN001_3', 2, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 749);
INSERT INTO public.subject_major VALUES ('NGB_IN005_1', 2, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 747);
INSERT INTO public.subject_major VALUES ('NGB_MA007_1', 2, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 752);
INSERT INTO public.subject_major VALUES ('NGB_AU001_1', 2, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 739);
INSERT INTO public.subject_major VALUES ('NGB_IN008_1', 2, 3, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 751);
INSERT INTO public.subject_major VALUES ('NGB_IN085_1', 2, 4, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 833);
INSERT INTO public.subject_major VALUES ('NGB_IN003_1', 2, 4, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 757);
INSERT INTO public.subject_major VALUES ('NGB_MA001_3', 2, 4, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 753);
INSERT INTO public.subject_major VALUES ('NGB_IN010_1', 2, 4, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 755);
INSERT INTO public.subject_major VALUES ('MKNB_DSTM003', 1, 0, 2017, 'S', 'Gazdasági és humán ismeretek', 563);
INSERT INTO public.subject_major VALUES ('NGB_KJ001_1', 2, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 763);
INSERT INTO public.subject_major VALUES ('NGB_IN011_1', 2, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 761);
INSERT INTO public.subject_major VALUES ('NGB_TA002_1', 2, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 750);
INSERT INTO public.subject_major VALUES ('NGB_MA006_1', 2, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 760);
INSERT INTO public.subject_major VALUES ('NGB_IN015_1', 2, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 892);
INSERT INTO public.subject_major VALUES ('NGB_SZ005_1', 2, 5, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 766);
INSERT INTO public.subject_major VALUES ('NGB_IN007_1', 2, 6, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 759);
INSERT INTO public.subject_major VALUES ('NGB_IN092_1', 2, 6, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 865);
INSERT INTO public.subject_major VALUES ('NGB_SV002_1', 2, 6, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 765);
INSERT INTO public.subject_major VALUES ('NGB_IN092_2', 2, 7, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 871);
INSERT INTO public.subject_major VALUES ('NGB_IN013_1', 2, 7, 2015, 'K', 'Számítástechnikai és programozási ismeretek', 767);
INSERT INTO public.subject_major VALUES ('NGB_IN084_1', 2, 5, 2015, 'V', 'Természettudományi ismeretek', 815);
INSERT INTO public.subject_major VALUES ('MKNB_DSTM004', 1, 0, 2017, 'S', 'Számítástechnikai és programozási ismeretek', 574);
INSERT INTO public.subject_major VALUES ('NGB_SZ011_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 816);
INSERT INTO public.subject_major VALUES ('NGB_IN080_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 774);
INSERT INTO public.subject_major VALUES ('GKNB_INTM010', 1, 0, 2017, 'V', 'Számítástechnikai és programozási ismeretek', 577);
INSERT INTO public.subject_major VALUES ('NGB_IN022_1', 2, 5, 2015, 'V', 'Természettudományi ismeretek', 817);
INSERT INTO public.subject_major VALUES ('NGB_IN027_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 818);
INSERT INTO public.subject_major VALUES ('NGB_IN047_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 821);
INSERT INTO public.subject_major VALUES ('NGB_IN037_1', 2, 5, 2015, 'V', 'Természettudományi ismeretek', 822);
INSERT INTO public.subject_major VALUES ('NGB_IN026_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 823);
INSERT INTO public.subject_major VALUES ('NGB_IN044_1', 2, 5, 2015, 'V', 'Természettudományi ismeretek', 824);
INSERT INTO public.subject_major VALUES ('NGB_IN083_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 825);
INSERT INTO public.subject_major VALUES ('NGB_IN046_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 826);
INSERT INTO public.subject_major VALUES ('NGB_IN087_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 827);
INSERT INTO public.subject_major VALUES ('NGB_IN045_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 828);
INSERT INTO public.subject_major VALUES ('GKNB_INTM027', 1, 0, 2017, 'V', 'Számítástechnikai és programozási ismeretek', 588);
INSERT INTO public.subject_major VALUES ('NGB_MA014_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 829);
INSERT INTO public.subject_major VALUES ('NGB_MA020_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 830);
INSERT INTO public.subject_major VALUES ('NGB_IN035_1', 2, 5, 2015, 'V', 'Természettudományi ismeretek', 831);
INSERT INTO public.subject_major VALUES ('NGB_IN082_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 832);
INSERT INTO public.subject_major VALUES ('NGB_AU017_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 834);
INSERT INTO public.subject_major VALUES ('GKNB_INTM031', 1, 0, 2017, 'V', 'Számítástechnikai és programozási ismeretek', 594);
INSERT INTO public.subject_major VALUES ('NGB_IN025_1', 2, 5, 2015, 'V', 'Természettudományi ismeretek', 835);
INSERT INTO public.subject_major VALUES ('NGB_IN030_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 836);
INSERT INTO public.subject_major VALUES ('NGB_IN038_1', 2, 5, 2015, 'V', 'Információs rendszerek ismeretek', 837);
INSERT INTO public.subject_major VALUES ('NGB_IN034_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 838);
INSERT INTO public.subject_major VALUES ('NGB_IN036_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 839);
INSERT INTO public.subject_major VALUES ('NGB_SZ012_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 840);
INSERT INTO public.subject_major VALUES ('NGB_SZ014_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 841);
INSERT INTO public.subject_major VALUES ('NGB_IN033_1', 2, 5, 2015, 'V', 'Természettudományi ismeretek', 842);
INSERT INTO public.subject_major VALUES ('NGB_SZ007_1', 2, 5, 2015, 'V', 'Természettudományi ismeretek', 843);
INSERT INTO public.subject_major VALUES ('NGB_SZ007_2', 2, 5, 2015, 'V', 'Információs rendszerek ismeretek', 844);
INSERT INTO public.subject_major VALUES ('NGB_AU018_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 845);
INSERT INTO public.subject_major VALUES ('NGB_IN012_1', 2, 5, 2015, 'V', 'Információs rendszerek ismeretek', 764);
INSERT INTO public.subject_major VALUES ('NGB_SZ013_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 846);
INSERT INTO public.subject_major VALUES ('NGB_IN009_1', 2, 5, 2015, 'V', 'Információs rendszerek ismeretek', 758);
INSERT INTO public.subject_major VALUES ('NGB_IN086_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 847);
INSERT INTO public.subject_major VALUES ('NGB_IN040_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 848);
INSERT INTO public.subject_major VALUES ('NGB_SZ017_1', 2, 5, 2015, 'V', 'Információs rendszerek ismeretek', 893);
INSERT INTO public.subject_major VALUES ('NGB_IN031_1', 2, 5, 2015, 'V', 'Számítástechnikai és programozási ismeretek', 849);
INSERT INTO public.subject_major VALUES ('NGB_IN024_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 850);
INSERT INTO public.subject_major VALUES ('NGB_IN088_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 894);
INSERT INTO public.subject_major VALUES ('NGB_IN039_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 851);
INSERT INTO public.subject_major VALUES ('NGB_IN029_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 854);
INSERT INTO public.subject_major VALUES ('NGB_IN029_2', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 855);
INSERT INTO public.subject_major VALUES ('NGB_SZ009_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 856);
INSERT INTO public.subject_major VALUES ('NGB_SZ009_2', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 857);
INSERT INTO public.subject_major VALUES ('NGB_IN010_2', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 762);
INSERT INTO public.subject_major VALUES ('NGB_IN023_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 858);
INSERT INTO public.subject_major VALUES ('NGB_IN023_2', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 859);
INSERT INTO public.subject_major VALUES ('NGB_IN016_1', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 895);
INSERT INTO public.subject_major VALUES ('NGB_IN016_2', 2, 5, 2015, 'V', 'Gazdasági és humán ismeretek', 896);
INSERT INTO public.subject_major VALUES ('NGB_TT006_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 768);
INSERT INTO public.subject_major VALUES ('NGB_SZ016_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 769);
INSERT INTO public.subject_major VALUES ('NGB_IT003_2', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 770);
INSERT INTO public.subject_major VALUES ('NGB_IT003_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 771);
INSERT INTO public.subject_major VALUES ('GKNB_INTM046', 1, 0, 2017, 'V', 'Gazdasági és humán ismeretek', 629);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM079', 1, 1, 2017, 'I', 'Számítástechnikai és programozási ismeretek', 630);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM080', 1, 2, 2017, 'I', 'Információs rendszerek ismeretek', 631);
INSERT INTO public.subject_major VALUES ('NGB_KV037_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 772);
INSERT INTO public.subject_major VALUES ('NGB_TT007_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 773);
INSERT INTO public.subject_major VALUES ('NGB_MT003_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 775);
INSERT INTO public.subject_major VALUES ('NGB_AK004_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 776);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM016', 1, 1, 2020, 'K', 'Gazdasági és humán ismeretek', 512);
INSERT INTO public.subject_major VALUES ('GKNB_INTM012', 1, 1, 2020, 'K', 'Gazdasági és humán ismeretek', 515);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM014', 1, 1, 2020, 'K', 'Gazdasági és humán ismeretek', 516);
INSERT INTO public.subject_major VALUES ('GKNB_INTM021', 1, 2, 2020, 'K', 'Gazdasági és humán ismeretek', 518);
INSERT INTO public.subject_major VALUES ('GKNB_INTM022', 1, 2, 2020, 'K', 'Gazdasági és humán ismeretek', 519);
INSERT INTO public.subject_major VALUES ('GKNB_INTM001', 1, 2, 2020, 'K', 'Gazdasági és humán ismeretek', 520);
INSERT INTO public.subject_major VALUES ('GKNB_INTM018', 1, 2, 2020, 'K', 'Gazdasági és humán ismeretek', 521);
INSERT INTO public.subject_major VALUES ('NGB_FI005_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 777);
INSERT INTO public.subject_major VALUES ('NGB_ET005_3', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 778);
INSERT INTO public.subject_major VALUES ('NGB_TT001_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 779);
INSERT INTO public.subject_major VALUES ('NGB_TT001_2', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 780);
INSERT INTO public.subject_major VALUES ('NGB_IN043_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 781);
INSERT INTO public.subject_major VALUES ('NGB_TA011_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 782);
INSERT INTO public.subject_major VALUES ('NGB_IN042_1', 2, 2, 2015, 'S', 'Gazdasági és humán ismeretek', 783);
INSERT INTO public.subject_major VALUES ('NGB_SV003_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 784);
INSERT INTO public.subject_major VALUES ('GKNB_INTM085', 1, 3, 2020, 'K', 'Gazdasági és humán ismeretek', 636);
INSERT INTO public.subject_major VALUES ('GKNB_INTM086', 1, 3, 2020, 'K', 'Gazdasági és humán ismeretek', 637);
INSERT INTO public.subject_major VALUES ('GKNB_INTM020', 1, 3, 2020, 'K', 'Gazdasági és humán ismeretek', 527);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM007', 1, 4, 2020, 'K', 'Gazdasági és humán ismeretek', 528);
INSERT INTO public.subject_major VALUES ('GKNB_INTM002', 1, 4, 2020, 'K', 'Gazdasági és humán ismeretek', 530);
INSERT INTO public.subject_major VALUES ('GKNB_INTM004', 1, 4, 2020, 'K', 'Gazdasági és humán ismeretek', 531);
INSERT INTO public.subject_major VALUES ('KGNB_GETM004', 1, 4, 2020, 'K', 'Gazdasági és humán ismeretek', 532);
INSERT INTO public.subject_major VALUES ('DKNB_KATM030', 1, 5, 2020, 'K', 'Gazdasági és humán ismeretek', 534);
INSERT INTO public.subject_major VALUES ('GKNB_INTM019', 1, 5, 2020, 'K', 'Számítástechnikai és programozási ismeretek', 535);
INSERT INTO public.subject_major VALUES ('GKNB_INTM005', 1, 5, 2020, 'K', 'Számítástechnikai és programozási ismeretek', 536);
INSERT INTO public.subject_major VALUES ('GKNB_INTM006', 1, 5, 2020, 'K', 'Számítástechnikai és programozási ismeretek', 537);
INSERT INTO public.subject_major VALUES ('GKNB_INTM009', 1, 6, 2020, 'K', 'Számítástechnikai és programozási ismeretek', 538);
INSERT INTO public.subject_major VALUES ('DKNB_KATM031', 1, 0, 2020, 'S', 'Számítástechnikai és programozási ismeretek', 576);
INSERT INTO public.subject_major VALUES ('GKNB_INTM044', 1, 0, 2020, 'V', 'Természettudományi ismeretek', 578);
INSERT INTO public.subject_major VALUES ('MENB_VKTM002', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 639);
INSERT INTO public.subject_major VALUES ('GKNB_INTM053', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 584);
INSERT INTO public.subject_major VALUES ('MENB_NTTM046', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 640);
INSERT INTO public.subject_major VALUES ('GKNB_INTM054', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 586);
INSERT INTO public.subject_major VALUES ('GKNB_INTM026', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 587);
INSERT INTO public.subject_major VALUES ('GKNB_INTM028', 1, 0, 2020, 'V', 'Természettudományi ismeretek', 589);
INSERT INTO public.subject_major VALUES ('GKNB_INTM029', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 590);
INSERT INTO public.subject_major VALUES ('MENB_NTTM042', 1, 0, 2020, 'V', 'Információs rendszerek ismeretek', 641);
INSERT INTO public.subject_major VALUES ('GKNB_INTM030', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 591);
INSERT INTO public.subject_major VALUES ('GKNB_INTM038', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 592);
INSERT INTO public.subject_major VALUES ('GKNB_TATM036', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 593);
INSERT INTO public.subject_major VALUES ('GKNB_INTM032', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 595);
INSERT INTO public.subject_major VALUES ('GKNB_INTM033', 1, 0, 2020, 'V', 'Információs rendszerek ismeretek', 600);
INSERT INTO public.subject_major VALUES ('GKNB_INTM034', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 601);
INSERT INTO public.subject_major VALUES ('GKNB_INTM037', 1, 0, 2020, 'V', 'Információs rendszerek ismeretek', 602);
INSERT INTO public.subject_major VALUES ('MENB_NTTM014', 1, 0, 2020, 'V', 'Információs rendszerek ismeretek', 642);
INSERT INTO public.subject_major VALUES ('GKNB_INTM039', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 605);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM028', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 609);
INSERT INTO public.subject_major VALUES ('MENB_AVTM010', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 643);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM020', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 644);
INSERT INTO public.subject_major VALUES ('GKNB_INTM040', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 611);
INSERT INTO public.subject_major VALUES ('MENB_NTTM035', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 645);
INSERT INTO public.subject_major VALUES ('GKNB_INTM042', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 614);
INSERT INTO public.subject_major VALUES ('MENB_NTTM051', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 646);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM054', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 647);
INSERT INTO public.subject_major VALUES ('GKNB_INTM043', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 615);
INSERT INTO public.subject_major VALUES ('GKNB_INTM011', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 618);
INSERT INTO public.subject_major VALUES ('GKNB_INTM045', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 622);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM017', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 648);
INSERT INTO public.subject_major VALUES ('MENB_BÉTM011', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 649);
INSERT INTO public.subject_major VALUES ('MENB_VKTM026', 1, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 650);
INSERT INTO public.subject_major VALUES ('MENB_NTTM038', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 651);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM033', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 652);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM007', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 653);
INSERT INTO public.subject_major VALUES ('GKNB_INTM013', 1, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 628);
INSERT INTO public.subject_major VALUES ('NGB_MT026_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 785);
INSERT INTO public.subject_major VALUES ('NGB_SV004_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 788);
INSERT INTO public.subject_major VALUES ('NGB_AG019_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 789);
INSERT INTO public.subject_major VALUES ('NGB_SM075_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 790);
INSERT INTO public.subject_major VALUES ('NGB_SE015_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 791);
INSERT INTO public.subject_major VALUES ('NGB_AG012_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 792);
INSERT INTO public.subject_major VALUES ('NGB_MT001_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 794);
INSERT INTO public.subject_major VALUES ('NGB_MA008_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 795);
INSERT INTO public.subject_major VALUES ('NGB_TT003_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 796);
INSERT INTO public.subject_major VALUES ('NGB_IN041_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 797);
INSERT INTO public.subject_major VALUES ('NGB_MT002_2', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 798);
INSERT INTO public.subject_major VALUES ('NGB_MT002_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 799);
INSERT INTO public.subject_major VALUES ('NGB_SZ015_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 800);
INSERT INTO public.subject_major VALUES ('NGB_MT006_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 801);
INSERT INTO public.subject_major VALUES ('NGB_AU016_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 802);
INSERT INTO public.subject_major VALUES ('NGB_AU016_2', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 803);
INSERT INTO public.subject_major VALUES ('NGB_TT005_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 804);
INSERT INTO public.subject_major VALUES ('NGB_SM001_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 805);
INSERT INTO public.subject_major VALUES ('NGB_SM001_2', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 806);
INSERT INTO public.subject_major VALUES ('NGB_MT005_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 807);
INSERT INTO public.subject_major VALUES ('NGB_SV050_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 808);
INSERT INTO public.subject_major VALUES ('NGB_FI012_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 809);
INSERT INTO public.subject_major VALUES ('NGB_FI012_2', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 810);
INSERT INTO public.subject_major VALUES ('NGB_AG008_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 811);
INSERT INTO public.subject_major VALUES ('NGB_SM044_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 812);
INSERT INTO public.subject_major VALUES ('NGB_KO042_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 813);
INSERT INTO public.subject_major VALUES ('NGB_KA001_1', 2, 2, 2015, 'S', 'Számítástechnikai és programozási ismeretek', 814);
INSERT INTO public.subject_major VALUES ('NGB_TS001_2', 2, 1, 2015, 'T', 'Számítástechnikai és programozási ismeretek', 885);
INSERT INTO public.subject_major VALUES ('NGB_TS001_4', 2, 1, 2015, 'T', 'Számítástechnikai és programozási ismeretek', 886);
INSERT INTO public.subject_major VALUES ('NGB_TS001_3', 2, 1, 2015, 'T', 'Számítástechnikai és programozási ismeretek', 887);
INSERT INTO public.subject_major VALUES ('NGB_TS001_1', 2, 1, 2015, 'T', 'Számítástechnikai és programozási ismeretek', 888);
INSERT INTO public.subject_major VALUES ('NGB_IT024_1', 2, 2, 2015, 'I', 'Természettudományi ismeretek', 872);
INSERT INTO public.subject_major VALUES ('NGB_IT024_2', 2, 2, 2015, 'I', 'Gazdasági és humán ismeretek', 873);
INSERT INTO public.subject_major VALUES ('NGB_IT039_1', 2, 2, 2015, 'I', 'Számítástechnikai és programozási ismeretek', 874);
INSERT INTO public.subject_major VALUES ('NGB_IT039_2', 2, 2, 2015, 'I', 'Természettudományi ismeretek', 875);
INSERT INTO public.subject_major VALUES ('NGB_IT039_3', 2, 2, 2015, 'I', 'Számítástechnikai és programozási ismeretek', 876);
INSERT INTO public.subject_major VALUES ('NGB_IT039_4', 2, 2, 2015, 'I', 'Számítástechnikai és programozási ismeretek', 877);
INSERT INTO public.subject_major VALUES ('NGB_IT001_2', 2, 2, 2015, 'I', 'Természettudományi ismeretek', 878);
INSERT INTO public.subject_major VALUES ('NGB_IT001_1', 2, 2, 2015, 'I', 'Gazdasági és humán ismeretek', 879);
INSERT INTO public.subject_major VALUES ('NGB_IT034_1', 2, 2, 2015, 'I', 'Természettudományi ismeretek', 880);
INSERT INTO public.subject_major VALUES ('NGB_IT034_2', 2, 2, 2015, 'I', 'Számítástechnikai és programozási ismeretek', 881);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM018', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1051);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM028', 2, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 1052);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM065', 1, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 668);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM077', 1, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 669);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM064', 1, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 670);
INSERT INTO public.subject_major VALUES ('KGNB_NETM042', 1, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 513);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM001', 1, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 514);
INSERT INTO public.subject_major VALUES ('GKNB_INTM112', 1, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 671);
INSERT INTO public.subject_major VALUES ('GKNB_INTM110', 1, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 672);
INSERT INTO public.subject_major VALUES ('GKNB_INTM111', 1, 1, 2023, 'K', 'Természettudományi ismeretek', 673);
INSERT INTO public.subject_major VALUES ('GKNB_INTM116', 1, 2, 2023, 'K', 'Gazdasági és humán ismeretek', 674);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM048', 1, 2, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 524);
INSERT INTO public.subject_major VALUES ('GKNB_INTM118', 1, 2, 2023, 'K', 'Természettudományi ismeretek', 675);
INSERT INTO public.subject_major VALUES ('GKNB_INTM024', 2, 3, 2017, 'K', 'Számítástechnikai és programozási ismeretek', 910);
INSERT INTO public.subject_major VALUES ('GKNB_INTM117', 1, 2, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 676);
INSERT INTO public.subject_major VALUES ('GKNB_INTM114', 1, 2, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 677);
INSERT INTO public.subject_major VALUES ('GKNB_INTM115', 1, 2, 2023, 'K', 'Természettudományi ismeretek', 678);
INSERT INTO public.subject_major VALUES ('GKNB_INTM003', 2, 4, 2017, 'K', 'Információs rendszerek ismeretek', 914);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM008', 1, 2, 2023, 'K', 'Gazdasági és humán ismeretek', 517);
INSERT INTO public.subject_major VALUES ('GKNB_INTM120', 1, 3, 2023, 'K', 'Természettudományi ismeretek', 679);
INSERT INTO public.subject_major VALUES ('GKNB_INTM121', 1, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 680);
INSERT INTO public.subject_major VALUES ('GKNB_INTM122', 1, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 681);
INSERT INTO public.subject_major VALUES ('GKNB_INTM167', 1, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 523);
INSERT INTO public.subject_major VALUES ('GKNB_INTM119', 1, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 682);
INSERT INTO public.subject_major VALUES ('GKNB_INTM123', 1, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 683);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM011', 1, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 526);
INSERT INTO public.subject_major VALUES ('GKNB_INTM125', 1, 4, 2023, 'K', 'Természettudományi ismeretek', 684);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM087', 1, 4, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 685);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM045', 1, 4, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 686);
INSERT INTO public.subject_major VALUES ('GKNB_INTM124', 1, 4, 2023, 'K', 'Természettudományi ismeretek', 687);
INSERT INTO public.subject_major VALUES ('GKNB_INTM025', 1, 4, 2023, 'K', 'Gazdasági és humán ismeretek', 522);
INSERT INTO public.subject_major VALUES ('MKNB_DSTM006', 2, 0, 2017, 'S', 'Gazdasági és humán ismeretek', 928);
INSERT INTO public.subject_major VALUES ('GKNB_INTM126', 1, 5, 2023, 'K', 'Információs rendszerek ismeretek', 688);
INSERT INTO public.subject_major VALUES ('GKNB_INTM007', 1, 5, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 533);
INSERT INTO public.subject_major VALUES ('GKNB_INTM128', 1, 5, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 689);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM054', 1, 5, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 690);
INSERT INTO public.subject_major VALUES ('GKNB_INTM087', 1, 5, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 638);
INSERT INTO public.subject_major VALUES ('GKNB_INTM129', 1, 6, 2023, 'K', 'Természettudományi ismeretek', 691);
INSERT INTO public.subject_major VALUES ('GKNB_INTM096', 1, 6, 2023, 'K', 'Természettudományi ismeretek', 539);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM045', 2, 0, 2017, 'S', 'Gazdasági és humán ismeretek', 936);
INSERT INTO public.subject_major VALUES ('GKNB_TATM038', 1, 6, 2023, 'K', 'Információs rendszerek ismeretek', 692);
INSERT INTO public.subject_major VALUES ('GKNB_INTM008', 1, 7, 2023, 'K', 'Gazdasági és humán ismeretek', 540);
INSERT INTO public.subject_major VALUES ('GKNB_INTM097', 1, 7, 2023, 'K', 'Információs rendszerek ismeretek', 541);
INSERT INTO public.subject_major VALUES ('GKNB_INTM160', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 693);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM055', 1, 0, 2023, 'V', 'Információs rendszerek ismeretek', 694);
INSERT INTO public.subject_major VALUES ('GKNB_INTM138', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 695);
INSERT INTO public.subject_major VALUES ('MENB_BÉTM120', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 696);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM054', 1, 0, 2023, 'V', 'Információs rendszerek ismeretek', 697);
INSERT INTO public.subject_major VALUES ('GKNB_INTM133', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 698);
INSERT INTO public.subject_major VALUES ('DKNB_APTM053', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 699);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM060', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 700);
INSERT INTO public.subject_major VALUES ('MKNB_DSTM003', 2, 0, 2017, 'S', 'Gazdasági és humán ismeretek', 948);
INSERT INTO public.subject_major VALUES ('GKNB_INTM151', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 701);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM001', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 579);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM078', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 580);
INSERT INTO public.subject_major VALUES ('GKNB_KVTM029', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 581);
INSERT INTO public.subject_major VALUES ('GKNB_INTM157', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 702);
INSERT INTO public.subject_major VALUES ('GKNB_INTM135', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 703);
INSERT INTO public.subject_major VALUES ('GKNB_INTM052', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 582);
INSERT INTO public.subject_major VALUES ('AJNB_TVTM002', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 583);
INSERT INTO public.subject_major VALUES ('GKNB_INTM145', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 704);
INSERT INTO public.subject_major VALUES ('GKNB_INTM154', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 705);
INSERT INTO public.subject_major VALUES ('MKNB_DSTM004', 2, 0, 2017, 'S', 'Számítástechnikai és programozási ismeretek', 959);
INSERT INTO public.subject_major VALUES ('GKNB_INTM090', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 585);
INSERT INTO public.subject_major VALUES ('GKNB_INTM161', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 706);
INSERT INTO public.subject_major VALUES ('GKNB_INTM010', 2, 0, 2017, 'V', 'Számítástechnikai és programozási ismeretek', 962);
INSERT INTO public.subject_major VALUES ('GKNB_INTM162', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 707);
INSERT INTO public.subject_major VALUES ('GKNB_INTM134', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 708);
INSERT INTO public.subject_major VALUES ('GKNB_INTM155', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 709);
INSERT INTO public.subject_major VALUES ('GKNB_INTM164', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 710);
INSERT INTO public.subject_major VALUES ('GKNB_INTM035', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 596);
INSERT INTO public.subject_major VALUES ('GKNB_INTM047', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 597);
INSERT INTO public.subject_major VALUES ('GKNB_INTM048', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 598);
INSERT INTO public.subject_major VALUES ('GKNB_INTM036', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 599);
INSERT INTO public.subject_major VALUES ('GKNB_INTM149', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 711);
INSERT INTO public.subject_major VALUES ('GKNB_INTM139', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 712);
INSERT INTO public.subject_major VALUES ('GKNB_INTM027', 2, 0, 2017, 'V', 'Számítástechnikai és programozási ismeretek', 973);
INSERT INTO public.subject_major VALUES ('GKNB_INTM132', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 713);
INSERT INTO public.subject_major VALUES ('GKNB_INTM131', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 714);
INSERT INTO public.subject_major VALUES ('GKNB_INTM130', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 715);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM029', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 603);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM028', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 604);
INSERT INTO public.subject_major VALUES ('GKNB_INTM031', 2, 0, 2017, 'V', 'Számítástechnikai és programozási ismeretek', 979);
INSERT INTO public.subject_major VALUES ('GKNB_INTM147', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 716);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM030', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 606);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM007', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 607);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM061', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 717);
INSERT INTO public.subject_major VALUES ('KGNB_NETM042', 2, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 898);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM001', 2, 1, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 899);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM048', 2, 2, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 909);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM008', 2, 2, 2023, 'K', 'Gazdasági és humán ismeretek', 902);
INSERT INTO public.subject_major VALUES ('GKNB_INTM167', 2, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 908);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM011', 2, 3, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 911);
INSERT INTO public.subject_major VALUES ('GKNB_INTM025', 2, 4, 2023, 'K', 'Gazdasági és humán ismeretek', 907);
INSERT INTO public.subject_major VALUES ('GKNB_INTM007', 2, 5, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 918);
INSERT INTO public.subject_major VALUES ('GKNB_INTM087', 2, 5, 2023, 'K', 'Számítástechnikai és programozási ismeretek', 1023);
INSERT INTO public.subject_major VALUES ('GKNB_INTM096', 2, 6, 2023, 'K', 'Természettudományi ismeretek', 924);
INSERT INTO public.subject_major VALUES ('GKNB_INTM008', 2, 7, 2023, 'K', 'Gazdasági és humán ismeretek', 925);
INSERT INTO public.subject_major VALUES ('GKNB_INTM097', 2, 7, 2023, 'K', 'Információs rendszerek ismeretek', 926);
INSERT INTO public.subject_major VALUES ('EKNB_KOTM110', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 927);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM030', 2, 0, 2023, 'S', 'Természettudományi ismeretek', 929);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM018', 2, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 930);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM019', 2, 0, 2023, 'S', 'Természettudományi ismeretek', 931);
INSERT INTO public.subject_major VALUES ('EKNB_KETM029', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 932);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM027', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 933);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM022', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 934);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM023', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 935);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM029', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 937);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM023', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 938);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM004', 2, 0, 2023, 'S', 'Természettudományi ismeretek', 939);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM005', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 940);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM036', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 941);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM031', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 608);
INSERT INTO public.subject_major VALUES ('GKNB_INTM152', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 718);
INSERT INTO public.subject_major VALUES ('GKNB_INTM137', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 719);
INSERT INTO public.subject_major VALUES ('GKNB_INTM148', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 720);
INSERT INTO public.subject_major VALUES ('GKNB_INTM150', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 721);
INSERT INTO public.subject_major VALUES ('GKNB_INTM153', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 722);
INSERT INTO public.subject_major VALUES ('GKNB_INTM046', 2, 0, 2017, 'V', 'Gazdasági és humán ismeretek', 1014);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM079', 2, 1, 2017, 'I', 'Számítástechnikai és programozási ismeretek', 1015);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM080', 2, 2, 2017, 'I', 'Információs rendszerek ismeretek', 1016);
INSERT INTO public.subject_major VALUES ('GKNB_INTM159', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 723);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM014', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 610);
INSERT INTO public.subject_major VALUES ('GKNB_INTM136', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 724);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM080', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 612);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM016', 2, 1, 2020, 'K', 'Gazdasági és humán ismeretek', 897);
INSERT INTO public.subject_major VALUES ('GKNB_INTM012', 2, 1, 2020, 'K', 'Gazdasági és humán ismeretek', 900);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM014', 2, 1, 2020, 'K', 'Gazdasági és humán ismeretek', 901);
INSERT INTO public.subject_major VALUES ('GKNB_INTM021', 2, 2, 2020, 'K', 'Gazdasági és humán ismeretek', 903);
INSERT INTO public.subject_major VALUES ('GKNB_INTM022', 2, 2, 2020, 'K', 'Gazdasági és humán ismeretek', 904);
INSERT INTO public.subject_major VALUES ('GKNB_INTM001', 2, 2, 2020, 'K', 'Gazdasági és humán ismeretek', 905);
INSERT INTO public.subject_major VALUES ('GKNB_INTM018', 2, 2, 2020, 'K', 'Gazdasági és humán ismeretek', 906);
INSERT INTO public.subject_major VALUES ('GKNB_INTM085', 2, 3, 2020, 'K', 'Gazdasági és humán ismeretek', 1021);
INSERT INTO public.subject_major VALUES ('GKNB_INTM086', 2, 3, 2020, 'K', 'Gazdasági és humán ismeretek', 1022);
INSERT INTO public.subject_major VALUES ('GKNB_INTM020', 2, 3, 2020, 'K', 'Gazdasági és humán ismeretek', 912);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM007', 2, 4, 2020, 'K', 'Gazdasági és humán ismeretek', 913);
INSERT INTO public.subject_major VALUES ('GKNB_INTM002', 2, 4, 2020, 'K', 'Gazdasági és humán ismeretek', 915);
INSERT INTO public.subject_major VALUES ('GKNB_INTM004', 2, 4, 2020, 'K', 'Gazdasági és humán ismeretek', 916);
INSERT INTO public.subject_major VALUES ('KGNB_GETM004', 2, 4, 2020, 'K', 'Gazdasági és humán ismeretek', 917);
INSERT INTO public.subject_major VALUES ('DKNB_KATM030', 2, 5, 2020, 'K', 'Gazdasági és humán ismeretek', 919);
INSERT INTO public.subject_major VALUES ('GKNB_INTM019', 2, 5, 2020, 'K', 'Számítástechnikai és programozási ismeretek', 920);
INSERT INTO public.subject_major VALUES ('GKNB_INTM005', 2, 5, 2020, 'K', 'Számítástechnikai és programozási ismeretek', 921);
INSERT INTO public.subject_major VALUES ('GKNB_INTM006', 2, 5, 2020, 'K', 'Számítástechnikai és programozási ismeretek', 922);
INSERT INTO public.subject_major VALUES ('GKNB_INTM009', 2, 6, 2020, 'K', 'Számítástechnikai és programozási ismeretek', 923);
INSERT INTO public.subject_major VALUES ('GKNB_INTM142', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 725);
INSERT INTO public.subject_major VALUES ('GKNB_INTM041', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 613);
INSERT INTO public.subject_major VALUES ('GKNB_INTM141', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 726);
INSERT INTO public.subject_major VALUES ('GKNB_INTM140', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 727);
INSERT INTO public.subject_major VALUES ('GKNB_INTM156', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 728);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM032', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 616);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM077', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 617);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM033', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 619);
INSERT INTO public.subject_major VALUES ('GKNB_INTM088', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 620);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM007', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 621);
INSERT INTO public.subject_major VALUES ('GKNB_INTM144', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 729);
INSERT INTO public.subject_major VALUES ('GKNB_INTM089', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 623);
INSERT INTO public.subject_major VALUES ('GKNB_INTM143', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 730);
INSERT INTO public.subject_major VALUES ('GKNB_INTM146', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 731);
INSERT INTO public.subject_major VALUES ('GKNB_INTM113', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 624);
INSERT INTO public.subject_major VALUES ('GKNB_INTM049', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 625);
INSERT INTO public.subject_major VALUES ('GKNB_INTM050', 1, 0, 2023, 'V', 'Természettudományi ismeretek', 626);
INSERT INTO public.subject_major VALUES ('GKNB_INTM051', 1, 0, 2023, 'V', 'Gazdasági és humán ismeretek', 627);
INSERT INTO public.subject_major VALUES ('GKNB_INTM158', 1, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 732);
INSERT INTO public.subject_major VALUES ('GKNB_INTM163', 1, 0, 2023, 'V', 'Természettudományi ismeretek', 733);
INSERT INTO public.subject_major VALUES ('EKNB_KOTM110', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 542);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM056', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 734);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM030', 1, 0, 2023, 'S', 'Természettudományi ismeretek', 544);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM018', 1, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 545);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM019', 1, 0, 2023, 'S', 'Természettudományi ismeretek', 546);
INSERT INTO public.subject_major VALUES ('EKNB_KETM029', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 547);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM027', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 548);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM022', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 549);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM023', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 550);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM029', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 552);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM023', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 553);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM004', 1, 0, 2023, 'S', 'Természettudományi ismeretek', 554);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM005', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 555);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM036', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 556);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM100', 1, 0, 2023, 'S', 'Természettudományi ismeretek', 557);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM024', 1, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 558);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM034', 1, 0, 2023, 'S', 'Információs rendszerek ismeretek', 559);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM041', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 560);
INSERT INTO public.subject_major VALUES ('AKNB_TTTM202', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 561);
INSERT INTO public.subject_major VALUES ('DKNB_KATM031', 2, 0, 2020, 'S', 'Számítástechnikai és programozási ismeretek', 961);
INSERT INTO public.subject_major VALUES ('GKNB_INTM044', 2, 0, 2020, 'V', 'Természettudományi ismeretek', 963);
INSERT INTO public.subject_major VALUES ('MENB_VKTM002', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1024);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM033', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 562);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM248', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 564);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM026', 1, 0, 2023, 'S', 'Természettudományi ismeretek', 565);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM017', 1, 0, 2023, 'S', 'Természettudományi ismeretek', 566);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM024', 1, 0, 2023, 'S', 'Információs rendszerek ismeretek', 567);
INSERT INTO public.subject_major VALUES ('GKNB_INTM053', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 969);
INSERT INTO public.subject_major VALUES ('MENB_NTTM046', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 1025);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM197', 1, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 568);
INSERT INTO public.subject_major VALUES ('GKNB_INTM054', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 971);
INSERT INTO public.subject_major VALUES ('GKNB_INTM026', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 972);
INSERT INTO public.subject_major VALUES ('GKNB_INTM028', 2, 0, 2020, 'V', 'Természettudományi ismeretek', 974);
INSERT INTO public.subject_major VALUES ('GKNB_INTM029', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 975);
INSERT INTO public.subject_major VALUES ('MENB_NTTM042', 2, 0, 2020, 'V', 'Információs rendszerek ismeretek', 1026);
INSERT INTO public.subject_major VALUES ('GKNB_INTM030', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 976);
INSERT INTO public.subject_major VALUES ('GKNB_INTM038', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 977);
INSERT INTO public.subject_major VALUES ('GKNB_TATM036', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 978);
INSERT INTO public.subject_major VALUES ('GKNB_INTM032', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 980);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM085', 1, 0, 2023, 'S', 'Információs rendszerek ismeretek', 569);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM025', 1, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 570);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM026', 1, 0, 2023, 'S', 'Információs rendszerek ismeretek', 571);
INSERT INTO public.subject_major VALUES ('EKNB_KETM032', 1, 0, 2023, 'S', 'Gazdasági és humán ismeretek', 572);
INSERT INTO public.subject_major VALUES ('GKNB_INTM033', 2, 0, 2020, 'V', 'Információs rendszerek ismeretek', 985);
INSERT INTO public.subject_major VALUES ('GKNB_INTM034', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 986);
INSERT INTO public.subject_major VALUES ('GKNB_INTM037', 2, 0, 2020, 'V', 'Információs rendszerek ismeretek', 987);
INSERT INTO public.subject_major VALUES ('AKNB_BHTM164', 1, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 573);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM186', 1, 0, 2023, 'S', 'Információs rendszerek ismeretek', 575);
INSERT INTO public.subject_major VALUES ('MENB_NTTM014', 2, 0, 2020, 'V', 'Információs rendszerek ismeretek', 1027);
INSERT INTO public.subject_major VALUES ('GKNB_INTM039', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 990);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM002', 1, 0, 2023, 'T', 'Számítástechnikai és programozási ismeretek', 632);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM004', 1, 0, 2023, 'T', 'Gazdasági és humán ismeretek', 633);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM003', 1, 0, 2023, 'T', 'Gazdasági és humán ismeretek', 634);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM028', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 994);
INSERT INTO public.subject_major VALUES ('MENB_AVTM010', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1028);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM001', 1, 0, 2023, 'T', 'Gazdasági és humán ismeretek', 635);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM020', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1029);
INSERT INTO public.subject_major VALUES ('GKNB_INTM040', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 996);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM012', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 654);
INSERT INTO public.subject_major VALUES ('MENB_NTTM035', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1030);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM013', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 655);
INSERT INTO public.subject_major VALUES ('GKNB_INTM042', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 999);
INSERT INTO public.subject_major VALUES ('MENB_NTTM051', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1031);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM054', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1032);
INSERT INTO public.subject_major VALUES ('GKNB_INTM043', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1000);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM017', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 656);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM031', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 657);
INSERT INTO public.subject_major VALUES ('GKNB_INTM011', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1003);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM016', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 658);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM030', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 659);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM015', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 660);
INSERT INTO public.subject_major VALUES ('GKNB_INTM045', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1007);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM017', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1033);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM027', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 661);
INSERT INTO public.subject_major VALUES ('MENB_BÉTM011', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1034);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM014', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 662);
INSERT INTO public.subject_major VALUES ('MENB_VKTM026', 2, 0, 2020, 'V', 'Gazdasági és humán ismeretek', 1035);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM026', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 663);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM019', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 664);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM029', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 665);
INSERT INTO public.subject_major VALUES ('MENB_NTTM038', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 1036);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM033', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 1037);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM007', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 1038);
INSERT INTO public.subject_major VALUES ('GKNB_INTM013', 2, 0, 2020, 'V', 'Számítástechnikai és programozási ismeretek', 1013);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM018', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 666);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM028', 1, 0, 2023, 'I', 'Gazdasági és humán ismeretek', 667);
INSERT INTO public.subject_major VALUES ('GKNB_INTM146', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1116);
INSERT INTO public.subject_major VALUES ('GKNB_INTM158', 2, 0, 2023, 'V', 'Számítástechnikai és programozási ismeretek', 1117);
INSERT INTO public.subject_major VALUES ('GKNB_INTM163', 2, 0, 2023, 'V', 'Természettudományi ismeretek', 1118);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM056', 2, 0, 2023, 'S', 'Számítástechnikai és programozási ismeretek', 1119);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM065', 52, 1, 2025, 'K', 'Természettudományi ismeretek', 3210);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM077', 52, 1, 2025, 'K', 'Gazdasági és humán ismeretek', 3211);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM064', 52, 1, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3212);
INSERT INTO public.subject_major VALUES ('KGNB_NETM042', 52, 1, 2025, 'K', 'Természettudományi ismeretek', 3213);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM001', 52, 1, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3214);
INSERT INTO public.subject_major VALUES ('GKNB_INTM112', 52, 1, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3215);
INSERT INTO public.subject_major VALUES ('GKNB_INTM110', 52, 1, 2025, 'K', 'Természettudományi ismeretek', 3216);
INSERT INTO public.subject_major VALUES ('GKNB_INTM111', 52, 1, 2025, 'K', 'Gazdasági és humán ismeretek', 3217);
INSERT INTO public.subject_major VALUES ('GKNB_INTM182', 52, 2, 2025, 'K', 'Természettudományi ismeretek', 3218);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM048', 52, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3219);
INSERT INTO public.subject_major VALUES ('GKNB_INTM118', 52, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3220);
INSERT INTO public.subject_major VALUES ('GKNB_INTM115', 52, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3221);
INSERT INTO public.subject_major VALUES ('GKNB_INTM183', 52, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3222);
INSERT INTO public.subject_major VALUES ('GKNB_INTM114', 52, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3223);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM059', 52, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3224);
INSERT INTO public.subject_major VALUES ('GKNB_INTM185', 52, 3, 2025, 'K', 'Természettudományi ismeretek', 3225);
INSERT INTO public.subject_major VALUES ('GKNB_INTM121', 52, 3, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3226);
INSERT INTO public.subject_major VALUES ('GKNB_INTM122', 52, 3, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3227);
INSERT INTO public.subject_major VALUES ('GKNB_INTM167', 52, 3, 2025, 'K', 'Természettudományi ismeretek', 3228);
INSERT INTO public.subject_major VALUES ('GKNB_INTM119', 52, 3, 2025, 'K', 'Gazdasági és humán ismeretek', 3229);
INSERT INTO public.subject_major VALUES ('GKNB_INTM184', 52, 3, 2025, 'K', 'Információs rendszerek ismeretek', 3230);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM100', 52, 3, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3231);
INSERT INTO public.subject_major VALUES ('GKNB_INTM186', 52, 4, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3232);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM087', 52, 4, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3233);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM045', 52, 4, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3234);
INSERT INTO public.subject_major VALUES ('GKNB_INTM124', 52, 4, 2025, 'K', 'Természettudományi ismeretek', 3235);
INSERT INTO public.subject_major VALUES ('GKNB_INTM025', 52, 4, 2025, 'K', 'Természettudományi ismeretek', 3236);
INSERT INTO public.subject_major VALUES ('GKNB_INTM126', 52, 5, 2025, 'K', 'Információs rendszerek ismeretek', 3237);
INSERT INTO public.subject_major VALUES ('GKNB_INTM007', 52, 5, 2025, 'K', 'Gazdasági és humán ismeretek', 3238);
INSERT INTO public.subject_major VALUES ('GKNB_INTM128', 52, 5, 2025, 'K', 'Információs rendszerek ismeretek', 3239);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM054', 52, 5, 2025, 'K', 'Gazdasági és humán ismeretek', 3240);
INSERT INTO public.subject_major VALUES ('GKNB_INTM087', 52, 5, 2025, 'K', 'Információs rendszerek ismeretek', 3241);
INSERT INTO public.subject_major VALUES ('GKNB_INTM187', 52, 6, 2025, 'K', 'Gazdasági és humán ismeretek', 3242);
INSERT INTO public.subject_major VALUES ('GKNB_INTM096', 52, 6, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3243);
INSERT INTO public.subject_major VALUES ('GKNB_TATM038', 52, 6, 2025, 'K', 'Információs rendszerek ismeretek', 3244);
INSERT INTO public.subject_major VALUES ('GKNB_INTM008', 52, 7, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3245);
INSERT INTO public.subject_major VALUES ('GKNB_INTM097', 52, 7, 2025, 'K', 'Gazdasági és humán ismeretek', 3246);
INSERT INTO public.subject_major VALUES ('GKNB_INTM160', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3247);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM055', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3248);
INSERT INTO public.subject_major VALUES ('GKNB_INTM138', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3249);
INSERT INTO public.subject_major VALUES ('MENB_BÉTM120', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3250);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM054', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3251);
INSERT INTO public.subject_major VALUES ('GKNB_INTM133', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3252);
INSERT INTO public.subject_major VALUES ('DKNB_APTM053', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3253);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM060', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3254);
INSERT INTO public.subject_major VALUES ('GKNB_INTM151', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3255);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM001', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3256);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM078', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3257);
INSERT INTO public.subject_major VALUES ('GKNB_KVTM029', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3258);
INSERT INTO public.subject_major VALUES ('GKNB_INTM157', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3259);
INSERT INTO public.subject_major VALUES ('GKNB_INTM135', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3260);
INSERT INTO public.subject_major VALUES ('GKNB_INTM052', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3261);
INSERT INTO public.subject_major VALUES ('AJNB_TVTM002', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3262);
INSERT INTO public.subject_major VALUES ('GKNB_INTM145', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3263);
INSERT INTO public.subject_major VALUES ('GKNB_INTM154', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3264);
INSERT INTO public.subject_major VALUES ('GKNB_INTM090', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3265);
INSERT INTO public.subject_major VALUES ('GKNB_INTM161', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3266);
INSERT INTO public.subject_major VALUES ('GKNB_INTM162', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3267);
INSERT INTO public.subject_major VALUES ('GKNB_INTM134', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3268);
INSERT INTO public.subject_major VALUES ('GKNB_INTM164', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3269);
INSERT INTO public.subject_major VALUES ('GKNB_INTM035', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3270);
INSERT INTO public.subject_major VALUES ('GKNB_INTM047', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3271);
INSERT INTO public.subject_major VALUES ('GKNB_INTM048', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3272);
INSERT INTO public.subject_major VALUES ('GKNB_INTM036', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3273);
INSERT INTO public.subject_major VALUES ('GKNB_INTM149', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3274);
INSERT INTO public.subject_major VALUES ('GKNB_INTM139', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3275);
INSERT INTO public.subject_major VALUES ('GKNB_INTM132', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3276);
INSERT INTO public.subject_major VALUES ('GKNB_INTM131', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3277);
INSERT INTO public.subject_major VALUES ('GKNB_INTM130', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3278);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM029', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3279);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM028', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3280);
INSERT INTO public.subject_major VALUES ('GKNB_INTM147', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3281);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM030', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3282);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM007', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3283);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM061', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3284);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM031', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3285);
INSERT INTO public.subject_major VALUES ('GKNB_INTM152', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3286);
INSERT INTO public.subject_major VALUES ('GKNB_INTM137', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3287);
INSERT INTO public.subject_major VALUES ('GKNB_INTM148', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3288);
INSERT INTO public.subject_major VALUES ('GKNB_INTM150', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3289);
INSERT INTO public.subject_major VALUES ('GKNB_INTM153', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3290);
INSERT INTO public.subject_major VALUES ('GKNB_INTM117', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3291);
INSERT INTO public.subject_major VALUES ('GKNB_INTM159', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3292);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM014', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3293);
INSERT INTO public.subject_major VALUES ('GKNB_INTM136', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3294);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM080', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3295);
INSERT INTO public.subject_major VALUES ('GKNB_INTM142', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3296);
INSERT INTO public.subject_major VALUES ('GKNB_INTM041', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3297);
INSERT INTO public.subject_major VALUES ('GKNB_INTM141', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3298);
INSERT INTO public.subject_major VALUES ('GKNB_INTM140', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3299);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM032', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3300);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM077', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3301);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM033', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3302);
INSERT INTO public.subject_major VALUES ('GKNB_INTM088', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3303);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM007', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3304);
INSERT INTO public.subject_major VALUES ('GKNB_INTM144', 52, 1, 2025, 'V', 'Természettudományi ismeretek', 3305);
INSERT INTO public.subject_major VALUES ('GKNB_INTM089', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3306);
INSERT INTO public.subject_major VALUES ('GKNB_INTM143', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3307);
INSERT INTO public.subject_major VALUES ('GKNB_INTM146', 52, 1, 2025, 'V', 'Természettudományi ismeretek', 3308);
INSERT INTO public.subject_major VALUES ('GKNB_INTM113', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3309);
INSERT INTO public.subject_major VALUES ('GKNB_INTM049', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3310);
INSERT INTO public.subject_major VALUES ('GKNB_INTM050', 52, 1, 2025, 'V', 'Természettudományi ismeretek', 3311);
INSERT INTO public.subject_major VALUES ('GKNB_INTM051', 52, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3312);
INSERT INTO public.subject_major VALUES ('GKNB_INTM158', 52, 1, 2025, 'V', 'Természettudományi ismeretek', 3313);
INSERT INTO public.subject_major VALUES ('GKNB_INTM188', 52, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3314);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM056', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3315);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM030', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3316);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM018', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3317);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM019', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3318);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM027', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3319);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM021', 52, 1, 2025, 'S', 'Természettudományi ismeretek', 3320);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM022', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3321);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM023', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3322);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM023', 52, 1, 2025, 'S', 'Természettudományi ismeretek', 3323);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM004', 52, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3324);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM005', 52, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3325);
INSERT INTO public.subject_major VALUES ('GKNB_TATM036', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3326);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM036', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3327);
INSERT INTO public.subject_major VALUES ('SZENB_MCKM001', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3328);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM100', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3329);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM024', 52, 1, 2025, 'S', 'Természettudományi ismeretek', 3330);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM002', 52, 1, 2025, 'S', 'Természettudományi ismeretek', 3331);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM003', 52, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3332);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM034', 52, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3333);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM041', 52, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3334);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM033', 52, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3335);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM248', 52, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3336);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM026', 52, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3337);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM197', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3338);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM085', 52, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3339);
INSERT INTO public.subject_major VALUES ('EKNB_KETM032', 52, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3340);
INSERT INTO public.subject_major VALUES ('AKNB_BHTM164', 52, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3341);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM186', 52, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3342);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM002', 52, 1, 2025, 'T', 'Gazdasági és humán ismeretek', 3343);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM004', 52, 1, 2025, 'T', 'Gazdasági és humán ismeretek', 3344);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM003', 52, 1, 2025, 'T', 'Gazdasági és humán ismeretek', 3345);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM001', 52, 1, 2025, 'T', 'Gazdasági és humán ismeretek', 3346);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM015', 52, 1, 2025, 'I', 'Gazdasági és humán ismeretek', 3347);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM027', 52, 1, 2025, 'I', 'Gazdasági és humán ismeretek', 3348);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM014', 52, 1, 2025, 'I', 'Gazdasági és humán ismeretek', 3349);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM026', 52, 1, 2025, 'I', 'Gazdasági és humán ismeretek', 3350);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM065', 53, 1, 2025, 'K', 'Természettudományi ismeretek', 3351);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM077', 53, 1, 2025, 'K', 'Gazdasági és humán ismeretek', 3352);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM064', 53, 1, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3353);
INSERT INTO public.subject_major VALUES ('KGNB_NETM042', 53, 1, 2025, 'K', 'Természettudományi ismeretek', 3354);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM001', 53, 1, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3355);
INSERT INTO public.subject_major VALUES ('GKNB_INTM112', 53, 1, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3356);
INSERT INTO public.subject_major VALUES ('GKNB_INTM110', 53, 1, 2025, 'K', 'Természettudományi ismeretek', 3357);
INSERT INTO public.subject_major VALUES ('GKNB_INTM111', 53, 1, 2025, 'K', 'Gazdasági és humán ismeretek', 3358);
INSERT INTO public.subject_major VALUES ('GKNB_INTM182', 53, 2, 2025, 'K', 'Természettudományi ismeretek', 3359);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM048', 53, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3360);
INSERT INTO public.subject_major VALUES ('GKNB_INTM118', 53, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3361);
INSERT INTO public.subject_major VALUES ('GKNB_INTM115', 53, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3362);
INSERT INTO public.subject_major VALUES ('GKNB_INTM183', 53, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3363);
INSERT INTO public.subject_major VALUES ('GKNB_INTM114', 53, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3364);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM059', 53, 2, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3365);
INSERT INTO public.subject_major VALUES ('GKNB_INTM185', 53, 3, 2025, 'K', 'Természettudományi ismeretek', 3366);
INSERT INTO public.subject_major VALUES ('GKNB_INTM121', 53, 3, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3367);
INSERT INTO public.subject_major VALUES ('GKNB_INTM146', 53, 1, 2025, 'V', 'Természettudományi ismeretek', 3449);
INSERT INTO public.subject_major VALUES ('GKNB_INTM122', 53, 3, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3368);
INSERT INTO public.subject_major VALUES ('GKNB_INTM167', 53, 3, 2025, 'K', 'Természettudományi ismeretek', 3369);
INSERT INTO public.subject_major VALUES ('GKNB_INTM119', 53, 3, 2025, 'K', 'Gazdasági és humán ismeretek', 3370);
INSERT INTO public.subject_major VALUES ('GKNB_INTM184', 53, 3, 2025, 'K', 'Információs rendszerek ismeretek', 3371);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM100', 53, 3, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3372);
INSERT INTO public.subject_major VALUES ('GKNB_INTM186', 53, 4, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3373);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM087', 53, 4, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3374);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM045', 53, 4, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3375);
INSERT INTO public.subject_major VALUES ('GKNB_INTM124', 53, 4, 2025, 'K', 'Természettudományi ismeretek', 3376);
INSERT INTO public.subject_major VALUES ('GKNB_INTM025', 53, 4, 2025, 'K', 'Természettudományi ismeretek', 3377);
INSERT INTO public.subject_major VALUES ('GKNB_INTM126', 53, 5, 2025, 'K', 'Információs rendszerek ismeretek', 3378);
INSERT INTO public.subject_major VALUES ('GKNB_INTM007', 53, 5, 2025, 'K', 'Gazdasági és humán ismeretek', 3379);
INSERT INTO public.subject_major VALUES ('GKNB_INTM128', 53, 5, 2025, 'K', 'Információs rendszerek ismeretek', 3380);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM054', 53, 5, 2025, 'K', 'Gazdasági és humán ismeretek', 3381);
INSERT INTO public.subject_major VALUES ('GKNB_INTM087', 53, 5, 2025, 'K', 'Információs rendszerek ismeretek', 3382);
INSERT INTO public.subject_major VALUES ('GKNB_INTM187', 53, 6, 2025, 'K', 'Gazdasági és humán ismeretek', 3383);
INSERT INTO public.subject_major VALUES ('GKNB_INTM096', 53, 6, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3384);
INSERT INTO public.subject_major VALUES ('GKNB_TATM038', 53, 6, 2025, 'K', 'Információs rendszerek ismeretek', 3385);
INSERT INTO public.subject_major VALUES ('GKNB_INTM008', 53, 7, 2025, 'K', 'Számítástechnikai és programozási ismeretek', 3386);
INSERT INTO public.subject_major VALUES ('GKNB_INTM097', 53, 7, 2025, 'K', 'Gazdasági és humán ismeretek', 3387);
INSERT INTO public.subject_major VALUES ('GKNB_INTM160', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3388);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM055', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3389);
INSERT INTO public.subject_major VALUES ('GKNB_INTM138', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3390);
INSERT INTO public.subject_major VALUES ('MENB_BÉTM120', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3391);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM054', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3392);
INSERT INTO public.subject_major VALUES ('GKNB_INTM133', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3393);
INSERT INTO public.subject_major VALUES ('DKNB_APTM053', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3394);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM060', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3395);
INSERT INTO public.subject_major VALUES ('GKNB_INTM151', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3396);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM001', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3397);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM078', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3398);
INSERT INTO public.subject_major VALUES ('GKNB_KVTM029', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3399);
INSERT INTO public.subject_major VALUES ('GKNB_INTM157', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3400);
INSERT INTO public.subject_major VALUES ('GKNB_INTM135', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3401);
INSERT INTO public.subject_major VALUES ('GKNB_INTM052', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3402);
INSERT INTO public.subject_major VALUES ('AJNB_TVTM002', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3403);
INSERT INTO public.subject_major VALUES ('GKNB_INTM145', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3404);
INSERT INTO public.subject_major VALUES ('GKNB_INTM154', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3405);
INSERT INTO public.subject_major VALUES ('GKNB_INTM090', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3406);
INSERT INTO public.subject_major VALUES ('GKNB_INTM161', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3407);
INSERT INTO public.subject_major VALUES ('GKNB_INTM162', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3408);
INSERT INTO public.subject_major VALUES ('GKNB_INTM134', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3409);
INSERT INTO public.subject_major VALUES ('GKNB_INTM164', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3410);
INSERT INTO public.subject_major VALUES ('GKNB_INTM035', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3411);
INSERT INTO public.subject_major VALUES ('GKNB_INTM047', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3412);
INSERT INTO public.subject_major VALUES ('GKNB_INTM048', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3413);
INSERT INTO public.subject_major VALUES ('GKNB_INTM036', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3414);
INSERT INTO public.subject_major VALUES ('GKNB_INTM149', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3415);
INSERT INTO public.subject_major VALUES ('GKNB_INTM139', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3416);
INSERT INTO public.subject_major VALUES ('GKNB_INTM132', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3417);
INSERT INTO public.subject_major VALUES ('GKNB_INTM131', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3418);
INSERT INTO public.subject_major VALUES ('GKNB_INTM130', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3419);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM029', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3420);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM028', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3421);
INSERT INTO public.subject_major VALUES ('GKNB_INTM147', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3422);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM030', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3423);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM007', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3424);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM061', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3425);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM031', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3426);
INSERT INTO public.subject_major VALUES ('GKNB_INTM152', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3427);
INSERT INTO public.subject_major VALUES ('GKNB_INTM137', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3428);
INSERT INTO public.subject_major VALUES ('GKNB_INTM148', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3429);
INSERT INTO public.subject_major VALUES ('GKNB_INTM150', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3430);
INSERT INTO public.subject_major VALUES ('GKNB_INTM153', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3431);
INSERT INTO public.subject_major VALUES ('GKNB_INTM117', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3432);
INSERT INTO public.subject_major VALUES ('GKNB_INTM159', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3433);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM014', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3434);
INSERT INTO public.subject_major VALUES ('GKNB_INTM136', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3435);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM080', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3436);
INSERT INTO public.subject_major VALUES ('GKNB_INTM142', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3437);
INSERT INTO public.subject_major VALUES ('GKNB_INTM041', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3438);
INSERT INTO public.subject_major VALUES ('GKNB_INTM141', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3439);
INSERT INTO public.subject_major VALUES ('GKNB_INTM140', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3440);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM032', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3441);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM077', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3442);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM033', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3443);
INSERT INTO public.subject_major VALUES ('GKNB_INTM088', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3444);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM007', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3445);
INSERT INTO public.subject_major VALUES ('GKNB_INTM144', 53, 1, 2025, 'V', 'Természettudományi ismeretek', 3446);
INSERT INTO public.subject_major VALUES ('GKNB_INTM089', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3447);
INSERT INTO public.subject_major VALUES ('GKNB_INTM143', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3448);
INSERT INTO public.subject_major VALUES ('GKNB_INTM113', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3450);
INSERT INTO public.subject_major VALUES ('GKNB_INTM049', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3451);
INSERT INTO public.subject_major VALUES ('GKNB_INTM050', 53, 1, 2025, 'V', 'Természettudományi ismeretek', 3452);
INSERT INTO public.subject_major VALUES ('GKNB_INTM051', 53, 1, 2025, 'V', 'Gazdasági és humán ismeretek', 3453);
INSERT INTO public.subject_major VALUES ('GKNB_INTM158', 53, 1, 2025, 'V', 'Természettudományi ismeretek', 3454);
INSERT INTO public.subject_major VALUES ('GKNB_INTM188', 53, 1, 2025, 'V', 'Számítástechnikai és programozási ismeretek', 3455);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM056', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3456);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM030', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3457);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM018', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3458);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM019', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3459);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM027', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3460);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM021', 53, 1, 2025, 'S', 'Természettudományi ismeretek', 3461);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM022', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3462);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM023', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3463);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM023', 53, 1, 2025, 'S', 'Természettudományi ismeretek', 3464);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM004', 53, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3465);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM005', 53, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3466);
INSERT INTO public.subject_major VALUES ('GKNB_TATM036', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3467);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM036', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3468);
INSERT INTO public.subject_major VALUES ('SZENB_MCKM001', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3469);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM100', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3470);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM024', 53, 1, 2025, 'S', 'Természettudományi ismeretek', 3471);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM002', 53, 1, 2025, 'S', 'Természettudományi ismeretek', 3472);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM003', 53, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3473);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM034', 53, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3474);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM041', 53, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3475);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM033', 53, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3476);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM248', 53, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3477);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM026', 53, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3478);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM197', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3479);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM085', 53, 1, 2025, 'S', 'Információs rendszerek ismeretek', 3480);
INSERT INTO public.subject_major VALUES ('EKNB_KETM032', 53, 1, 2025, 'S', 'Számítástechnikai és programozási ismeretek', 3481);
INSERT INTO public.subject_major VALUES ('AKNB_BHTM164', 53, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3482);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM186', 53, 1, 2025, 'S', 'Gazdasági és humán ismeretek', 3483);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM002', 53, 1, 2025, 'T', 'Gazdasági és humán ismeretek', 3484);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM004', 53, 1, 2025, 'T', 'Gazdasági és humán ismeretek', 3485);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM003', 53, 1, 2025, 'T', 'Gazdasági és humán ismeretek', 3486);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM001', 53, 1, 2025, 'T', 'Gazdasági és humán ismeretek', 3487);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM015', 53, 1, 2025, 'I', 'Gazdasági és humán ismeretek', 3488);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM027', 53, 1, 2025, 'I', 'Gazdasági és humán ismeretek', 3489);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM014', 53, 1, 2025, 'I', 'Gazdasági és humán ismeretek', 3490);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM026', 53, 1, 2025, 'I', 'Gazdasági és humán ismeretek', 3491);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM065', 54, 1, 2025, 'Kötelező', 'Természettudományi ismeretek', 3492);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM077', 54, 1, 2025, 'Kötelező', 'Gazdasági és humán ismeretek', 3493);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM064', 54, 1, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3494);
INSERT INTO public.subject_major VALUES ('KGNB_NETM042', 54, 1, 2025, 'Kötelező', 'Természettudományi ismeretek', 3495);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM001', 54, 1, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3496);
INSERT INTO public.subject_major VALUES ('GKNB_INTM112', 54, 1, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3497);
INSERT INTO public.subject_major VALUES ('GKNB_INTM110', 54, 1, 2025, 'Kötelező', 'Természettudományi ismeretek', 3498);
INSERT INTO public.subject_major VALUES ('GKNB_INTM111', 54, 1, 2025, 'Kötelező', 'Gazdasági és humán ismeretek', 3499);
INSERT INTO public.subject_major VALUES ('GKNB_INTM182', 54, 2, 2025, 'Kötelező', 'Természettudományi ismeretek', 3500);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM048', 54, 2, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3501);
INSERT INTO public.subject_major VALUES ('GKNB_INTM118', 54, 2, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3502);
INSERT INTO public.subject_major VALUES ('GKNB_INTM115', 54, 2, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3503);
INSERT INTO public.subject_major VALUES ('GKNB_INTM183', 54, 2, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3504);
INSERT INTO public.subject_major VALUES ('GKNB_INTM114', 54, 2, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3505);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM059', 54, 2, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3506);
INSERT INTO public.subject_major VALUES ('GKNB_INTM185', 54, 3, 2025, 'Kötelező', 'Természettudományi ismeretek', 3507);
INSERT INTO public.subject_major VALUES ('GKNB_INTM121', 54, 3, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3508);
INSERT INTO public.subject_major VALUES ('GKNB_INTM122', 54, 3, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3509);
INSERT INTO public.subject_major VALUES ('GKNB_INTM167', 54, 3, 2025, 'Kötelező', 'Természettudományi ismeretek', 3510);
INSERT INTO public.subject_major VALUES ('GKNB_INTM119', 54, 3, 2025, 'Kötelező', 'Gazdasági és humán ismeretek', 3511);
INSERT INTO public.subject_major VALUES ('GKNB_INTM184', 54, 3, 2025, 'Kötelező', 'Információs rendszerek ismeretek', 3512);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM100', 54, 3, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3513);
INSERT INTO public.subject_major VALUES ('GKNB_INTM186', 54, 4, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3514);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM087', 54, 4, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3515);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM045', 54, 4, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3516);
INSERT INTO public.subject_major VALUES ('GKNB_INTM124', 54, 4, 2025, 'Kötelező', 'Természettudományi ismeretek', 3517);
INSERT INTO public.subject_major VALUES ('GKNB_INTM025', 54, 4, 2025, 'Kötelező', 'Természettudományi ismeretek', 3518);
INSERT INTO public.subject_major VALUES ('GKNB_INTM126', 54, 5, 2025, 'Kötelező', 'Információs rendszerek ismeretek', 3519);
INSERT INTO public.subject_major VALUES ('GKNB_INTM007', 54, 5, 2025, 'Kötelező', 'Gazdasági és humán ismeretek', 3520);
INSERT INTO public.subject_major VALUES ('GKNB_INTM128', 54, 5, 2025, 'Kötelező', 'Információs rendszerek ismeretek', 3521);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM054', 54, 5, 2025, 'Kötelező', 'Gazdasági és humán ismeretek', 3522);
INSERT INTO public.subject_major VALUES ('GKNB_INTM087', 54, 5, 2025, 'Kötelező', 'Információs rendszerek ismeretek', 3523);
INSERT INTO public.subject_major VALUES ('GKNB_INTM187', 54, 6, 2025, 'Kötelező', 'Gazdasági és humán ismeretek', 3524);
INSERT INTO public.subject_major VALUES ('GKNB_INTM096', 54, 6, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3525);
INSERT INTO public.subject_major VALUES ('GKNB_TATM038', 54, 6, 2025, 'Kötelező', 'Információs rendszerek ismeretek', 3526);
INSERT INTO public.subject_major VALUES ('GKNB_INTM008', 54, 7, 2025, 'Kötelező', 'Számítástechnikai és programozási ismeretek', 3527);
INSERT INTO public.subject_major VALUES ('GKNB_INTM097', 54, 7, 2025, 'Kötelező', 'Gazdasági és humán ismeretek', 3528);
INSERT INTO public.subject_major VALUES ('GKNB_INTM160', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3529);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM055', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3530);
INSERT INTO public.subject_major VALUES ('GKNB_INTM138', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3531);
INSERT INTO public.subject_major VALUES ('MENB_BÉTM120', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3532);
INSERT INTO public.subject_major VALUES ('MENB_ÉTTM054', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3533);
INSERT INTO public.subject_major VALUES ('GKNB_INTM133', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3534);
INSERT INTO public.subject_major VALUES ('DKNB_APTM053', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3535);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM060', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3536);
INSERT INTO public.subject_major VALUES ('GKNB_INTM151', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3537);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM001', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3538);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM078', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3539);
INSERT INTO public.subject_major VALUES ('GKNB_KVTM029', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3540);
INSERT INTO public.subject_major VALUES ('GKNB_INTM157', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3541);
INSERT INTO public.subject_major VALUES ('GKNB_INTM135', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3542);
INSERT INTO public.subject_major VALUES ('GKNB_INTM052', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3543);
INSERT INTO public.subject_major VALUES ('AJNB_TVTM002', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3544);
INSERT INTO public.subject_major VALUES ('GKNB_INTM145', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3545);
INSERT INTO public.subject_major VALUES ('GKNB_INTM154', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3546);
INSERT INTO public.subject_major VALUES ('GKNB_INTM090', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3547);
INSERT INTO public.subject_major VALUES ('GKNB_INTM161', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3548);
INSERT INTO public.subject_major VALUES ('GKNB_INTM162', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3549);
INSERT INTO public.subject_major VALUES ('GKNB_INTM134', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3550);
INSERT INTO public.subject_major VALUES ('GKNB_INTM164', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3551);
INSERT INTO public.subject_major VALUES ('GKNB_INTM035', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3552);
INSERT INTO public.subject_major VALUES ('GKNB_INTM047', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3553);
INSERT INTO public.subject_major VALUES ('GKNB_INTM048', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3554);
INSERT INTO public.subject_major VALUES ('GKNB_INTM036', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3555);
INSERT INTO public.subject_major VALUES ('GKNB_INTM149', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3556);
INSERT INTO public.subject_major VALUES ('GKNB_INTM139', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3557);
INSERT INTO public.subject_major VALUES ('GKNB_INTM132', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3558);
INSERT INTO public.subject_major VALUES ('GKNB_INTM131', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3559);
INSERT INTO public.subject_major VALUES ('GKNB_INTM130', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3560);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM029', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3561);
INSERT INTO public.subject_major VALUES ('AJNB_JFTM028', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3562);
INSERT INTO public.subject_major VALUES ('GKNB_INTM147', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3563);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM030', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3564);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM007', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3565);
INSERT INTO public.subject_major VALUES ('MENB_ÁTTM061', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3566);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM031', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3567);
INSERT INTO public.subject_major VALUES ('GKNB_INTM152', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3568);
INSERT INTO public.subject_major VALUES ('GKNB_INTM137', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3569);
INSERT INTO public.subject_major VALUES ('GKNB_INTM148', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3570);
INSERT INTO public.subject_major VALUES ('GKNB_INTM150', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3571);
INSERT INTO public.subject_major VALUES ('GKNB_INTM153', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3572);
INSERT INTO public.subject_major VALUES ('GKNB_INTM117', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3573);
INSERT INTO public.subject_major VALUES ('GKNB_INTM159', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3574);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM014', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3575);
INSERT INTO public.subject_major VALUES ('GKNB_INTM136', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3576);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM080', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3577);
INSERT INTO public.subject_major VALUES ('GKNB_INTM142', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3578);
INSERT INTO public.subject_major VALUES ('GKNB_INTM041', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3579);
INSERT INTO public.subject_major VALUES ('GKNB_INTM141', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3580);
INSERT INTO public.subject_major VALUES ('GKNB_INTM140', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3581);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM032', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3582);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM077', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3583);
INSERT INTO public.subject_major VALUES ('GKNB_MSTM033', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3584);
INSERT INTO public.subject_major VALUES ('GKNB_INTM088', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3585);
INSERT INTO public.subject_major VALUES ('GKNB_AUTM007', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3586);
INSERT INTO public.subject_major VALUES ('GKNB_INTM144', 54, 1, 2025, 'Választható', 'Természettudományi ismeretek', 3587);
INSERT INTO public.subject_major VALUES ('GKNB_INTM089', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3588);
INSERT INTO public.subject_major VALUES ('GKNB_INTM143', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3589);
INSERT INTO public.subject_major VALUES ('GKNB_INTM146', 54, 1, 2025, 'Választható', 'Természettudományi ismeretek', 3590);
INSERT INTO public.subject_major VALUES ('GKNB_INTM113', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3591);
INSERT INTO public.subject_major VALUES ('GKNB_INTM049', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3592);
INSERT INTO public.subject_major VALUES ('GKNB_INTM050', 54, 1, 2025, 'Választható', 'Természettudományi ismeretek', 3593);
INSERT INTO public.subject_major VALUES ('GKNB_INTM051', 54, 1, 2025, 'Választható', 'Gazdasági és humán ismeretek', 3594);
INSERT INTO public.subject_major VALUES ('GKNB_INTM158', 54, 1, 2025, 'Választható', 'Természettudományi ismeretek', 3595);
INSERT INTO public.subject_major VALUES ('GKNB_INTM188', 54, 1, 2025, 'Választható', 'Számítástechnikai és programozási ismeretek', 3596);
INSERT INTO public.subject_major VALUES ('DKNB_JTTM056', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3597);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM030', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3598);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM018', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3599);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM019', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3600);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM027', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3601);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM021', 54, 1, 2025, 'Szabadon választható', 'Természettudományi ismeretek', 3602);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM022', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3603);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM023', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3604);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM023', 54, 1, 2025, 'Szabadon választható', 'Természettudományi ismeretek', 3605);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM004', 54, 1, 2025, 'Szabadon választható', 'Gazdasági és humán ismeretek', 3606);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM005', 54, 1, 2025, 'Szabadon választható', 'Információs rendszerek ismeretek', 3607);
INSERT INTO public.subject_major VALUES ('GKNB_TATM036', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3608);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM036', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3609);
INSERT INTO public.subject_major VALUES ('SZENB_MCKM001', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3610);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM100', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3611);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM024', 54, 1, 2025, 'Szabadon választható', 'Természettudományi ismeretek', 3612);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM002', 54, 1, 2025, 'Szabadon választható', 'Természettudományi ismeretek', 3613);
INSERT INTO public.subject_major VALUES ('SZENB_AWKM003', 54, 1, 2025, 'Szabadon választható', 'Információs rendszerek ismeretek', 3614);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM034', 54, 1, 2025, 'Szabadon választható', 'Gazdasági és humán ismeretek', 3615);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM041', 54, 1, 2025, 'Szabadon választható', 'Információs rendszerek ismeretek', 3616);
INSERT INTO public.subject_major VALUES ('GKNB_FKTM033', 54, 1, 2025, 'Szabadon választható', 'Gazdasági és humán ismeretek', 3617);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM248', 54, 1, 2025, 'Szabadon választható', 'Információs rendszerek ismeretek', 3618);
INSERT INTO public.subject_major VALUES ('KGNB_VKTM026', 54, 1, 2025, 'Szabadon választható', 'Gazdasági és humán ismeretek', 3619);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM197', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3620);
INSERT INTO public.subject_major VALUES ('KGNB_MMTM085', 54, 1, 2025, 'Szabadon választható', 'Információs rendszerek ismeretek', 3621);
INSERT INTO public.subject_major VALUES ('EKNB_KETM032', 54, 1, 2025, 'Szabadon választható', 'Számítástechnikai és programozási ismeretek', 3622);
INSERT INTO public.subject_major VALUES ('AKNB_BHTM164', 54, 1, 2025, 'Szabadon választható', 'Gazdasági és humán ismeretek', 3623);
INSERT INTO public.subject_major VALUES ('AKNB_SSTM186', 54, 1, 2025, 'Szabadon választható', 'Gazdasági és humán ismeretek', 3624);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM002', 54, 1, 2025, 'Testnevelés', 'Gazdasági és humán ismeretek', 3625);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM004', 54, 1, 2025, 'Testnevelés', 'Gazdasági és humán ismeretek', 3626);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM003', 54, 1, 2025, 'Testnevelés', 'Gazdasági és humán ismeretek', 3627);
INSERT INTO public.subject_major VALUES ('TKNB_TSKM001', 54, 1, 2025, 'Testnevelés', 'Gazdasági és humán ismeretek', 3628);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM015', 54, 1, 2025, 'Idegen nyelv', 'Gazdasági és humán ismeretek', 3629);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM027', 54, 1, 2025, 'Idegen nyelv', 'Gazdasági és humán ismeretek', 3630);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM014', 54, 1, 2025, 'Idegen nyelv', 'Gazdasági és humán ismeretek', 3631);
INSERT INTO public.subject_major VALUES ('KGNB_NOKM026', 54, 1, 2025, 'Idegen nyelv', 'Gazdasági és humán ismeretek', 3632);


--
-- TOC entry 4987 (class 0 OID 16440)
-- Dependencies: 220
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.subjects VALUES ('NGB_MA001_1', 'Analízis', 6);
INSERT INTO public.subjects VALUES ('NGB_AK001_1', 'Közgazdaságtan', 4);
INSERT INTO public.subjects VALUES ('NGB_IN001_1', 'Programozás I.', 5);
INSERT INTO public.subjects VALUES ('NGB_TA001_1', 'Villamosságtan', 4);
INSERT INTO public.subjects VALUES ('NGB_AU001_1', 'Digitális hálózatok', 6);
INSERT INTO public.subjects VALUES ('NGB_SZ001_1', 'Algoritmusok és adatstruktúrák', 3);
INSERT INTO public.subjects VALUES ('NGB_FI001_1', 'Fizika', 4);
INSERT INTO public.subjects VALUES ('NGB_JE001_1', 'Jogi ismeretek', 4);
INSERT INTO public.subjects VALUES ('NGB_MA001_2', 'Lineáris algebra és többváltozós függvények', 4);
INSERT INTO public.subjects VALUES ('NGB_IN001_2', 'Programozás II.', 4);
INSERT INTO public.subjects VALUES ('NGB_IN002_1', 'Szoftver-technológia I.', 5);
INSERT INTO public.subjects VALUES ('NGB_IN004_1', 'Számítógép-architektúrák', 4);
INSERT INTO public.subjects VALUES ('NGB_IN005_1', 'Operációs rendszerek', 6);
INSERT INTO public.subjects VALUES ('NGB_IN002_2', 'Szoftver-technológia II.', 5);
INSERT INTO public.subjects VALUES ('NGB_IN001_3', 'Programozás III.', 6);
INSERT INTO public.subjects VALUES ('NGB_TA002_1', 'Jelek és rendszerek', 4);
INSERT INTO public.subjects VALUES ('NGB_IN008_1', 'Adatbáziskezelés', 5);
INSERT INTO public.subjects VALUES ('NGB_MA007_1', 'Diszkrét matematika és kódelmélet', 5);
INSERT INTO public.subjects VALUES ('NGB_MA001_3', 'Valószínűségszámítás és matematikai statisztika', 5);
INSERT INTO public.subjects VALUES ('NGB_SV001_1', 'Vállalati gazdaságtan', 4);
INSERT INTO public.subjects VALUES ('NGB_IN010_1', 'Vállalati információs rendszerek I.', 3);
INSERT INTO public.subjects VALUES ('NGB_IN006_1', 'Számítógép-hálózatok', 6);
INSERT INTO public.subjects VALUES ('NGB_IN003_1', 'Szoftver-minőségbiztosítás', 4);
INSERT INTO public.subjects VALUES ('NGB_IN009_1', 'Szakértői rendszerek', 3);
INSERT INTO public.subjects VALUES ('NGB_IN007_1', 'Szabályozástechnika', 4);
INSERT INTO public.subjects VALUES ('NGB_MA006_1', 'Optimumszámítás', 4);
INSERT INTO public.subjects VALUES ('NGB_IN011_1', 'Számítógépes adatbiztonság', 3);
INSERT INTO public.subjects VALUES ('NGB_IN010_2', 'Vállalati információs rendszerek II.', 4);
INSERT INTO public.subjects VALUES ('NGB_KJ001_1', 'Üzleti és informatikai jog', 4);
INSERT INTO public.subjects VALUES ('NGB_IN012_1', 'Rendszerintegrálás', 4);
INSERT INTO public.subjects VALUES ('NGB_SV002_1', 'Termelésmenedzsment', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ005_1', 'Formális nyelvek és automaták', 4);
INSERT INTO public.subjects VALUES ('NGB_IN013_1', 'Vezetői információs rendszerek', 4);
INSERT INTO public.subjects VALUES ('NGB_TT006_1', 'A modern társadalmak', 2);
INSERT INTO public.subjects VALUES ('NGB_SZ016_1', 'Alkalmazásgenerátorok', 4);
INSERT INTO public.subjects VALUES ('NGB_IT003_2', 'Angol műszaki nyelv', 2);
INSERT INTO public.subjects VALUES ('NGB_IT003_1', 'Angol műszaki nyelv', 2);
INSERT INTO public.subjects VALUES ('NGB_KV037_1', 'Autóipari termékfejlesztés', 2);
INSERT INTO public.subjects VALUES ('NGB_TT007_1', 'Az információs társadalom', 2);
INSERT INTO public.subjects VALUES ('NGB_IN080_1', 'Banki Informatika', 3);
INSERT INTO public.subjects VALUES ('NGB_MT003_1', 'Didaktika és oktatásszervezés', 2);
INSERT INTO public.subjects VALUES ('NGB_AK004_1', 'EU-tanulmányok', 2);
INSERT INTO public.subjects VALUES ('NGB_FI005_1', 'Fizikatörténet', 2);
INSERT INTO public.subjects VALUES ('NGB_ET005_3', 'Geoinformatika', 2);
INSERT INTO public.subjects VALUES ('NGB_TT001_1', 'Globalizáció és magyar társadalom I.', 2);
INSERT INTO public.subjects VALUES ('NGB_TT001_2', 'Globalizáció és magyar társadalom II.', 2);
INSERT INTO public.subjects VALUES ('NGB_IN043_1', 'Informatikatörténet', 2);
INSERT INTO public.subjects VALUES ('NGB_TA011_1', 'Intelligens rendszerek', 4);
INSERT INTO public.subjects VALUES ('NGB_IN042_1', 'Irodaautomatizálási rendszerek', 4);
INSERT INTO public.subjects VALUES ('NGB_SV003_1', 'Kommunikációs ismeretek', 2);
INSERT INTO public.subjects VALUES ('NGB_MT026_1', 'Konfliktuskezelés alapjai', 2);
INSERT INTO public.subjects VALUES ('NGB_IT023_1', 'Középfokú nyelvvizsgára felkészítő', 2);
INSERT INTO public.subjects VALUES ('NGB_IT023_2', 'Középfokú nyelvvizsgára felkészítő', 2);
INSERT INTO public.subjects VALUES ('NGB_SV004_1', 'Marketing', 2);
INSERT INTO public.subjects VALUES ('NGB_AG019_1', 'Megelőző katasztrófavédelem', 2);
INSERT INTO public.subjects VALUES ('NGB_SM075_1', 'Mindennapi szociális ismeretek', 2);
INSERT INTO public.subjects VALUES ('NGB_SE015_1', 'Mérnöki képességfejlesztés', 3);
INSERT INTO public.subjects VALUES ('NGB_AG012_1', 'Műszaki dokumentáció és szabványismeret', 4);
INSERT INTO public.subjects VALUES ('NGB_MT001_2', 'Neveléstörténet és neveléstan', 2);
INSERT INTO public.subjects VALUES ('NGB_MT001_1', 'Neveléstörténet és neveléstan', 2);
INSERT INTO public.subjects VALUES ('NGB_MA008_1', 'Numerikus módszerek', 4);
INSERT INTO public.subjects VALUES ('NGB_TT003_1', 'Politológia', 2);
INSERT INTO public.subjects VALUES ('NGB_IN041_1', 'Prezentációs grafika', 4);
INSERT INTO public.subjects VALUES ('NGB_MT002_2', 'Pszichológia és személyiségfejlesztés', 4);
INSERT INTO public.subjects VALUES ('NGB_MT002_1', 'Pszichológia és személyiségfejlesztés', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ015_1', 'Speciális programfejlesztő eszközök', 4);
INSERT INTO public.subjects VALUES ('NGB_MT006_1', 'Szakmai gyak. oktatásának módszertana', 4);
INSERT INTO public.subjects VALUES ('NGB_AU016_1', 'Szimuláció módszertana és alkalmazása I.', 3);
INSERT INTO public.subjects VALUES ('NGB_AU016_2', 'Szimuláció módszertana és alkalmazása II.', 3);
INSERT INTO public.subjects VALUES ('NGB_TT005_1', 'Szociológia', 2);
INSERT INTO public.subjects VALUES ('NGB_SM001_1', 'Szociális gyakorlat', 2);
INSERT INTO public.subjects VALUES ('NGB_SM001_2', 'Szociális gyakorlatot követő szeminárium', 2);
INSERT INTO public.subjects VALUES ('NGB_MT005_1', 'Tanári kommunikáció', 2);
INSERT INTO public.subjects VALUES ('NGB_SV050_1', 'Tudatos karriertervezés, munkaerőpiaci ismeretek', 2);
INSERT INTO public.subjects VALUES ('NGB_FI012_1', 'Tudomány népszerűsítés I.', 2);
INSERT INTO public.subjects VALUES ('NGB_FI012_2', 'Tudomány népszerűsítés II.', 2);
INSERT INTO public.subjects VALUES ('NGB_AG008_1', 'Tűz- és Munkavédelem', 2);
INSERT INTO public.subjects VALUES ('NGB_SM044_1', 'Önkéntes segítő gyakorlat', 4);
INSERT INTO public.subjects VALUES ('NGB_KO042_1', 'Ötletből üzlet (Bevezetés az innováció menedzsmentbe)', 2);
INSERT INTO public.subjects VALUES ('NGB_KA001_1', 'Üzleti jog és iparjogvédelem', 2);
INSERT INTO public.subjects VALUES ('NGB_IN084_1', 'Adatintenzív adatbázis-kezelő alkalmazások', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ011_1', 'Algoritmusok tervezése', 4);
INSERT INTO public.subjects VALUES ('NGB_IN022_1', 'Beágyazott szoftverek', 4);
INSERT INTO public.subjects VALUES ('NGB_IN027_1', 'CASE technológia', 4);
INSERT INTO public.subjects VALUES ('NGB_IN021_1', 'Döntéselőkészítés', 4);
INSERT INTO public.subjects VALUES ('NGB_IN028_1', 'Döntéselőkészítő rendszerek', 4);
INSERT INTO public.subjects VALUES ('NGB_IN047_1', 'Emberközpontú infokommunikáció', 4);
INSERT INTO public.subjects VALUES ('NGB_IN037_1', 'Grafikus fejlesztés dotNET-ben', 4);
INSERT INTO public.subjects VALUES ('NGB_IN026_1', 'Grafikus modellezés', 4);
INSERT INTO public.subjects VALUES ('NGB_IN044_1', 'Gépi tanulás', 4);
INSERT INTO public.subjects VALUES ('NGB_IN083_1', 'Humanoid informatika', 4);
INSERT INTO public.subjects VALUES ('NGB_IN046_1', 'Humanoid robotok irányítása', 4);
INSERT INTO public.subjects VALUES ('NGB_IN087_1', 'IT a járműgyártásban', 4);
INSERT INTO public.subjects VALUES ('NGB_IN045_1', 'Információ modellezés', 4);
INSERT INTO public.subjects VALUES ('NGB_MA014_1', 'Interaktív 3D környezetek', 4);
INSERT INTO public.subjects VALUES ('NGB_MA020_1', 'Interaktív multimédia alkalmazások', 4);
INSERT INTO public.subjects VALUES ('NGB_IN035_1', 'Internet alkalmazások', 4);
INSERT INTO public.subjects VALUES ('NGB_IN082_1', 'Kiterjesztett kollaboráció a jövő Internetén', 4);
INSERT INTO public.subjects VALUES ('NGB_IN085_1', 'Mesterséges intelligencia', 4);
INSERT INTO public.subjects VALUES ('NGB_AU017_1', 'Minőség és megbízhatóság', 4);
INSERT INTO public.subjects VALUES ('NGB_IN025_1', 'Multimédia', 4);
INSERT INTO public.subjects VALUES ('NGB_IN030_1', 'Objektumorientált technológia', 4);
INSERT INTO public.subjects VALUES ('NGB_IN038_1', 'Portálfejlesztés dotNET-ben', 4);
INSERT INTO public.subjects VALUES ('NGB_IN034_1', 'Programozás C++ nyelven', 4);
INSERT INTO public.subjects VALUES ('NGB_IN036_1', 'Programozás dotNET-ben', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ012_1', 'Programozáselmélet', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ014_1', 'Programozási nyelvek és paradigmák', 4);
INSERT INTO public.subjects VALUES ('NGB_IN033_1', 'Projektvezetés', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ007_1', 'Párhuzamos programozás I.', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ007_2', 'Párhuzamos programozás II.', 4);
INSERT INTO public.subjects VALUES ('NGB_AU018_1', 'Reaktív rendszerek fejlesztése', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ013_1', 'Statisztikai alkalmazások', 4);
INSERT INTO public.subjects VALUES ('NGB_IN086_1', 'Szemantikus technológiák', 4);
INSERT INTO public.subjects VALUES ('NGB_IN040_1', 'Szimulációs technikák', 4);
INSERT INTO public.subjects VALUES ('NGB_IN031_1', 'Számítógépek üzemeltetése', 4);
INSERT INTO public.subjects VALUES ('NGB_IN024_1', 'Számítógépes grafika', 4);
INSERT INTO public.subjects VALUES ('NGB_IN039_1', 'Tudományos szoftverek tervezése', 4);
INSERT INTO public.subjects VALUES ('NGB_IN032_1', 'UML-alapú fejlesztés I.', 4);
INSERT INTO public.subjects VALUES ('NGB_IN032_2', 'UML-alapú fejlesztés II.', 4);
INSERT INTO public.subjects VALUES ('NGB_IN029_1', 'Vizuális adatbáziskezelés I.', 4);
INSERT INTO public.subjects VALUES ('NGB_IN029_2', 'Vizuális adatbáziskezelés II.', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ009_1', 'Vizuális alkalmazásfejlesztés I', 4);
INSERT INTO public.subjects VALUES ('NGB_SZ009_2', 'Vizuális alkalmazásfejlesztés II.', 4);
INSERT INTO public.subjects VALUES ('NGB_IN023_1', 'Web-technológia I.', 4);
INSERT INTO public.subjects VALUES ('NGB_IN023_2', 'Web-technológia II.', 4);
INSERT INTO public.subjects VALUES ('NGB_AU091_1', 'Diplomatervezés I.', 5);
INSERT INTO public.subjects VALUES ('NGB_IN091_1', 'Diplomatervezés I.', 5);
INSERT INTO public.subjects VALUES ('NGB_TA091_1', 'Diplomatervezés I.', 5);
INSERT INTO public.subjects VALUES ('NGB_FI091_1', 'Diplomatervezés I.', 5);
INSERT INTO public.subjects VALUES ('NGB_MA091_1', 'Diplomatervezés I.', 5);
INSERT INTO public.subjects VALUES ('NGB_IN092_1', 'Szakdolgozatkészítés I.', 7);
INSERT INTO public.subjects VALUES ('NGB_MA091_2', 'Diplomatervezés II.', 10);
INSERT INTO public.subjects VALUES ('NGB_TA091_2', 'Diplomatervezés II.', 10);
INSERT INTO public.subjects VALUES ('NGB_AU091_2', 'Diplomatervezés II.', 10);
INSERT INTO public.subjects VALUES ('NGB_FI091_2', 'Diplomatervezés II.', 10);
INSERT INTO public.subjects VALUES ('NGB_IN091_2', 'Diplomatervezés II.', 10);
INSERT INTO public.subjects VALUES ('NGB_IN092_2', 'Szakdolgozatkészítés II.', 8);
INSERT INTO public.subjects VALUES ('NGB_IT024_1', 'BME műszaki nyelv I.', 0);
INSERT INTO public.subjects VALUES ('NGB_IT024_2', 'BME műszaki nyelv II.', 0);
INSERT INTO public.subjects VALUES ('NGB_IT039_1', 'Járműipari szaknyelv 1.', 0);
INSERT INTO public.subjects VALUES ('NGB_IT039_2', 'Járműipari szaknyelv 2.', 0);
INSERT INTO public.subjects VALUES ('NGB_IT039_3', 'Járműipari szaknyelv 3.', 0);
INSERT INTO public.subjects VALUES ('NGB_IT039_4', 'Járműipari szaknyelv 4.', 0);
INSERT INTO public.subjects VALUES ('NGB_IT001_2', 'Középfokú nyelvvizsgára felkészítő', 0);
INSERT INTO public.subjects VALUES ('NGB_IT001_1', 'Középfokú nyelvvizsgára felkészítő', 0);
INSERT INTO public.subjects VALUES ('NGB_IT034_1', 'Lexinfo-Informatikai szaknyelv I.', 0);
INSERT INTO public.subjects VALUES ('NGB_IT034_2', 'Lexinfo-Informatikai szaknyelv II.', 0);
INSERT INTO public.subjects VALUES ('N_TS03', 'Aerob állóképesség', 0);
INSERT INTO public.subjects VALUES ('N_TS02', 'Erőgyakorlat', 0);
INSERT INTO public.subjects VALUES ('N_TS04', 'Sportági ismeretek', 0);
INSERT INTO public.subjects VALUES ('NGB_TS001_2', 'Testnevelés / Erő', 0);
INSERT INTO public.subjects VALUES ('NGB_TS001_4', 'Testnevelés / Sportági ismeret', 0);
INSERT INTO public.subjects VALUES ('NGB_TS001_3', 'Testnevelés / Állóképesség', 0);
INSERT INTO public.subjects VALUES ('NGB_TS001_1', 'Testnevelés / Úszás', 0);
INSERT INTO public.subjects VALUES ('N_TS01', 'Úszás', 0);
INSERT INTO public.subjects VALUES ('NGB_IN014_1', 'Bevezetés az információtechnológiába', 3);
INSERT INTO public.subjects VALUES ('NGB_MA002_2', 'Matematika (Lineáris algebra és többváltozós függvények)', 4);
INSERT INTO public.subjects VALUES ('NGB_IN015_1', 'IT-szolgáltatások', 3);
INSERT INTO public.subjects VALUES ('NGB_SZ017_1', 'Számítástudomány', 4);
INSERT INTO public.subjects VALUES ('NGB_IN088_1', 'Tesztvezérelt fejlesztési módszerek', 4);
INSERT INTO public.subjects VALUES ('NGB_IN016_1', 'Üzleti folyamatok modellezése I.', 4);
INSERT INTO public.subjects VALUES ('NGB_IN016_2', 'Üzleti folyamatok modellezése II.', 4);
INSERT INTO public.subjects VALUES ('GKNB_MSTM016', 'Algoritmusok és adatstruktúrák', 6);
INSERT INTO public.subjects VALUES ('KGNB_NETM042', 'Közgazdaságtan', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM012', 'Számítógépek működése', 8);
INSERT INTO public.subjects VALUES ('GKNB_MSTM014', 'Diszkrét matematika', 6);
INSERT INTO public.subjects VALUES ('GKNB_MSTM008', 'Matematika 2.', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM021', 'Programozás', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM022', 'Projektmunka és szoftvertechnológia', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM001', 'Rendszer és irányítás', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM018', 'Számítógép-hálózatok', 6);
INSERT INTO public.subjects VALUES ('GKNB_MSTM100', 'Matematika 3 (valószínűségszámítás)', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM186', 'Adatbázis-kezelés projektalapon', 4);
INSERT INTO public.subjects VALUES ('GKNB_MSTM087', 'Bevezetés az adatelemzésbe', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM024', 'OO programozás és adatbázis-kezelés', 7);
INSERT INTO public.subjects VALUES ('GKNB_MSTM011', 'Matematika 3.', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM020', 'Mikroelektromechanikai rendszerek', 3);
INSERT INTO public.subjects VALUES ('GKNB_FKTM007', 'Fizika informatikusoknak', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM003', 'Kiberfizikai rendszerek', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM002', 'Mesterséges intelligencia', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM004', 'Projektmunka 1.', 6);
INSERT INTO public.subjects VALUES ('KGNB_GETM004', 'Statisztika', 2);
INSERT INTO public.subjects VALUES ('GKNB_FKTM045', 'Fizika informatikusoknak', 4);
INSERT INTO public.subjects VALUES ('DKNB_KATM030', 'Üzleti és informatikai jog', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM019', 'Modellezés és optimalizálás a gyakorlatban', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM005', 'Projektmunka 2.', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM006', 'Modern szoftverfejlesztési eszközök', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM009', 'Korszerű hálózati alkalmazások', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM124', 'Mesterséges intelligencia', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM025', 'Rendszerüzemeltetés és biztonság', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM126', 'Projektmunka', 6);
INSERT INTO public.subjects VALUES ('EKNB_KOTM110', 'A vasút világa', 3);
INSERT INTO public.subjects VALUES ('MKNB_DSTM006', 'Bevezetés a kommunikáció- és reklámtörténetbe', 2);
INSERT INTO public.subjects VALUES ('GKNB_INTM007', 'Vállalati információs rendszerek', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM128', 'Modellezés és optimalizálás a gyakorlatban', 5);
INSERT INTO public.subjects VALUES ('DKNB_JTTM054', 'Modern információtechnológia jogi kérdései', 4);
INSERT INTO public.subjects VALUES ('EKNB_KETM029', 'CAD alkalmazások 1.', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM087', 'Ipar 4.0 technológiák', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM187', 'Modern szoftverfejlesztési eszközök projektalapon', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM096', 'Szakdolgozati konzultáció I.', 7);
INSERT INTO public.subjects VALUES ('KGNB_NOKM045', 'Exchange Course 6.', 3);
INSERT INTO public.subjects VALUES ('GKNB_FKTM029', 'Fizikai alapmérések', 2);
INSERT INTO public.subjects VALUES ('GKNB_TATM038', 'Virtualizációs technológiák', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM008', 'IT-szolgáltatások', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM097', 'Szakdolgozati konzultáció II.', 8);
INSERT INTO public.subjects VALUES ('GKNB_INTM160', '3D modellezés Blenderben', 5);
INSERT INTO public.subjects VALUES ('DKNB_JTTM055', 'A kiberbiztonság hazai és szövetségi kereteinek mérnöki relevanciái', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM138', 'Adatbázis-kezelés Oracle-ben', 5);
INSERT INTO public.subjects VALUES ('MENB_BÉTM120', 'Adatelemzés a mezőgazdaságban és élelmiszeriparban', 4);
INSERT INTO public.subjects VALUES ('MENB_ÉTTM054', 'Adatgyűjtés a mezőgazdaságban és élelmiszeriparban', 5);
INSERT INTO public.subjects VALUES ('AKNB_TTTM202', 'Mérnöki képességfejlesztés', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM133', 'Adattárolás és adatkezelés Java nyelven', 5);
INSERT INTO public.subjects VALUES ('MKNB_DSTM003', 'Prezentációs technikák', 2);
INSERT INTO public.subjects VALUES ('DKNB_APTM053', 'Adatvédelmi jog mérnöki szemmel', 3);
INSERT INTO public.subjects VALUES ('MENB_ÁTTM060', 'Agrárinformatika alapjai', 5);
INSERT INTO public.subjects VALUES ('KGNB_VKTM017', 'Startup vállalkozás I.', 4);
INSERT INTO public.subjects VALUES ('KGNB_VKTM024', 'Startup vállalkozás II.', 4);
INSERT INTO public.subjects VALUES ('GKNB_FKTM025', 'Tudomány népszerűsítés I.', 2);
INSERT INTO public.subjects VALUES ('GKNB_FKTM026', 'Tudomány népszerűsítés II.', 2);
INSERT INTO public.subjects VALUES ('GKNB_INTM151', 'Ajánlórendszerek alapjai', 5);
INSERT INTO public.subjects VALUES ('GKNB_AUTM001', 'Automatikai építőelemek', 5);
INSERT INTO public.subjects VALUES ('MKNB_DSTM004', 'Önarculat', 2);
INSERT INTO public.subjects VALUES ('GKNB_AUTM078', 'Autonóm járművek és robotok programozása', 5);
INSERT INTO public.subjects VALUES ('DKNB_KATM031', 'Üzleti jog és iparjogvédelem', 2);
INSERT INTO public.subjects VALUES ('GKNB_INTM010', 'Adatbázisok', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM044', 'Adatintenzív adatbázis-kezelő alkalmazások', 5);
INSERT INTO public.subjects VALUES ('GKNB_KVTM029', 'Autóipari termékfejlesztés', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM157', 'BA kompetenciák és módszerek', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM135', 'Backend fejlesztés Java környezetben', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM052', 'Banki Informatika', 3);
INSERT INTO public.subjects VALUES ('AJNB_TVTM002', 'Bevezetés a beágyazott rendszerekbe', 2);
INSERT INTO public.subjects VALUES ('GKNB_INTM053', 'Beágyazott rendszerek (IoT)', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM145', 'Bevezetés a kiterjesztett és virtuális valóságba', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM054', 'C#', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM026', 'C++', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM027', 'Emberközpontú infokommunikáció', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM028', 'Felhasználói interfészek tervezése (Sw ergonómia)', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM029', 'Funkcionális programozás', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM030', 'Gyakorlatorientált sw-technológia', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM038', 'Gépi látás', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM154', 'Beágyazott rendszerek (IoT)', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM031', 'Humanoid informatika', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM032', 'Humanoid robotok irányítása', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM090', 'Blokklánc rendszerek', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM161', 'CAx technológiák 1.', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM162', 'CAx technológiák 2.', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM134', 'Desktop alkalmazásfejlesztés Java nyelven', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM033', 'Információ modellezés', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM034', 'Interaktív multimédia alkalmazások', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM037', 'Java programozás', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM164', 'Gépi látás', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM035', 'IT a járműgyártásban', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM039', 'Kiterjesztett kollaboráció a jövő Internetén', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM047', 'IT-beruházások megtérülése I', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM048', 'IT-beruházások megtérülése II', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM036', 'IT-változásmenedzsment', 5);
INSERT INTO public.subjects VALUES ('GKNB_MSTM028', 'Linux ismeretek', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM149', 'Intelligens irányítórendszerek', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM040', 'Mobilalkalmazás-fejlesztés', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM139', 'Intelligens robotok szimulációja és verifikációja', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM132', 'Java nyelvi alapok', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM042', 'Portálfejlesztés .NET-ben', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM043', 'Programozás.Net-ben', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM131', 'Javascript alapú backend fejlesztés', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM130', 'Javascript alapú frontend fejlesztés', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM011', 'Rendszerfejlesztés', 6);
INSERT INTO public.subjects VALUES ('AJNB_JFTM029', 'Járműdinamika informatikusoknak', 4);
INSERT INTO public.subjects VALUES ('AJNB_JFTM028', 'Járműfejlesztés alapjai informatikusoknak', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM147', 'Játékfejlesztés', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM045', 'Számítógépes adatbiztonság', 5);
INSERT INTO public.subjects VALUES ('GKNB_MSTM030', 'Kombinatorikus optimalizálás', 5);
INSERT INTO public.subjects VALUES ('KGNB_VKTM007', 'Kommunikációs ismeretek', 4);
INSERT INTO public.subjects VALUES ('MENB_ÁTTM061', 'Komplex informatikai rendszerek a mezőgazdaságban és élelmiszeriparban', 4);
INSERT INTO public.subjects VALUES ('GKNB_MSTM031', 'Komponens alapú programozás', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM152', 'Képfeldolgozás', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM013', 'Üzleti célú rendszerek', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM046', 'Üzleti célú rendszerek', 6);
INSERT INTO public.subjects VALUES ('KGNB_NOKM079', 'Műszaki szakmai idegen nyelv I.BSc mérnökök részére', 2);
INSERT INTO public.subjects VALUES ('KGNB_NOKM080', 'Műszaki szakmai idegen nyelv II.BSc mérnökök részére', 2);
INSERT INTO public.subjects VALUES ('GKNB_INTM137', 'Laravel-re épülő keretrendszerek', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM148', 'Mesterséges intelligencia haladó', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM150', 'Mesterséges intelligencia tervezése', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM153', 'Metaheurisztikus algoritmusok', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM085', 'OO programozás', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM086', 'Adatbázis-kezelés', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM117', 'Mikroelektromechanikai rendszerek', 3);
INSERT INTO public.subjects VALUES ('MENB_VKTM002', 'Agrometeorológia alapjai', 4);
INSERT INTO public.subjects VALUES ('MENB_NTTM046', 'Biotermékektől a géntechnológiáig', 4);
INSERT INTO public.subjects VALUES ('MENB_NTTM042', 'Földműveléstan', 4);
INSERT INTO public.subjects VALUES ('MENB_NTTM014', 'Kertészet alapjai', 4);
INSERT INTO public.subjects VALUES ('MENB_AVTM010', 'Mezőgazdasági alapismeretek', 4);
INSERT INTO public.subjects VALUES ('MENB_ÉTTM020', 'Minőségbiztosítás alapjai', 3);
INSERT INTO public.subjects VALUES ('MENB_NTTM035', 'Növényvédelem technológiai alapjai', 4);
INSERT INTO public.subjects VALUES ('MENB_NTTM051', 'Precíziós növénytermesztési gazdálkodás', 4);
INSERT INTO public.subjects VALUES ('MENB_ÁTTM054', 'Precíziós állattenyésztés', 4);
INSERT INTO public.subjects VALUES ('MENB_ÁTTM017', 'Takarmányozástan alapjai', 4);
INSERT INTO public.subjects VALUES ('MENB_BÉTM011', 'Térinformatika', 4);
INSERT INTO public.subjects VALUES ('MENB_VKTM026', 'Vízgazdálkodás alapjai', 4);
INSERT INTO public.subjects VALUES ('MENB_NTTM038', 'Általános növénytermesztéstan', 4);
INSERT INTO public.subjects VALUES ('MENB_ÁTTM033', 'Általános állattenyésztéstan', 4);
INSERT INTO public.subjects VALUES ('MENB_ÉTTM007', 'Élelmiszerismeret', 4);
INSERT INTO public.subjects VALUES ('KGNB_NOKM012', 'Gazdasági szakmai nyelvvizsgára felkészítő I.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM013', 'Gazdasági szakmai nyelvvizsgára felkészítő II.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM017', 'Idegenforgalmi szakmai felsőfokú nyelvvizsga felkészítő I.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM031', 'Idegenforgalmi szakmai felsőfokú nyelvvizsga felkészítő II.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM016', 'Idegenforgalmi szakmai középfokú nyelvvizsga felkészítő I.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM030', 'Idegenforgalmi szakmai középfokú nyelvvizsga felkészítő II.', 0);
INSERT INTO public.subjects VALUES ('GKNB_INTM159', 'Mikroelektromechanikai rendszerek haladó', 6);
INSERT INTO public.subjects VALUES ('GKNB_AUTM014', 'Mikrokontroller programozás', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM136', 'Mobilalkalmazás fejlesztés', 3);
INSERT INTO public.subjects VALUES ('GKNB_MSTM080', 'Nagyteljesítményű számítási rendszerek', 5);
INSERT INTO public.subjects VALUES ('KGNB_NOKM019', 'TELC általános felsőfokú nyelvvizsga felkészítő I.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM029', 'TELC általános felsőfokú nyelvvizsga felkészítő II.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM018', 'TELC általános középfokú nyelvvizsga felkészítő I.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM028', 'TELC általános középfokú nyelvvizsga felkészítő II.', 0);
INSERT INTO public.subjects VALUES ('GKNB_INTM142', 'Natív alkalmazásfejlesztés .NET-ben', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM041', 'PHP', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM141', 'Portálfejlesztés .NET-ben', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM116', 'Rendszer és irányítási alapok', 3);
INSERT INTO public.subjects VALUES ('GKNB_MSTM065', 'Algoritmusok és adatstruktúrák', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM120', 'Unix, Windows operációs rendszerek', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM123', 'Adatbázis-kezelés 1.', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM125', 'Adatbázis-kezelés 2.', 4);
INSERT INTO public.subjects VALUES ('GKNB_AUTM077', 'Digitális logikai rendszerek és kapcsolások informatikusoknak', 3);
INSERT INTO public.subjects VALUES ('GKNB_MSTM064', 'Diszkrét Matematika', 5);
INSERT INTO public.subjects VALUES ('GKNB_MSTM001', 'Matematika 1.', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM112', 'Python alapok informatikusoknak', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM110', 'Számítógép architektúrák', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM111', 'Digitális kompetenciák, önálló képzési stratégia', 2);
INSERT INTO public.subjects VALUES ('GKNB_INTM129', 'Modern szoftverfejlesztési eszközök', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM182', 'Rendszer és domain modellezés', 4);
INSERT INTO public.subjects VALUES ('KGNB_MMTM048', 'Vállalatgazdaságtan', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM118', 'Szoftvertechnológia 1.', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM115', 'Operációs rendszerek', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM183', 'Projektmenedzsment alapjai', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM114', 'Programozás', 5);
INSERT INTO public.subjects VALUES ('GKNB_MSTM059', 'Matematika 2.', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM185', 'Unix operációs rendszerek', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM121', 'Számítógép-hálózatok', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM122', 'Szoftvertechnológia 2.', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM167', 'Szakmai gyakorlat', 0);
INSERT INTO public.subjects VALUES ('GKNB_INTM119', 'OO Programozás', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM184', 'Adatbázis-kezelés alapjai', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM140', 'Programozás .NET-ben', 5);
INSERT INTO public.subjects VALUES ('GKNB_MSTM032', 'Python programozás', 5);
INSERT INTO public.subjects VALUES ('GKNB_MSTM077', 'Párhuzamos programozás', 4);
INSERT INTO public.subjects VALUES ('GKNB_MSTM033', 'Robot programozás', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM155', 'Domain modellezés a gyakorlatban', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM088', 'SAP alkalmazói ismeretek', 4);
INSERT INTO public.subjects VALUES ('GKNB_AUTM007', 'Szabályozástechnika', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM144', 'Szoftver minőségbiztosítás és tesztelés', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM089', 'Tartalomkezelő rendszerek', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM143', 'Tesztelés gyakorlata', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM146', 'Unity alapú VR fejlesztés haladó', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM113', 'Unity alapú VR fejlesztések', 4);
INSERT INTO public.subjects VALUES ('GKNB_INTM049', 'WEB technológia', 6);
INSERT INTO public.subjects VALUES ('GKNB_INTM050', 'Ágazati információrendszerek I.', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM051', 'Ágazati információrendszerek II.', 3);
INSERT INTO public.subjects VALUES ('GKNB_INTM158', 'Üzleti folyamatmodellezés és technikák', 5);
INSERT INTO public.subjects VALUES ('GKNB_INTM188', 'Üzleti intelligencia projektalapon', 4);
INSERT INTO public.subjects VALUES ('DKNB_JTTM056', 'Az iratkezelés jogi és biztonsági vonatkozásai', 3);
INSERT INTO public.subjects VALUES ('GKNB_FKTM030', 'Bevezetés a nukleáris technikába', 2);
INSERT INTO public.subjects VALUES ('KGNB_VKTM018', 'Bevezetés az innováció- és kutatáskommunikációba I.', 5);
INSERT INTO public.subjects VALUES ('KGNB_VKTM019', 'Bevezetés az innováció- és kutatáskommunikációba II.', 5);
INSERT INTO public.subjects VALUES ('GKNB_FKTM027', 'Diagnosztikai képalkotó eljárások', 2);
INSERT INTO public.subjects VALUES ('KGNB_NOKM021', 'Exchange Course 1.', 2);
INSERT INTO public.subjects VALUES ('GKNB_INTM156', 'Projektszervezet és menedzsment', 5);
INSERT INTO public.subjects VALUES ('KGNB_NOKM022', 'Exchange Course 2.', 3);
INSERT INTO public.subjects VALUES ('KGNB_NOKM023', 'Exchange Course 3.', 4);
INSERT INTO public.subjects VALUES ('GKNB_FKTM023', 'Fizikatörténet', 4);
INSERT INTO public.subjects VALUES ('SZENB_AWKM004', 'Gyakorlatorientált hallgatói projektrészvétel és szerepvállalás 1.', 2);
INSERT INTO public.subjects VALUES ('GKNB_INTM163', 'Üzleti intelligencia', 5);
INSERT INTO public.subjects VALUES ('SZENB_AWKM005', 'Gyakorlatorientált hallgatói projektrészvétel és szerepvállalás 2.', 2);
INSERT INTO public.subjects VALUES ('GKNB_TATM036', 'Hang-és képtechnika alapjai', 5);
INSERT INTO public.subjects VALUES ('GKNB_FKTM036', 'Honvédelmi alapismeretek', 2);
INSERT INTO public.subjects VALUES ('SZENB_MCKM001', 'Junior Leadership', 4);
INSERT INTO public.subjects VALUES ('KGNB_NOKM100', 'KULT- kredit', 2);
INSERT INTO public.subjects VALUES ('GKNB_FKTM024', 'Komplex energetikai rendszerek', 4);
INSERT INTO public.subjects VALUES ('SZENB_AWKM002', 'Készségfejlesztés II.', 4);
INSERT INTO public.subjects VALUES ('SZENB_AWKM003', 'Készségfejlesztés III.', 4);
INSERT INTO public.subjects VALUES ('GKNB_FKTM034', 'Környezetkémiai alapismeretek', 2);
INSERT INTO public.subjects VALUES ('KGNB_MMTM041', 'Munkaerőpiaci ismeretek', 4);
INSERT INTO public.subjects VALUES ('GKNB_FKTM033', 'Műszaki kémiai laboratóriumi gyakorlatok', 2);
INSERT INTO public.subjects VALUES ('KGNB_MMTM248', 'Startup I.', 2);
INSERT INTO public.subjects VALUES ('KGNB_VKTM026', 'Startup II.', 4);
INSERT INTO public.subjects VALUES ('AKNB_SSTM197', 'Színházi alkotás és előadástechnika', 2);
INSERT INTO public.subjects VALUES ('KGNB_MMTM085', 'Termelésmenedzsment', 4);
INSERT INTO public.subjects VALUES ('EKNB_KETM032', 'Térinformatika', 4);
INSERT INTO public.subjects VALUES ('AKNB_BHTM164', 'Értékek és kihívások', 3);
INSERT INTO public.subjects VALUES ('AKNB_SSTM186', 'Önkéntes segítő gyakorlat', 2);
INSERT INTO public.subjects VALUES ('TKNB_TSKM002', 'Testnevelés / Erő', 2);
INSERT INTO public.subjects VALUES ('TKNB_TSKM004', 'Testnevelés / Sportági ismeret', 2);
INSERT INTO public.subjects VALUES ('TKNB_TSKM003', 'Testnevelés / Állóképesség', 2);
INSERT INTO public.subjects VALUES ('TKNB_TSKM001', 'Testnevelés / Úszás', 2);
INSERT INTO public.subjects VALUES ('KGNB_NOKM015', 'ORIGO általános felsőfokú nyelvvizsga felkészítő I.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM027', 'ORIGO általános felsőfokú nyelvvizsga felkészítő II.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM014', 'ORIGO általános középfokú nyelvvizsga felkészítő I.', 0);
INSERT INTO public.subjects VALUES ('KGNB_NOKM026', 'ORIGO általános középfokú nyelvvizsga felkészítő II.', 0);


--
-- TOC entry 4995 (class 0 OID 16575)
-- Dependencies: 228
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tokens VALUES (1, '6fdb1119-f5ca-4d31-a7cc-baa7cf0417df', 'password_reset', '2026-04-29 20:37:53.785626', 1);


--
-- TOC entry 4997 (class 0 OID 17016)
-- Dependencies: 230
-- Data for Name: user_saves; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.user_saves VALUES (58, 1, 3, 'hehe', '{"userData": {"field1": "asf", "field2": "sf", "field3": "afs"}, "acceptedSubjects": [], "requiredSubjects": [{"id": 1053, "code": "GKNB_MSTM065", "name": "Algoritmusok és adatstruktúrák", "type": "Számítástechnikai és programozási ismeretek", "credit": 5, "category": "Kötelező", "syllabus_year": 2023, "recommended_semester": 1}]}', '2026-05-01 18:11:26.806566', 2);
INSERT INTO public.user_saves VALUES (15, 1, 2, 'igen', '{"userData": {"field1": "asf", "field2": "asf", "field3": "saf"}, "acceptedSubjects": [], "requiredSubjects": [{"id": 358, "code": "NGB_MA001_2", "name": "Lineáris algebra és többváltozós függvények", "type": "Természettudományi ismeretek", "credit": 4, "category": "Kötelező", "syllabus_year": 2010, "recommended_semester": 2}]}', '2026-04-24 11:52:16.724031', 1);
INSERT INTO public.user_saves VALUES (34, 1, 3, 'nem', '{"userData": {"field1": "asf", "field2": "asf", "field3": "asf"}, "acceptedSubjects": [], "requiredSubjects": [{"id": 358, "code": "NGB_MA001_2", "name": "Lineáris algebra és többváltozós függvények", "type": "Természettudományi ismeretek", "credit": 4, "category": "Kötelező", "syllabus_year": 2010, "recommended_semester": 2}, {"id": 402, "code": "NGB_IT023_2", "name": "Középfokú nyelvvizsgára felkészítő", "type": "Gazdasági és humán ismeretek", "credit": 2, "category": "Szabadon válaszott", "syllabus_year": 2010, "recommended_semester": 1}, {"id": 467, "code": "NGB_IN032_1", "name": "UML-alapú fejlesztés I.", "type": "Számítástechnikai és programozási ismeretek", "credit": 4, "category": "Kötelezően Választható", "syllabus_year": 2010, "recommended_semester": 5}]}', '2026-04-24 11:56:22.48031', 1);
INSERT INTO public.user_saves VALUES (52, 1, 2, 'Slot 2', '{"userData": {"field1": "asd", "field2": "asd", "field3": "asd"}, "acceptedSubjects": [], "requiredSubjects": [{"id": 1053, "code": "GKNB_MSTM065", "name": "Algoritmusok és adatstruktúrák", "type": "Számítástechnikai és programozási ismeretek", "credit": 5, "category": "Kötelező", "syllabus_year": 2023, "recommended_semester": 1}]}', '2026-05-01 10:59:37.629552', 2);
INSERT INTO public.user_saves VALUES (85, 1, 4, 'Slot 4', '{"userData": {"field1": "asf", "field2": "sf", "field3": "afs"}, "acceptedSubjects": [{"id": 1777801670416, "externalNames": ["sad"], "internalSubjects": [{"id": 1058, "code": "GKNB_INTM111", "name": "Digitális kompetenciák, önálló képzési stratégia", "type": "Természettudományi ismeretek", "credit": 2, "category": "K", "syllabus_year": 2023, "recommended_semester": 1}, {"id": 1059, "code": "GKNB_INTM116", "name": "Rendszer és irányítási alapok", "type": "Gazdasági és humán ismeretek", "credit": 3, "category": "K", "syllabus_year": 2023, "recommended_semester": 2}]}, {"id": 1777801687608, "externalNames": ["sees"], "internalSubjects": [{"id": 1085, "code": "MENB_ÁTTM060", "name": "Agrárinformatika alapjai", "type": "Gazdasági és humán ismeretek", "credit": 5, "category": "V", "syllabus_year": 2023, "recommended_semester": 0}, {"id": 743, "code": "NGB_MA001_2", "name": "Lineáris algebra és többváltozós függvények", "type": "Természettudományi ismeretek", "credit": 4, "category": "K", "syllabus_year": 2010, "recommended_semester": 2}]}, {"id": 1777801701560, "externalNames": ["lulu"], "internalSubjects": [{"id": 1086, "code": "GKNB_INTM151", "name": "Ajánlórendszerek alapjai", "type": "Gazdasági és humán ismeretek", "credit": 5, "category": "V", "syllabus_year": 2023, "recommended_semester": 0}, {"id": 1011, "code": "GKNB_INTM050", "name": "Ágazati információrendszerek I.", "type": "Természettudományi ismeretek", "credit": 3, "category": "V", "syllabus_year": 2023, "recommended_semester": 0}]}, {"id": 1777908806845, "externalNames": ["af"], "internalSubjects": [{"id": 1067, "code": "GKNB_INTM119", "name": "OO Programozás", "type": "Számítástechnikai és programozási ismeretek", "credit": 5, "category": "K", "syllabus_year": 2023, "recommended_semester": 3}]}], "requiredSubjects": [{"id": 1053, "code": "GKNB_MSTM065", "name": "Algoritmusok és adatstruktúrák", "type": "Számítástechnikai és programozási ismeretek", "credit": 5, "category": "Kötelező", "syllabus_year": 2023, "recommended_semester": 1}, {"id": 1054, "code": "GKNB_AUTM077", "name": "Digitális logikai rendszerek és kapcsolások informatikusoknak", "type": "Számítástechnikai és programozási ismeretek", "credit": 3, "category": "K", "syllabus_year": 2023, "recommended_semester": 1}, {"id": 1056, "code": "GKNB_INTM112", "name": "Python alapok informatikusoknak", "type": "Számítástechnikai és programozási ismeretek", "credit": 3, "category": "K", "syllabus_year": 2023, "recommended_semester": 1}, {"id": 1080, "code": "GKNB_INTM138", "name": "Adatbázis-kezelés Oracle-ben", "type": "Gazdasági és humán ismeretek", "credit": 5, "category": "V", "syllabus_year": 2023, "recommended_semester": 0}]}', '2026-05-04 17:33:36.336979', 2);
INSERT INTO public.user_saves VALUES (33, 1, 1, 'Autosave', '{"userData": {"field1": "asf", "field2": "asf", "field3": "asf"}, "acceptedSubjects": [], "requiredSubjects": [{"id": 358, "code": "NGB_MA001_2", "name": "Lineáris algebra és többváltozós függvények", "type": "Természettudományi ismeretek", "credit": 4, "category": "Kötelező", "syllabus_year": 2010, "recommended_semester": 2}, {"id": 402, "code": "NGB_IT023_2", "name": "Középfokú nyelvvizsgára felkészítő", "type": "Gazdasági és humán ismeretek", "credit": 2, "category": "Szabadon válaszott", "syllabus_year": 2010, "recommended_semester": 1}, {"id": 467, "code": "NGB_IN032_1", "name": "UML-alapú fejlesztés I.", "type": "Számítástechnikai és programozási ismeretek", "credit": 4, "category": "Kötelezően Választható", "syllabus_year": 2010, "recommended_semester": 5}, {"id": 434, "code": "NGB_IN021_1", "name": "Döntéselőkészítés", "type": "Számítástechnikai és programozási ismeretek", "credit": 4, "category": "Kötelezően Választható", "syllabus_year": 2010, "recommended_semester": 5}]}', '2026-05-11 16:47:45.256571', 1);
INSERT INTO public.user_saves VALUES (74, 1, 1, 'Autosave', '{"userData": {"field1": "asfasf", "field2": "sfsfa", "field3": "asf"}, "acceptedSubjects": [{"id": 1777916985717, "externalNames": ["asf"], "internalSubjects": [{"id": 1058, "code": "GKNB_INTM111", "name": "Digitális kompetenciák, önálló képzési stratégia", "type": "Természettudományi ismeretek", "credit": 2, "category": "K", "syllabus_year": 2023, "recommended_semester": 1}, {"id": 1061, "code": "GKNB_INTM117", "name": "Mikroelektromechanikai rendszerek", "type": "Számítástechnikai és programozási ismeretek", "credit": 3, "category": "K", "syllabus_year": 2023, "recommended_semester": 2}]}], "requiredSubjects": [{"id": "req-1777910076687-0.5274194020932959", "code": "GKNB_INTM112", "name": "Python alapok informatikusoknak", "type": "Számítástechnikai és programozási ismeretek", "credit": 3, "category": "K", "recommended_semester": 1}, {"id": "req-1777910076687-0.7162053878606343", "code": "NGB_MA001_2", "name": "Lineáris algebra és többváltozós függvények", "type": "Természettudományi ismeretek", "credit": 4, "category": "K", "recommended_semester": 2}, {"id": "req-1777910076687-0.13509037404008284", "code": "GKNB_INTM115", "name": "Operációs rendszerek", "type": "Természettudományi ismeretek", "credit": 3, "category": "K", "recommended_semester": 2}, {"id": "req-1777910076687-0.3551253153349888", "code": "GKNB_AUTM077", "name": "Digitális logikai rendszerek és kapcsolások informatikusoknak", "type": "Számítástechnikai és programozási ismeretek", "credit": 3, "category": "K", "recommended_semester": 1}]}', '2026-05-04 20:05:04.239338', 2);
INSERT INTO public.user_saves VALUES (131, 1, 1, 'Autosave', '{"userData": {"field1": "saf", "field2": "asf", "field3": "afs"}, "acceptedSubjects": [{"id": 1777995854304, "externalNames": ["asf"], "internalSubjects": [{"id": 3216, "code": "GKNB_INTM110", "name": "Számítógép architektúrák", "type": "Természettudományi ismeretek", "credit": 4, "category": "K", "syllabus_year": 2025, "recommended_semester": 1}]}, {"id": 1777995916900, "externalNames": ["asd"], "internalSubjects": [{"id": 3234, "code": "GKNB_FKTM045", "name": "Fizika informatikusoknak", "type": "Számítástechnikai és programozási ismeretek", "credit": 4, "category": "K", "syllabus_year": 2025, "recommended_semester": 4}, {"id": 3239, "code": "GKNB_INTM128", "name": "Modellezés és optimalizálás a gyakorlatban", "type": "Információs rendszerek ismeretek", "credit": 5, "category": "K", "syllabus_year": 2025, "recommended_semester": 5}]}], "requiredSubjects": [{"id": 3210, "code": "GKNB_MSTM065", "name": "Algoritmusok és adatstruktúrák", "type": "Természettudományi ismeretek", "credit": 5, "category": "K", "syllabus_year": 2025, "recommended_semester": 1}, {"id": 3211, "code": "GKNB_AUTM077", "name": "Digitális logikai rendszerek és kapcsolások informatikusoknak", "type": "Gazdasági és humán ismeretek", "credit": 3, "category": "K", "syllabus_year": 2025, "recommended_semester": 1}, {"id": 3212, "code": "GKNB_MSTM064", "name": "Diszkrét Matematika", "type": "Számítástechnikai és programozási ismeretek", "credit": 5, "category": "K", "syllabus_year": 2025, "recommended_semester": 1}, {"id": 3216, "code": "GKNB_INTM110", "name": "Számítógép architektúrák", "type": "Természettudományi ismeretek", "credit": 4, "category": "K", "syllabus_year": 2025, "recommended_semester": 1}, {"id": 3219, "code": "KGNB_MMTM048", "name": "Vállalatgazdaságtan", "type": "Számítástechnikai és programozási ismeretek", "credit": 5, "category": "K", "syllabus_year": 2025, "recommended_semester": 2}, {"id": 3228, "code": "GKNB_INTM167", "name": "Szakmai gyakorlat", "type": "Természettudományi ismeretek", "credit": 0, "category": "K", "syllabus_year": 2025, "recommended_semester": 3}]}', '2026-05-05 17:46:17.240172', 52);


--
-- TOC entry 4994 (class 0 OID 16518)
-- Dependencies: 227
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users VALUES (1, 'Kiss', 'Ákos', 'akosober12@gmail.com', '$2b$10$JGlJE.NcaUIqHr041f/Sx.3/ACbnrcjfuJfiyYkbcmerz5zlwCTlW', true, 'admin', '2026-04-01 10:04:51.12968', '2026-04-01 10:04:51.12968');
INSERT INTO public.users VALUES (26, 'Kiss', 'Ákos', 'oberka.bi@gmail.com', '$2b$10$O3IHyED3N7QOg.Vbyg.Sl.Y0oq2jKp.e1AM9Z7euEwAMIaC4foBGa', true, 'user', '2026-05-11 15:46:59.372627', '2026-05-11 15:46:59.372627');


--
-- TOC entry 5009 (class 0 OID 0)
-- Dependencies: 224
-- Name: fac_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fac_id_seq', 17, true);


--
-- TOC entry 5010 (class 0 OID 0)
-- Dependencies: 223
-- Name: majors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.majors_id_seq', 54, true);


--
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 225
-- Name: subject_major_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subject_major_id_seq', 3632, true);


--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 231
-- Name: tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tokens_id_seq', 4, true);


--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 229
-- Name: user_saves_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_saves_id_seq', 149, true);


--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 226
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 26, true);


--
-- TOC entry 4818 (class 2606 OID 16479)
-- Name: colors FilterColor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT "FilterColor_pkey" PRIMARY KEY (id);


--
-- TOC entry 4812 (class 2606 OID 16447)
-- Name: subjects Subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT "Subjects_pkey" PRIMARY KEY (code);


--
-- TOC entry 4800 (class 2606 OID 17223)
-- Name: subjects chek_code_lenght; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.subjects
    ADD CONSTRAINT chek_code_lenght CHECK (((length(code) <= 32) AND (length(code) > 0))) NOT VALID;


--
-- TOC entry 4808 (class 2606 OID 16414)
-- Name: majors majors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.majors
    ADD CONSTRAINT majors_pkey PRIMARY KEY (id);


--
-- TOC entry 4814 (class 2606 OID 16505)
-- Name: subject_major subject_major_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_major
    ADD CONSTRAINT subject_major_pkey PRIMARY KEY (id);


--
-- TOC entry 4825 (class 2606 OID 17219)
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4821 (class 2606 OID 17146)
-- Name: users unique_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- TOC entry 4810 (class 2606 OID 17096)
-- Name: majors unique_major_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.majors
    ADD CONSTRAINT unique_major_name UNIQUE (major_name);


--
-- TOC entry 4816 (class 2606 OID 17131)
-- Name: subject_major unique_subject_major_pair; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_major
    ADD CONSTRAINT unique_subject_major_pair UNIQUE (subject_code, major_id);


--
-- TOC entry 4827 (class 2606 OID 17221)
-- Name: tokens unique_token; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT unique_token UNIQUE (token);


--
-- TOC entry 4829 (class 2606 OID 17176)
-- Name: user_saves unique_user_major_slot; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_saves
    ADD CONSTRAINT unique_user_major_slot UNIQUE (user_id, major_id, slot_number);


--
-- TOC entry 4831 (class 2606 OID 17028)
-- Name: user_saves user_saves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_saves
    ADD CONSTRAINT user_saves_pkey PRIMARY KEY (id);


--
-- TOC entry 4823 (class 2606 OID 16534)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4806 (class 2606 OID 17222)
-- Name: user_saves valid_slot_range; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.user_saves
    ADD CONSTRAINT valid_slot_range CHECK (((slot_number >= 1) AND (slot_number <= 4))) NOT VALID;


--
-- TOC entry 4819 (class 1259 OID 17086)
-- Name: idx_only_one_active_per_major; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_only_one_active_per_major ON public.colors USING btree (user_id, major) WHERE (is_active = true);


--
-- TOC entry 4837 (class 2606 OID 17155)
-- Name: user_saves fk_save_major; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_saves
    ADD CONSTRAINT fk_save_major FOREIGN KEY (major_id) REFERENCES public.majors(id) ON DELETE CASCADE;


--
-- TOC entry 4838 (class 2606 OID 17150)
-- Name: user_saves fk_save_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_saves
    ADD CONSTRAINT fk_save_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4836 (class 2606 OID 17138)
-- Name: tokens fk_token_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT fk_token_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4834 (class 2606 OID 17160)
-- Name: colors major-filtercolor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT "major-filtercolor" FOREIGN KEY (major) REFERENCES public.majors(id) ON DELETE CASCADE;


--
-- TOC entry 4832 (class 2606 OID 17198)
-- Name: subject_major major_to_sum; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_major
    ADD CONSTRAINT major_to_sum FOREIGN KEY (major_id) REFERENCES public.majors(id) ON DELETE CASCADE;


--
-- TOC entry 4833 (class 2606 OID 17203)
-- Name: subject_major subject_to_sum; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_major
    ADD CONSTRAINT subject_to_sum FOREIGN KEY (subject_code) REFERENCES public.subjects(code) ON DELETE RESTRICT;


--
-- TOC entry 4835 (class 2606 OID 17167)
-- Name: colors user-filtecolor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT "user-filtecolor" FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;


-- Completed on 2026-05-12 09:47:20

--
-- PostgreSQL database dump complete
--

\unrestrict rgJutODtBz3kn3Q8bjzxOzRFunOjceodn9sHRdPtoLAuCiJ4GhLRbZLWk9IwpwD

