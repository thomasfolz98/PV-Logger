--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases (except postgres and template1)
--

DROP DATABASE "housecontrol-db";




--
-- Drop roles
--

DROP ROLE housecontrol_user;


--
-- Roles
--

CREATE ROLE housecontrol_user;
ALTER ROLE housecontrol_user WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:fnaEWq6DuFmnLqvEvnSPzw==$KeXrOLLUSm3P80L8p9vv2MTGZr8/GMlOIlwAHPd3HTo=:0St4UVJTds0fHj8f1lNhKAk/XuV/NoRI8MYAW4zy43w=';

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0 (Debian 17.0-1.pgdg110+1)
-- Dumped by pg_dump version 17.0 (Debian 17.0-1.pgdg110+1)

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

UPDATE pg_catalog.pg_database SET datistemplate = false WHERE datname = 'template1';
DROP DATABASE template1;
--
-- Name: template1; Type: DATABASE; Schema: -; Owner: housecontrol_user
--

CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE template1 OWNER TO housecontrol_user;

\connect template1

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
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: housecontrol_user
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: template1; Type: DATABASE PROPERTIES; Schema: -; Owner: housecontrol_user
--

ALTER DATABASE template1 IS_TEMPLATE = true;


\connect template1

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
-- Name: DATABASE template1; Type: ACL; Schema: -; Owner: housecontrol_user
--

REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- Database "housecontrol-db" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0 (Debian 17.0-1.pgdg110+1)
-- Dumped by pg_dump version 17.0 (Debian 17.0-1.pgdg110+1)

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
-- Name: housecontrol-db; Type: DATABASE; Schema: -; Owner: housecontrol_user
--

CREATE DATABASE "housecontrol-db" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE "housecontrol-db" OWNER TO housecontrol_user;

\connect -reuse-previous=on "dbname='housecontrol-db'"

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
-- Name: cache; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache OWNER TO housecontrol_user;

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO housecontrol_user;

