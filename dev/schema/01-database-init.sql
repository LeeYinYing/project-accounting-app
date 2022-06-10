--Initialize database, admin role, and schema
CREATE role harmony_owner INHERIT NOLOGIN;
CREATE DATABASE harmony OWNER harmony_owner LOCALE 'en_CA.utf8';
CREATE USER harmony_admin ENCRYPTED PASSWORD 'harmony' IN GROUP harmony_owner;
DROP SCHEMA IF EXISTS public;

-- Create trigger to automatically set table owner to harmony_owner
CREATE OR REPLACE FUNCTION trg_create_set_owner()
 RETURNS event_trigger
 LANGUAGE plpgsql
AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands() WHERE command_tag='CREATE TABLE' LOOP
    EXECUTE format('ALTER TABLE %s OWNER TO harmony_owner', obj.object_identity);
  END LOOP;
END;
$$;

CREATE EVENT TRIGGER trg_create_set_owner
 ON ddl_command_end
 WHEN tag IN ('CREATE TABLE')
 EXECUTE PROCEDURE trg_create_set_owner();
 
-- Create accounting schema
CREATE SCHEMA IF NOT EXISTS harmony_accounting AUTHORIZATION harmony_owner;
SET search_path = harmony_accounting;

-- Create tables
CREATE TABLE IF NOT EXISTS harmony_accounting.payment_types(
  id serial PRIMARY KEY,
  name VARCHAR(225) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS harmony_accounting.admin_expense_types(
  id serial PRIMARY KEY,
  name VARCHAR(225) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS harmony_accounting.admin_expenses(
  id serial PRIMARY KEY,
  type_id INT NOT NULL,
  name VARCHAR(225) NOT NULL,
  date DATE NOT NULL,
  amount MONEY NOT NULL,
  cheque_number VARCHAR(50),
  receipt VARCHAR(50),
  note TEXT,
  FOREIGN KEY (type_id) REFERENCES harmony_accounting.admin_expense_types (id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.fundings(
  id serial PRIMARY KEY,
  name VARCHAR(225) NOT NULL,
  year INT NOT NULL,
  organization VARCHAR(100) NOT NULL,
  amount MONEY NOT NULL,
  cheque VARCHAR(50),
  note TEXT
);

CREATE TABLE IF NOT EXISTS harmony_accounting.concerts(
  id serial PRIMARY KEY,
  year INT NOT NULL,
  location VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.concert_expense_types(
  id serial PRIMARY KEY,
  name VARCHAR(225) UNIQUE NOT NULL
 );
 
 CREATE TABLE IF NOT EXISTS harmony_accounting.concert_expenses(
   id serial PRIMARY KEY,
   concert_id INT NOT NULL,
   expense_id INT NOT NULL,
   budget_amount MONEY,
   actual_amount MONEY,
   cheque VARCHAR(50),
   note TEXT,
   FOREIGN KEY (concert_id) REFERENCES harmony_accounting.concerts(id),
   FOREIGN KEY (expense_id) REFERENCES harmony_accounting.concert_expense_types(id)
 );

CREATE TABLE IF NOT EXISTS harmony_accounting.concert_income_types(
  id SERIAL PRIMARY KEY,
  name VARCHAR(225) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS harmony_accounting.concert_incomes(
  id SERIAL PRIMARY KEY,
  concert_id INT NOT NULL,
  income_id INT NOT NULL,
  amount MONEY,
  payment_type INT,
  cheque VARCHAR(50),
  receipt VARCHAR(50),
  note TEXT,
  FOREIGN KEY (concert_id) REFERENCES harmony_accounting.concerts(id),
  FOREIGN KEY (income_id) REFERENCES harmony_accounting.concert_income_types(id),
  FOREIGN KEY (payment_type) REFERENCES harmony_accounting.payment_types(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.donations(
  id SERIAL PRIMARY KEY,
  name VARCHAR(225) NOT NULL,
  date DATE NOT NULL,
  organization VARCHAR(100),
  amount MONEY NOT NULL,
  payment_type INT NOT NULL,
  cheque VARCHAR(50),
  receipt VARCHAR(50),
  note TEXT,
  FOREIGN KEY (payment_type) REFERENCES harmony_accounting.payment_types(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.misc_transactions(
  id SERIAL PRIMARY KEY,
  name VARCHAR(225) NOT NULL,
  date DATE NOT NULL,
  payment_type INT,
  amount MONEY NOT NULL,
  credit BOOL NOT NULL,
  cheque VARCHAR(50),
  receipt VARCHAR(50),
  note TEXT,
  FOREIGN KEY (payment_type) REFERENCES harmony_accounting.payment_types(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.members(
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  performer BOOL NOT NULL,
  phone VARCHAR(15) CHECK (phone ~ $$^\(\d{3}\)\d{3}-\d{4}\Z$$),
  email VARCHAR(50) CHECK (email ~ $$^[\w\.]+@([\w]+\.)+[\w]{2,4}\Z$$),
  street VARCHAR(50),
  city VARCHAR(50),
  province VARCHAR(50),
  postal_code VARCHAR(10) CHECK (postal_code ~ $$^[A-Z]\d[A-z]\s\d[A-Z]\d\Z$$),
  active BOOL NOT NULL
);

CREATE TABLE IF NOT EXISTS harmony_accounting.deposit_items(
  id SERIAL PRIMARY KEY,
  name varchar(225) UNIQUE NOT NULL,
  amount MONEY NOT NULL
);

CREATE TABLE IF NOT EXISTS harmony_accounting.deposits(
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL,
  item_id INT NOT NULL,
  paid BOOL NOT NULL,
  payment_type INT,
  payment_date DATE,
  payment_cheque VARCHAR(50),
  payment_receipt VARCHAR(50),
  payment_note TEXT,
  refunded BOOL NOT NULL,
  refund_date DATE,
  refund_amount MONEY,
  refund_cheque VARCHAR(50),
  refund_note TEXT,
  FOREIGN KEY (member_id) REFERENCES harmony_accounting.members(id),
  FOREIGN KEY (item_id) REFERENCES harmony_accounting.deposit_items(id),
  FOREIGN KEY (payment_type) REFERENCES harmony_accounting.payment_types(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.performance_types(
  id SERIAL PRIMARY KEY,
  name VARCHAR(225) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS harmony_accounting.performances(
  id SERIAL PRIMARY KEY,
  name VARCHAR(225) NOT NULL,
  location VARCHAR(100) NOT NULL,
  date DATE NOT NULL,
  duration_hour FLOAT NOT NULL,
  solo BOOL NOT NULL,
  type INT NOT NULL,
  payment_amount MONEY,
  payment_type INT, 
  payment_receipt VARCHAR(50),
  payment_note TEXT,
  FOREIGN KEY (type) REFERENCES harmony_accounting.performance_types(id),
  FOREIGN KEY (payment_type) REFERENCES harmony_accounting.payment_types(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.member_performances(
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL,
  performance_id INT NOT NULL,
  performer BOOL NOT NULL,
  FOREIGN KEY (member_id) REFERENCES harmony_accounting.members(id),
  FOREIGN KEY (performance_id) REFERENCES harmony_accounting.performances(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.member_honorariums(
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL,
  year INT NOT NULL,
  performance_count INT NOT NULL,
  performance_hour FLOAT NOT NULL,
  amount MONEY NOT NULL,
  cheque VARCHAR(50),
  FOREIGN KEY (member_id) REFERENCES harmony_accounting.members(id)
);
  
CREATE TABLE IF NOT EXISTS harmony_accounting.membership_payments(
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL,
  year INT NOT NULL,
  amount MONEY NOT NULL,
  payment_type INT,
  payment_cheque VARCHAR(50),
  payment_receipt VARCHAR(50),
  FOREIGN KEY (member_id) REFERENCES harmony_accounting.members(id),
  FOREIGN KEY (payment_type) REFERENCES harmony_accounting.payment_types(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.services(
  id SERIAL PRIMARY KEY,
  name VARCHAR(225) UNIQUE NOT NULL,
  amount_per_hour MONEY NOT NULL,
  year INT NOT NULL
);

CREATE TABLE IF NOT EXISTS harmony_accounting.member_services(
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL,
  service_id INT NOT NULL,
  hour FLOAT NOT NULL,
  date DATE,
  FOREIGN KEY (member_id) REFERENCES harmony_accounting.members(id),
  FOREIGN KEY (service_id) REFERENCES harmony_accounting.services(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.exams(
  id SERIAL PRIMARY KEY,
  year INT NOT NULL,
  grade VARCHAR(10) NOT NULL,
  fee MONEY NOT NULL
);

CREATE TABLE IF NOT EXISTS harmony_accounting.exam_awards(
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL,
  exam_id INT NOT NULL,
  amount MONEY NOT NULL,
  year INT NOT NULL,
  cheque VARCHAR(50),
  exam_grade INT,
  exam_mark FLOAT,
  FOREIGN KEY (member_id) REFERENCES harmony_accounting.members(id),
  FOREIGN KEY (exam_id) REFERENCES harmony_accounting.exams(id)
);

CREATE TABLE IF NOT EXISTS harmony_accounting.volunteer_awards(
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL,
  award_name VARCHAR(225) NOT NULL,
  amount MONEY NOT NULL,
  year INT NOT NULL,
  cheque VARCHAR(50),
  note TEXT,
  FOREIGN KEY (member_id) REFERENCES harmony_accounting.members(id)
);