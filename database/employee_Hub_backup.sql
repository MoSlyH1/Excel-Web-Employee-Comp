--
-- PostgreSQL database dump
--

\restrict mBXYHKEHoaxyMJg6PmuO8bss4kYCke4CrniwHxUuzsCFz1odu1HskTUGoW92qdg

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

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
-- Name: search_employees(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_employees(search_query text) RETURNS TABLE(emp_id integer, employee_id_num text, full_name text, department text, job_position text, match_source text)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT
    e.id,
    e.employee_id,
    e.full_name,
    e.department,
    e.job_position,
    'employee'::TEXT AS match_source
  FROM employees e
  WHERE
    e.full_name ILIKE '%' || search_query || '%'
    OR e.employee_id ILIKE '%' || search_query || '%'
    OR e.email ILIKE '%' || search_query || '%'
    OR e.department ILIKE '%' || search_query || '%'
    OR e.job_position ILIKE '%' || search_query || '%'

  UNION

  SELECT DISTINCT
    e.id,
    e.employee_id,
    e.full_name,
    e.department,
    e.job_position,
    'document: ' || d.file_name AS match_source
  FROM employees e
  INNER JOIN employee_documents d ON d.employee_id = e.id
  WHERE d.file_name ILIKE '%' || search_query || '%'

  ORDER BY full_name;
END;
$$;


ALTER FUNCTION public.search_employees(search_query text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: company_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_documents (
    id integer NOT NULL,
    file_name text NOT NULL,
    file_path text NOT NULL,
    file_size bigint,
    mime_type text,
    uploaded_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.company_documents OWNER TO postgres;

--
-- Name: company_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.company_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.company_documents_id_seq OWNER TO postgres;

--
-- Name: company_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.company_documents_id_seq OWNED BY public.company_documents.id;


--
-- Name: company_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_info (
    id integer NOT NULL,
    company_name text,
    trade_name text,
    ministry_reg_number text,
    social_security_number text,
    governorate text,
    district text,
    area text,
    neighborhood text,
    street text,
    building text,
    floor text,
    property_number text,
    phone1 text,
    phone2 text,
    fax text,
    po_box text,
    email text,
    contact_name text,
    contact_title text,
    contact_phone text,
    contact_fax text,
    created_at timestamp with time zone DEFAULT now(),
    cadastral_area text,
    po_box_number text,
    po_box_area text,
    attached_requests_count integer,
    submitted_by_name text,
    submitted_by_title text,
    submitted_date text,
    book_number text,
    book_submitted_date text
);


ALTER TABLE public.company_info OWNER TO postgres;

--
-- Name: company_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.company_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.company_info_id_seq OWNER TO postgres;

--
-- Name: company_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.company_info_id_seq OWNED BY public.company_info.id;


--
-- Name: employee_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_documents (
    id integer NOT NULL,
    employee_id integer NOT NULL,
    file_name text NOT NULL,
    file_path text NOT NULL,
    file_size bigint,
    mime_type text,
    uploaded_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.employee_documents OWNER TO postgres;

--
-- Name: employee_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_documents_id_seq OWNER TO postgres;

--
-- Name: employee_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_documents_id_seq OWNED BY public.employee_documents.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    employee_id text NOT NULL,
    full_name text NOT NULL,
    nationality text,
    email text,
    phone text,
    contract_type text,
    department text,
    job_position text,
    grade numeric,
    joining_date date,
    start_date date,
    left_date date,
    hiring_date date,
    left_2_date date,
    hiring_2_date date,
    status numeric,
    end_date date,
    wage numeric,
    wage_type text,
    basic_salary numeric,
    other_allowances numeric,
    bank_account_nb text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    first_name text,
    last_name text,
    father_name text,
    mother_name text,
    gender text,
    place_of_birth text,
    date_of_birth date,
    register_number text,
    register_place text,
    id_card_number text,
    marital_status text,
    number_of_children integer,
    has_financial_number boolean,
    personal_financial_number text,
    ministry_registration_number text,
    spouse_name text,
    spouse_maiden_name text,
    spouse_father_name text,
    spouse_mother_name text,
    spouse_nationality text,
    spouse_place_of_birth text,
    spouse_date_of_birth date,
    spouse_id_card_number text,
    spouse_register_number text,
    spouse_register_place text,
    spouse_works boolean,
    spouse_work_details text,
    spouse_registration_number text,
    governorate text,
    district text,
    area text,
    neighborhood text,
    street text,
    building text,
    floor text,
    property_number text,
    fax text,
    spouse_work_sector text,
    spouse_work_company text,
    spouse_registration_number_2 text,
    po_box_number text,
    po_box_area text,
    social_security_number text,
    work_start_date date,
    social_security_start_date date,
    r3_notes text,
    r3_social_security_start_date date,
    employer_name text,
    employer_title text,
    r3_financial_number text,
    r3_registration_date date,
    r3_rejection_reason text,
    phone2 character varying(50)
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_id_seq OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: company_documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_documents ALTER COLUMN id SET DEFAULT nextval('public.company_documents_id_seq'::regclass);


--
-- Name: company_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_info ALTER COLUMN id SET DEFAULT nextval('public.company_info_id_seq'::regclass);


--
-- Name: employee_documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_documents ALTER COLUMN id SET DEFAULT nextval('public.employee_documents_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Data for Name: company_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_documents (id, file_name, file_path, file_size, mime_type, uploaded_at) FROM stdin;
12	Ø´Ø±ÙØ©Ø§Ø¨ÙÙØ§Ø¯ÙÙÙØ³Ø´.Ù.Ù_1_R3-1_20260313_180531.pdf	company/1773417931896_______________________________.__.___1_R3-1_20260313_180531.pdf	192441	application/pdf	2026-03-13 18:05:31.905741
13	R3_JAMO_20260313_180613.pdf	company/1773417973975_R3_JAMO_20260313_180613.pdf	261016	application/pdf	2026-03-13 18:06:13.984481
\.


--
-- Data for Name: company_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_info (id, company_name, trade_name, ministry_reg_number, social_security_number, governorate, district, area, neighborhood, street, building, floor, property_number, phone1, phone2, fax, po_box, email, contact_name, contact_title, contact_phone, contact_fax, created_at, cadastral_area, po_box_number, po_box_area, attached_requests_count, submitted_by_name, submitted_by_title, submitted_date, book_number, book_submitted_date) FROM stdin;
3	شركة ابولا ديليس ش.م.ل	Abela Delices sal	00000	000000	xxxxx	xxxxxx	xxx	xxxx	xx	xx	0	00	000000	000000	00	\N	X@example.com	xx	xxx	00000	00	2026-03-12 10:34:06.270922+02	xxx	000	xxxx	1	xxx	xx	2026-03-12	00	2026-03-12
1	شركة ابولا ديليس ش.م.ل	Abela Delices sal	00000	000000	xxxxx	xxxxxx	xxx	xxxx	xx	xx	0	00	000000	000000	00	\N	X@example.com	xx	xxx	00000	00	2026-03-12 09:15:41.323858+02	xxx	000	xxxx	1	xxx	xx	2026-03-12	00	2026-03-12
2	شركة ابولا ديليس ش.م.ل	Abela Delices sal	00000	000000	xxxxx	xxxxxx	xxx	xxxx	xx	xx	0	00	000000	000000	00	\N	X@example.com	xx	xxx	00000	00	2026-03-12 10:33:58.40497+02	xxx	000	xxxx	1	xxx	xx	2026-03-12	00	2026-03-12
\.


--
-- Data for Name: employee_documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee_documents (id, employee_id, file_name, file_path, file_size, mime_type, uploaded_at) FROM stdin;
48	52	R4_JAMO_20260313.pdf	52/1773417633850_R4_JAMO_20260313.pdf	366648	application/pdf	2026-03-13 18:00:33.861747+02
50	52	R3_JAMO_20260313_180613.pdf	52/1773417974340_R3_JAMO_20260313_180613.pdf	261016	application/pdf	2026-03-13 18:06:14.342716+02
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, employee_id, full_name, nationality, email, phone, contract_type, department, job_position, grade, joining_date, start_date, left_date, hiring_date, left_2_date, hiring_2_date, status, end_date, wage, wage_type, basic_salary, other_allowances, bank_account_nb, created_at, updated_at, first_name, last_name, father_name, mother_name, gender, place_of_birth, date_of_birth, register_number, register_place, id_card_number, marital_status, number_of_children, has_financial_number, personal_financial_number, ministry_registration_number, spouse_name, spouse_maiden_name, spouse_father_name, spouse_mother_name, spouse_nationality, spouse_place_of_birth, spouse_date_of_birth, spouse_id_card_number, spouse_register_number, spouse_register_place, spouse_works, spouse_work_details, spouse_registration_number, governorate, district, area, neighborhood, street, building, floor, property_number, fax, spouse_work_sector, spouse_work_company, spouse_registration_number_2, po_box_number, po_box_area, social_security_number, work_start_date, social_security_start_date, r3_notes, r3_social_security_start_date, employer_name, employer_title, r3_financial_number, r3_registration_date, r3_rejection_reason, phone2) FROM stdin;
1	ROYO	Rony Younes	Lebanese	ronyyounes@gmail.com	70/953864	Monthly	HO	HR	\N	2016-02-18	2016-03-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2	CHHA	Charbel Hamam	Lebanese	chef_charbel_h@hotmail.com	03/187980	Monthly	HO	Operation manager	\N	\N	2016-08-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	ELBA	Elie Baroud	Lebanese	ebaroud89@hotmail.com	71/650777	Monthly	HO	Accounting manager	\N	2012-09-01	2013-02-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4	JONA	Joleen Nabhan	Lebanese	joleennabhan73@gmail.com	71/967838	Monthly	HO	Food Safety manager	\N	2021-03-16	2021-08-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5	LAHA	Lara Harik	Lebanese	laraharik4@gmail.com	70/537943	Monthly	HO	Food Safety assistant	\N	2025-01-03	2025-06-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6	ABAK	Abed Al Massih Aghnatios	Lebanese	agnatios.abdelmassih@gmail.com	76/101319	Monthly	HO	Store Keeper	\N	2013-02-01	2013-02-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7	MOAL	Mohamad Alawiye	Lebanese	Alawieh423@gmail.com	03/562213	Monthly	HO	Purchase	\N	2020-09-24	2021-05-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	ABAK	Abed El Kader Akawi	Lebanese	user.abed28@gmail.com	03/041057	Monthly	Baabda	Chef De partie	\N	2021-12-01	2022-05-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9	ABAB	Abbas Abboud	Lebanese	abbassaboud713@gmail.com	71/496054	Monthly	Baabda	Chef De partie	\N	2025-07-16	2025-09-01	\N	\N	\N	\N	\N	2026-02-28	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
10	ALSEI	Ali Seif El Dine	Lebanese	saifedine.ali88@gmail.com	03/920157	Monthly	baabda	Demi chef De partie	\N	2021-08-30	2021-11-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
11	BIBA	Bilal Bachnaty	Lebanese	\N	78/867469	Monthly	Baabda	Kitchen Commis	\N	2023-01-06	2023-11-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
12	FAIZ	Fadia El Izzo	Lebanese	\N	70/141028	Monthly	Baabda	Kitchen Commis	\N	2023-05-03	2023-11-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
13	HAIM	Haidar Moustafa	Lebanese	haidarmostafa27@gmail.com	70896551	Monthly	Baabda	Demi chef De partie	\N	2025-09-15	2025-12-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
14	LAWA	Lara Wakim	Lebanese	lara.wakim92@outlook.com	76/770299	Monthly	Baabda	Store Keeper	\N	2022-07-12	2022-10-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
15	MOER	Mohamad Erhayem	Lebanese	Hamoudi.rhaim@gmail.com	03/177947	Monthly	Baabda	Pastry Chef	\N	2018-10-15	2019-04-01	2022-07-31	2022-11-01	2025-02-28	2025-05-06	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
16	MOAR	Mohamad El Arab	Lebanese	omaralarab060@gmail.com	71/126278	Monthly	Baabda	Demi chef De partie	\N	2022-02-21	2022-10-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
17	MOHA	Mohamad Harb	Lebanese	Chefmohharb@gmail.com	70957548	Monthly	Baabda	Head Chef	\N	2013-02-01	2013-02-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
18	OMAR	Omar Al Arab	Lebanese	omararab856@gmail.com	03/404388	Monthly	Baabda	Kitchen Commis	\N	2025-04-21	2025-09-01	\N	\N	\N	\N	\N	2026-02-28	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
19	ABCH	Abdallah Choukor	Lebanese	shokorabdallah@gmail.com	78/984406	Monthly	LOG	Driver	\N	2023-07-31	2023-11-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
20	BIHA	Bilal Hassoun	Lebanese	bilal.hassoun@gmail.com	70/009981	Monthly	LOG	Driver	\N	2021-08-27	2021-11-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
21	HAAR	Hassan El Arab	Lebanese	arabhassan498@gmail.com	03/610781	Monthly	LOG	Driver	\N	2025-10-29	2025-12-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
22	HASA	Hassan El Saiid	Lebanese	hasanalsaeed721@gmail.com	70/470817	Monthly	LOG	Driver	\N	2024-06-10	2024-09-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
23	KHTU	Khaled Turk	Lebanese	khaledturk29@gmail.com	70/082184	Monthly	LOG	Driver	\N	2012-08-01	2012-08-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
24	MOFA	Mohamad Fakher El Dine	Lebanese	mohammadfakhreddine267@gmail.com	76/917245	Monthly	LOG	Driver	\N	2023-02-06	2023-03-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
25	HUMA	Hussein Al Mawla	Lebanese	almawla7@hotmail.com	71/149822	Monthly	RHUH	Head Chef	\N	2013-02-01	2013-02-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
26	MAAM	Malak Amro	Lebanese	malakjad12345@gmail.com	70/092649	Monthly	RHUH Cafeteria	waiter	\N	2012-11-01	2012-11-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
27	OUAL	Oussama Alameh	Lebanese	ossamaalameh4@gmail.com	71/650568	Monthly	RHUH Cafeteria	waiter	\N	2015-07-01	2015-07-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
28	RABO	Rawad Bou Izz	Lebanese	ro_ro_1500@hotmail.com	71315457	Monthly	RHUH Cafeteria	waiter	\N	2012-11-01	2012-11-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
29	AMAL	Amani Al Ezza	Lebanese	amani.ezza95@icloud.com	03/612641	Monthly	RHUH Dietary	Dietition	\N	2019-07-01	2019-07-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
30	FEFA	Ferial Fattouh	Lebanese	ferial.fattouh1@hotmail.com	71/203922	Monthly	RHUH Dietary	Dietition	\N	2023-08-24	2023-12-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
31	GHKO	Ghiwa kolailat	Lebanese	d.ghiwakolailat@gmail.com	78/848807	Monthly	RHUH Dietary	Dietition	\N	2024-01-31	2024-09-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
32	HAMMO	Hala Mohsen	Lebanese	halayehyamohsen@gmail.com	70882387	Monthly	RHUH Dietary	Dietition	\N	2022-10-11	2023-02-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
33	TANA	Tala Nasser	Lebanese	talanasser152@gmail.com	71/170224	Monthly	RHUH Dietary	Dietition	\N	2024-11-01	2025-03-01	2025-09-01	2026-03-31	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
34	AHHA	Ahmad Al Harake	Lebanese	\N	81/041001	Monthly	RHUH Runner	Runner	\N	2013-02-01	2013-02-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
35	ALIK	Ali Kassem	Lebanese	alihassankassem4@gmail.com	71509449	Monthly	RHUH Runner	Runner	\N	2025-12-15	\N	\N	\N	\N	\N	\N	\N	\N	Part time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
36	HAYA	Hadi Yazbek	Lebanese	hadiyazbek390@gmail.com	70/852264	Monthly	RHUH Runner	Runner	\N	2025-03-17	2025-09-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
37	HADI	Hanady Dia	Lebanese	hanadidia17111999@gmail.com	81/057769	Monthly	RHUH Runner	Runner	\N	2025-01-27	2025-06-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
38	IMMC	Iman Mcheik	Lebanese	mshkayman@gmail.com	78/923820	Monthly	RHUH Runner	Runner	\N	2025-03-17	2025-12-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
39	KAAKE	kassem Akil	Lebanese	ksmakil16@gmail.com	70/033603	Monthly	RHUH Runner	Runner	\N	2023-05-12	2023-12-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
40	SAHA	Samia Hamdoun	Lebanese	samia.hamdoun123@gmail.com	03/775624	Monthly	RHUH Runner	Runner	\N	2019-06-01	2019-06-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
41	ALKAL	Ali Al Arab	Lebanese	alialarab548@gmail.com	03/451192	Monthly	RHUH Kitchen	Demi chef De partie	\N	2022-11-18	2023-02-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
42	ALKN	Ali kanaan	Lebanese	majd_kn06@hotmail.com	03/058330	Monthly	RHUH Kitchen	Butcher	\N	2011-04-01	2011-04-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
43	ASDA	Ali Saada	Lebanese	abohusseinsaada@gmail.com	03/968463	Monthly	RHUH Kitchen	Demi chef De partie	\N	\N	2016-01-02	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
44	ALAM	Aly Amro	Lebanese	amro14763@gmail.com	76/968210	Monthly	RHUH Kitchen	Kitchen Commis	\N	2022-09-05	2023-02-01	\N	\N	\N	\N	\N	2026-01-31	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
45	HUKA	Hussein Kaouk	Lebanese	hkaouk55@gmail.com	76/736586	Monthly	RHUH Kitchen	Kitchen Commis	\N	2025-05-26	2025-09-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
46	LAYL	Layla Al Mawla	Lebanese	leynomawla@gmail.com	76/021820	Monthly	RHUH Kitchen	Kitchen Commis	\N	2025-12-15	\N	\N	\N	\N	\N	\N	\N	\N	Part time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
47	MARI	Mariam Ghazzal	Lebanese	Mariam.gh@email.com	76/381018	Monthly	RHUH Kitchen	Demi chef De partie	\N	2025-10-07	\N	\N	\N	\N	\N	\N	\N	\N	Part time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
48	MOHO	Mohamad Onaissy	Lebanese	mohammadalionaissy4@gmail.com	81/833524	Monthly	RHUH Kitchen	Demi chef De partie	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Part time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
49	ELHA	Elie Habshy	Lebanese	habchycelie@gmail.com	81/353945	Monthly	HO	Junior Accounting	\N	\N	2025-08-01	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
50	MOAM	Mohamad Al Masri	Lebanese	elmasrimo@hotmail.com	71/167812	Monthly	HO	Cost Controller	\N	2019-11-08	\N	\N	\N	\N	\N	\N	\N	\N	full time	\N	\N	\N	2026-03-07 20:44:17.939952+02	2026-03-07 20:44:17.939952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
52	JAMO	Jad Mosleh	Lebanese	jadd7748@gmail.com	76330961	part time	IT	XXX	\N	2026-02-23	2026-03-01	\N	\N	\N	\N	\N	\N	\N	full time	100	0	100	2026-03-09 13:57:34.629702+02	2026-03-13 18:06:00.190857+02	Jad	Mosleh	Imad	Abla Yehia	ذكر	/	2002-07-04	000000	/	00000000	أعزب	0	t	12345	00000	X	X	X	X	X	X	1999-12-29	000000	000000	X	t	X	000000	XXX	XX	X	XXXX	XX	X	X	00000000	00000	B	AB	000000	00000000	XXX	\N	2026-03-12	\N	XXXX	2026-03-10	XX	XXX	0000	2026-03-09	XXXX	\N
\.


--
-- Name: company_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.company_documents_id_seq', 13, true);


--
-- Name: company_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.company_info_id_seq', 3, true);


--
-- Name: employee_documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_documents_id_seq', 50, true);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 52, true);


--
-- Name: company_documents company_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_documents
    ADD CONSTRAINT company_documents_pkey PRIMARY KEY (id);


--
-- Name: company_info company_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_info
    ADD CONSTRAINT company_info_pkey PRIMARY KEY (id);


--
-- Name: employee_documents employee_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_documents
    ADD CONSTRAINT employee_documents_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: idx_doc_emp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_doc_emp ON public.employee_documents USING btree (employee_id);


--
-- Name: idx_doc_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_doc_name ON public.employee_documents USING gin (to_tsvector('english'::regconfig, file_name));


--
-- Name: idx_emp_dept; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_emp_dept ON public.employees USING btree (department);


--
-- Name: idx_emp_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_emp_name ON public.employees USING gin (to_tsvector('english'::regconfig, full_name));


--
-- Name: employee_documents employee_documents_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_documents
    ADD CONSTRAINT employee_documents_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict mBXYHKEHoaxyMJg6PmuO8bss4kYCke4CrniwHxUuzsCFz1odu1HskTUGoW92qdg

