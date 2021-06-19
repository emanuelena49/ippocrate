CREATE TABLE IF NOT EXISTS medicine (
    medicine_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    notes TEXT,
    from_date DATE DEFAULT CURRENT_DATE,
    to_date DATE,
    n_intakes_per_day INTEGER DEFAULT 1,
);