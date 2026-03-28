IF NOT EXISTS (
	SELECT name
	FROM sys.databases
	Where name='btl_database'
) CREATE DATABASE btl_database;
GO
USE btl_database;
GO
-- 1. persons
IF OBJECT_ID('dbo.persons','U') IS NULL
CREATE TABLE dbo.persons (
	person_id INT PRIMARY KEY IDENTITY(1,1),
	name VARCHAR(50) NOT NULL,
	dob DATE NOT NULL,
	sex VARCHAR(36) NOT NULL CHECK(sex in ('MALE','FEMALE')),
	tel VARCHAR(10) NOT NULL CHECK(LEN(tel)=10),
	address VARCHAR(255),
	password VARCHAR(30) NOT NULL
);
-- 2. person_roles
IF OBJECT_ID('dbo.person_roles','U') IS NULL
CREATE TABLE dbo.person_roles(
	person_id INT NOT NULL,
	role varchar(36) NOT NULL CHECK(role in ('DOCTOR','PATIENT','STAFF')),
	PRIMARY KEY(person_id,role),
	FOREIGN KEY(person_id) REFERENCES persons(person_id)
);
-- 3. doctors
IF OBJECT_ID('dbo.doctors','U') IS NULL
CREATE TABLE dbo.doctors(
	d_person_id INT PRIMARY KEY,
	speciality VARCHAR(30),
	level VARCHAR(36) NOT NULL CHECK(level in ('STANDARD', 'PROFESSOR')),
	FOREIGN KEY (d_person_id) REFERENCES persons(person_id)
);
-- 4.patients
IF OBJECT_ID('dbo.patients','U') IS NULL
CREATE TABLE dbo.patients(
	p_person_id INT PRIMARY KEY,
	first_seen int CHECK(first_seen in(0,1)),
	FOREIGN KEY(p_person_id) REFERENCES persons(person_id)
);
-- 5.staffs
IF OBJECT_ID('dbo.staffs','U') IS NULL
CREATE TABLE dbo.staffs(
	s_person_id INT PRIMARY KEY,
	workyear_start DATE,
	FOREIGN KEY (s_person_id) REFERENCES persons(person_id)
);
-- 6. time_slots
IF OBJECT_ID('dbo.time_slots','U') IS NULL
CREATE TABLE dbo.time_slots(
	slot_id INT PRIMARY KEY IDENTITY(1,1),
	d_person_id INT NOT NULL,
	start_time DATETIME NOT NULL,
	end_time DATETIME NOT NULL,
	-- cai nay phai co defaut chu =))
	status VARCHAR(36) NOT NULL CHECK(status in ('AVAILABLE', 'BOOKED', 'BLOCKED')),
	is_active INT CHECK(is_active in (0,1)) DEFAULT 1,
    FOREIGN KEY (d_person_id) REFERENCES doctors(d_person_id),
    UNIQUE (d_person_id, start_time, end_time),
    CHECK (end_time > start_time)
);
-- 7. appointments
IF OBJECT_ID('dbo.appointments','U') IS NULL
CREATE TABLE dbo.appointments(
	app_id INT PRIMARY KEY IDENTITY(1,1),
	-- bo di cung duoc
	s_person_id INT NOT NULL,
	p_person_id INT NOT NULL,
	slot_id INT NOT NULL,
	status VARCHAR(36) NOT NULL CHECK(status in('BOOKED', 'CHECKED_IN', 'CANCELLED', 'NO_SHOW')),
    FOREIGN KEY (s_person_id) REFERENCES staffs(s_person_id),
    FOREIGN KEY (p_person_id) REFERENCES patients(p_person_id),
    FOREIGN KEY (slot_id) REFERENCES time_slots(slot_id),
    UNIQUE (p_person_id, slot_id)
);

-- 8. encounters
IF OBJECT_ID('dbo.encounters','U') IS NULL
CREATE TABLE dbo.encounters(
	encounter_id INT PRIMARY KEY IDENTITY(1,1),
	app_id INT NOT NULL UNIQUE,
	start_time DATETIME,
	end_time DATETIME,
	diagnosis TEXT,
	symptom TEXT,
	notes TEXT,
	fee DECIMAL(10,2),
	FOREIGN KEY(app_id) REFERENCES appointments(app_id),
	CHECK(end_time>start_time)
);

-- 9. procedure_catalogs
IF OBJECT_ID('dbo.procedure_catalogs','U') IS NULL
CREATE TABLE dbo.procedure_catalogs(
	procedure_id INT PRIMARY KEY IDENTITY(1,1),
	name TEXT NOT NULL,
	type VARCHAR(50),
	description TEXT,
    default_price DECIMAL(10,2) NOT NULL,
    is_active int CHECK(is_active in(0,1)) DEFAULT 1
);

-- 10. procedure_orders
IF OBJECT_ID('dbo.procedure_orders','U') IS NULL
CREATE TABLE dbo.procedure_orders(
	porder_id INT PRIMARY KEY IDENTITY(1,1),
	encounter_id INT NOT NULL,
	procedure_id INT NOT NULL,
	status VARCHAR(36) NOT NULL CHECK(status in ('REQUESTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
	result TEXT,
	start_time DATETIME NOT NULL,
	end_time DATETIME,
    FOREIGN KEY (encounter_id) REFERENCES encounters(encounter_id),
    FOREIGN KEY (procedure_id) REFERENCES procedure_catalogs(procedure_id),
    UNIQUE (encounter_id, procedure_id)
);

-- 11. prescriptions
IF OBJECT_ID('dbo.prescriptions','U') IS NULL
CREATE TABLE dbo.prescriptions(
    prescription_id INT PRIMARY KEY IDENTITY(1,1),
    encounter_id INT UNIQUE,
    title VARCHAR(100),
    FOREIGN KEY (encounter_id) REFERENCES encounters(encounter_id)
);

-- 12. medicines
IF OBJECT_ID('dbo.medicines','U') IS NULL
CREATE TABLE dbo.medicines(
    medicine_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    strength VARCHAR(50),
    unit VARCHAR(50),
    is_active INT CHECK(is_active in(0,1)) DEFAULT 1
);


-- 13. prescription_lines
IF OBJECT_ID('dbo.prescription_lines','U') IS NULL
CREATE TABLE dbo.prescription_lines(
    prescription_id INT NOT NULL,
    medicine_id INT NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
	PRIMARY KEY (prescription_id, medicine_id),
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id),
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id),
    UNIQUE (prescription_id, medicine_id)
);

-- 14. payments
IF OBJECT_ID('dbo.payments','U') IS NULL
CREATE TABLE dbo.payments(
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    encounter_id INT NOT NULL,
    s_person_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method VARCHAR(36) CHECK(method in ('CASH', 'CARD', 'EWALLET')) NOT NULL,
    pay_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (encounter_id) REFERENCES encounters(encounter_id),
    FOREIGN KEY (s_person_id) REFERENCES staffs(s_person_id)
);