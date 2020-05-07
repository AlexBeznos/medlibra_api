--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1
-- Dumped by pg_dump version 12.1

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.answers (
    id integer NOT NULL,
    title text NOT NULL,
    correct boolean NOT NULL,
    question_id integer
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.answers ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: assessment_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_questions (
    id integer NOT NULL,
    question_id integer,
    assessment_id integer
);


--
-- Name: assessment_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.assessment_questions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.assessment_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessments (
    id integer NOT NULL,
    type text NOT NULL,
    questions_amount integer NOT NULL,
    krok_id integer,
    field_id integer,
    subfield_id integer,
    year_id integer
);


--
-- Name: assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.assessments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fields (
    id integer NOT NULL,
    name text NOT NULL,
    krok_id integer
);


--
-- Name: fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.fields ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: kroks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kroks (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: kroks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.kroks ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.kroks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id integer NOT NULL,
    title text NOT NULL
);


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.questions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    filename text NOT NULL
);


--
-- Name: subfields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subfields (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: subfields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.subfields ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.subfields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    uid text NOT NULL,
    learning_intensity text DEFAULT 'light'::text NOT NULL,
    helper_notifications_enabled boolean DEFAULT false NOT NULL,
    changes_notifications_enabled boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    krok_id integer,
    field_id integer
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.users ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: years; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.years (
    id integer NOT NULL,
    name text NOT NULL
);


--
-- Name: years_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.years ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.years_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: answers answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: assessment_questions assessment_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_questions
    ADD CONSTRAINT assessment_questions_pkey PRIMARY KEY (id);


--
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- Name: kroks kroks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kroks
    ADD CONSTRAINT kroks_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: subfields subfields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subfields
    ADD CONSTRAINT subfields_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_uid_key UNIQUE (uid);


--
-- Name: years years_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.years
    ADD CONSTRAINT years_pkey PRIMARY KEY (id);


--
-- Name: assessments_type_krok_id_field_id_subfield_id_year_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assessments_type_krok_id_field_id_subfield_id_year_id_index ON public.assessments USING btree (type, krok_id, field_id, subfield_id, year_id);


--
-- Name: assessments_type_krok_id_field_id_year_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assessments_type_krok_id_field_id_year_id_index ON public.assessments USING btree (type, krok_id, field_id, year_id);


--
-- Name: answers answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: assessment_questions assessment_questions_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_questions
    ADD CONSTRAINT assessment_questions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id);


--
-- Name: assessment_questions assessment_questions_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_questions
    ADD CONSTRAINT assessment_questions_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: assessments assessments_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id);


--
-- Name: assessments assessments_krok_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_krok_id_fkey FOREIGN KEY (krok_id) REFERENCES public.kroks(id);


--
-- Name: assessments assessments_subfield_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_subfield_id_fkey FOREIGN KEY (subfield_id) REFERENCES public.subfields(id);


--
-- Name: assessments assessments_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_year_id_fkey FOREIGN KEY (year_id) REFERENCES public.years(id);


--
-- Name: fields fields_krok_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_krok_id_fkey FOREIGN KEY (krok_id) REFERENCES public.kroks(id);


--
-- Name: users users_field_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_field_id_fkey FOREIGN KEY (field_id) REFERENCES public.fields(id);


--
-- Name: users users_krok_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_krok_id_fkey FOREIGN KEY (krok_id) REFERENCES public.kroks(id);


--
-- PostgreSQL database dump complete
--

