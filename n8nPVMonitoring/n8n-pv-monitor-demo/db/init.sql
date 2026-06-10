CREATE TABLE IF NOT EXISTS pv_readings (
    id         SERIAL PRIMARY KEY,
    ts         TIMESTAMPTZ NOT NULL DEFAULT now(),
    power_w    INTEGER,
    energy_wh  INTEGER,
    temp_c     NUMERIC(4,1)
);

CREATE INDEX IF NOT EXISTS idx_pv_readings_ts ON pv_readings(ts DESC);
