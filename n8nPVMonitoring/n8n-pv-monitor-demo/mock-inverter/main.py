"""
Mock PV Inverter API — simuliert einen Photovoltaik-Wechselrichter ohne Hardware.

Simulationslogik:
- Leistungskurve: Gaußkurve mit Peak um 12:00 Uhr, tägl. Max. 2500–4200 W
- Bewölkungs-Einbrüche: 2–3 pro Tag, 15–45 Min., Leistung auf 20–50% reduziert
- Deterministisch pro Minute: gleiche Uhrzeit → gleiche Werte (kein Springen bei Reloads)
- Keine Datenbank, kein State: alle Werte werden zur Laufzeit berechnet
"""

import math
import random
from datetime import datetime, date, timedelta
from fastapi import FastAPI, Query

app = FastAPI(title="Mock PV Inverter", version="1.0.0")


def _day_rng(d: date) -> random.Random:
    return random.Random(int(d.strftime("%Y%m%d")))


def _minute_rng(dt: datetime) -> random.Random:
    seed = int(dt.strftime("%Y%m%d")) * 10000 + dt.hour * 100 + dt.minute
    return random.Random(seed)


def _daily_params(d: date) -> dict:
    """Stabile Tagesparameter: Maximalleistung und Bewölkungsereignisse."""
    rng = _day_rng(d)
    max_power = rng.uniform(2500, 4200)

    cloud_rng = random.Random(int(d.strftime("%Y%m%d")) + 99)
    num_clouds = cloud_rng.randint(2, 3)
    clouds = []
    for _ in range(num_clouds):
        start = cloud_rng.uniform(8.0, 17.0)
        duration = cloud_rng.uniform(0.25, 0.75)
        factor = cloud_rng.uniform(0.2, 0.5)
        clouds.append((start, start + duration, factor))

    return {"max_power": max_power, "clouds": clouds}


def _power_at(dt: datetime) -> float:
    """Momentanleistung in Watt für einen gegebenen Zeitpunkt."""
    hour = dt.hour + dt.minute / 60.0

    if hour < 6.0 or hour > 21.0:
        return 0.0

    params = _daily_params(dt.date())

    # Gaußkurve: Peak um 12:00, σ = 3 Stunden
    gauss = math.exp(-0.5 * ((hour - 12.0) / 3.0) ** 2)
    power = gauss * params["max_power"]

    # Bewölkungs-Einbruch anwenden (erster zutreffender Eintrag)
    for cloud_start, cloud_end, factor in params["clouds"]:
        if cloud_start <= hour <= cloud_end:
            power *= factor
            break

    # Stochastisches Rauschen ±12,5% (deterministisch pro Minute)
    noise = _minute_rng(dt).uniform(0.875, 1.125)
    return max(0.0, power * noise)


def _energy_today_wh(dt: datetime) -> int:
    """Kumulierte Tagesenergie seit Mitternacht via Trapez-Integration (5-Min-Schritte)."""
    total = 0.0
    t = dt.replace(hour=0, minute=0, second=0, microsecond=0)
    while t < dt:
        total += _power_at(t) * (5 / 60)
        minutes = t.hour * 60 + t.minute + 5
        if minutes >= 24 * 60:
            break
        t = t.replace(hour=minutes // 60, minute=minutes % 60)
    return int(total)


def _temperature(power_w: float) -> float:
    """Modultemperatur: 25 °C bei 0 W, 65 °C bei 4200 W (linear korreliert)."""
    return round(25.0 + (min(power_w, 4200.0) / 4200.0) * 40.0, 1)


@app.get("/api/realtime")
def get_realtime():
    """Momentanwerte des Wechselrichters."""
    now = datetime.now().replace(second=0, microsecond=0)
    power_w = int(_power_at(now))
    return {
        "timestamp": now.isoformat(),
        "power_w": power_w,
        "energy_today_wh": _energy_today_wh(now),
        "temperature_c": _temperature(power_w),
        "status": "producing" if power_w > 0 else "standby",
    }


@app.get("/api/history")
def get_history(hours: int = Query(default=24, ge=1, le=168)):
    """Stündliche Aggregationen der letzten N Stunden (für KI-Auswertung)."""
    now = datetime.now().replace(minute=0, second=0, microsecond=0)
    result = []
    for h in range(hours, 0, -1):
        hour_start = now - timedelta(hours=h)
        # Durchschnitt aus 12 Stichproben pro Stunde (alle 5 Min.)
        samples = [_power_at(hour_start.replace(minute=m)) for m in range(0, 60, 5)]
        avg_power = int(sum(samples) / len(samples))
        result.append({
            "hour": hour_start.isoformat(),
            "avg_power_w": avg_power,
            "energy_wh": avg_power,  # avg W × 1 h = Wh
        })
    return result
