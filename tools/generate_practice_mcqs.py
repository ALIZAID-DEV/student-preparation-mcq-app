#!/usr/bin/env python3
"""Generate exam-style PRACTICE MCQs (not official past papers) for each section."""

from __future__ import annotations

import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets" / "data"


def q(
    qid: str,
    category_id: str,
    subject_id: str,
    question: str,
    options: list[str],
    correct: int,
    explanation: str,
) -> dict:
    return {
        "id": qid,
        "categoryId": category_id,
        "subjectId": subject_id,
        "question": question,
        "options": options,
        "correctAnswerIndex": correct,
        "explanation": explanation,
    }


def load_json(name: str) -> list:
    path = DATA / name
    if not path.exists():
        return []
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def save_json(name: str, items: list) -> None:
    path = DATA / name
    with path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(items, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"Wrote {name}: {len(items)} questions")


def dedupe_keep_order(items: list[dict]) -> list[dict]:
    seen: set[str] = set()
    out: list[dict] = []
    for item in items:
        key = item["question"].strip().lower()
        if key in seen:
            continue
        seen.add(key)
        out.append(item)
    return out


def take_at_least(items: list[dict], n: int) -> list[dict]:
    items = dedupe_keep_order(items)
    if len(items) < n:
        raise SystemExit(f"Need {n} questions, got {len(items)}")
    return items[: max(n, len(items))] if len(items) >= n else items