--
-- Name: electricity_prices; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.electricity_prices (
    id bigint NOT NULL,
    price_per_kwh numeric(8,4) NOT NULL,
    vat_rate numeric(5,2) DEFAULT '19'::numeric NOT NULL,
    valid_from date NOT NULL,
    valid_to date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.electricity_prices OWNER TO housecontrol_user;

--
-- Name: electricity_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: housecontrol_user
--

CREATE SEQUENCE public.electricity_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.electricity_prices_id_seq OWNER TO housecontrol_user;

--
-- Name: electricity_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: housecontrol_user
--

ALTER SEQUENCE public.electricity_prices_id_seq OWNED BY public.electricity_prices.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO housecontrol_user;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: housecontrol_user
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO housecontrol_user;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: housecontrol_user
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO housecontrol_user;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO housecontrol_user;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: housecontrol_user
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO housecontrol_user;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: housecontrol_user
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO housecontrol_user;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: housecontrol_user
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO housecontrol_user;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: housecontrol_user
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO housecontrol_user;

--
-- Name: production_data; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.production_data (
    id bigint NOT NULL,
    date_of_production date NOT NULL,
    produced bigint NOT NULL,
    consumed bigint NOT NULL,
    injected bigint NOT NULL,
    unit character varying(255) NOT NULL
);


ALTER TABLE public.production_data OWNER TO housecontrol_user;

--
-- Name: production_data_id_seq; Type: SEQUENCE; Schema: public; Owner: housecontrol_user
--

CREATE SEQUENCE public.production_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.production_data_id_seq OWNER TO housecontrol_user;

--
-- Name: production_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: housecontrol_user
--

ALTER SEQUENCE public.production_data_id_seq OWNED BY public.production_data.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO housecontrol_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: housecontrol_user
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.users OWNER TO housecontrol_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: housecontrol_user
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO housecontrol_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: housecontrol_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: electricity_prices id; Type: DEFAULT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.electricity_prices ALTER COLUMN id SET DEFAULT nextval('public.electricity_prices_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: production_data id; Type: DEFAULT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.production_data ALTER COLUMN id SET DEFAULT nextval('public.production_data_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.cache (key, value, expiration) FROM stdin;
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: electricity_prices; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.electricity_prices (id, price_per_kwh, vat_rate, valid_from, valid_to, created_at, updated_at) FROM stdin;
4	35.5100	19.00	2025-01-01	\N	\N	\N
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2024_12_18_134300_create_production_data_table	2
5	2025_08_28_124357_create_electricity_prices_table	3
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: production_data; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.production_data (id, date_of_production, produced, consumed, injected, unit) FROM stdin;
1	2023-11-01	1198	10154	11	Wh
2	2023-11-02	925	9608	72	Wh
3	2023-11-03	1348	8216	111	Wh
4	2023-11-04	1290	6834	84	Wh
5	2023-11-05	1236	7026	187	Wh
6	2023-11-06	1208	8519	40	Wh
7	2023-11-07	1295	10405	78	Wh
8	2023-11-08	1364	10503	42	Wh
9	2023-11-09	516	10554	0	Wh
10	2023-11-10	958	8445	59	Wh
11	2023-11-11	714	7301	16	Wh
12	2023-11-12	1024	7776	19	Wh
13	2023-11-13	632	7955	20	Wh
14	2023-11-14	952	10196	78	Wh
15	2023-11-15	773	8896	20	Wh
16	2023-11-16	755	9294	32	Wh
17	2023-11-17	1112	9738	34	Wh
18	2023-11-18	991	7574	21	Wh
19	2023-11-19	1074	7637	66	Wh
20	2023-11-20	477	9088	0	Wh
21	2023-11-21	781	7990	7	Wh
22	2023-11-22	1291	16368	12	Wh
23	2023-11-23	168	8061	0	Wh
24	2023-11-24	861	9930	9	Wh
25	2023-11-25	676	15028	0	Wh
26	2023-11-26	410	24886	0	Wh
27	2023-11-27	151	8886	0	Wh
28	2023-11-28	12	23476	0	Wh
29	2023-11-29	0	15001	0	Wh
30	2023-11-30	11	19972	0	Wh
31	2024-01-01	287	6812	0	Wh
32	2024-01-02	220	9440	0	Wh
33	2024-01-03	610	7236	15	Wh
34	2024-01-04	526	7690	17	Wh
35	2024-01-05	397	13287	0	Wh
36	2024-01-06	108	24983	0	Wh
37	2024-01-07	0	45623	0	Wh
38	2024-01-08	37	39775	0	Wh
39	2024-01-09	45	50678	0	Wh
40	2024-01-10	60	43384	0	Wh
41	2024-01-11	0	49036	0	Wh
42	2024-01-12	72	23369	0	Wh
43	2024-01-13	337	23174	0	Wh
44	2024-01-14	312	17362	0	Wh
45	2024-01-15	829	23819	1	Wh
46	2024-01-16	847	24132	17	Wh
47	2023-10-27	559	8715	0	Wh
48	2023-10-28	1256	9686	112	Wh
49	2023-10-29	1659	6041	417	Wh
50	2023-10-30	1684	7431	365	Wh
51	2023-10-31	933	6920	53	Wh
52	2024-01-17	1010	32660	0	Wh
53	2024-01-18	1206	29079	119	Wh
54	2024-01-19	1336	34015	32	Wh
55	2024-01-20	1410	30407	63	Wh
56	2024-01-21	705	24203	14	Wh
57	2024-01-22	682	9701	26	Wh
58	2024-01-23	956	6665	72	Wh
59	2024-01-24	179	6619	0	Wh
60	2024-01-25	1203	6483	249	Wh
61	2024-01-26	575	10435	19	Wh
62	2024-01-27	1725	12720	249	Wh
63	2024-01-28	1742	17849	500	Wh
64	2024-01-29	1948	10278	398	Wh
65	2024-01-30	1440	7624	282	Wh
66	2024-01-31	710	8836	0	Wh
67	2024-02-01	1986	7911	522	Wh
68	2024-02-02	662	7964	0	Wh
69	2024-02-03	337	9660	0	Wh
70	2024-02-04	710	5510	5	Wh
71	2024-02-05	409	9051	0	Wh
72	2024-02-06	427	7864	0	Wh
73	2024-02-07	1846	9827	165	Wh
74	2024-02-08	1172	20828	200	Wh
75	2024-02-09	984	19401	66	Wh
76	2024-02-10	2541	6759	612	Wh
77	2024-02-11	197	7246	0	Wh
78	2024-02-12	1401	9639	26	Wh
79	2024-02-13	2776	7588	872	Wh
80	2024-02-14	701	5568	12	Wh
81	2024-02-15	1021	8064	24	Wh
82	2024-02-16	1456	8838	44	Wh
83	2024-02-17	2887	6120	1138	Wh
84	2024-02-18	1058	6351	77	Wh
85	2024-02-19	1795	6394	515	Wh
86	2024-02-20	2097	9234	506	Wh
87	2024-02-21	2202	6244	408	Wh
88	2024-02-22	2079	6917	579	Wh
89	2024-02-23	3401	7267	1118	Wh
90	2024-02-24	2844	7482	636	Wh
91	2024-02-25	2321	6257	883	Wh
92	2024-02-26	1672	15121	164	Wh
93	2024-02-27	1745	7161	254	Wh
94	2024-02-28	4047	12989	1839	Wh
95	2024-02-29	4832	13008	2303	Wh
96	2024-03-01	3935	6082	1439	Wh
97	2024-03-02	4194	5985	1764	Wh
98	2024-03-03	4176	4946	2112	Wh
99	2024-03-04	1550	9533	155	Wh
100	2024-03-05	471	10356	0	Wh
101	2024-03-06	3947	8159	1422	Wh
102	2024-03-07	2846	14220	1193	Wh
103	2024-03-08	5948	11876	3261	Wh
104	2024-03-09	6116	7526	3486	Wh
105	2024-03-10	3734	9989	1219	Wh
106	2024-03-11	2261	7059	469	Wh
107	2024-03-12	1071	8519	162	Wh
108	2024-03-13	2025	6986	306	Wh
109	2024-03-14	6006	6247	3671	Wh
110	2024-03-15	2336	8404	646	Wh
111	2024-03-16	3741	7066	1794	Wh
112	2024-03-17	4924	7915	2548	Wh
113	2024-03-18	3542	5305	1303	Wh
114	2024-03-19	4526	7042	2141	Wh
115	2024-03-20	5743	6507	2818	Wh
116	2024-03-21	2510	6271	751	Wh
117	2024-03-22	1284	8200	142	Wh
118	2024-03-23	5265	6135	2712	Wh
119	2024-03-24	3004	5551	1000	Wh
120	2024-03-25	6421	5675	3310	Wh
121	2024-03-26	4218	8420	1338	Wh
122	2024-03-27	6225	6497	2983	Wh
123	2024-03-28	2716	8161	581	Wh
124	2024-03-29	3344	6334	1596	Wh
125	2024-03-30	2603	8464	877	Wh
126	2024-03-31	5732	5723	3118	Wh
127	2024-04-01	883	5190	46	Wh
128	2024-04-02	3449	5964	1223	Wh
129	2024-04-03	3181	7724	890	Wh
130	2024-04-04	3810	5075	1732	Wh
131	2024-04-05	2991	6664	985	Wh
132	2024-04-06	7085	5292	5259	Wh
133	2024-04-07	8148	3913	5804	Wh
134	2024-04-08	7792	5157	4543	Wh
135	2024-04-09	1996	5864	636	Wh
136	2024-04-10	6255	5072	3144	Wh
137	2024-04-11	4245	7912	1983	Wh
138	2024-04-12	4712	4442	2219	Wh
139	2024-04-13	6658	5249	4015	Wh
140	2024-04-14	8716	3378	5246	Wh
141	2024-04-15	4706	4154	2515	Wh
142	2024-04-16	4454	6358	2254	Wh
143	2024-04-17	5797	5757	3622	Wh
144	2024-04-18	6718	5141	4585	Wh
145	2024-04-19	5713	3462	3441	Wh
146	2024-04-20	5934	6204	2889	Wh
147	2024-04-21	8001	4021	4742	Wh
148	2024-04-22	8146	11112	4596	Wh
149	2024-04-23	3960	7174	1617	Wh
150	2024-04-24	5162	4668	3117	Wh
151	2024-04-25	7039	6349	3428	Wh
152	2024-04-26	2121	6804	260	Wh
153	2024-04-27	6270	4405	3481	Wh
154	2024-04-28	5377	5432	2544	Wh
155	2024-04-29	8772	3983	5869	Wh
156	2024-04-30	11104	4465	8577	Wh
157	2024-05-01	10702	2676	8395	Wh
158	2024-05-02	11024	2686	7682	Wh
159	2024-05-03	3702	5969	1625	Wh
160	2024-05-04	4285	4567	1849	Wh
161	2024-05-05	4852	4209	2556	Wh
162	2024-05-06	11392	3327	8740	Wh
163	2024-05-07	8045	4827	4789	Wh
164	2024-05-08	13029	4100	9596	Wh
165	2024-05-09	11608	2913	9219	Wh
166	2024-05-10	10582	4356	6713	Wh
167	2024-05-11	12778	2449	10831	Wh
168	2024-05-12	12609	2727	10915	Wh
169	2024-05-13	13042	4413	8763	Wh
170	2024-05-14	13724	2704	11578	Wh
171	2024-05-15	13489	3953	10860	Wh
172	2024-05-16	5349	3379	3473	Wh
173	2024-05-17	7307	3545	4934	Wh
174	2024-05-18	8352	3937	5448	Wh
175	2024-05-19	5649	3682	3465	Wh
176	2024-05-20	8497	3836	5411	Wh
177	2024-05-21	7315	3557	5063	Wh
178	2024-05-22	1830	5142	268	Wh
179	2024-05-23	12686	4294	9990	Wh
180	2024-05-24	6794	2583	4453	Wh
181	2024-05-25	10756	5085	6765	Wh
182	2024-05-26	11044	2402	7746	Wh
183	2024-05-27	7630	3414	4820	Wh
184	2024-05-28	12023	1830	8557	Wh
185	2024-05-29	5395	4854	2405	Wh
186	2024-05-30	5254	3900	2635	Wh
187	2024-05-31	7420	3445	4611	Wh
188	2024-06-01	12992	4421	7827	Wh
189	2024-06-02	2595	2880	643	Wh
190	2024-06-03	4802	2301	2370	Wh
191	2024-06-04	9291	2293	6353	Wh
192	2024-06-05	8669	2258	6542	Wh
193	2024-06-06	10381	1709	6976	Wh
194	2024-06-07	10590	1396	8979	Wh
195	2024-06-08	11050	1614	9273	Wh
196	2024-06-09	10050	1278	8058	Wh
197	2024-06-10	4735	2980	2163	Wh
198	2024-06-11	10109	3050	6695	Wh
199	2024-06-12	7781	7525	3892	Wh
200	2024-06-13	8318	5109	3317	Wh
201	2024-06-14	7640	5072	4163	Wh
202	2024-06-15	10101	3478	6382	Wh
203	2024-06-16	6900	3977	4132	Wh
204	2024-06-17	6928	5672	4263	Wh
205	2024-06-18	5529	4435	2513	Wh
206	2024-06-19	11034	4413	9026	Wh
207	2024-06-20	7427	4819	5069	Wh
208	2024-06-21	5159	3504	2833	Wh
209	2024-06-22	13713	3280	10640	Wh
210	2024-06-23	11549	3097	9136	Wh
211	2024-06-24	14465	3195	11992	Wh
212	2024-06-25	14212	2149	11604	Wh
213	2024-06-26	11900	4359	8698	Wh
214	2024-06-27	5997	3016	3865	Wh
215	2024-06-28	12591	4936	9405	Wh
216	2024-06-29	12407	3711	9601	Wh
217	2024-06-30	2644	4262	917	Wh
218	2024-07-01	7275	5161	4643	Wh
219	2024-07-02	3780	3803	1798	Wh
220	2024-07-03	5216	5169	2199	Wh
221	2024-07-04	12280	3088	9798	Wh
222	2024-07-05	5220	5805	2157	Wh
223	2024-07-06	7159	1707	5729	Wh
224	2024-07-07	10512	4211	7683	Wh
225	2024-07-08	10771	3071	7706	Wh
226	2024-07-09	12228	3751	9384	Wh
227	2024-07-10	8513	3360	5616	Wh
228	2024-07-11	11246	2246	8215	Wh
229	2024-07-12	5392	4049	2750	Wh
230	2024-07-13	5130	4202	2516	Wh
231	2024-07-14	10691	3920	8280	Wh
232	2024-07-15	11912	2249	9182	Wh
233	2024-07-16	8424	3574	6828	Wh
234	2024-07-17	6243	4215	3269	Wh
235	2024-07-18	11347	4478	7601	Wh
236	2024-07-19	8864	3368	5307	Wh
237	2024-07-20	12102	3995	8773	Wh
238	2024-07-21	4930	3751	3068	Wh
239	2024-07-22	11795	2825	8566	Wh
240	2024-07-23	3965	4603	2250	Wh
241	2024-07-24	8817	4062	5530	Wh
242	2024-07-25	10765	6551	6943	Wh
243	2024-07-26	4548	4354	2498	Wh
244	2024-07-27	4479	5316	2141	Wh
245	2024-07-28	7378	3890	5385	Wh
246	2024-07-29	12995	3162	9523	Wh
247	2024-07-30	12174	4500	9722	Wh
248	2024-07-31	6013	2143	3760	Wh
249	2024-08-01	9306	3343	7700	Wh
250	2024-08-02	10756	2030	8057	Wh
251	2024-08-03	8242	4200	5798	Wh
252	2024-08-04	7867	2130	6013	Wh
253	2024-08-05	9902	4636	7594	Wh
254	2024-08-06	10611	2721	9056	Wh
255	2024-08-07	6513	4908	2823	Wh
256	2024-08-08	7489	1976	5533	Wh
257	2024-08-09	3418	3995	1546	Wh
258	2024-08-10	8499	2454	6594	Wh
259	2024-08-11	10977	3347	6999	Wh
260	2024-08-12	10702	3813	8725	Wh
261	2024-08-13	8519	3716	6017	Wh
262	2024-08-14	6922	2847	5000	Wh
263	2024-08-15	8353	3033	6677	Wh
264	2024-08-16	4023	4607	2005	Wh
265	2024-08-17	2063	3886	595	Wh
266	2024-08-18	2112	4514	476	Wh
267	2024-08-19	5527	4416	3036	Wh
268	2024-08-20	8008	2814	5900	Wh
269	2024-08-21	8203	4958	5647	Wh
270	2024-08-22	7854	4181	5386	Wh
271	2024-08-23	5773	3817	3833	Wh
272	2024-08-24	8534	5060	5807	Wh
273	2024-08-25	7978	3450	5589	Wh
274	2024-08-26	6695	4748	4328	Wh
275	2024-08-27	8180	4096	6150	Wh
276	2024-08-28	7877	3350	6113	Wh
277	2024-08-29	6627	3832	4841	Wh
278	2024-08-30	2745	4369	1188	Wh
279	2024-08-31	7170	4261	4358	Wh
280	2024-09-01	7322	3451	4905	Wh
281	2024-09-02	6809	2559	4528	Wh
282	2024-09-03	5871	4153	4222	Wh
283	2024-09-04	5636	4220	4032	Wh
284	2024-09-05	6872	4456	4626	Wh
285	2024-09-06	5292	3504	3257	Wh
286	2024-09-07	6542	3202	3905	Wh
287	2024-09-08	5582	3749	3888	Wh
288	2024-09-09	4413	4777	2580	Wh
289	2024-09-10	3934	5005	2238	Wh
290	2024-09-11	5744	5313	3456	Wh
291	2024-09-12	5339	2998	3532	Wh
292	2024-09-13	4958	6662	2182	Wh
293	2024-09-14	5833	7125	2648	Wh
294	2024-09-15	4929	5486	2867	Wh
295	2024-09-16	1714	5643	410	Wh
296	2024-09-17	3072	6689	1316	Wh
297	2024-09-18	4213	5920	2419	Wh
298	2024-09-19	2919	5345	1494	Wh
299	2024-09-20	5720	5468	4089	Wh
300	2024-09-21	5583	4975	3802	Wh
301	2024-09-22	5158	5262	2628	Wh
302	2024-09-23	2780	4151	1163	Wh
303	2024-09-24	2644	5658	1215	Wh
304	2024-09-25	1932	6543	373	Wh
305	2024-09-26	2395	4190	1055	Wh
306	2024-09-27	4354	4500	2399	Wh
307	2024-09-28	3210	6126	1524	Wh
308	2024-09-29	2180	3374	939	Wh
309	2024-09-30	3442	6611	1794	Wh
310	2024-10-01	1534	5008	293	Wh
311	2024-10-02	985	7979	18	Wh
312	2024-10-03	2162	5968	853	Wh
313	2024-10-04	3522	4317	1907	Wh
314	2024-10-05	2031	6107	475	Wh
315	2024-10-06	3414	6408	1092	Wh
316	2024-10-07	2955	6204	1127	Wh
317	2024-10-08	2241	6050	787	Wh
318	2024-10-09	1533	8949	273	Wh
319	2024-10-10	1274	6767	194	Wh
320	2024-10-11	2622	4648	1202	Wh
321	2024-10-12	2305	5602	648	Wh
322	2024-10-13	2391	3822	923	Wh
323	2024-10-14	2522	6348	778	Wh
324	2024-10-15	2580	6191	1243	Wh
325	2024-10-16	2378	6371	959	Wh
326	2024-10-17	2106	4838	738	Wh
327	2024-10-18	2222	7069	506	Wh
328	2024-10-19	796	7415	86	Wh
329	2024-10-20	2156	5001	766	Wh
330	2024-10-21	620	8228	29	Wh
331	2024-10-22	2263	4956	1032	Wh
332	2024-10-23	1915	5798	549	Wh
333	2024-10-24	1708	6263	392	Wh
334	2024-10-25	1589	5401	438	Wh
335	2024-10-26	1566	3912	394	Wh
336	2024-10-27	831	7018	69	Wh
337	2024-10-28	1674	4897	397	Wh
338	2024-10-29	617	4393	5	Wh
339	2024-10-30	947	7670	107	Wh
340	2024-10-31	840	7833	22	Wh
341	2024-11-01	337	6025	0	Wh
342	2024-11-02	1554	4966	239	Wh
343	2024-11-03	1270	17015	383	Wh
344	2024-11-04	677	11973	0	Wh
345	2024-11-05	1167	5520	84	Wh
346	2024-11-06	279	8538	0	Wh
347	2024-11-07	292	7986	0	Wh
348	2024-11-08	249	10062	0	Wh
349	2024-11-09	375	8453	0	Wh
350	2024-11-10	370	8354	0	Wh
351	2024-11-11	425	6508	4	Wh
352	2024-11-12	960	5754	111	Wh
353	2024-11-13	157	10015	0	Wh
354	2024-11-14	587	7834	24	Wh
355	2024-11-15	753	8948	5	Wh
356	2024-11-16	465	6457	0	Wh
357	2024-11-17	769	6566	55	Wh
358	2024-11-18	781	6975	41	Wh
359	2024-11-19	190	12026	0	Wh
360	2024-11-20	305	16339	0	Wh
361	2024-11-21	963	16543	143	Wh
362	2024-11-22	600	16862	0	Wh
363	2024-11-23	709	20777	31	Wh
364	2024-11-24	850	6289	60	Wh
365	2024-11-25	498	5636	40	Wh
366	2024-11-26	846	7094	63	Wh
367	2024-11-27	348	7098	0	Wh
368	2024-11-28	752	7645	102	Wh
369	2024-11-29	1017	12295	16	Wh
370	2024-11-30	853	22747	27	Wh
371	2024-12-01	786	18057	11	Wh
372	2024-12-02	556	12825	8	Wh
373	2024-12-03	645	8206	41	Wh
374	2024-12-04	747	6638	32	Wh
375	2024-12-05	634	16906	6	Wh
376	2024-12-06	255	9099	0	Wh
377	2024-12-07	41	9606	0	Wh
378	2024-12-08	594	13949	16	Wh
379	2024-12-09	222	7402	0	Wh
380	2024-12-10	332	11531	1	Wh
381	2024-12-11	94	13158	0	Wh
382	2024-12-12	167	14640	0	Wh
383	2024-12-13	445	15233	0	Wh
384	2024-12-14	363	22595	0	Wh
385	2024-12-15	221	12666	0	Wh
386	2024-12-16	213	8644	0	Wh
387	2024-12-17	180	9415	0	Wh
388	2024-12-18	328	9310	3	Wh
389	2024-12-19	372	8014	10	Wh
390	2024-12-20	980	7406	41	Wh
391	2024-12-21	361	9914	0	Wh
392	2024-12-22	607	9581	5	Wh
393	2024-12-23	559	38072	0	Wh
394	2024-12-24	974	26346	27	Wh
395	2024-12-25	504	8212	1	Wh
396	2024-12-26	216	6686	0	Wh
397	2024-12-27	558	19434	0	Wh
398	2024-12-28	962	24209	25	Wh
399	2024-12-29	309	26359	0	Wh
400	2024-12-30	198	13412	0	Wh
401	2024-12-31	375	19495	0	Wh
402	2025-01-01	251	6793	0	Wh
403	2025-01-02	794	9307	21	Wh
404	2025-01-03	575	16162	12	Wh
405	2025-01-04	688	22336	0	Wh
406	2025-01-05	13	24471	0	Wh
407	2025-01-06	561	7751	2	Wh
408	2025-01-07	517	7163	23	Wh
409	2025-01-08	1079	16689	90	Wh
410	2025-01-09	42	20372	0	Wh
411	2025-01-10	444	20046	0	Wh
412	2025-01-11	820	22362	51	Wh
413	2025-01-12	920	23675	73	Wh
414	2025-01-13	1033	40854	8	Wh
415	2025-01-14	662	31325	0	Wh
416	2025-01-15	521	16421	4	Wh
417	2025-01-16	274	15863	0	Wh
418	2025-01-17	637	21537	0	Wh
419	2025-01-18	957	38311	4	Wh
420	2025-01-19	826	21620	8	Wh
421	2025-01-20	214	28602	0	Wh
422	2025-01-21	1441	23119	110	Wh
423	2025-01-22	1251	26486	73	Wh
424	2025-01-23	742	12859	46	Wh
425	2025-01-24	523	11945	0	Wh
426	2025-01-25	451	8849	6	Wh
427	2025-01-26	477	11393	0	Wh
428	2025-01-27	1190	5405	163	Wh
429	2025-01-28	1509	3590	307	Wh
430	2025-01-29	750	6836	23	Wh
431	2025-01-30	553	7242	3	Wh
432	2025-01-31	1666	13144	219	Wh
433	2025-02-01	1362	16920	359	Wh
434	2025-02-02	1978	27197	0	Wh
435	2025-02-03	2133	26219	664	Wh
436	2025-02-04	2040	54627	0	Wh
437	2025-02-05	416	34032	0	Wh
438	2025-02-06	397	12755	0	Wh
439	2025-02-07	612	15044	0	Wh
440	2025-02-08	2293	17676	720	Wh
441	2025-02-09	2323	18442	578	Wh
442	2025-02-10	1362	18945	158	Wh
443	2025-02-11	596	25314	2	Wh
444	2025-02-12	844	21453	1	Wh
445	2025-02-13	90	26876	0	Wh
446	2025-02-14	60	25200	0	Wh
447	2025-02-15	845	22315	48	Wh
448	2025-02-16	2449	24345	303	Wh
449	2025-02-17	3306	29130	415	Wh
450	2025-02-18	3454	32884	1770	Wh
451	2025-02-19	3518	34703	1064	Wh
452	2025-02-20	2169	26321	696	Wh
453	2025-02-21	3449	4806	1521	Wh
454	2025-02-22	2167	8664	609	Wh
455	2025-02-23	3107	6126	1209	Wh
456	2025-02-24	1456	5607	180	Wh
457	2025-02-25	2769	5999	1249	Wh
458	2025-02-26	890	7962	38	Wh
459	2025-02-27	2008	6253	508	Wh
460	2025-02-28	901	17837	62	Wh
461	2025-03-01	3034	7918	688	Wh
462	2025-03-02	5080	21623	2841	Wh
463	2025-03-03	5037	13038	2480	Wh
464	2025-03-04	5186	13409	2853	Wh
465	2025-03-05	5117	12065	2499	Wh
466	2025-03-06	5101	9137	2759	Wh
467	2025-03-07	5162	5059	2508	Wh
468	2025-03-08	5222	6581	2602	Wh
469	2025-03-09	5252	5875	2551	Wh
470	2025-03-10	5564	8917	3145	Wh
471	2025-03-11	1146	12371	35	Wh
472	2025-03-12	2301	12397	332	Wh
473	2025-03-13	4009	14355	1905	Wh
474	2025-03-14	2922	15396	1262	Wh
475	2025-03-15	5035	13189	2879	Wh
476	2025-03-16	6139	9853	3458	Wh
477	2025-03-17	6895	8118	4276	Wh
478	2025-03-18	7009	11403	5107	Wh
479	2025-03-19	7052	6706	4623	Wh
480	2025-03-20	6440	4654	4852	Wh
481	2025-03-21	6822	5029	4203	Wh
482	2025-03-22	6584	4130	4330	Wh
483	2025-03-23	5722	5585	3270	Wh
484	2025-03-24	3937	6711	1473	Wh
485	2025-03-25	3568	6512	1981	Wh
486	2025-03-26	3963	4663	1524	Wh
487	2025-03-27	8259	4979	5974	Wh
488	2025-03-28	7710	3542	5308	Wh
489	2025-03-29	8082	5763	4922	Wh
490	2025-03-30	4893	5257	2821	Wh
491	2025-03-31	6234	5183	4036	Wh
492	2025-04-01	7202	3943	4200	Wh
493	2025-04-02	8201	4523	5301	Wh
494	2025-04-03	8467	4952	5763	Wh
495	2025-04-04	8300	3986	5324	Wh
496	2025-04-05	8254	4461	4771	Wh
497	2025-04-06	8799	6834	6178	Wh
498	2025-04-07	9157	4420	6604	Wh
499	2025-04-08	9068	5332	6254	Wh
500	2025-04-09	7219	4639	4666	Wh
501	2025-04-10	5790	2662	3753	Wh
502	2025-04-11	7854	5719	4867	Wh
503	2025-04-12	9321	4740	5961	Wh
504	2025-04-13	5503	4789	2876	Wh
505	2025-04-14	6849	4277	4679	Wh
506	2025-04-15	8730	4829	6823	Wh
507	2025-04-16	7957	5246	5920	Wh
508	2025-04-17	0	0	0	Wh
509	2025-04-18	0	0	0	Wh
510	2025-04-19	0	0	0	Wh
511	2025-04-20	0	0	0	Wh
512	2025-04-21	0	0	0	Wh
513	2025-04-22	0	0	0	Wh
514	2025-04-23	0	0	0	Wh
515	2025-04-24	0	0	0	Wh
516	2025-04-25	0	0	0	Wh
517	2025-04-26	0	0	0	Wh
518	2025-04-27	0	0	0	Wh
519	2025-04-28	0	0	0	Wh
520	2025-04-29	0	0	0	Wh
521	2025-04-30	0	0	0	Wh
522	2025-05-01	0	0	0	Wh
523	2025-05-02	0	0	0	Wh
524	2025-05-03	0	0	0	Wh
525	2025-05-04	0	0	0	Wh
526	2025-05-05	0	0	0	Wh
527	2025-05-06	0	0	0	Wh
528	2025-05-07	0	0	0	Wh
529	2025-05-08	0	0	0	Wh
530	2025-05-09	0	0	0	Wh
531	2025-05-10	0	0	0	Wh
532	2025-05-11	0	0	0	Wh
533	2025-05-12	0	0	0	Wh
534	2025-05-13	0	0	0	Wh
535	2025-05-14	0	0	0	Wh
536	2025-05-15	0	0	0	Wh
537	2025-05-16	0	0	0	Wh
538	2025-05-17	0	0	0	Wh
539	2025-05-18	0	0	0	Wh
540	2025-05-19	0	0	0	Wh
541	2025-05-20	0	0	0	Wh
542	2025-05-21	0	0	0	Wh
543	2025-05-22	0	0	0	Wh
544	2025-05-23	0	0	0	Wh
545	2025-05-24	0	0	0	Wh
546	2025-05-25	0	0	0	Wh
547	2025-05-26	0	0	0	Wh
548	2025-05-27	0	0	0	Wh
549	2025-05-28	0	0	0	Wh
550	2025-05-29	0	0	0	Wh
551	2025-05-30	0	0	0	Wh
552	2025-05-31	0	0	0	Wh
553	2025-06-01	0	0	0	Wh
554	2025-06-02	0	0	0	Wh
555	2025-06-03	0	0	0	Wh
556	2025-06-04	0	0	0	Wh
557	2025-06-05	0	0	0	Wh
558	2025-06-06	0	0	0	Wh
559	2025-06-07	0	0	0	Wh
560	2025-06-08	0	0	0	Wh
561	2025-06-09	0	0	0	Wh
562	2025-06-10	0	0	0	Wh
563	2025-06-11	0	0	0	Wh
564	2025-06-12	0	0	0	Wh
565	2025-06-13	0	0	0	Wh
566	2025-06-14	0	0	0	Wh
567	2025-06-15	0	0	0	Wh
568	2025-06-16	0	0	0	Wh
569	2025-06-17	0	0	0	Wh
570	2025-06-18	0	0	0	Wh
571	2025-06-19	0	0	0	Wh
572	2025-06-20	0	0	0	Wh
573	2025-06-21	0	0	0	Wh
574	2025-06-22	0	0	0	Wh
575	2025-06-23	0	0	0	Wh
576	2025-06-24	0	0	0	Wh
577	2025-06-25	0	0	0	Wh
578	2025-06-26	0	0	0	Wh
579	2025-06-27	0	0	0	Wh
580	2025-06-28	0	0	0	Wh
581	2025-06-29	0	0	0	Wh
582	2025-06-30	0	0	0	Wh
583	2025-07-01	0	0	0	Wh
584	2025-07-02	0	0	0	Wh
585	2025-07-03	0	0	0	Wh
586	2025-07-04	0	0	0	Wh
587	2025-07-05	0	0	0	Wh
588	2025-07-06	0	0	0	Wh
589	2025-07-07	0	0	0	Wh
590	2025-07-08	0	0	0	Wh
591	2025-07-09	0	0	0	Wh
592	2025-07-10	0	0	0	Wh
593	2025-07-11	0	0	0	Wh
594	2025-07-12	0	0	0	Wh
595	2025-07-13	0	0	0	Wh
596	2025-07-14	0	0	0	Wh
597	2025-07-15	0	0	0	Wh
598	2025-07-16	0	0	0	Wh
599	2025-07-17	0	0	0	Wh
600	2025-07-18	0	0	0	Wh
601	2025-07-19	0	0	0	Wh
602	2025-07-20	0	0	0	Wh
603	2025-07-21	0	0	0	Wh
604	2025-07-22	0	0	0	Wh
605	2025-07-23	0	0	0	Wh
606	2025-07-24	0	0	0	Wh
607	2025-07-25	0	0	0	Wh
608	2025-07-26	0	0	0	Wh
609	2025-07-27	0	0	0	Wh
610	2025-07-28	0	0	0	Wh
611	2025-07-29	5362	2520	3467	Wh
612	2025-07-30	3692	4483	1568	Wh
613	2025-07-31	5335	4644	2782	Wh
614	2025-08-01	5233	4697	2534	Wh
615	2025-08-02	7831	3570	4867	Wh
616	2025-08-03	3824	4006	1752	Wh
617	2025-08-04	7286	2188	4867	Wh
618	2025-08-05	8689	3656	6658	Wh
619	2025-08-06	5763	4747	3337	Wh
620	2025-08-07	9490	3453	7600	Wh
621	2025-08-08	7979	3794	5436	Wh
622	2025-08-09	9859	3223	8025	Wh
623	2025-08-10	8416	3538	5922	Wh
624	2025-08-11	9766	4093	6535	Wh
625	2025-08-12	8576	2732	7096	Wh
626	2025-08-13	8908	4993	5820	Wh
627	2025-08-14	7064	5071	5868	Wh
628	2025-08-15	9180	5554	6228	Wh
629	2025-08-16	7693	5528	5658	Wh
630	2025-08-17	7734	2547	5265	Wh
631	2025-08-18	9093	4525	7291	Wh
632	2025-08-19	8782	4954	6755	Wh
633	2025-08-20	7405	3299	5236	Wh
634	2025-08-21	6372	5663	3876	Wh
635	2025-08-22	3882	4028	1769	Wh
636	2025-08-23	6078	1671	4215	Wh
637	2025-08-24	4551	2947	2168	Wh
638	2025-08-25	7368	4983	4559	Wh
639	2025-08-26	7003	5581	4797	Wh
640	2025-08-27	5198	4651	3098	Wh
641	2025-08-28	3077	6150	1446	Wh
642	2025-08-29	6318	5597	4654	Wh
643	2025-08-30	5613	5304	2687	Wh
644	2025-08-31	4736	3538	2928	Wh
645	2025-09-01	2340	6200	661	Wh
646	2025-09-02	5316	4535	4139	Wh
647	2025-09-03	5371	4994	2862	Wh
648	2025-09-04	4758	4812	2963	Wh
649	2025-09-05	4995	4127	3003	Wh
650	2025-09-06	5923	3233	4191	Wh
651	2025-09-07	5584	5186	3711	Wh
652	2025-09-08	4486	4990	2480	Wh
653	2025-09-09	4248	4351	2621	Wh
654	2025-09-10	2553	4727	758	Wh
655	2025-09-11	2550	5236	711	Wh
656	2025-09-12	4188	5093	2449	Wh
657	2025-09-13	3232	4741	1479	Wh
658	2025-09-14	5116	4639	2708	Wh
659	2025-09-15	4230	6148	2276	Wh
660	2025-09-16	3202	3873	1549	Wh
661	2025-09-17	2554	5932	858	Wh
662	2025-09-18	1907	5889	617	Wh
663	2025-09-19	5370	3231	3708	Wh
664	2025-09-20	4738	5284	2719	Wh
665	2025-09-21	3714	4546	1713	Wh
666	2025-09-22	3728	8327	1456	Wh
667	2025-09-23	3534	18347	1545	Wh
668	2025-09-24	5219	10194	3061	Wh
669	2025-09-25	2662	5007	765	Wh
670	2025-09-26	3271	6232	1081	Wh
671	2025-09-27	2114	6083	540	Wh
672	2025-09-28	3549	7783	1437	Wh
673	2025-09-29	4247	5948	2211	Wh
674	2025-09-30	3787	7091	2142	Wh
675	2025-10-01	2670	7040	938	Wh
676	2025-10-02	3744	4867	2304	Wh
677	2025-10-03	4010	4269	1791	Wh
678	2025-10-04	1068	9487	29	Wh
679	2025-10-05	1900	6267	297	Wh
680	2025-10-06	1060	6925	71	Wh
681	2025-10-07	1605	5980	300	Wh
682	2025-10-08	1418	6716	216	Wh
683	2025-10-09	1790	5385	399	Wh
684	2025-10-10	1598	5863	280	Wh
685	2025-10-11	1150	6301	39	Wh
686	2025-10-12	1351	6760	146	Wh
687	2025-10-13	2194	7921	582	Wh
688	2025-10-14	1326	8109	227	Wh
689	2025-10-15	782	6972	1	Wh
690	2025-10-16	1748	5903	390	Wh
691	2025-10-17	1650	8256	182	Wh
692	2025-10-18	2148	8097	918	Wh
693	2025-10-19	2443	7232	805	Wh
694	2025-10-20	684	7649	0	Wh
695	2025-10-21	1294	4551	244	Wh
696	2025-10-22	1947	7645	336	Wh
697	2025-10-23	1244	5623	244	Wh
698	2025-10-24	1628	5681	161	Wh
699	2025-10-25	867	7812	28	Wh
700	2025-10-26	1044	6877	70	Wh
701	2025-10-27	1451	7805	199	Wh
702	2025-10-28	774	8473	43	Wh
703	2025-10-29	1349	5937	301	Wh
704	2025-10-30	1349	7201	270	Wh
705	2025-10-31	1625	5505	223	Wh
706	2025-11-01	418	10594	0	Wh
707	2025-11-02	1222	7658	95	Wh
708	2025-11-03	1369	7280	330	Wh
709	2025-11-04	1315	5600	278	Wh
710	2025-11-05	1208	7452	226	Wh
711	2025-11-06	993	7471	186	Wh
712	2025-11-07	747	7328	0	Wh
713	2025-11-08	561	9617	10	Wh
714	2025-11-09	344	10751	0	Wh
715	2025-11-10	1152	6127	75	Wh
716	2025-11-11	952	6922	31	Wh
717	2025-11-12	1314	7001	136	Wh
718	2025-11-13	1090	6219	147	Wh
719	2025-11-14	346	8096	0	Wh
720	2025-11-15	133	9496	0	Wh
721	2025-11-16	208	10310	0	Wh
722	2025-11-17	1053	8466	24	Wh
723	2025-11-18	862	5990	134	Wh
724	2025-11-19	801	7877	47	Wh
725	2025-11-20	842	4985	93	Wh
726	2025-11-21	824	37408	46	Wh
727	2025-11-22	861	28029	0	Wh
728	2025-11-23	1237	36519	14	Wh
729	2025-11-24	522	13502	8	Wh
730	2025-11-25	794	7458	89	Wh
731	2025-11-26	720	7765	7	Wh
732	2025-11-27	679	14061	12	Wh
733	2025-11-28	353	9526	0	Wh
734	2025-11-29	825	6922	62	Wh
735	2025-11-30	757	10547	6	Wh
736	2025-12-01	881	8794	32	Wh
737	2025-12-02	607	6004	0	Wh
738	2025-12-03	432	8879	0	Wh
739	2025-12-04	551	7191	16	Wh
740	2025-12-05	908	12797	41	Wh
741	2025-12-06	277	8957	3	Wh
742	2025-12-07	447	9802	0	Wh
743	2025-12-08	331	7260	1	Wh
744	2025-12-09	233	7840	0	Wh
745	2025-12-10	462	8700	0	Wh
746	2025-12-11	949	6407	48	Wh
747	2025-12-12	898	7921	27	Wh
748	2025-12-13	402	7879	0	Wh
749	2025-12-14	900	15115	4	Wh
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
ozilChlCvg1lOBi2cfN4mWEtzpBsOQgHSuIFMRQ5	\N	\N		YTozOntzOjY6Il90b2tlbiI7czo0MDoiQXIwSVlidzlWcTY4ekRrRVppYWNRenM3VDZPU0pxSlg0d3k5SWFCTSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6ODoiaHR0cDovLzoiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19	1761550100
RQMDnikF8t2LS9Pu7ZYuXtJwhUr4AOUTpWoWYsj5	\N	127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:144.0) Gecko/20100101 Firefox/144.0	YTozOntzOjY6Il90b2tlbiI7czo0MDoiUmRGaEJBdWdnQW5tak5QZFdoSEdWQ2hYUW1vU3pIdnpnVzJzMEVlQiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjY6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9zYXZlIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1761556180
KXtnXnuXz14Kn6HMGUeDuEq7nzARrNOEkRnvjf5s	\N	192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoiQTZNNDBwRTZTWXh3T01ZenNDRU1lU2hWNWl3Q0ZrenA5SkZ2VndaMiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjY6Imh0dHA6Ly9sb2NhbGhvc3Q6OTA4MC9zYXZlIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1763720932
yRMll0B8WJH9gsYQbDEqnDFogOM6PtrxKKg0Qpjp	\N	\N		YTozOntzOjY6Il90b2tlbiI7czo0MDoieldRanV3eGdzRnFDNEdwYWlRV1RWc0NBQVY4WDZiMDI0RjJSWjVHNiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6ODoiaHR0cDovLzoiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19	1765205964
7sP6ncvlQmzhokXxaYu3viwLmTncvyc2u8i9dBYc	\N	\N		YTozOntzOjY6Il90b2tlbiI7czo0MDoiN3QwN25CWWRCcTk0Q3RuUVNrWkRNVUFwQ1I1TTg3b3NkQTk5ZTBKQyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6ODoiaHR0cDovLzoiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19	1765281758
qC9m3yQHZVIhkzzldIuYJhWnVt2xgN8cLxOb60g4	\N	192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoiaGpLVEFyNlF5M3ZKV3JkbEQ5Y2p1WmVTMUlraWY2VXVGT0xZTlN0byI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjY6Imh0dHA6Ly9sb2NhbGhvc3Q6OTA4MC9zYXZlIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==	1761556069
rE6HjwRTy5LLs6iX8ky8vxDqCQgvkpzJPLTDZLSZ	\N	192.168.65.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36	YTozOntzOjY6Il90b2tlbiI7czo0MDoib0o4cDJHOVN3UDZGUkJFbE44OElWdkttTEJnOEZraVhDMktYbWZpQyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6OTA4MCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1761569302
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: housecontrol_user
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at) FROM stdin;
\.


