--
-- PostgreSQL database dump
--

\restrict Hubc6ayom0nlJUwgXqMKd1Y7F1rNcS4guqejtxjTyX4xm46Fnp7PqIvwjesSra8

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2026-05-14 12:21:21

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
-- TOC entry 4991 (class 0 OID 0)
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
-- TOC entry 4992 (class 0 OID 0)
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
-- TOC entry 4993 (class 0 OID 0)
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
-- TOC entry 4994 (class 0 OID 0)
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
-- TOC entry 4995 (class 0 OID 0)
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


-- Completed on 2026-05-14 12:21:22

--
-- PostgreSQL database dump complete
--

\unrestrict Hubc6ayom0nlJUwgXqMKd1Y7F1rNcS4guqejtxjTyX4xm46Fnp7PqIvwjesSra8