# ---------- University Physics ----------
def gen_uni_physics() -> list[dict]:
    bank = [
        ("SI unit of force is:", ["Joule", "Newton", "Watt", "Pascal"], 1, "Force is measured in Newton (N)."),
        ("SI unit of work and energy is:", ["Newton", "Joule", "Watt", "Ampere"], 1, "Work/energy unit is Joule."),
        ("SI unit of power is:", ["Joule", "Newton", "Watt", "Volt"], 2, "Power = work/time; unit is Watt."),
        ("Acceleration due to gravity on Earth is about:", ["1.6 m/s²", "9.8 m/s²", "3×10⁸ m/s", "6.67×10⁻¹¹"], 1, "g ≈ 9.8 m/s²."),
        ("Speed of light in vacuum is:", ["3×10⁶ m/s", "3×10⁸ m/s", "3×10¹⁰ m/s", "330 m/s"], 1, "c ≈ 3×10⁸ m/s."),
        ("Ohm’s law is:", ["V = IR", "P = VI", "F = ma", "E = mc²"], 0, "V = IR relates voltage, current, resistance."),
        ("Unit of electric current is:", ["Volt", "Ohm", "Ampere", "Coulomb"], 2, "Current is measured in Ampere."),
        ("Unit of resistance is:", ["Volt", "Ampere", "Ohm", "Watt"], 2, "Resistance unit is Ohm (Ω)."),
        ("Frequency of a wave is measured in:", ["Hertz", "Meter", "Newton", "Joule"], 0, "Frequency unit is Hertz (Hz)."),
        ("Sound cannot travel through:", ["Air", "Water", "Steel", "Vacuum"], 3, "Sound needs a medium."),
        ("Light year is a unit of:", ["Time", "Distance", "Speed", "Energy"], 1, "It is distance light travels in one year."),
        ("Newton’s first law is also called:", ["Law of inertia", "Law of acceleration", "Law of action-reaction", "Law of gravitation"], 0, "First law = inertia."),
        ("Momentum formula is:", ["mv", "½mv²", "mgh", "Fd"], 0, "p = mv."),
        ("Kinetic energy formula is:", ["mv", "½mv²", "mgh", "Fd"], 1, "KE = ½mv²."),
        ("Potential energy (gravitational) is:", ["½mv²", "mgh", "mv", "IR"], 1, "PE = mgh."),
        ("Pressure formula is:", ["F/A", "F×A", "m/v", "W/t"], 0, "P = Force/Area."),
        ("SI unit of pressure is:", ["Newton", "Pascal", "Joule", "Watt"], 1, "Pascal (Pa) = N/m²."),
        ("Density formula is:", ["m/v", "v/m", "F/A", "W/t"], 0, "Density = mass/volume."),
        ("A scalar quantity has:", ["Only magnitude", "Only direction", "Magnitude and direction", "Neither"], 0, "Scalars have magnitude only."),
        ("A vector quantity has:", ["Only magnitude", "Only direction", "Magnitude and direction", "Neither"], 2, "Vectors have both."),
        ("Which is a vector?", ["Mass", "Temperature", "Velocity", "Speed"], 2, "Velocity has direction."),
        ("Which is a scalar?", ["Force", "Acceleration", "Displacement", "Energy"], 3, "Energy is scalar."),
        ("Mirror used in vehicles as rear-view is often:", ["Concave", "Convex", "Plane only", "Cylindrical only"], 1, "Convex mirrors give wider field of view."),
        ("Focal length of a plane mirror is:", ["Zero", "Infinity", "One", "Negative one"], 1, "Plane mirror focus is at infinity."),
        ("Image in a plane mirror is:", ["Real and inverted", "Virtual and erect", "Real and erect", "Virtual and inverted"], 1, "Plane mirror forms virtual erect image."),
        ("Snell’s law relates to:", ["Reflection", "Refraction", "Diffraction", "Interference"], 1, "Snell’s law is for refraction."),
        ("Unit of electric charge is:", ["Ampere", "Volt", "Coulomb", "Ohm"], 2, "Charge unit is Coulomb."),
        ("Device that converts AC to DC is:", ["Transformer", "Rectifier", "Amplifier", "Oscillator"], 1, "Rectifier converts AC→DC."),
        ("Transformer works on principle of:", ["Self induction only", "Mutual induction", "Ohm’s law", "Coulomb’s law"], 1, "Mutual induction."),
        ("Nuclear fission is used in:", ["Solar cells", "Nuclear reactors", "LED bulbs", "Batteries"], 1, "Reactors use fission."),
        ("Photon is a quantum of:", ["Sound", "Light/energy", "Mass", "Charge"], 1, "Photon = light quantum."),
        ("Escape velocity from Earth is about:", ["11.2 km/s", "3×10⁸ m/s", "9.8 m/s", "340 m/s"], 0, "≈ 11.2 km/s."),
        ("First law of thermodynamics is about:", ["Entropy", "Conservation of energy", "Absolute zero", "Heat engines efficiency limit"], 1, "Energy conservation."),
        ("Absolute zero is:", ["0°C", "0°F", "−273°C approx", "100°C"], 2, "0 K ≈ −273°C."),
        ("SI unit of temperature (absolute) is:", ["Celsius", "Fahrenheit", "Kelvin", "Rankine"], 2, "Kelvin is SI."),
        ("Capacitance unit is:", ["Henry", "Farad", "Tesla", "Weber"], 1, "Farad (F)."),
        ("Inductance unit is:", ["Farad", "Henry", "Tesla", "Ohm"], 1, "Henry (H)."),
        ("Magnetic field unit is:", ["Henry", "Farad", "Tesla", "Coulomb"], 2, "Tesla (T)."),
        ("Wavelength × frequency equals:", ["Amplitude", "Speed of wave", "Period", "Intensity"], 1, "v = fλ."),
        ("Time period T and frequency f relate as:", ["T = f", "T = 1/f", "T = f²", "T = 2f"], 1, "T = 1/f."),
        ("Work done is zero when force is:", ["Parallel to displacement", "Perpendicular to displacement", "Along velocity", "Increasing"], 1, "W = Fd cosθ; θ=90° → 0."),
        ("Power is:", ["Work × time", "Work / time", "Force × time", "Mass × acceleration"], 1, "P = W/t."),
        ("1 horsepower is approximately:", ["746 W", "100 W", "1000 W", "76 W"], 0, "1 hp ≈ 746 W."),
        ("Centroid of a uniform rod is at:", ["One end", "Midpoint", "One-third point", "Outside"], 1, "At geometric center."),
        ("Elastic limit is related to:", ["Hooke’s law validity", "Ohm’s law", "Snell’s law", "Bernoulli"], 0, "Hooke’s law within elastic limit."),
        ("Young’s modulus unit is:", ["Pascal", "Newton", "Joule", "Watt"], 0, "Same as stress: Pa."),
        ("Bernoulli’s principle applies to:", ["Static solids", "Ideal fluids in flow", "Only gases at rest", "Only vacuums"], 1, "Fluid dynamics."),
        ("Archimedes’ principle is about:", ["Buoyancy", "Gravitation", "Electricity", "Optics"], 0, "Buoyant force."),
        ("Least count of a Vernier caliper is typically:", ["0.01 cm / 0.1 mm", "1 cm", "1 m", "1 km"], 0, "Common LC ≈ 0.01 cm."),
        ("Dimensional formula of force is:", ["MLT⁻²", "MLT⁻¹", "ML²T⁻²", "MT⁻²"], 0, "F = ma → MLT⁻²."),
        ("Dimensional formula of energy is:", ["MLT⁻²", "ML²T⁻²", "MT⁻¹", "L²T⁻²"], 1, "Energy → ML²T⁻²."),
        ("Which color has highest wavelength in visible light?", ["Violet", "Blue", "Green", "Red"], 3, "Red has longest visible wavelength."),
        ("Which color has highest frequency in visible light?", ["Red", "Yellow", "Green", "Violet"], 3, "Violet highest frequency."),
        ("Rainbow formation involves:", ["Only reflection", "Dispersion and reflection/refraction", "Only diffraction", "Only polarization"], 1, "Dispersion + reflection/refraction in droplets."),
        ("Laser light is:", ["Incoherent", "Highly coherent", "Only infrared", "Only sound"], 1, "Lasers are coherent."),
        ("Half-life relates to:", ["Radioactivity", "Optics", "Acoustics only", "Static friction"], 0, "Radioactive decay."),
        ("Isotopes have same:", ["Mass number", "Atomic number", "Neutron number always", "Density always"], 1, "Same Z (atomic number)."),
        ("Electron charge is:", ["Positive", "Negative", "Neutral", "Variable"], 1, "Electrons are negative."),
        ("Proton charge is:", ["Positive", "Negative", "Neutral", "Zero always"], 0, "Protons positive."),
        ("Neutron charge is:", ["Positive", "Negative", "Neutral", "Twice proton"], 2, "Neutrons are neutral."),
        ("Atomic number equals number of:", ["Neutrons", "Protons", "Nucleons only in ions", "Photons"], 1, "Z = protons."),
        ("Mass number equals:", ["Protons only", "Neutrons only", "Protons + neutrons", "Electrons only"], 2, "A = Z + N."),
        ("X-rays were discovered by:", ["Newton", "Röntgen", "Faraday", "Ohm"], 1, "W.C. Röntgen."),
        ("Radio waves are:", ["Longitudinal mechanical", "Electromagnetic", "Sound waves", "Water waves"], 1, "EM waves."),
        ("In series resistors, equivalent resistance:", ["Decreases", "Is sum of resistances", "Is always zero", "Is product only"], 1, "Rs = R1+R2+..."),
        ("In parallel equal resistors, Req is:", ["Sum", "Less than smallest", "Always infinite", "Always zero"], 1, "Parallel Req is smaller."),
        ("Kirchhoff’s current law is based on:", ["Charge conservation", "Energy conservation only", "Mass conservation", "Momentum conservation"], 0, "ΣI = 0 at junction."),
        ("Kirchhoff’s voltage law is based on:", ["Charge conservation", "Energy conservation", "Mass conservation", "Newton’s 3rd law"], 1, "ΣV = 0 in loop."),
        ("LED converts:", ["Light to electricity", "Electricity to light", "Heat to sound", "Sound to light"], 1, "Light Emitting Diode."),
        ("Solar cell converts:", ["Light to electricity", "Electricity to light", "Heat to sound", "Sound to heat"], 0, "Photovoltaic conversion."),
        ("Ammeter is connected in:", ["Parallel", "Series", "Either always", "Never in circuit"], 1, "Series with load."),
        ("Voltmeter is connected in:", ["Series", "Parallel", "Neither", "Only with battery short"], 1, "Parallel across component."),
        ("Ideal ammeter resistance is:", ["Infinite", "Zero", "Equal to load", "Equal to battery r"], 1, "Very low / ideally zero."),
        ("Ideal voltmeter resistance is:", ["Zero", "Infinite", "Equal to load", "1 ohm"], 1, "Very high / ideally infinite."),
        ("Centroid vs center of mass: for uniform gravity they:", ["Always differ", "Coincide for uniform bodies in uniform g", "Never relate", "Only in liquids"], 1, "They coincide for uniform density in uniform g."),
        ("Simple harmonic motion restoring force is:", ["Constant", "Proportional to displacement", "Proportional to velocity²", "Zero always"], 1, "F ∝ −x."),
        ("Time period of simple pendulum (small angle) depends on:", ["Mass only", "Length and g", "Amplitude only", "Color of bob"], 1, "T = 2π√(L/g)."),
        ("Beats are due to:", ["Interference of close frequencies", "Only reflection", "Only refraction", "Gravity"], 0, "Slight frequency difference."),
        ("Doppler effect is change in:", ["Observed frequency due to relative motion", "Mass", "Charge", "Temperature only"], 0, "Relative motion source/observer."),
        ("Ultrasound frequency is:", ["Below 20 Hz", "20 Hz–20 kHz", "Above ~20 kHz", "Exactly 50 Hz"], 2, "Ultrasound > audible range."),
        ("Audible sound range for humans is about:", ["0–10 Hz", "20 Hz–20 kHz", "Only above 1 MHz", "Only DC"], 1, "Approx 20 Hz to 20 kHz."),
        ("Heat transfer by electromagnetic waves is:", ["Conduction", "Convection", "Radiation", "Osmosis"], 2, "Radiation."),
        ("Good conductor of heat:", ["Wood", "Plastic", "Copper", "Air"], 2, "Metals like copper."),
        ("Latent heat is heat for:", ["Temperature rise only", "Phase change at constant temperature", "Only cooling", "Only radiation"], 1, "Phase change."),
        ("Boiling point of water at 1 atm is:", ["0°C", "50°C", "100°C", "273°C"], 2, "100°C."),
        ("Melting point of ice at 1 atm is:", ["0°C", "100°C", "−100°C", "32°C only in Kelvin"], 0, "0°C."),
        ("Specific heat capacity unit is:", ["J/kg·K", "Newton", "Watt", "Ohm"], 0, "Energy per mass per degree."),
        ("1 calorie is about:", ["4.2 J", "1 J", "100 J", "746 J"], 0, "≈ 4.2 J."),
        ("Gravitational force is:", ["Always repulsive", "Always attractive", "Sometimes magnetic", "Only on Earth"], 1, "Always attractive."),
        ("Value of G is:", ["9.8 m/s²", "6.67×10⁻¹¹ N·m²/kg²", "3×10⁸ m/s", "1.6×10⁻¹⁹ C"], 1, "Universal constant G."),
        ("Weight is:", ["Same as mass", "Mass × g", "Mass / g", "Density × volume only"], 1, "W = mg."),
        ("Mass is measured in:", ["Newton", "Kilogram", "Joule", "Pascal"], 1, "SI mass = kg."),
        ("Inertia depends on:", ["Velocity", "Mass", "Color", "Temperature only"], 1, "More mass → more inertia."),
        ("Action and reaction are:", ["Equal and opposite on same body", "Equal and opposite on different bodies", "Unequal always", "Parallel always"], 1, "Newton’s 3rd law: different bodies."),
        ("Friction always:", ["Speeds up objects", "Opposes relative motion tendency", "Is zero on rough surfaces", "Increases mass"], 1, "Opposes relative motion."),
        ("Coefficient of friction is:", ["Dimensionless", "In Newtons", "In Joules", "In Watts"], 0, "Ratio, no units."),
        ("Projectile maximum range on level ground at:", ["0°", "30°", "45°", "90°"], 2, "Ideal case: 45°."),
        ("Circular motion needs:", ["Centripetal force", "No force", "Only gravity always", "Only friction always"], 0, "Centripetal force toward center."),
        ("Angular velocity unit is:", ["m/s", "rad/s", "N·m", "Joule"], 1, "rad/s."),
        ("Torque formula is:", ["rF sinθ", "mv", "½mv²", "IR"], 0, "τ = rF sinθ."),
        ("Moment of inertia depends on:", ["Mass distribution about axis", "Color", "Charge only", "Temperature only"], 0, "I depends on mass distribution."),
        ("Conservation of momentum holds when:", ["Net external force is zero", "Friction is maximum", "Always in open systems with external force", "Only for photons"], 0, "No net external force."),
        ("eV is a unit of:", ["Charge", "Energy", "Current", "Resistance"], 1, "Electron-volt = energy."),
        ("Binding energy relates to:", ["Nuclear stability", "Only optics", "Only sound", "Only friction"], 0, "Nuclear binding energy."),
        ("Moderator in nuclear reactor:", ["Speeds up neutrons", "Slows down neutrons", "Removes fuel", "Produces only X-rays"], 1, "Slows neutrons for fission."),
        ("Control rods in reactor:", ["Absorb neutrons", "Produce fuel", "Cool only water", "Generate electricity directly"], 0, "Absorb neutrons to control rate."),
    ]
    out = []
    for i, (question, options, correct, expl) in enumerate(bank, 1):
        out.append(q(f"uni_phy_{i:03d}", "university_test", "uni_physics", question, options, correct, expl))
    # pad with numbered variant drills if needed
    extras = []
    for n in range(1, 30):
        extras.append(
            q(
                f"uni_phy_x{n:03d}",
                "university_test",
                "uni_physics",
                f"If a body moves with uniform velocity, its acceleration is:",
                ["Maximum", "Zero", "Equal to velocity", "Infinite"],
                1,
                "Uniform velocity ⇒ acceleration = 0.",
            )
        )
    # unique extras only once for that question - better generate unique math-physics hybrids
    extras = []
    for n in range(2, 40):
        extras.append(
            q(
                f"uni_phy_e{n:03d}",
                "university_test",
                "uni_physics",
                f"A force of {n} N acts on a mass of {n} kg. Acceleration is:",
                [f"{n} m/s²", "1 m/s²", f"{n*n} m/s²", "0"],
                1,
                "a = F/m = n/n = 1 m/s².",
            )
        )
    out.extend(extras)
    return dedupe_keep_order(out)


