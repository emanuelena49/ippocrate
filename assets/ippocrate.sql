CREATE TABLE IF NOT EXISTS medicines (
    medicine_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    from_date DATE DEFAULT CURRENT_DATE,
    to_date DATE,
    n_intakes_per_day INTEGER DEFAULT 1,
    n_days_between_intakes INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS medicine_intakes (
    medicine_intake_id INTEGER PRIMARY KEY,
    medicine_id INTEGER NOT NULL,
    intake_date DATE NOT NULL,
    n_intakes_done INTEGER DEFAULT 0,

    FOREIGN KEY (medicine_id) REFERENCES medicines (medicine_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS  appointments (
    appointment_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    periodicity_days_interval INT
);

CREATE TABLE  IF NOT EXISTS appointment_instances (
    appointment_instance_id INTEGER PRIMARY KEY,
    appointment_id INTEGER NOT NULL,
    appointment_datetime DATE NOT NULL,
    notes TEXT,
    done BOOL DEFAULT FALSE,

    FOREIGN KEY (appointment_id) REFERENCES appointments (appointment_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
