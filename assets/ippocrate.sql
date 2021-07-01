DROP TABLE IF EXISTS medicine_intakes;
DROP TABLE IF EXISTS medicines;
DROP TABLE IF EXISTS appointment_instances;
DROP TABLE IF EXISTS appointments;

CREATE TABLE medicines (
    medicine_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    from_date DATE DEFAULT CURRENT_DATE,
    to_date DATE,
    n_intakes_per_day INTEGER DEFAULT 1,
    n_days_between_intakes INTEGER DEFAULT 1
);

CREATE TABLE medicine_intakes (
    medicine_intake_id INTEGER PRIMARY KEY,
    medicine_id INTEGER NOT NULL,
    intake_date DATE NOT NULL,
    n_intakes_done INTEGER DEFAULT 0,

    FOREIGN KEY (medicine_id) REFERENCES medicines (medicine_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE appointments (
    appointment_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    periodicity_days_interval INT
);

CREATE TABLE appointment_instances (
    appointment_instance_id INTEGER PRIMARY KEY,
    appointment_id INTEGER NOT NULL,
    appointment_datetime DATE NOT NULL,

    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

insert into appointments (name, notes)
values ("controllo dentista", "controllo periodico dentista"),
("visita medico di base", null);

insert into appointment_instances (appointment_id, appointment_datetime)
values (1, "2021-08-15 10:00:00"),
(1, "2021-06-15 09:00:00"),
(2, "2021-07-25 16:00:00");