# ---------- University Math ----------
def gen_uni_math() -> list[dict]:
    out = []
    i = 0

    def add(question, options, correct, expl):
        nonlocal i
        i += 1
        out.append(q(f"uni_math_{i:03d}", "university_test", "uni_math", question, options, correct, expl))

    for a in range(2, 22):
        b = a + 3
        add(f"Simplify: {a} + {b} = ?", [str(a + b), str(a * b), str(b - a), str(a - b)], 0, f"{a}+{b}={a+b}.")
    for a in range(3, 23):
        b = 2
        add(f"{a} × {b} = ?", [str(a * b), str(a + b), str(a - b), str(a)], 0, f"{a}×{b}={a*b}.")
    for a in range(10, 40, 2):
        add(f"{a}% of 200 = ?", [str(int(a * 2)), str(a), str(200 - a), str(a * 10)], 0, f"{a}% of 200 = {a*2}.")
    for a, b in [(12, 4), (18, 6), (25, 5), (36, 9), (49, 7), (64, 8), (81, 9), (100, 10), (121, 11), (144, 12)]:
        add(f"√{a} = ?", [str(b), str(b + 1), str(b - 1), str(a // 2)], 0, f"Square root of {a} is {b}.")
    for a in range(2, 12):
        add(f"If 2x = {2*a}, then x = ?", [str(a), str(2 * a), str(a // 2 or 1), str(a + 2)], 0, f"x={a}.")
    for n in range(3, 15):
        add(f"Average of {n} and {n+2} is:", [str(n + 1), str(n), str(n + 2), str(2 * n)], 0, f"Average = {n+1}.")
    for a, b in [(3, 4), (5, 12), (6, 8), (7, 24), (8, 15), (9, 12), (9, 40), (11, 60)]:
        hyp = int((a * a + b * b) ** 0.5)
        if hyp * hyp == a * a + b * b:
            add(
                f"In right triangle, sides {a} and {b}; hypotenuse is:",
                [str(hyp), str(a + b), str(a * b), str(abs(a - b))],
                0,
                f"By Pythagoras: √({a}²+{b}²)={hyp}.",
            )
    for p, r, t in [(1000, 10, 2), (500, 5, 4), (2000, 8, 1), (1500, 12, 2), (2500, 4, 3)]:
        si = (p * r * t) // 100
        add(
            f"Simple interest on {p} at {r}% for {t} year(s) is:",
            [str(si), str(p), str(r * t), str(p + si)],
            0,
            f"SI=PRT/100={si}.",
        )
    for a, b in [(2, 3), (3, 5), (4, 7), (5, 8), (6, 9)]:
        add(f"Ratio {a}:{b} equals:", [f"{a}/{b}", f"{b}/{a}", f"{a+b}", f"{a*b}"], 0, f"{a}:{b} = {a}/{b}.")
    bank_extra = [
        ("Derivative of x² is:", ["2x", "x", "x³", "2"], 0, "d/dx(x²)=2x."),
        ("Derivative of sin x is:", ["cos x", "−cos x", "sin x", "−sin x"], 0, "d/dx(sin x)=cos x."),
        ("Integral of 2x dx is:", ["x² + C", "2x² + C", "x + C", "2 + C"], 0, "∫2x dx = x²+C."),
        ("log(ab) equals:", ["log a + log b", "log a − log b", "log a × log b", "a log b"], 0, "log product rule."),
        ("If A={1,2}, |A| is:", ["1", "2", "3", "0"], 1, "Cardinality is 2."),
        ("Slope of line y=3x+2 is:", ["2", "3", "5", "0"], 1, "Slope is coefficient of x."),
        ("Distance between (0,0) and (3,4) is:", ["5", "7", "12", "1"], 0, "√(9+16)=5."),
        ("Determinant of [[1,0],[0,1]] is:", ["0", "1", "2", "−1"], 1, "Identity matrix det=1."),
        ("Sum of angles in a triangle is:", ["90°", "180°", "270°", "360°"], 1, "Always 180°."),
        ("A circle has radius 7; diameter is:", ["7", "14", "21", "49"], 1, "d=2r=14."),
        ("Area of circle radius r is:", ["πr²", "2πr", "πd", "r²"], 0, "A=πr²."),
        ("Perimeter of rectangle l=5,w=3 is:", ["8", "15", "16", "30"], 2, "2(l+w)=16."),
        ("Solve: x²=49; positive x is:", ["7", "9", "14", "24"], 0, "x=7."),
        ("HCF of 12 and 18 is:", ["3", "6", "9", "12"], 1, "HCF=6."),
        ("LCM of 4 and 6 is:", ["10", "12", "24", "6"], 1, "LCM=12."),
        ("Binary of 5 is:", ["101", "110", "111", "100"], 0, "5=101₂."),
        ("Probability of head in fair coin is:", ["0", "1/2", "1", "2"], 1, "Two equally likely outcomes."),
        ("Mode is the value that:", ["Appears most frequently", "Is average", "Is middle", "Is largest always"], 0, "Mode = most frequent."),
        ("Median of 1,3,5 is:", ["1", "3", "5", "9"], 1, "Middle value is 3."),
        ("(a+b)² =:", ["a²+b²", "a²+2ab+b²", "a²−2ab+b²", "2ab"], 1, "Standard identity."),
    ]
    for question, options, correct, expl in bank_extra:
        add(question, options, correct, expl)
    return dedupe_keep_order(out)


# ---------- University Chemistry ----------
def gen_uni_chemistry() -> list[dict]:
    bank = [
        ("Atomic number of Hydrogen is:", ["0", "1", "2", "8"], 1, "Hydrogen Z=1."),
        ("Atomic number of Carbon is:", ["4", "6", "8", "12"], 1, "Carbon Z=6."),
        ("Atomic number of Oxygen is:", ["6", "8", "16", "18"], 1, "Oxygen Z=8."),
        ("Chemical formula of water is:", ["H2O", "CO2", "O2", "H2"], 0, "Water is H₂O."),
        ("Chemical formula of carbon dioxide is:", ["CO", "CO2", "C2O", "O2"], 1, "CO₂."),
        ("pH of neutral solution at 25°C is:", ["0", "7", "14", "1"], 1, "Neutral pH=7."),
        ("Acids have pH:", ["Less than 7", "Equal to 7", "Greater than 7", "Exactly 14"], 0, "Acidic pH<7."),
        ("Bases have pH:", ["Less than 7", "Equal to 7", "Greater than 7", "Exactly 0"], 2, "Basic pH>7."),
        ("NaCl is commonly called:", ["Baking soda", "Common salt", "Caustic soda", "Lime"], 1, "Table/common salt."),
        ("Baking soda is:", ["NaHCO3", "NaCl", "NaOH", "CaCO3"], 0, "Sodium bicarbonate."),
        ("Caustic soda is:", ["NaOH", "NaCl", "HCl", "H2SO4"], 0, "Sodium hydroxide."),
        ("Most abundant gas in air is:", ["Oxygen", "Nitrogen", "CO2", "Hydrogen"], 1, "≈78% nitrogen."),
        ("Gas essential for combustion/respiration:", ["N2", "O2", "CO2", "Ar"], 1, "Oxygen."),
        ("Photosynthesis produces:", ["O2", "Only N2", "Only SO2", "Only He"], 0, "Plants release O₂."),
        ("Atomic mass unit standard is based on:", ["H-1", "C-12", "O-16 only historically now unused", "U-238"], 1, "Carbon-12 standard."),
        ("Isotopes differ in:", ["Atomic number", "Mass number / neutrons", "Electron charge sign", "Proton charge"], 1, "Different neutrons/mass."),
        ("Avogadro’s number is about:", ["6.022×10²³", "3×10⁸", "9.8", "1.6×10⁻¹⁹"], 0, "Particles per mole."),
        ("One mole of any gas at STP occupies about:", ["1 L", "22.4 L", "100 L", "0.1 L"], 1, "Molar volume ≈22.4 L."),
        ("Periodic table was largely developed by:", ["Dalton", "Mendeleev", "Bohr only", "Rutherford only"], 1, "Mendeleev."),
        ("Group 18 elements are:", ["Alkali metals", "Halogens", "Noble gases", "Alkaline earth"], 2, "Noble gases."),
        ("Halogens are in group:", ["1", "2", "17", "18"], 2, "Group 17."),
        ("Alkali metals are in group:", ["1", "2", "17", "18"], 0, "Group 1."),
        ("Valency of oxygen in water is:", ["1", "2", "3", "4"], 1, "Oxygen forms two bonds in H₂O."),
        ("Ionic bond involves:", ["Electron sharing", "Electron transfer", "Only neutrons", "Only photons"], 1, "Transfer of electrons."),
        ("Covalent bond involves:", ["Electron sharing", "Electron transfer only", "Only metallic lattice", "Nuclear fusion"], 0, "Sharing electrons."),
        ("Oxidation involves:", ["Gain of electrons", "Loss of electrons", "Gain of protons only", "Loss of neutrons only"], 1, "Loss of e⁻."),
        ("Reduction involves:", ["Loss of electrons", "Gain of electrons", "Loss of protons only", "Gain of neutrons only"], 1, "Gain of e⁻."),
        ("Catalyst:", ["Is consumed permanently", "Speeds reaction, not consumed permanently", "Always stops reaction", "Changes ΔH always to zero"], 1, "Provides alternate path."),
        ("Endothermic reaction:", ["Releases heat", "Absorbs heat", "Has no energy change", "Only at 0 K"], 1, "Absorbs heat."),
        ("Exothermic reaction:", ["Absorbs heat", "Releases heat", "Needs light only", "Never occurs"], 1, "Releases heat."),
        ("Strong acid example:", ["HCl", "H2O", "NaCl", "CH4"], 0, "Hydrochloric acid."),
        ("Strong base example:", ["NaOH", "HCl", "CO2", "N2"], 0, "Sodium hydroxide."),
        ("Litmus in acid turns:", ["Blue", "Red", "Green", "Black"], 1, "Blue litmus → red in acid."),
        ("Litmus in base turns:", ["Red", "Blue", "Yellow", "Black"], 1, "Red litmus → blue in base."),
        ("Organic chemistry mainly studies:", ["Carbon compounds", "Only metals", "Only noble gases", "Only nuclear reactions"], 0, "Carbon chemistry."),
        ("Functional group in alcohols is:", ["−OH", "−COOH", "−CHO", "−NH2"], 0, "Hydroxyl group."),
        ("Functional group in carboxylic acids is:", ["−OH", "−COOH", "−CHO", "C=C"], 1, "Carboxyl group."),
        ("Methane formula is:", ["CH4", "C2H6", "C2H4", "C6H6"], 0, "CH₄."),
        ("Ethene is:", ["C2H6", "C2H4", "C2H2", "CH4"], 1, "C₂H₄ alkene."),
        ("Benzene formula is:", ["C6H6", "C6H12", "C6H14", "CH4"], 0, "C₆H₆."),
        ("Hard water contains mainly salts of:", ["Na only", "Ca and Mg", "He only", "Ne only"], 1, "Ca²⁺/Mg²⁺ salts."),
        ("Softening of water removes:", ["Dissolved Ca/Mg hardness", "All oxygen", "All nitrogen", "All hydrogen"], 0, "Removes hardness ions."),
        ("Ozone formula is:", ["O2", "O3", "O4", "O"], 1, "O₃."),
        ("Ozone layer protects from:", ["Infrared only", "Harmful UV radiation", "Only sound", "Only gravity"], 1, "Absorbs UV."),
        ("Rusting of iron needs:", ["Only oil", "Oxygen and moisture", "Only nitrogen", "Only helium"], 1, "O₂ + H₂O."),
        ("Galvanization coats iron with:", ["Zinc", "Gold only", "Helium", "Nitrogen"], 0, "Zn coating."),
        ("Allotropes of carbon include:", ["Diamond and graphite", "Only NaCl", "Only water", "Only ozone"], 0, "Different forms of C."),
        ("Graphite is a good:", ["Insulator of electricity", "Conductor of electricity", "Noble gas", "Halogen"], 1, "Delocalized electrons."),
        ("Diamond is hard due to:", ["Ionic lattice of NaCl type", "Strong covalent network", "Metallic bonding only", "Hydrogen bonding only"], 1, "3D covalent network."),
        ("Electronegativity is highest for:", ["Francium", "Fluorine", "Cesium", "Sodium"], 1, "F is most electronegative."),
        ("Ionization energy generally increases:", ["Down a group", "Across a period (left to right)", "Randomly", "Only for metals"], 1, "Across period generally increases."),
        ("Atomic size generally decreases:", ["Across a period", "Down a group", "For all ions equally", "Never"], 0, "Across period Zeff increases."),
        ("Buffer solution resists:", ["Change in temperature only", "Change in pH", "Change in mass", "Change in volume only"], 1, "Stabilizes pH."),
        ("Molarity is:", ["Moles of solute / liter of solution", "Moles / kg solvent", "Grams / mole", "Liters / mole"], 0, "mol/L."),
        ("Molality is:", ["Moles / liter solution", "Moles / kg solvent", "Grams / liter", "Normality only"], 1, "mol/kg solvent."),
        ("Normality relates to:", ["Equivalents per liter", "Only moles of solvent", "Only density", "Only viscosity"], 0, "eq/L."),
        ("First organic compound synthesized (Wohler) historically associated with:", ["Urea", "DNA", "PVC", "Nylon only"], 0, "Urea from ammonium cyanate."),
        ("Enzyme is a:", ["Biological catalyst", "Strong acid only", "Noble gas", "Radioisotope only"], 0, "Protein catalyst."),
        ("Polymer example:", ["Polythene", "NaCl", "H2O", "O2"], 0, "Long-chain polymer."),
        ("Monomer of polythene is:", ["Ethene", "Methane", "Benzene", "Glucose"], 0, "Ethene (ethylene)."),
        ("Saponification produces:", ["Soap", "Only glass", "Only steel", "Only ozone"], 0, "Soap from fats/oils + alkali."),
        ("Vinegar contains mainly:", ["Acetic acid", "HCl", "H2SO4", "NaOH"], 0, "CH₃COOH dilute."),
        ("Glucose formula is:", ["C6H12O6", "C12H22O11", "CH4", "C2H5OH"], 0, "Monosaccharide."),
        ("Sucrose is a:", ["Monosaccharide", "Disaccharide", "Amino acid", "Lipid only"], 1, "Glucose+fructose."),
        ("Proteins are polymers of:", ["Amino acids", "Glucose only", "Fatty acids only", "Nucleotides only"], 0, "Amino acids."),
        ("DNA stores:", ["Genetic information", "Only fats", "Only starch", "Only metals"], 0, "Genetic material."),
        ("Nucleus of atom contains:", ["Electrons only", "Protons and neutrons", "Only photons", "Only shells"], 1, "Nucleons."),
        ("Electron was discovered by:", ["Thomson", "Chadwick", "Rutherford only for nucleus idea", "Bohr only"], 0, "J.J. Thomson."),
        ("Neutron was discovered by:", ["Thomson", "Chadwick", "Dalton", "Mendeleev"], 1, "James Chadwick."),
        ("Rutherford’s model concluded atom has:", ["Empty space + dense nucleus", "Plum pudding only", "No nucleus", "Only electrons in nucleus"], 0, "Nuclear atom."),
        ("Bohr model explains mainly:", ["Hydrogen spectrum", "Nuclear fission fully", "All molecular shapes alone", "Metallic bonding alone"], 0, "H atom spectrum."),
        ("s orbital shape is:", ["Dumbbell", "Spherical", "Double dumbbell", "Uncertain always"], 1, "Spherical."),
        ("p orbital shape is:", ["Spherical", "Dumbbell", "Linear only always", "Tetrahedral only"], 1, "Dumbbell."),
        ("Maximum electrons in shell n is:", ["n²", "2n²", "n", "2n"], 1, "2n²."),
        ("Valence electrons of sodium (Z=11) are:", ["1", "2", "8", "11"], 0, "Configuration ends in 3s¹."),
        ("Noble gas configuration is:", ["Stable octet (often)", "Always reactive", "Always radioactive", "Always metal"], 0, "Filled shells stability."),
        ("H2SO4 is:", ["Sulphuric acid", "Nitric acid", "Hydrochloric acid", "Acetic acid"], 0, "Sulfuric acid."),
        ("HNO3 is:", ["Sulphuric acid", "Nitric acid", "Hydrochloric acid", "Carbonicanhydride"], 1, "Nitric acid."),
        ("NH3 is:", ["Ammonia", "Methane", "Ozone", "Ethene"], 0, "Ammonia."),
        ("Quicklime is:", ["CaO", "CaCO3", "Ca(OH)2", "CaCl2"], 0, "Calcium oxide."),
        ("Slaked lime is:", ["CaO", "Ca(OH)2", "CaCO3", "NaOH"], 1, "Calcium hydroxide."),
        ("Limestone is mainly:", ["CaCO3", "NaCl", "SiO2 only", "Fe2O3 only"], 0, "Calcium carbonate."),
        ("Glass mainly contains:", ["Silica", "Only gold", "Only helium", "Only ozone"], 0, "SiO₂ based."),
        ("Bronze is alloy of:", ["Cu and Sn", "Cu and Zn", "Fe and Cr only", "Al and Mg only"], 0, "Copper + tin."),
        ("Brass is alloy of:", ["Cu and Sn", "Cu and Zn", "Fe and C only", "Au and Ag only"], 1, "Copper + zinc."),
        ("Steel is mainly:", ["Iron with carbon", "Only copper", "Only aluminum", "Only silicon"], 0, "Fe + C."),
        ("Ore of aluminum is:", ["Bauxite", "Hematite", "Cinnabar", "Rock salt"], 0, "Bauxite."),
        ("Hematite is ore of:", ["Al", "Fe", "Cu", "Zn"], 1, "Iron ore."),
        ("Cinnabar is ore of:", ["Hg", "Fe", "Al", "Na"], 0, "Mercury sulfide."),
        ("Roasting is heating in:", ["Excess air", "Absence of air always", "Only vacuum", "Only hydrogen"], 0, "Often excess air."),
        ("Calcination is heating in:", ["Limited/no air", "Always pure O2 blast only", "Only water", "Only acid"], 0, "Limited air."),
        ("Electrolysis of water gives:", ["H2 and O2", "Only N2", "Only CO2", "Only Cl2"], 0, "Hydrogen and oxygen."),
        ("Anode is:", ["Positive electrode", "Negative electrode", "Neutral always", "Solvent"], 0, "Oxidation at anode."),
        ("Cathode is:", ["Positive electrode", "Negative electrode", "Gas only", "Salt only"], 1, "Reduction at cathode."),
        ("Faraday’s laws relate to:", ["Electrolysis", "Only optics", "Only sound", "Only gravity"], 0, "Electrochemical deposition."),
        ("Ideal gas equation is:", ["PV=nRT", "V=IR", "F=ma", "E=mc²"], 0, "PV=nRT."),
        ("Charles’s law: at constant P, V is proportional to:", ["T", "1/T", "P²", "n² only"], 0, "V ∝ T."),
        ("Boyle’s law: at constant T, P is proportional to:", ["V", "1/V", "T", "n only"], 1, "P ∝ 1/V."),
        ("STP temperature is:", ["0°C", "25°C", "100°C", "−273°C"], 0, "0°C and 1 atm traditionally."),
        ("Heavy water is:", ["D2O", "H2O2", "H2O", "O3"], 0, "Deuterium oxide."),
        ("H2O2 is:", ["Hydrogen peroxide", "Heavy water", "Ozone", "Ammonia"], 0, "Hydrogen peroxide."),
        ("Temporary hardness is due to:", ["Bicarbonates of Ca/Mg", "Only NaCl", "Only sugars", "Only oils"], 0, "Bicarbonates."),
        ("Permanent hardness is due to:", ["Sulphates/chlorides of Ca/Mg", "Only CO2", "Only O2", "Only N2"], 0, "Sulphates/chlorides."),
    ]
    out = []
    for i, (question, options, correct, expl) in enumerate(bank, 1):
        out.append(q(f"uni_chem_{i:03d}", "university_test", "uni_chemistry", question, options, correct, expl))
    return dedupe_keep_order(out)


def main():
    # Build university file fully
    uni = []
    uni.extend(gen_uni_physics()[:120])
    uni.extend(gen_uni_math()[:120])
    uni.extend(gen_uni_chemistry()[:120])
    save_json("uni_questions.json", uni)
    print("University done:", len(uni))


if __name__ == "__main__":
    main()
