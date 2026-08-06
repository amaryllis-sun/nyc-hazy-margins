--
-- PostgreSQL database dump
--

\restrict lRJvpxTVdPybUcJG3ijqTHYOB504wTfFB9ckohGk6l9Erad32fLvcNXlBSlyKlk

-- Dumped from database version 18.4 (Homebrew)
-- Dumped by pg_dump version 18.4 (Homebrew)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: amaryllis
--

CREATE TABLE public.cities (
    city_id integer NOT NULL,
    city_name character varying(100),
    state character varying(2)
);


ALTER TABLE public.cities OWNER TO amaryllis;

--
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: public; Owner: amaryllis
--

CREATE SEQUENCE public.cities_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cities_city_id_seq OWNER TO amaryllis;

--
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: amaryllis
--

ALTER SEQUENCE public.cities_city_id_seq OWNED BY public.cities.city_id;


--
-- Name: daily_readings; Type: TABLE; Schema: public; Owner: amaryllis
--

CREATE TABLE public.daily_readings (
    reading_id integer NOT NULL,
    station_id character varying(20),
    reading_date date,
    pm25 double precision,
    ozone double precision,
    aqi integer,
    max_temp_f double precision,
    min_temp_f double precision
);


ALTER TABLE public.daily_readings OWNER TO amaryllis;

--
-- Name: daily_readings_reading_id_seq; Type: SEQUENCE; Schema: public; Owner: amaryllis
--

CREATE SEQUENCE public.daily_readings_reading_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.daily_readings_reading_id_seq OWNER TO amaryllis;

--
-- Name: daily_readings_reading_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: amaryllis
--

ALTER SEQUENCE public.daily_readings_reading_id_seq OWNED BY public.daily_readings.reading_id;


--
-- Name: heat_vulnerability; Type: TABLE; Schema: public; Owner: amaryllis
--

CREATE TABLE public.heat_vulnerability (
    zip_code character varying(5) NOT NULL,
    hvi_score integer
);


ALTER TABLE public.heat_vulnerability OWNER TO amaryllis;

--
-- Name: stations; Type: TABLE; Schema: public; Owner: amaryllis
--

CREATE TABLE public.stations (
    station_id character varying(20) NOT NULL,
    city_id integer,
    latitude double precision,
    longitude double precision,
    zip_code character varying(5)
);


ALTER TABLE public.stations OWNER TO amaryllis;

--
-- Name: weather_readings; Type: TABLE; Schema: public; Owner: amaryllis
--

CREATE TABLE public.weather_readings (
    reading_id integer NOT NULL,
    city_id integer,
    reading_date date,
    max_temp_f double precision,
    min_temp_f double precision
);


ALTER TABLE public.weather_readings OWNER TO amaryllis;

--
-- Name: weather_readings_reading_id_seq; Type: SEQUENCE; Schema: public; Owner: amaryllis
--

CREATE SEQUENCE public.weather_readings_reading_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weather_readings_reading_id_seq OWNER TO amaryllis;

--
-- Name: weather_readings_reading_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: amaryllis
--

ALTER SEQUENCE public.weather_readings_reading_id_seq OWNED BY public.weather_readings.reading_id;


--
-- Name: cities city_id; Type: DEFAULT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.cities ALTER COLUMN city_id SET DEFAULT nextval('public.cities_city_id_seq'::regclass);


--
-- Name: daily_readings reading_id; Type: DEFAULT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.daily_readings ALTER COLUMN reading_id SET DEFAULT nextval('public.daily_readings_reading_id_seq'::regclass);


--
-- Name: weather_readings reading_id; Type: DEFAULT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.weather_readings ALTER COLUMN reading_id SET DEFAULT nextval('public.weather_readings_reading_id_seq'::regclass);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- Name: daily_readings daily_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.daily_readings
    ADD CONSTRAINT daily_readings_pkey PRIMARY KEY (reading_id);


--
-- Name: heat_vulnerability heat_vulnerability_pkey; Type: CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.heat_vulnerability
    ADD CONSTRAINT heat_vulnerability_pkey PRIMARY KEY (zip_code);


--
-- Name: stations stations_pkey; Type: CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_pkey PRIMARY KEY (station_id);


--
-- Name: daily_readings unique_station_date; Type: CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.daily_readings
    ADD CONSTRAINT unique_station_date UNIQUE (station_id, reading_date);


--
-- Name: weather_readings weather_readings_city_id_reading_date_key; Type: CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.weather_readings
    ADD CONSTRAINT weather_readings_city_id_reading_date_key UNIQUE (city_id, reading_date);


--
-- Name: weather_readings weather_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.weather_readings
    ADD CONSTRAINT weather_readings_pkey PRIMARY KEY (reading_id);


--
-- Name: daily_readings daily_readings_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.daily_readings
    ADD CONSTRAINT daily_readings_station_id_fkey FOREIGN KEY (station_id) REFERENCES public.stations(station_id);


--
-- Name: stations stations_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.stations
    ADD CONSTRAINT stations_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id);


--
-- Name: weather_readings weather_readings_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: amaryllis
--

ALTER TABLE ONLY public.weather_readings
    ADD CONSTRAINT weather_readings_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id);


--
-- PostgreSQL database dump complete
--

\unrestrict lRJvpxTVdPybUcJG3ijqTHYOB504wTfFB9ckohGk6l9Erad32fLvcNXlBSlyKlk

