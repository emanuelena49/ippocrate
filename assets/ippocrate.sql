DROP TABLE IF EXISTS medicines;

CREATE TABLE medicines (
    medicine_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    notes TEXT,
    from_date DATE DEFAULT CURRENT_DATE,
    to_date DATE,
    n_intakes_per_day INTEGER DEFAULT 1,
    n_days_between_intakes INTEGER DEFAULT 1
);

INSERT INTO medicines (name, notes, n_intakes_per_day, n_days_between_intakes)
VALUES ("Medicina 1", "Note per medicina 1", 2, 1),
("Medicina 2", "Note per medicina 2", 1, 30),
("Medicina 3", NULL, 1, 1);

CREATE TABLE IF NOT EXISTS notes (
    id INTEGER PRIMARY KEY,
    title TEXT,
    content TEXT,
    color TEXT
);