--
-- Name: electricity_prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: housecontrol_user
--

SELECT pg_catalog.setval('public.electricity_prices_id_seq', 4, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: housecontrol_user
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: housecontrol_user
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: housecontrol_user
--

SELECT pg_catalog.setval('public.migrations_id_seq', 5, true);


--
-- Name: production_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: housecontrol_user
--

SELECT pg_catalog.setval('public.production_data_id_seq', 749, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: housecontrol_user
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: electricity_prices electricity_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.electricity_prices
    ADD CONSTRAINT electricity_prices_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: production_data production_data_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.production_data
    ADD CONSTRAINT production_data_pkey PRIMARY KEY (id);


--
-- Name: production_data production_data_unique_idx; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.production_data
    ADD CONSTRAINT production_data_unique_idx UNIQUE (date_of_production);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: housecontrol_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: housecontrol_user
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: housecontrol_user
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: housecontrol_user
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0 (Debian 17.0-1.pgdg110+1)
-- Dumped by pg_dump version 17.0 (Debian 17.0-1.pgdg110+1)

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

DROP DATABASE postgres;
--
-- Name: postgres; Type: DATABASE; Schema: -; Owner: housecontrol_user
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE postgres OWNER TO housecontrol_user;

\connect postgres

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
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: housecontrol_user
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

