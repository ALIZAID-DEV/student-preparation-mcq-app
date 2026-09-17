#!/usr/bin/env python3
"""Part 2: NTS / STS / SHC practice MCQ banks."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets" / "data"


def q(qid, category_id, subject_id, question, options, correct, explanation):
    return {
        "id": qid,
        "categoryId": category_id,
        "subjectId": subject_id,
        "question": question,
        "options": options,
        "correctAnswerIndex": correct,
        "explanation": explanation,
    }


def dedupe(items):
    seen = set()
    out = []
    for item in items:
        key = item["question"].strip().lower()
        if key in seen:
            continue
        seen.add(key)
        out.append(item)
    return out


def save(name, items):
    path = DATA / name
    with path.open("w", encoding="utf-8", newline="\n") as f:
        json.dump(items, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"Wrote {name}: {len(items)}")


def load(name):
    path = DATA / name
    if not path.exists():
        return []
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def gen_nts_analytics():
    out = []
    i = 0

    def add(question, options, correct, expl):
        nonlocal i
        i += 1
        out.append(q(f"nts_an_{i:03d}", "nts_exam", "nts_analytics", question, options, correct, expl))

    # Number series
    series = [
        ("2, 4, 8, 16, ?", ["18", "24", "32", "30"], 2, "Each term ×2 → 32."),
        ("3, 9, 27, 81, ?", ["162", "243", "108", "90"], 1, "Each ×3 → 243."),
        ("5, 10, 20, 40, ?", ["60", "80", "70", "100"], 1, "Each ×2 → 80."),
        ("1, 4, 9, 16, ?", ["20", "25", "30", "36"], 1, "Squares: 5²=25."),
        ("1, 8, 27, 64, ?", ["100", "125", "81", "121"], 1, "Cubes: 5³=125."),
        ("2, 6, 12, 20, ?", ["28", "30", "24", "22"], 0, "+4,+6,+8,+10 → 30? Wait +4+6+8=+10 → 20+10=30. Fix: options say 28 wrong.",),
    ]
    # Fix the buggy one - recalculate: 2,6,12,20 differences 4,6,8 next +10 = 30
    series = [
        ("2, 4, 8, 16, ?", ["18", "24", "32", "30"], 2, "Multiply by 2 each time."),
        ("3, 9, 27, 81, ?", ["162", "243", "108", "90"], 1, "Multiply by 3 each time."),
        ("5, 10, 20, 40, ?", ["60", "80", "70", "100"], 1, "Multiply by 2 each time."),
        ("1, 4, 9, 16, ?", ["20", "25", "30", "36"], 1, "Perfect squares."),
        ("1, 8, 27, 64, ?", ["100", "125", "81", "121"], 1, "Perfect cubes."),
        ("2, 6, 12, 20, ?", ["30", "28", "24", "22"], 0, "Differences +4,+6,+8,+10."),
        ("7, 14, 28, 56, ?", ["70", "84", "112", "98"], 2, "×2 each time → 112."),
        ("11, 13, 17, 19, ?", ["21", "23", "25", "27"], 1, "Prime numbers → 23."),
        ("10, 9, 7, 4, ?", ["1", "0", "2", "3"], 1, "−1,−2,−3,−4 → 0."),
        ("100, 50, 25, 12.5, ?", ["6.25", "5", "10", "8"], 0, "÷2 each time."),
    ]
    for row in series:
        add(*row)

    for n in range(2, 30):
        add(
            f"Find next number: {n}, {n*2}, {n*4}, {n*8}, ?",
            [str(n * 16), str(n * 10), str(n * 12), str(n * 6)],
            0,
            "Geometric sequence ×2.",
        )

    analogies = [
        ("Book : Reading :: Fork : ?", ["Drawing", "Writing", "Eating", "Stirring only always"], 2, "Tool-purpose analogy."),
        ("Doctor : Hospital :: Teacher : ?", ["School", "Court", "Clinic", "Factory"], 0, "Workplace analogy."),
        ("Bird : Nest :: Bee : ?", ["Hive", "Den", "Stable", "Burrow"], 0, "Home analogy."),
        ("Eye : See :: Ear : ?", ["Smell", "Hear", "Taste", "Touch"], 1, "Sense analogy."),
        ("Pen : Write :: Knife : ?", ["Cut", "Drive", "Fly", "Swim"], 0, "Function analogy."),
        ("Cow : Calf :: Cat : ?", ["Puppy", "Kitten", "Cub", "Chick"], 1, "Young one."),
        ("Day : Night :: White : ?", ["Black", "Blue", "Red", "Green"], 0, "Opposites."),
        ("Hot : Cold :: Tall : ?", ["High", "Short", "Big", "Wide"], 1, "Antonyms."),
        ("Fish : Water :: Bird : ?", ["Sky/Air", "Soil only", "Fire", "Ice only"], 0, "Habitat."),
        ("Finger : Hand :: Toe : ?", ["Foot", "Head", "Arm", "Neck"], 0, "Part-whole."),
    ]
    for row in analogies:
        add(*row)

    coding = [
        ("If CAT = 24 (C=3,A=1,T=20), then DOG = ?", ["26", "28", "30", "32"], 0, "4+15+7=26."),
        ("If A=1, B=2, … then BAD = ?", ["7", "6", "8", "9"], 0, "2+1+4=7."),
        ("If ‘TOP’ is coded as ‘UQP’, then ‘MAT’ is:", ["NBU", "LBU", "NBS", "NCU"], 0, "Each letter +1."),
        ("If ‘FISH’ → ‘GJTI’, then ‘BIRD’ → ?", ["CJSE", "CJQE", "AHQC", "CJSD"], 0, "Each letter +1."),
        ("If ‘LION’ → ‘MJPO’, then ‘BEAR’ → ?", ["CFBS", "ADZQ", "CFBQ", "CFAR"], 0, "Each +1."),
        ("Opposite of NORTH is:", ["East", "West", "South", "North-East"], 2, "South."),
        ("If you face East and turn left, you face:", ["North", "South", "West", "East"], 0, "Left from East → North."),
        ("If you face South and turn right, you face:", ["East", "West", "North", "South"], 1, "Right from South → West."),
        ("A is brother of B. B is sister of C. C is brother of D. D is:", ["Male/Female unknown alone", "Definitely male", "Definitely female", "Uncle of A"], 0, "Gender of D not fixed."),
        ("Pointing to a man, a woman says ‘His mother is the only daughter of my mother’. The man is her:", ["Brother", "Son", "Uncle", "Father"], 1, "Only daughter = woman herself → man is her son."),
    ]
    for row in coding:
        add(*row)

    odd = [
        ("Odd one out: 2, 3, 5, 7, 9, 11", ["2", "9", "7", "11"], 1, "9 is not prime."),
        ("Odd one out: Apple, Mango, Potato, Banana", ["Apple", "Mango", "Potato", "Banana"], 2, "Potato is vegetable/tuber."),
        ("Odd one out: Red, Blue, Square, Green", ["Red", "Blue", "Square", "Green"], 2, "Square is shape, not color."),
        ("Odd one out: Car, Bus, Train, Road", ["Car", "Bus", "Train", "Road"], 3, "Road is not a vehicle."),
        ("Odd one out: Circle, Triangle, Rectangle, Cube", ["Circle", "Triangle", "Rectangle", "Cube"], 3, "Cube is 3D."),
        ("Odd one out: Monday, Tuesday, January, Friday", ["Monday", "Tuesday", "January", "Friday"], 2, "January is a month."),
        ("Odd one out: Iron, Copper, Mercury, Wood", ["Iron", "Copper", "Mercury", "Wood"], 3, "Wood is not metal."),
        ("Odd one out: Sparrow, Crow, Eagle, Bat", ["Sparrow", "Crow", "Eagle", "Bat"], 3, "Bat is mammal."),
        ("Odd one out: 16, 25, 36, 48, 49", ["16", "36", "48", "49"], 2, "48 not a perfect square."),
        ("Odd one out: A, E, I, O, B", ["A", "E", "B", "O"], 2, "B is not a vowel."),
    ]
    for row in odd:
        add(*row)

    for n in range(1, 40):
        a, b, c = n, n + 2, n + 4
        add(
            f"Complete analogy: {a} : {a*a} :: {b} : ?",
            [str(b * b), str(b * 2), str(a * b), str(c * c)],
            0,
            f"{b}² = {b*b}.",
        )

    directions = [
        ("A man walks 5 km East, then 5 km North. He is from start:", ["5 km West", "5√2 km North-East", "10 km East", "0 km"], 1, "Right triangle displacement."),
        ("Opposite direction of South-East is:", ["North-West", "North-East", "South-West", "East"], 0, "SE ↔ NW."),
        ("If South becomes East, then East becomes:", ["North", "South", "West", "East"], 0, "90° rotation mapping."),
    ]
    for row in directions:
        add(*row)

    return dedupe(out)


def gen_nts_english():
    out = []
    i = 0

    def add(question, options, correct, expl):
        nonlocal i
        i += 1
        out.append(q(f"nts_en_{i:03d}", "nts_exam", "nts_english", question, options, correct, expl))

    syn = [
        ("Synonym of ‘Happy’:", ["Sad", "Joyful", "Angry", "Tired"], 1, "Joyful ≈ happy."),
        ("Synonym of ‘Begin’:", ["Start", "End", "Stop", "Close"], 0, "Begin = start."),
        ("Synonym of ‘Quick’:", ["Slow", "Fast", "Late", "Dull"], 1, "Quick = fast."),
        ("Synonym of ‘Big’:", ["Large", "Tiny", "Narrow", "Thin"], 0, "Big = large."),
        ("Synonym of ‘Smart’:", ["Intelligent", "Foolish", "Lazy", "Weak"], 0, "Smart ≈ intelligent."),
        ("Synonym of ‘Brave’:", ["Courageous", "Fearful", "Shy", "Weak"], 0, "Brave = courageous."),
        ("Synonym of ‘Purchase’:", ["Buy", "Sell", "Rent", "Lose"], 0, "Purchase = buy."),
        ("Synonym of ‘Assist’:", ["Help", "Hinder", "Ignore", "Fight"], 0, "Assist = help."),
        ("Synonym of ‘Ancient’:", ["Old", "New", "Modern", "Fresh"], 0, "Ancient = very old."),
        ("Synonym of ‘Silent’:", ["Quiet", "Noisy", "Loud", "Busy"], 0, "Silent = quiet."),
    ]
    ant = [
        ("Antonym of ‘Hot’:", ["Cold", "Warm", "Boiling", "Heated"], 0, "Hot ↔ cold."),
        ("Antonym of ‘Rich’:", ["Poor", "Wealthy", "Moneyed", "Affluent"], 0, "Rich ↔ poor."),
        ("Antonym of ‘Early’:", ["Late", "Soon", "Quick", "Prompt"], 0, "Early ↔ late."),
        ("Antonym of ‘Love’:", ["Hate", "Like", "Admire", "Prefer"], 0, "Love ↔ hate."),
        ("Antonym of ‘Strong’:", ["Weak", "Powerful", "Tough", "Hard"], 0, "Strong ↔ weak."),
        ("Antonym of ‘Victory’:", ["Defeat", "Win", "Success", "Triumph"], 0, "Victory ↔ defeat."),
        ("Antonym of ‘Include’:", ["Exclude", "Add", "Contain", "Cover"], 0, "Include ↔ exclude."),
        ("Antonym of ‘Arrive’:", ["Depart", "Come", "Enter", "Reach"], 0, "Arrive ↔ depart."),
        ("Antonym of ‘Accept’:", ["Reject", "Receive", "Take", "Approve"], 0, "Accept ↔ reject."),
        ("Antonym of ‘Permanent’:", ["Temporary", "Lasting", "Fixed", "Stable"], 0, "Permanent ↔ temporary."),
    ]
    prep = [
        ("He is good ___ English.", ["in", "at", "on", "over"], 1, "Good at."),
        ("She insisted ___ going.", ["on", "in", "at", "for"], 0, "Insist on."),
        ("Depend ___ your hard work.", ["in", "on", "at", "by"], 1, "Depend on."),
        ("Afraid ___ dogs.", ["from", "of", "with", "by"], 1, "Afraid of."),
        ("Interested ___ science.", ["on", "in", "at", "for"], 1, "Interested in."),
        ("Prefer tea ___ coffee.", ["than", "to", "from", "over"], 1, "Prefer to."),
        ("Capable ___ doing it.", ["to", "of", "for", "with"], 1, "Capable of."),
        ("Married ___ a doctor.", ["with", "to", "by", "for"], 1, "Married to."),
        ("Listen ___ the teacher.", ["at", "to", "on", "for"], 1, "Listen to."),
        ("Angry ___ his mistake.", ["at", "on", "over", "by"], 0, "Angry at (thing)/with (person) — at fits."),
    ]
    grammar = [
        ("Choose correct: She ___ to school daily.", ["go", "goes", "going", "gone"], 1, "3rd person singular."),
        ("Choose correct: They ___ playing cricket.", ["is", "are", "am", "be"], 1, "Plural → are."),
        ("Article: He is ___ honest man.", ["a", "an", "the", "no article"], 1, "Honest begins with vowel sound."),
        ("Article: ___ sun rises in the east.", ["A", "An", "The", "No article"], 2, "Unique noun → the."),
        ("Past of ‘go’ is:", ["goed", "went", "gone", "going"], 1, "Go → went."),
        ("Past participle of ‘write’ is:", ["wrote", "written", "writing", "writes"], 1, "Write → written."),
        ("Plural of ‘child’ is:", ["childs", "children", "childes", "childrens"], 1, "Children."),
        ("Plural of ‘mouse’ is:", ["mouses", "mice", "mouse", "meese"], 1, "Mice."),
        ("Correct spelling:", ["Recieve", "Receive", "Receeve", "Receve"], 1, "i before e except after c → receive."),
        ("Correct spelling:", ["Accomodate", "Accommodate", "Acommodate", "Acomodate"], 1, "Accommodate has double c,m."),
    ]
    for block in (syn, ant, prep, grammar):
        for row in block:
            add(*row)

    fill = [
        ("Neither Ali nor his friends ___ present.", ["is", "are", "was", "be"], 1, "Agreement with nearer noun friends."),
        ("The news ___ true.", ["are", "is", "were", "have"], 1, "News is singular."),
        ("Mathematics ___ my favorite subject.", ["are", "is", "were", "have"], 1, "Subject name singular."),
        ("One of the boys ___ absent.", ["are", "is", "were", "have"], 1, "One → singular."),
        ("She has been working here ___ 2020.", ["for", "since", "from", "at"], 1, "Since + point of time."),
        ("I have lived here ___ five years.", ["since", "for", "from", "at"], 1, "For + period."),
        ("If I ___ rich, I would help you.", ["am", "was", "were", "be"], 2, "Subjunctive were."),
        ("He said that he ___ busy.", ["is", "was", "will", "are"], 1, "Backshift in reported speech."),
        ("This is the book ___ I bought.", ["who", "which", "where", "whom"], 1, "Which for things."),
        ("The man ___ called you is my uncle.", ["which", "who", "where", "what"], 1, "Who for people."),
    ]
    for row in fill:
        add(*row)

    # more vocab
    words = [
        ("Benevolent", "Kind", "Cruel", "Lazy", "Poor", 0, "Benevolent = kind/generous."),
        ("Obsolete", "Outdated", "Modern", "Fresh", "New", 0, "Obsolete = outdated."),
        ("Candid", "Frank", "Secretive", "Rude", "Silent", 0, "Candid = frank."),
        ("Diligent", "Hardworking", "Lazy", "Careless", "Slow", 0, "Diligent = hardworking."),
        ("Hostile", "Unfriendly", "Friendly", "Neutral", "Kind", 0, "Hostile = unfriendly."),
        ("Lucid", "Clear", "Confusing", "Dark", "Vague", 0, "Lucid = clear."),
        ("Meager", "Scanty", "Abundant", "Huge", "Rich", 0, "Meager = scanty."),
        ("Novice", "Beginner", "Expert", "Teacher", "Leader", 0, "Novice = beginner."),
        ("Prudent", "Wise/careful", "Reckless", "Angry", "Loud", 0, "Prudent = careful."),
        ("Robust", "Strong", "Weak", "Fragile", "Thin", 0, "Robust = strong."),
        ("Scarce", "Rare", "Common", "Plenty", "Many", 0, "Scarce = rare."),
        ("Tedious", "Boring", "Exciting", "Funny", "Short", 0, "Tedious = boring."),
        ("Urgent", "Pressing", "Delayed", "Optional", "Slow", 0, "Urgent = pressing."),
        ("Vague", "Unclear", "Clear", "Exact", "Sharp", 0, "Vague = unclear."),
        ("Wary", "Cautious", "Careless", "Bold always", "Sleepy", 0, "Wary = cautious."),
        ("Zealous", "Enthusiastic", "Lazy", "Indifferent", "Cold", 0, "Zealous = enthusiastic."),
        ("Abolish", "End/cancel", "Start", "Build", "Keep", 0, "Abolish = end."),
        ("Brief", "Short", "Long", "Endless", "Wide", 0, "Brief = short."),
        ("Compel", "Force", "Request softly", "Ignore", "Allow", 0, "Compel = force."),
        ("Diverse", "Varied", "Same", "Single", "Identical", 0, "Diverse = varied."),
    ]
    for w, right, w1, w2, w3, idx, expl in words:
        opts = [right, w1, w2, w3]
        # shuffle correct to index 0 already
        add(f"Synonym of ‘{w}’:", opts, idx, expl)

    for n in range(1, 35):
        add(
            f"Choose the correct article: He bought ___ umbrella.",
            ["a", "an", "the only always", "no article"],
            1,
            "Umbrella starts with vowel sound → an.",
        )
    # that last loop creates duplicates - dedupe will shrink. Better unique sentences:
    out = [x for x in out if not x["id"].startswith("nts_en_") or True]
    # remove duplicate umbrella questions by regenerating unique ones
    out = [item for item in out if "umbrella" not in item["question"].lower()]
    unique_extra = [
        ("I saw ___ eagle.", ["a", "an", "the", "no"], 1, "Eagle vowel sound → an."),
        ("She is ___ university student.", ["a", "an", "the", "no"], 0, "University consonant sound → a."),
        ("He is ___ MBA graduate.", ["a", "an", "the", "no"], 1, "MBA vowel sound → an."),
        ("___ Amazon is a river.", ["A", "An", "The", "No"], 2, "Unique/famous → the."),
        ("Please pass me ___ salt.", ["a", "an", "the", "no"], 2, "Specific salt → the."),
        ("She plays ___ piano well.", ["a", "an", "the", "no"], 2, "Musical instruments → the."),
        ("He goes to ___ school by bus.", ["a", "an", "the", "no article"], 3, "Institution sense often no article."),
        ("Mount Everest is ___ highest peak.", ["a", "an", "the", "no"], 2, "Superlative → the."),
        ("I need ___ hour to finish.", ["a", "an", "the", "no"], 1, "Hour vowel sound → an."),
        ("This is ___ useful tip.", ["a", "an", "the", "no"], 0, "Useful consonant sound /j/ → a."),
    ]
    for row in unique_extra:
        add(*row)

    # sentence correction style
    more = [
        ("Identify error pattern: ‘He don’t know.’ Correct is:", ["He doesn’t know.", "He don’t knows.", "He not know.", "He no know."], 0, "Doesn’t for 3rd person."),
        ("Correct: ‘She can sings.’ →", ["She can sing.", "She can singing.", "She cans sing.", "She can to sing."], 0, "Modal + base verb."),
        ("Correct comparative: ‘more better’ →", ["better", "most better", "bestest", "good"], 0, "Better already comparative."),
        ("‘Between you and ___’:", ["I", "me", "mine", "myself"], 1, "Object pronoun me."),
        ("‘Each of the girls ___ a book.’", ["have", "has", "having", "had always"], 1, "Each → singular."),
        ("Passive of ‘He writes a letter’:", ["A letter is written by him.", "A letter wrote him.", "A letter written.", "He is written a letter."], 0, "Present simple passive."),
        ("‘Seldom’ is an:", ["Adverb", "Noun", "Preposition", "Conjunction only"], 0, "Adverb of frequency."),
        ("Homophone of ‘pair’:", ["Pear", "Peer only", "Poor", "Pour"], 0, "Pair/pear."),
        ("‘Their’ shows:", ["Possession", "Place", "Action", "Time"], 0, "Possessive."),
        ("‘There’ often shows:", ["Place", "Possession", "Only tense", "Only gender"], 0, "Location."),
    ]
    for row in more:
        add(*row)

    # pad with distinct fill-in grammar
    verbs = [
        ("run", "runs", "He ___ fast every morning."),
        ("eat", "eats", "She ___ breakfast at 8."),
        ("read", "reads", "Ali ___ the newspaper."),
        ("write", "writes", "Sara ___ neat notes."),
        ("play", "plays", "The child ___ outside."),
        ("watch", "watches", "He ___ cricket on TV."),
        ("study", "studies", "Amina ___ at night."),
        ("teach", "teaches", "Mr. Khan ___ English."),
        ("drive", "drives", "Father ___ to office."),
        ("speak", "speaks", "She ___ three languages."),
        ("come", "comes", "The bus ___ on time."),
        ("leave", "leaves", "Train ___ at noon."),
        ("live", "lives", "He ___ in Karachi."),
        ("work", "works", "She ___ in a bank."),
        ("help", "helps", "Ali ___ his mother."),
        ("open", "opens", "Shop ___ at 9 am."),
        ("close", "closes", "Market ___ late."),
        ("start", "starts", "Class ___ soon."),
        ("finish", "finishes", "He ___ work early."),
        ("call", "calls", "She ___ her friend daily."),
        ("need", "needs", "Baby ___ milk."),
        ("want", "wants", "He ___ success."),
        ("like", "likes", "She ___ mangoes."),
        ("love", "loves", "He ___ his country."),
        ("know", "knows", "Everyone ___ the answer."),
        ("think", "thinks", "She ___ carefully."),
        ("feel", "feels", "He ___ better today."),
        ("look", "looks", "It ___ beautiful."),
        ("seem", "seems", "She ___ tired."),
        ("become", "becomes", "It ___ dark early."),
    ]
    for base, third, stem in verbs:
        add(
            stem.replace("___", "______"),
            [base, third, base + "ing", base + "ed"],
            1,
            f"3rd person singular present → {third}.",
        )

    return dedupe(out)


def gen_nts_gk():
    bank = [
        ("Capital of Pakistan is:", ["Karachi", "Lahore", "Islamabad", "Peshawar"], 2, "Islamabad."),
        ("Largest city of Pakistan by population is generally:", ["Islamabad", "Karachi", "Quetta", "Gwadar"], 1, "Karachi."),
        ("National language of Pakistan is:", ["English", "Urdu", "Punjabi", "Sindhi"], 1, "Urdu."),
        ("Pakistan’s independence day is:", ["14 August", "23 March", "6 September", "25 December"], 0, "14 Aug 1947."),
        ("Pakistan Resolution was passed in:", ["1940", "1947", "1956", "1971"], 0, "23 March 1940."),
        ("Currency of Pakistan is:", ["Rupee", "Taka", "Rial", "Dinar"], 0, "Pakistani Rupee."),
        ("Highest mountain in Pakistan is:", ["Nanga Parbat", "K2", "Rakaposhi", "Broad Peak"], 1, "K2."),
        ("Longest river of Pakistan is:", ["Jhelum", "Chenab", "Indus", "Ravi"], 2, "Indus."),
        ("Quaid-e-Azam was born in:", ["Karachi", "Lahore", "Delhi", "Peshawar"], 0, "Karachi."),
        ("National poet of Pakistan is:", ["Faiz", "Allama Iqbal", "Ghalib", "Mir"], 1, "Allama Iqbal."),
        ("UN headquarters is in:", ["Geneva", "New York", "Paris", "London"], 1, "New York."),
        ("WHO stands for:", ["World Health Organization", "World Human Office", "Water Health Org", "World Housing Org"], 0, "World Health Organization."),
        ("UNESCO is related to:", ["Education/science/culture", "Only banks", "Only armies", "Only oil"], 0, "UN educational body."),
        ("Earth completes one rotation in about:", ["24 hours", "365 days", "30 days", "7 days"], 0, "Rotation ~24h."),
        ("Earth completes one revolution around Sun in about:", ["24 hours", "365 days", "30 days", "12 hours"], 1, "≈365 days."),
        ("Largest ocean is:", ["Atlantic", "Indian", "Pacific", "Arctic"], 2, "Pacific."),
        ("Smallest continent is:", ["Asia", "Europe", "Australia", "Africa"], 2, "Australia."),
        ("Largest continent is:", ["Africa", "Asia", "Europe", "Antarctica"], 1, "Asia."),
        ("Hardest natural substance is:", ["Gold", "Iron", "Diamond", "Silver"], 2, "Diamond."),
        ("Gas used in balloons often:", ["Oxygen", "Helium", "CO2", "Chlorine"], 1, "Helium."),
        ("Vitamin C deficiency causes:", ["Scurvy", "Rickets", "Night blindness", "Beriberi"], 0, "Scurvy."),
        ("Vitamin D deficiency causes:", ["Scurvy", "Rickets", "Anemia only", "Goitre only"], 1, "Rickets."),
        ("Blood is purified in:", ["Heart", "Lungs/kidneys context", "Only stomach", "Only skin"], 1, "Kidneys filter; lungs gas exchange — kidneys typically ‘purify’ blood of wastes."),
        ("Human heart has chambers:", ["2", "3", "4", "5"], 2, "Four chambers."),
        ("Largest gland in human body is:", ["Liver", "Pancreas", "Thyroid", "Pituitary"], 0, "Liver."),
        ("Computer brain is called:", ["Monitor", "CPU", "Keyboard", "Mouse"], 1, "CPU."),
        ("WWW stands for:", ["World Wide Web", "World Web Wide", "Wide World Web", "Web World Wide"], 0, "World Wide Web."),
        ("First Prime Minister of Pakistan was:", ["Liaquat Ali Khan", "Ayub Khan", "Zulfikar Ali Bhutto", "Benazir Bhutto"], 0, "Liaquat Ali Khan."),
        ("Objective Resolution was passed in:", ["1949", "1956", "1962", "1973"], 0, "1949."),
        ("Current constitution of Pakistan was enforced in:", ["1956", "1962", "1973", "1985"], 2, "1973."),
        ("Sindh’s capital is:", ["Hyderabad", "Sukkur", "Karachi", "Larkana"], 2, "Karachi."),
        ("Punjab’s capital is:", ["Multan", "Lahore", "Faisalabad", "Rawalpindi"], 1, "Lahore."),
        ("Khyber Pakhtunkhwa capital is:", ["Peshawar", "Abbottabad", "Mardan", "Swat"], 0, "Peshawar."),
        ("Balochistan capital is:", ["Gwadar", "Quetta", "Turbat", "Zhob"], 1, "Quetta."),
        ("Gilgit-Baltistan capital is:", ["Skardu", "Gilgit", "Hunza", "Chitral"], 1, "Gilgit."),
        ("SAARC includes countries of:", ["South Asia", "Europe", "Africa only", "Only Middle East"], 0, "South Asian association."),
        ("OIC is organization of:", ["Islamic countries", "Oil companies only", "European states only", "Banks only"], 0, "Organisation of Islamic Cooperation."),
        ("IMF stands for:", ["International Monetary Fund", "Internal Money Forum", "Indian Money Fund", "International Market Force"], 0, "IMF."),
        ("Fastest land animal is:", ["Lion", "Cheetah", "Horse", "Tiger"], 1, "Cheetah."),
        ("National animal of Pakistan is:", ["Markhor", "Lion", "Tiger", "Deer"], 0, "Markhor."),
        ("National bird of Pakistan is:", ["Chukar", "Eagle", "Sparrow", "Peacock"], 0, "Chukar."),
        ("National flower of Pakistan is:", ["Rose", "Jasmine", "Sunflower", "Tulip"], 1, "Jasmine."),
        ("Lightest gas is:", ["Oxygen", "Hydrogen", "Nitrogen", "CO2"], 1, "Hydrogen."),
        ("Chemical symbol of gold is:", ["Go", "Gd", "Au", "Ag"], 2, "Au."),
        ("Chemical symbol of silver is:", ["Si", "Ag", "Au", "Sr"], 1, "Ag."),
        ("Chemical symbol of iron is:", ["Ir", "Fe", "In", "I"], 1, "Fe."),
        ("Boiling point of water (1 atm) is:", ["0°C", "50°C", "100°C", "212°C only in C"], 2, "100°C."),
        ("Freezing point of water is:", ["0°C", "100°C", "−100°C", "50°C"], 0, "0°C."),
        ("Photosynthesis occurs in:", ["Mitochondria", "Chloroplast", "Nucleus", "Ribosome"], 1, "Chloroplasts."),
        ("DNA full form:", ["Deoxyribonucleic acid", "Dynamic nuclear acid", "Deoxy nitrogen acid", "Dual nucleic acid"], 0, "DNA."),
        ("Inventor of telephone (credited):", ["Edison", "Alexander Graham Bell", "Newton", "Tesla only"], 1, "Bell."),
        ("Gravity discovery associated with:", ["Einstein only", "Newton", "Faraday", "Ohm"], 1, "Newton."),
        ("Speed of sound in air is about:", ["330 m/s", "3×10⁸ m/s", "11.2 km/s", "9.8 m/s"], 0, "~330–340 m/s."),
        ("Planet known as Red Planet:", ["Venus", "Mars", "Jupiter", "Mercury"], 1, "Mars."),
        ("Largest planet in solar system:", ["Earth", "Saturn", "Jupiter", "Neptune"], 2, "Jupiter."),
        ("Closest planet to Sun:", ["Venus", "Mercury", "Earth", "Mars"], 1, "Mercury."),
        ("Number of planets in solar system (standard):", ["7", "8", "9", "10"], 1, "Eight."),
        ("Moon is a:", ["Star", "Satellite", "Planet", "Comet"], 1, "Earth’s satellite."),
        ("Eclipse of sun occurs when:", ["Moon between Earth and Sun", "Earth between Moon and Sun", "Sun between", "None"], 0, "Solar eclipse geometry."),
        ("Ramadan is the ___ month of Islamic calendar.", ["8th", "9th", "10th", "12th"], 1, "9th month."),
        ("Hajj is performed in:", ["Makka", "Madina only", "Jerusalem only", "Cairo"], 0, "Makkah."),
        ("First revelation of Quran was in:", ["Cave Hira", "Cave Thawr", "Masjid Nabawi", "Kaaba door"], 0, "Hira."),
        ("Zakat is:", ["Optional gift only", "Obligatory charity (pillar)", "Only tax to state always", "Only fasting"], 1, "Pillar of Islam."),
        ("Number of pillars of Islam is:", ["3", "4", "5", "6"], 2, "Five."),
        ("Prophet Muhammad (PBUH) migrated to:", ["Taif", "Madina", "Yemen", "Egypt"], 1, "Hijrah to Madina."),
        ("Islamic calendar is:", ["Solar", "Lunar", "Only Gregorian", "Only Julian"], 1, "Lunar Hijri."),
        ("Pakistan’s national anthem writer (lyrics):", ["Hafeez Jalandhari", "Iqbal", "Faiz", "Josh"], 0, "Hafeez Jalandhari."),
        ("Minar-e-Pakistan is in:", ["Karachi", "Lahore", "Islamabad", "Multan"], 1, "Lahore."),
        ("Faisal Mosque is in:", ["Lahore", "Karachi", "Islamabad", "Peshawar"], 2, "Islamabad."),
        ("Badshahi Mosque is in:", ["Lahore", "Delhi", "Agra", "Multan"], 0, "Lahore."),
        ("Mohenjo-Daro is in:", ["Sindh", "Punjab", "KP", "Balochistan"], 0, "Sindh."),
        ("Harappa is in:", ["Sindh", "Punjab", "Balochistan", "GB"], 1, "Punjab."),
        ("Indus Valley Civilization is famous for:", ["Planned cities", "Only nomads", "Only ice age", "Only Europe"], 0, "Urban planning."),
        ("First woman Prime Minister of Pakistan:", ["Fatima Jinnah", "Benazir Bhutto", "Maryam", "Hina"], 1, "Benazir Bhutto."),
        ("Radar is used to detect:", ["Only sound", "Objects using radio waves", "Only smell", "Only taste"], 1, "Radio detection."),
        ("ATM stands for:", ["Automated Teller Machine", "Auto Time Machine", "Any Time Money only informal", "Automatic Train Motor"], 0, "Automated Teller Machine."),
        ("CPU stands for:", ["Central Processing Unit", "Computer Personal Unit", "Central Print Unit", "Control Power Unit"], 0, "CPU."),
        ("HTTP is used for:", ["Web communication", "Only email files", "Only printing", "Only sound"], 0, "Web protocol."),
        ("Pakistan’s national sport (often cited):", ["Cricket", "Hockey", "Football", "Squash"], 1, "Field hockey traditionally."),
        ("Olympic games are held every:", ["2 years", "4 years", "5 years", "10 years"], 1, "Every 4 years."),
        ("FIFA World Cup is for:", ["Hockey", "Football/Soccer", "Cricket", "Tennis"], 1, "Football."),
        ("ICC is related to:", ["Cricket", "Football", "Hockey only", "Tennis only"], 0, "International Cricket Council."),
        ("Nobel Prize is not awarded in:", ["Physics", "Chemistry", "Mathematics (Fields instead)", "Peace"], 2, "No Nobel in Math."),
        ("Father of Computer (often titled):", ["Charles Babbage", "Bill Gates", "Steve Jobs", "Tim Berners-Lee"], 0, "Babbage."),
        ("WWW inventor:", ["Bill Gates", "Tim Berners-Lee", "Edison", "Newton"], 1, "Tim Berners-Lee."),
        ("Pakistan joined UN in:", ["1947", "1948", "1956", "1971"], 0, "30 Sep 1947."),
        ("LOC stands for:", ["Line of Control", "Line of Country", "Local Office Code", "Law of Court"], 0, "Line of Control."),
        ("ECO stands for:", ["Economic Cooperation Organization", "Eastern Cricket Office", "European Court only", "Energy Control Org"], 0, "ECO."),
        ("NAM stands for:", ["Non-Aligned Movement", "New Asian Market", "National Army Mission", "North Atlantic Map"], 0, "Non-Aligned Movement."),
        ("Commonwealth includes mostly:", ["Former British territories", "Only US states", "Only EU", "Only OPEC"], 0, "Commonwealth."),
        ("Desert in Sindh/Pakistan region famous:", ["Thar", "Sahara", "Gobi", "Kalahari"], 0, "Thar Desert."),
        ("Khyber Pass connects Pakistan with:", ["India", "Afghanistan", "Iran", "China only"], 1, "Afghanistan."),
        ("Karakoram Highway links Pakistan with:", ["China", "India", "Iran", "Turkey"], 0, "China."),
        ("Gwadar Port is in:", ["Sindh", "Balochistan", "Punjab", "KP"], 1, "Balochistan."),
        ("Tarbela Dam is on river:", ["Jhelum", "Indus", "Ravi", "Sutlej"], 1, "Indus."),
        ("Mangla Dam is on river:", ["Indus", "Jhelum", "Chenab", "Ravi"], 1, "Jhelum."),
        ("Warsak Dam is in:", ["KP", "Sindh", "Balochistan", "Punjab only"], 0, "Near Peshawar, KP."),
        ("Pakistan Steel Mills located near:", ["Karachi", "Lahore", "Islamabad", "Quetta"], 0, "Near Karachi."),
        ("Siachen Glacier is in:", ["Himalaya/Karakoram region", "Thar", "Makran coast only", "Cholistan only"], 0, "Northern region."),
        ("Cholistan is a:", ["Desert", "Mountain", "River", "Port"], 0, "Desert in Punjab."),
        ("Rann of Kutch is near:", ["Sindh-India border area", "Gilgit only", "China border only", "Iran only"], 0, "Southern border region."),
        ("Allama Iqbal’s famous work:", ["Asrar-e-Khudi", "Divine Comedy", "Iliad", "Hamlet"], 0, "Asrar-e-Khudi."),
        ("Quaid’s 14 Points were presented in:", ["1929", "1940", "1947", "1956"], 0, "1929."),
        ("Two-Nation Theory associated with:", ["Muslim separate identity", "Only economics", "Only geography of Africa", "Only language of Europe"], 0, "Basis for Pakistan."),
    ]
    out = []
    for i, row in enumerate(bank, 1):
        out.append(q(f"nts_gk_{i:03d}", "nts_exam", "nts_gk", *row))
    return dedupe(out)


def gen_sts_math():
    out = []
    i = 0

    def add(question, options, correct, expl):
        nonlocal i
        i += 1
        out.append(q(f"sts_math_{i:03d}", "sts_exam", "sts_math", question, options, correct, expl))

    for a in range(5, 55):
        b = a + 7
        add(f"{a} + {b} = ?", [str(a + b), str(a * b), str(b - a), str(a)], 0, f"{a}+{b}={a+b}")
    for a in range(2, 25):
        add(f"{a} × 5 = ?", [str(a * 5), str(a + 5), str(a * 2), str(5)], 0, f"{a*5}")
    for p in range(10, 60, 5):
        add(f"{p}% of 100 = ?", [str(p), str(p * 2), str(100 - p), str(p // 2)], 0, f"{p}% of 100 = {p}")
    for a, b in [(15, 5), (21, 7), (27, 9), (32, 8), (45, 9), (56, 7), (63, 9), (72, 8), (81, 9), (96, 12)]:
        add(f"{a} ÷ {b} = ?", [str(a // b), str(a - b), str(a + b), str(b)], 0, f"{a}/{b}={a//b}")
    extras = [
        ("LCM of 3 and 5 is:", ["8", "15", "1", "2"], 1, "15"),
        ("HCF of 8 and 12 is:", ["2", "4", "8", "24"], 1, "4"),
        ("Square of 12 is:", ["24", "144", "120", "132"], 1, "144"),
        ("Cube of 3 is:", ["6", "9", "27", "81"], 2, "27"),
        ("0.5 as fraction is:", ["1/2", "1/5", "5/1", "2/5"], 0, "1/2"),
        ("1/4 as percent is:", ["4%", "25%", "40%", "14%"], 1, "25%"),
        ("Average of 10 and 20 is:", ["10", "15", "20", "30"], 1, "15"),
        ("If cost=80, profit=20, SP=?", ["60", "100", "80", "20"], 1, "SP=100"),
        ("Simple interest formula is:", ["PRT/100", "P+R+T", "PR/T", "P/RT"], 0, "SI=PRT/100"),
        ("Perimeter of square side 5:", ["10", "20", "25", "15"], 1, "4×5=20"),
        ("Area of square side 6:", ["12", "24", "36", "18"], 2, "36"),
        ("Area of rectangle 8×3:", ["11", "24", "16", "32"], 1, "24"),
        ("2³ = ?", ["6", "8", "9", "5"], 1, "8"),
        ("√81 = ?", ["8", "9", "7", "81"], 1, "9"),
        ("3² + 4² = ?", ["5", "7", "12", "25"], 3, "9+16=25"),
        ("Next prime after 7:", ["8", "9", "10", "11"], 3, "11"),
        ("Even number among:", ["11", "13", "15", "16"], 3, "16"),
        ("Odd number among:", ["2", "4", "6", "9"], 3, "9"),
        ("10² = ?", ["20", "100", "50", "110"], 1, "100"),
        ("Convert 2 hours to minutes:", ["60", "90", "120", "150"], 2, "120"),
    ]
    for row in extras:
        add(*row)
    return dedupe(out)


def gen_sts_english():
    # reuse style of NTS english but different IDs/category
    out = []
    i = 0

    def add(question, options, correct, expl):
        nonlocal i
        i += 1
        out.append(q(f"sts_en_{i:03d}", "sts_exam", "sts_english", question, options, correct, expl))

    items = [
        ("Choose correct spelling:", ["Seperate", "Separate", "Seperete", "Separrete"], 1, "Separate."),
        ("Choose correct spelling:", ["Definate", "Definite", "Definete", "Definit"], 1, "Definite."),
        ("Plural of ‘leaf’:", ["leafs", "leaves", "leafes", "leave"], 1, "Leaves."),
        ("Plural of ‘knife’:", ["knifes", "knives", "knife", "knivess"], 1, "Knives."),
        ("Past of ‘teach’:", ["teached", "taught", "tought", "teaching"], 1, "Taught."),
        ("Past of ‘buy’:", ["buyed", "bought", "boughted", "buying"], 1, "Bought."),
        ("She is taller ___ Ali.", ["then", "than", "that", "to"], 1, "Than for comparison."),
        ("I prefer coffee ___ tea.", ["than", "to", "from", "for"], 1, "Prefer to."),
        ("He has lived here ___ 2018.", ["for", "since", "from", "at"], 1, "Since + year."),
        ("We stayed ___ a week.", ["since", "for", "from", "at"], 1, "For + duration."),
        ("Synonym of ‘Difficult’:", ["Hard", "Easy", "Simple", "Light"], 0, "Hard."),
        ("Synonym of ‘End’:", ["Finish", "Start", "Begin", "Open"], 0, "Finish."),
        ("Antonym of ‘Open’:", ["Close", "Start", "Begin", "Free"], 0, "Close."),
        ("Antonym of ‘Empty’:", ["Full", "Vacant", "Hollow", "Blank"], 0, "Full."),
        ("Article: ___ apple a day.", ["A", "An", "The", "No"], 1, "An apple."),
        ("Article: ___ Earth moves.", ["A", "An", "The", "No"], 2, "The Earth."),
        ("He ___ TV when I called.", ["watch", "was watching", "watches", "watched always"], 1, "Past continuous."),
        ("They ___ to Lahore yesterday.", ["go", "went", "gone", "going"], 1, "Past simple."),
        ("If it rains, we ___ home.", ["will stay", "stayed", "staying", "stay always past"], 0, "1st conditional."),
        ("The letter was ___ by Ali.", ["write", "wrote", "written", "writing"], 2, "Passive past participle."),
        ("Neither of them ___ ready.", ["are", "is", "were", "have"], 1, "Neither → singular often."),
        ("A lot of sugar ___ needed.", ["are", "is", "were", "have"], 1, "Uncountable singular."),
        ("Furniture ___ expensive.", ["are", "is", "were", "have"], 1, "Uncountable."),
        ("Scissors ___ on the table.", ["is", "are", "was", "has"], 1, "Plural tool."),
        ("He congratulated me ___ my success.", ["for", "on", "at", "with"], 1, "Congratulate on."),
        ("She is senior ___ me.", ["than", "to", "from", "of"], 1, "Senior to."),
        ("He died ___ cancer.", ["from", "of", "with", "by"], 1, "Died of."),
        ("Belong ___ this club.", ["in", "to", "at", "with"], 1, "Belong to."),
        ("Famous ___ his novels.", ["to", "for", "in", "at"], 1, "Famous for."),
        ("Guilty ___ murder.", ["for", "of", "to", "with"], 1, "Guilty of."),
        ("Keen ___ music.", ["on", "in", "at", "for"], 0, "Keen on."),
        ("Tired ___ work.", ["of", "from", "with", "at"], 0, "Tired of."),
        ("Fond ___ children.", ["on", "of", "in", "at"], 1, "Fond of."),
        ("Aware ___ the problem.", ["to", "of", "for", "at"], 1, "Aware of."),
        ("Proud ___ his son.", ["on", "of", "for", "at"], 1, "Proud of."),
        ("Similar ___ mine.", ["with", "to", "from", "of"], 1, "Similar to."),
        ("Different ___ yours.", ["to", "from", "with", "of"], 1, "Different from."),
        ("According ___ the rules.", ["with", "to", "by", "for"], 1, "According to."),
        ("In spite ___ rain.", ["of", "for", "to", "with"], 0, "In spite of."),
        ("Because ___ illness.", ["of", "for", "to", "with"], 0, "Because of."),
        ("He asked me ___ I was.", ["where", "were", "wear", "ware"], 0, "Where."),
        ("Do you know ___ she is?", ["who", "whom", "whose", "who’s"], 0, "Who."),
        ("This is the girl ___ bag was lost.", ["who", "whose", "whom", "which"], 1, "Whose."),
        ("The house ___ I live is large.", ["which", "where", "who", "whom"], 1, "Where."),
        ("He speaks English ___ .", ["fluent", "fluently", "fluency", "fluence"], 1, "Adverb fluently."),
        ("She looks ___ .", ["happy", "happily always only", "happiness", "happierly"], 0, "Adjective after look."),
        ("Drive ___ .", ["careful", "carefully", "care", "caring"], 1, "Adverb carefully."),
        ("He is a ___ driver.", ["careful", "carefully", "care", "caring only"], 0, "Adjective careful."),
        ("Much is used with:", ["Countable plural", "Uncountable", "Only people", "Only animals"], 1, "Uncountable."),
        ("Many is used with:", ["Uncountable", "Countable plural", "Only liquids", "Only time"], 1, "Countable plural."),
        ("Little money means:", ["Almost no money", "Many coins", "Enough money", "No meaning"], 0, "Little = almost none."),
        ("A few friends means:", ["Some friends", "No friends", "All friends", "One friend"], 0, "A few = some."),
        ("Choose correct: information", ["informations", "information", "informates", "informs"], 1, "Uncountable noun."),
        ("Choose correct: advice", ["advices", "advice", "advise as noun", "advicing"], 1, "Advice noun uncountable."),
        ("Verb form of advice is:", ["advice", "advise", "advicing", "advices"], 1, "Advise is verb."),
        ("He gave me useful ___ .", ["advise", "advice", "advices", "advising"], 1, "Advice noun."),
        ("I ___ swimming.", ["enjoy", "enjoys", "enjoying", "enjoyed always must"], 0, "I enjoy."),
        ("She ___ not like tea.", ["do", "does", "is", "are"], 1, "Does not."),
        ("___ you finish the work?", ["Does", "Do", "Is", "Are"], 1, "Do you."),
        ("There ___ a book on the table.", ["are", "is", "were", "have"], 1, "Singular book."),
        ("There ___ many students.", ["is", "are", "was", "has"], 1, "Plural students."),
        ("He can ___ English.", ["speaks", "speak", "speaking", "spoke"], 1, "Modal + V1."),
        ("You must ___ the rules.", ["follows", "follow", "following", "followed"], 1, "Must + V1."),
        ("She might ___ late.", ["be", "is", "are", "was"], 0, "Might + be."),
        ("I am used to ___ early.", ["get up", "getting up", "got up", "gets up"], 1, "Used to + gerund."),
        ("He looks forward to ___ you.", ["meet", "meeting", "met", "meets"], 1, "To + gerund here."),
        ("Avoid ___ mistakes.", ["make", "making", "made", "makes"], 1, "Avoid + gerund."),
        ("Stop ___ noise.", ["make", "making", "made", "makes"], 1, "Stop + gerund."),
        ("Let him ___ .", ["goes", "go", "going", "went"], 1, "Let + V1."),
        ("Make her ___ the truth.", ["tells", "tell", "telling", "told"], 1, "Make + V1."),
        ("I saw him ___ .", ["cross", "crossing", "crossed", "crosses"], 1, "See + -ing often."),
        ("Would you mind ___ the door?", ["open", "opening", "opened", "opens"], 1, "Mind + gerund."),
        ("It is no use ___ .", ["cry", "crying", "cried", "cries"], 1, "No use + gerund."),
        ("He is busy ___ a letter.", ["write", "writing", "wrote", "writes"], 1, "Busy + gerund."),
        ("She suggested ___ early.", ["leave", "leaving", "left", "leaves"], 1, "Suggest + gerund."),
        ("I can’t help ___ .", ["laugh", "laughing", "laughed", "laughs"], 1, "Can’t help + gerund."),
        ("He denied ___ the money.", ["steal", "stealing", "stole", "steals"], 1, "Deny + gerund."),
        ("They finished ___ the room.", ["clean", "cleaning", "cleaned", "cleans"], 1, "Finish + gerund."),
        ("Keep ___ .", ["try", "trying", "tried", "tries"], 1, "Keep + gerund."),
        ("He admitted ___ the window.", ["break", "breaking", "broke", "breaks"], 1, "Admit + gerund."),
        ("She practiced ___ piano.", ["play", "playing", "played", "plays"], 1, "Practice + gerund."),
        ("I miss ___ cricket.", ["play", "playing", "played", "plays"], 1, "Miss + gerund."),
        ("He risked ___ his job.", ["lose", "losing", "lost", "loses"], 1, "Risk + gerund."),
        ("They postponed ___ the meeting.", ["hold", "holding", "held", "holds"], 1, "Postpone + gerund."),
        ("She delayed ___ home.", ["go", "going", "went", "goes"], 1, "Delay + gerund."),
        ("I fancy ___ out.", ["eat", "eating", "ate", "eats"], 1, "Fancy + gerund."),
        ("He considered ___ abroad.", ["move", "moving", "moved", "moves"], 1, "Consider + gerund."),
        ("We discussed ___ a new plan.", ["make", "making", "made", "makes"], 1, "Discuss + gerund."),
        ("She imagines ___ famous.", ["be", "being", "been", "is"], 1, "Imagine + gerund."),
        ("He can’t stand ___ in queues.", ["wait", "waiting", "waited", "waits"], 1, "Can’t stand + gerund."),
        ("It’s worth ___ .", ["try", "trying", "tried", "tries"], 1, "Worth + gerund."),
        ("There’s no point ___ .", ["argue", "arguing", "argued", "argues"], 1, "No point + gerund."),
        ("He spent time ___ books.", ["read", "reading", "readed", "reads"], 1, "Spend time + gerund."),
        ("She had difficulty ___ him.", ["find", "finding", "found", "finds"], 1, "Difficulty + gerund."),
        ("I am thinking of ___ a car.", ["buy", "buying", "bought", "buys"], 1, "Of + gerund."),
        ("He succeeded in ___ the exam.", ["pass", "passing", "passed", "passes"], 1, "Succeed in + gerund."),
        ("She apologized for ___ late.", ["be", "being", "been", "was"], 1, "For + gerund."),
        ("They accused him of ___ .", ["steal", "stealing", "stole", "steals"], 1, "Of + gerund."),
        ("He is good at ___ stories.", ["tell", "telling", "told", "tells"], 1, "At + gerund."),
        ("She insisted on ___ with us.", ["come", "coming", "came", "comes"], 1, "On + gerund."),
        ("Thank you for ___ me.", ["help", "helping", "helped", "helps"], 1, "For + gerund."),
        ("He prevented me from ___ .", ["enter", "entering", "entered", "enters"], 1, "From + gerund."),
        ("I am tired of ___ excuses.", ["hear", "hearing", "heard", "hears"], 1, "Of + gerund."),
        ("She is responsible for ___ the files.", ["keep", "keeping", "kept", "keeps"], 1, "For + gerund."),
        ("He dreams of ___ a pilot.", ["become", "becoming", "became", "becomes"], 1, "Of + gerund."),
        ("We are interested in ___ French.", ["learn", "learning", "learned", "learns"], 1, "In + gerund."),
        ("He objected to ___ overtime.", ["work", "working", "worked", "works"], 1, "To + gerund."),
        ("She confessed to ___ the vase.", ["break", "breaking", "broke", "breaks"], 1, "To + gerund."),
        ("I look forward to ___ from you.", ["hear", "hearing", "heard", "hears"], 1, "To + gerund."),
        ("He is accustomed to ___ early.", ["rise", "rising", "rose", "rises"], 1, "To + gerund."),
        ("She devoted herself to ___ the poor.", ["help", "helping", "helped", "helps"], 1, "To + gerund."),
    ]
    for row in items:
        add(*row)
    return dedupe(out)


def gen_shc_computer():
    bank = [
        ("CPU stands for:", ["Central Processing Unit", "Computer Power Unit", "Central Print Unit", "Control Process Utility"], 0, "CPU."),
        ("RAM stands for:", ["Random Access Memory", "Read Access Memory", "Run All Memory", "Readily Available Mode"], 0, "RAM."),
        ("ROM stands for:", ["Read Only Memory", "Random Only Memory", "Run Only Memory", "Ready Output Mode"], 0, "ROM."),
        ("HDD stands for:", ["Hard Disk Drive", "High Data Disk", "Hardware Digital Device", "Host Data Drive"], 0, "HDD."),
        ("SSD stands for:", ["Solid State Drive", "Super Speed Disk", "System Storage Device", "Secure Soft Drive"], 0, "SSD."),
        ("URL stands for:", ["Uniform Resource Locator", "Universal Record Link", "User Remote Login", "Unique Route Line"], 0, "URL."),
        ("IP in networking stands for:", ["Internet Protocol", "Internal Program", "Input Process", "Interface Port"], 0, "IP."),
        ("LAN stands for:", ["Local Area Network", "Large Area Network", "Long Access Node", "Logical Area Net"], 0, "LAN."),
        ("WAN stands for:", ["Wide Area Network", "Wireless Area Node", "Web Access Network", "Weak Area Net"], 0, "WAN."),
        ("GUI stands for:", ["Graphical User Interface", "General User Internet", "Global Utility Input", "Graphic Unit Index"], 0, "GUI."),
        ("OS stands for:", ["Operating System", "Open Software", "Output Signal", "Online Service"], 0, "OS."),
        ("Example of OS:", ["Windows", "MS Word", "Chrome only", "Photoshop only"], 0, "Windows is OS."),
        ("MS Word is used for:", ["Word processing", "Only calculations", "Only presentations", "Only databases"], 0, "Documents."),
        ("MS Excel is used for:", ["Spreadsheets", "Only painting", "Only email", "Only video"], 0, "Sheets/calc."),
        ("MS PowerPoint is used for:", ["Presentations", "Only databases", "Only coding", "Only networking"], 0, "Slides."),
        ("Shortcut Ctrl+C is:", ["Copy", "Cut", "Paste", "Save"], 0, "Copy."),
        ("Shortcut Ctrl+V is:", ["Copy", "Cut", "Paste", "Undo"], 2, "Paste."),
        ("Shortcut Ctrl+X is:", ["Copy", "Cut", "Paste", "Print"], 1, "Cut."),
        ("Shortcut Ctrl+Z is:", ["Redo", "Undo", "Save", "Find"], 1, "Undo."),
        ("Shortcut Ctrl+S is:", ["Save", "Select all", "Search", "Spellcheck"], 0, "Save."),
        ("Shortcut Ctrl+A is:", ["Align", "Select all", "Save as", "Add"], 1, "Select all."),
        ("Shortcut Ctrl+P is:", ["Paste", "Print", "Paint", "Pause"], 1, "Print."),
        ("Shortcut Ctrl+B in Word:", ["Bold", "Break", "Back", "Bookmark"], 0, "Bold."),
        ("Shortcut Ctrl+I in Word:", ["Indent", "Italic", "Insert", "Info"], 1, "Italic."),
        ("Shortcut Ctrl+U in Word:", ["Undo", "Underline", "Update", "Upload"], 1, "Underline."),
        ("1 Byte =", ["4 bits", "8 bits", "16 bits", "32 bits"], 1, "8 bits."),
        ("1 KB =", ["1000 bytes exact always", "1024 bytes", "8 bytes", "512 bytes"], 1, "1024 bytes traditionally."),
        ("Binary number system base is:", ["2", "8", "10", "16"], 0, "Base 2."),
        ("Decimal base is:", ["2", "8", "10", "16"], 2, "Base 10."),
        ("Hexadecimal base is:", ["2", "8", "10", "16"], 3, "Base 16."),
        ("Bit is:", ["Smallest unit of data", "A program", "A printer", "A folder"], 0, "Binary digit."),
        ("Input device example:", ["Keyboard", "Monitor", "Speaker", "Printer"], 0, "Keyboard input."),
        ("Output device example:", ["Mouse", "Scanner", "Monitor", "Microphone"], 2, "Monitor output."),
        ("Both input/output device:", ["Touchscreen", "Only CPU", "Only RAM", "Only ROM"], 0, "Touchscreen."),
        ("Soft copy is:", ["On screen output", "Printed paper", "Only CD", "Only ink"], 0, "Digital display."),
        ("Hard copy is:", ["Printed output", "Only RAM content", "Only cache", "Only register"], 0, "Paper printout."),
        ("Browser example:", ["Chrome", "MS Excel", "Notepad only", "Paint only"], 0, "Web browser."),
        ("Search engine example:", ["Google", "Windows", "BIOS", "MS Word"], 0, "Google."),
        ("Email stands for:", ["Electronic mail", "Easy mail", "Extra mail", "Error mail"], 0, "Electronic mail."),
        ("@ symbol in email separates:", ["Username and domain", "Only dates", "Only files", "Only passwords"], 0, "user@domain."),
        ("HTTP default port often:", ["21", "25", "80", "110"], 2, "Port 80."),
        ("HTTPS is:", ["Secure HTTP", "Only file transfer", "Only printing", "Only offline mode"], 0, "Encrypted web."),
        ("Firewall is used for:", ["Network security", "Only printing", "Only cooling CPU", "Only sound"], 0, "Security filter."),
        ("Virus is a:", ["Malicious program", "Hardware chip", "Printer type", "Cable type"], 0, "Malware."),
        ("Antivirus software:", ["Detects/removes malware", "Only creates docs", "Only edits photos", "Only burns CDs"], 0, "Security."),
        ("Backup means:", ["Copy of data for safety", "Delete all files", "Format disk only", "Install OS only"], 0, "Data safety copy."),
        ("Cloud storage example:", ["Google Drive", "Only HDD inside PC always", "Only ROM", "Only cache"], 0, "Online storage."),
        ("Phishing is:", ["Fraud to steal info", "A printer error", "A coding language", "A CPU brand"], 0, "Social engineering fraud."),
        ("Cookie in browsers:", ["Small data stored by sites", "A hardware fan", "A virus only always", "A printer ink"], 0, "Web cookie."),
        ("Cache memory is:", ["High-speed memory", "Only slow tape", "Only printer buffer always", "Only CD"], 0, "Fast memory."),
        ("Register is located in:", ["CPU", "Monitor", "Keyboard", "Mouse"], 0, "Inside CPU."),
        ("Motherboard connects:", ["Computer components", "Only internet cables outside always", "Only printers alone", "Only speakers alone"], 0, "Main board."),
        ("GPU is related to:", ["Graphics processing", "Only sound", "Only networking always", "Only power supply"], 0, "Graphics."),
        ("UPS provides:", ["Backup power", "Only internet", "Only cooling", "Only display"], 0, "Uninterruptible power."),
        ("Resolution of screen relates to:", ["Image clarity/pixels", "Only CPU speed", "Only RAM size always", "Only HDD brand"], 0, "Pixel density/size."),
        ("PDF stands for:", ["Portable Document Format", "Print Document File", "Public Data Form", "Program Data Folder"], 0, "PDF."),
        ("JPEG is a:", ["Image format", "Audio only format", "Video only always", "Executable only"], 0, "Image."),
        ("MP3 is a:", ["Audio format", "Image format", "Spreadsheet", "OS"], 0, "Audio."),
        ("ZIP files are used for:", ["Compression/archive", "Only printing", "Only scanning", "Only cooling"], 0, "Compress."),
        ("Drag and drop means:", ["Move with mouse hold", "Only keyboard typing", "Only restart PC", "Only format"], 0, "GUI action."),
        ("Desktop in OS is:", ["Main screen workspace", "Only hard disk", "Only CPU", "Only BIOS"], 0, "Desktop UI."),
        ("Icon is:", ["Small pictorial shortcut", "A virus", "A cable", "A port only"], 0, "GUI icon."),
        ("Folder is used to:", ["Organize files", "Cool CPU", "Increase voltage", "Print only"], 0, "Directory."),
        ("File extension .docx is for:", ["Word documents", "Excel only", "PowerPoint only", "Images only"], 0, "Word."),
        ("File extension .xlsx is for:", ["Excel", "Word", "PowerPoint", "Access only always"], 0, "Excel."),
        ("File extension .pptx is for:", ["PowerPoint", "Word", "Excel", "Notepad"], 0, "PowerPoint."),
        ("In Excel, a cell is intersection of:", ["Row and column", "Only two rows", "Only charts", "Only macros"], 0, "Cell address."),
        ("Excel formula starts with:", ["=", "+", "#", "@"], 0, "Equals sign."),
        ("SUM function in Excel:", ["Adds numbers", "Multiplies only", "Sorts only", "Filters only"], 0, "Addition."),
        ("In Word, alignment options include:", ["Left/Center/Right/Justify", "Only Bold", "Only Italic", "Only Font"], 0, "Paragraph align."),
        ("Portrait orientation is:", ["Vertical page", "Horizontal page", "Circular page", "No page"], 0, "Vertical."),
        ("Landscape orientation is:", ["Horizontal page", "Vertical page", "Square only", "None"], 0, "Horizontal."),
        ("Cc in email means:", ["Carbon Copy", "Close Copy", "Central Copy", "Computer Copy"], 0, "Cc."),
        ("Bcc in email means:", ["Blind Carbon Copy", "Bold Carbon Copy", "Basic Computer Code", "Binary Copy Channel"], 0, "Bcc."),
        ("Spam email is:", ["Unwanted junk mail", "Official OS update only", "Antivirus only", "Hardware driver only"], 0, "Junk."),
        ("Bluetooth is for:", ["Short-range wireless", "Only long satellite", "Only wired LAN", "Only printing ink"], 0, "Wireless short range."),
        ("Wi-Fi is:", ["Wireless networking", "A virus", "A printer brand", "A CPU socket"], 0, "Wireless fidelity."),
        ("Modem is used to:", ["Connect to internet/line", "Only cool PC", "Only store files", "Only display"], 0, "Modulation/demodulation."),
        ("Router is used to:", ["Route network traffic", "Only type documents", "Only scan photos", "Only play music"], 0, "Networking device."),
        ("IP address identifies:", ["A device on network", "Only a file name", "Only a font", "Only a printer ink"], 0, "Network ID."),
        ("DNS translates:", ["Domain names to IP", "Only files to folders", "Only RAM to ROM", "Only bits to bytes always same"], 0, "Domain Name System."),
        ("HTML is used to:", ["Create web pages", "Only edit videos", "Only compress ZIP", "Only run antivirus"], 0, "Markup language."),
        ("CSS is used for:", ["Styling web pages", "Only database queries", "Only email protocols", "Only CPU scheduling"], 0, "Cascading Style Sheets."),
        ("JavaScript is mainly:", ["Web scripting language", "Only a hardware chip", "Only an OS", "Only a cable"], 0, "Scripting."),
        ("Database example software:", ["MS Access / MySQL", "Only Paint", "Only Notepad", "Only Calculator"], 0, "DBMS."),
        ("Primary key in DB uniquely:", ["Identifies a record", "Deletes OS", "Formats disk", "Creates virus"], 0, "Unique ID."),
        ("SQL is used to:", ["Query databases", "Only draw images", "Only play audio", "Only cool GPU"], 0, "Structured Query Language."),
        ("Booting means:", ["Starting the computer", "Shutting printer only", "Deleting files only", "Only installing game"], 0, "Boot process."),
        ("BIOS is:", ["Basic firmware on motherboard", "A word processor", "A web browser", "A search engine"], 0, "BIOS/UEFI."),
        ("Cold boot means:", ["Start from power off", "Restart only apps", "Only sleep mode", "Only lock screen"], 0, "Power-on start."),
        ("Warm boot means:", ["Restart without full power cycle sometimes", "Only format", "Only BIOS flash", "Only unplug"], 0, "Restart."),
        ("Sleep mode:", ["Low power state", "Deletes OS", "Formats HDD", "Removes RAM physically"], 0, "Power saving."),
        ("Task Manager in Windows shows:", ["Running processes", "Only fonts", "Only printers ink", "Only emails"], 0, "Processes/performance."),
        ("Ctrl+Alt+Del commonly used to:", ["Security options/Task Manager access", "Only copy text", "Only paste", "Only print"], 0, "System interrupt."),
        ("Recycle Bin stores:", ["Deleted files temporarily", "Only OS kernel", "Only drivers", "Only BIOS"], 0, "Deleted items."),
        ("Formatting a disk:", ["Prepares file system / erases data", "Only increases RAM", "Only cleans screen", "Only updates browser"], 0, "Format."),
        ("Path of a file shows:", ["Location in storage", "Only file color", "Only author age", "Only CPU temp"], 0, "Directory path."),
        ("Extension of a file indicates:", ["File type", "Only file size always", "Only author", "Only date created always alone"], 0, "Type via extension."),
        ("Clipboard temporarily holds:", ["Copied/cut data", "Only permanent HDD archive", "Only BIOS settings", "Only IP address"], 0, "Clipboard."),
        ("Peripheral device is:", ["External device connected to PC", "Only CPU core", "Only ALU", "Only register"], 0, "Peripherals."),
        ("Scanner is used to:", ["Digitize paper documents/images", "Only print", "Only cool", "Only amplify sound"], 0, "Scan input."),
        ("Plotter is used for:", ["Large precision drawings/prints", "Only typing", "Only browsing", "Only antivirus"], 0, "Plotting."),
        ("OCR stands for:", ["Optical Character Recognition", "Online Computer Relay", "Output Control Register", "Open Code Reader"], 0, "OCR."),
        ("AI stands for:", ["Artificial Intelligence", "Automatic Input", "Analog Interface", "Application Installer"], 0, "AI."),
        ("IoT stands for:", ["Internet of Things", "Input of Text", "Index of Tables", "Internal office Tool"], 0, "IoT."),
        ("5G is related to:", ["Mobile network generation", "Only USB version", "Only HDMI", "Only VGA"], 0, "Cellular tech."),
        ("Pixel is:", ["Picture element", "A programming loop", "A network cable", "A power unit"], 0, "Pixel."),
        ("Resolution 1920×1080 is called:", ["Full HD", "Only VGA", "Only 8K always", "Only QCIF"], 0, "1080p FHD."),
        ("Bit depth relates to:", ["Color information amount", "Only CPU cores", "Only fan speed", "Only mouse DPI alone always"], 0, "Color depth."),
        ("Driver software:", ["Helps OS use hardware", "Only writes novels", "Only plays songs", "Only edits DNA"], 0, "Device driver."),
    ]
    out = []
    for i, row in enumerate(bank, 1):
        out.append(q(f"shc_comp_{i:03d}", "sindh_high_court", "shc_computer", *row))
    return dedupe(out)


def gen_shc_english():
    # similar grammar/vocab oriented for clerical tests
    base = gen_sts_english()
    out = []
    for i, item in enumerate(base, 1):
        out.append(
            q(
                f"shc_en_{i:03d}",
                "sindh_high_court",
                "shc_english",
                item["question"],
                item["options"],
                item["correctAnswerIndex"],
                item["explanation"],
            )
        )
    return dedupe(out)


def gen_shc_general():
    # mix of Pakistan GK + basic legal/general awareness practice
    bank = [
        ("Constitution of Pakistan currently in force:", ["1956", "1962", "1973", "1985"], 2, "1973 Constitution."),
        ("Fundamental rights are mainly in:", ["Constitution", "Only municipal bylaws", "Only company policies", "Only sports rules"], 0, "Constitution."),
        ("Supreme Court of Pakistan is the:", ["Highest court", "Lowest court", "Only civil court", "Only traffic court"], 0, "Apex court."),
        ("High Court exists at:", ["Province level", "Union council only", "Village only", "School only"], 0, "Provincial High Courts."),
        ("Advocate is a:", ["Legal practitioner", "Only doctor", "Only engineer", "Only teacher"], 0, "Lawyer."),
        ("FIR stands for:", ["First Information Report", "Final Inquiry Record", "Federal Internal Rule", "File Index Report"], 0, "FIR."),
        ("Cognizable offence can be investigated:", ["Without magistrate order generally", "Never by police", "Only by army", "Only by schools"], 0, "Police can act."),
        ("Bail is related to:", ["Temporary release under conditions", "Permanent exile", "Only marriage", "Only tax"], 0, "Bail."),
        ("Plaintiff is:", ["Person who files civil suit", "Only accused always", "Only judge", "Only witness"], 0, "Complainant in civil."),
        ("Defendant is:", ["Person sued/accused in case context", "Only lawyer", "Only clerk", "Only journalist"], 0, "Opposite party."),
        ("Affidavit is:", ["Sworn written statement", "Oral joke", "Only invoice", "Only map"], 0, "Affidavit."),
        ("Notary public authenticates:", ["Documents/signatures", "Only cricket scores", "Only weather", "Only recipes"], 0, "Notarization."),
        ("Power of attorney authorizes:", ["Someone to act on behalf", "Only voting always", "Only driving", "Only cooking"], 0, "POA."),
        ("Civil law mainly deals with:", ["Private rights/disputes", "Only war", "Only astronomy", "Only sports"], 0, "Civil matters."),
        ("Criminal law deals with:", ["Offences against state/society", "Only contracts of sale", "Only trademarks only", "Only wills only"], 0, "Crimes."),
        ("IPC historically influenced region; Pakistan Penal Code is:", ["PPC", "Only FIFA code", "Only HTML", "Only ISBN"], 0, "PPC."),
        ("Evidence is presented in:", ["Court proceedings", "Only markets", "Only playgrounds", "Only kitchens"], 0, "Judicial evidence."),
        ("Witness gives:", ["Testimony", "Only judgment always", "Only FIR always alone", "Only gazette"], 0, "Witness testimony."),
        ("Judgment is:", ["Court’s decision", "Only police diary", "Only newspaper ad", "Only school result"], 0, "Judgment."),
        ("Appeal means:", ["Challenge decision in higher forum", "Delete case file", "Only settle out always", "Only FIR cancel alone"], 0, "Appeal."),
        ("Jurisdiction means:", ["Authority to hear a case", "Only geography of oceans", "Only currency", "Only climate"], 0, "Jurisdiction."),
        ("Summons is:", ["Order to appear", "Only salary slip", "Only passport", "Only visa"], 0, "Court summons."),
        ("Warrant may authorize:", ["Arrest/search as per law", "Only marriage", "Only tourism", "Only sports"], 0, "Warrant."),
        ("Contempt of court means:", ["Disrespect/disobedience to court", "Only praise", "Only silence", "Only applause"], 0, "Contempt."),
        ("Habeas corpus relates to:", ["Personal liberty remedy", "Only property tax", "Only customs duty", "Only import"], 0, "Produce the body."),
        ("Capital of Sindh:", ["Karachi", "Hyderabad", "Sukkur", "Thatta"], 0, "Karachi."),
        ("Indus River is also called:", ["Sindhu", "Ganga", "Nile", "Amazon"], 0, "Sindhu."),
        ("Pakistan’s official name is:", ["Islamic Republic of Pakistan", "Republic of Punjab", "State of Karachi", "Union of Sindh"], 0, "Islamic Republic."),
        ("National Assembly seats are filled by:", ["Elections (general)", "Only appointment of foreigners", "Only lottery always", "Only sports boards"], 0, "General elections."),
        ("Senate is:", ["Upper house", "Lower house", "Only court", "Only municipality"], 0, "Senate."),
        ("President of Pakistan is:", ["Head of State", "Only CM", "Only Mayor", "Only Judge always"], 0, "Head of State."),
        ("Prime Minister is:", ["Head of Government", "Only Head of State always", "Only Speaker always", "Only Chief Justice always"], 0, "Executive head."),
        ("Governor is appointed for:", ["Province", "Only union council", "Only school", "Only police station"], 0, "Provincial Governor."),
        ("Chief Minister heads:", ["Provincial government", "Federal cabinet alone always", "Only judiciary", "Only army"], 0, "CM."),
        ("Local government deals with:", ["Local affairs", "Only foreign policy", "Only nuclear policy", "Only space"], 0, "Local govt."),
        ("NADRA deals with:", ["Identity registration", "Only cricket", "Only cinema", "Only tourism ads"], 0, "Identity."),
        ("FBR deals with:", ["Taxes/revenue", "Only sports", "Only education boards only", "Only hospitals only"], 0, "Federal Board of Revenue."),
        ("SBP stands for:", ["State Bank of Pakistan", "Sindh Bus Project", "School Board Pakistan", "Sports Board Punjab"], 0, "Central bank."),
        ("SECP regulates:", ["Companies/securities", "Only traffic lights", "Only school uniforms", "Only food menus"], 0, "Corporate regulator."),
        ("PEMRA regulates:", ["Electronic media", "Only banks", "Only courts", "Only ports"], 0, "Media authority."),
        ("PTA regulates:", ["Telecom", "Only agriculture", "Only fisheries", "Only mining only"], 0, "Pakistan Telecommunication Authority."),
        ("Election Commission conducts:", ["Elections", "Only exams of schools always", "Only cricket matches", "Only trade fairs"], 0, "Elections."),
        ("CNIC is issued by:", ["NADRA", "Only police station always", "Only school", "Only bank alone"], 0, "NADRA."),
        ("Passport is issued for:", ["International travel identity", "Only local bus", "Only school ID", "Only library"], 0, "Passport."),
        ("Visa is permission to:", ["Enter another country", "Only open shop", "Only drive locally", "Only vote"], 0, "Visa."),
        ("Human rights include:", ["Basic freedoms/dignity", "Only shopping discounts", "Only game cheats", "Only passwords"], 0, "HR."),
        ("Child labor is:", ["Illegal/exploitative work of children", "Recommended always", "Only sports", "Only homework"], 0, "Prohibited/exploitative."),
        ("RTI often means:", ["Right to Information", "Road Traffic Island", "Random Text Input", "Rural Tax Index"], 0, "RTI."),
        ("Public servant is:", ["Government employee in public duty", "Only private shopkeeper", "Only tourist", "Only athlete"], 0, "Public service."),
        ("Corruption means:", ["Abuse of power for private gain", "Only charity", "Only volunteering", "Only studying"], 0, "Corruption."),
        ("Transparency in office means:", ["Openness/accountability", "Hiding records", "Deleting audits", "Avoiding rules"], 0, "Good governance."),
        ("Ethics means:", ["Moral principles", "Only fashion", "Only cricket rules", "Only recipes"], 0, "Ethics."),
        ("Punctuality means:", ["Being on time", "Being late always", "Skipping work", "Ignoring duty"], 0, "On time."),
        ("Office memo is:", ["Internal written communication", "Only novel", "Only poem", "Only invoice always"], 0, "Memo."),
        ("Agenda of meeting lists:", ["Items to discuss", "Only lunch menu", "Only salaries secretly", "Only rumors"], 0, "Agenda."),
        ("Minutes of meeting are:", ["Written record of proceedings", "Only clock time", "Only tea breaks", "Only attendance alone always"], 0, "Minutes."),
        ("Filing system helps:", ["Record keeping", "Only deleting forever", "Only hiding papers", "Only burning files"], 0, "Filing."),
        ("Dispatch means:", ["Sending official papers", "Only receiving always", "Only shredding", "Only photocopying alone"], 0, "Dispatch."),
        ("Diary register records:", ["Incoming/outgoing correspondence", "Only cricket scores", "Only weather", "Only recipes"], 0, "Diary."),
        ("Stamp paper is used for:", ["Legal documents", "Only drawing", "Only painting", "Only wrapping gifts only"], 0, "Legal docs."),
        ("Attestation means:", ["Certifying authenticity", "Deleting file", "Only translating poems", "Only sealing food"], 0, "Attest."),
        ("Photocopy is:", ["Duplicate copy", "Original only", "Only handwritten unique always", "Only oral"], 0, "Xerox/copy."),
        ("Scanning converts:", ["Paper to digital image", "Digital to paper only always", "Only audio to video", "Only virus to file"], 0, "Scan."),
        ("Email etiquette includes:", ["Clear subject/professional tone", "Only shouting caps always", "Sharing passwords", "Ignoring recipients"], 0, "Etiquette."),
        ("Password should be:", ["Strong and private", "Shared with all", "Written on monitor always", "Only 1234"], 0, "Security."),
        ("Official secrecy means:", ["Protect confidential info", "Publish all secrets", "Sell data", "Ignore rules"], 0, "Confidentiality."),
        ("Conflict of interest arises when:", ["Personal interest clashes with duty", "Duty is clear and pure always", "Only holidays", "Only bonuses"], 0, "COI."),
        ("Nepotism means:", ["Favoring relatives unfairly", "Merit selection", "Open competition", "Transparent hiring"], 0, "Nepotism."),
        ("Merit means:", ["Selection on ability", "Selection on bribe", "Selection on relation only", "Random pick only"], 0, "Merit."),
        ("Accountability means:", ["Answerable for actions", "Avoid responsibility", "Hide mistakes", "Blame others only"], 0, "Accountability."),
        ("Rule of law means:", ["Law applies equally", "Law for poor only", "Law for rich only", "No law"], 0, "Rule of law."),
        ("Democracy means:", ["Rule by people", "Rule by one forever without vote", "No elections", "Only monarchy"], 0, "Democracy."),
        ("Federation means:", ["Union of units with division of powers", "Only one city state always", "Only dictatorship", "Only anarchy"], 0, "Federal system."),
        ("Province of Pakistan count (standard):", ["4", "5", "3", "2"], 0, "Four provinces (+ special territories)."),
        ("Islamabad is:", ["Federal capital", "Provincial capital of Sindh", "Only a port city name for Quetta", "Only a desert"], 0, "Capital."),
        ("Karachi is major:", ["Port city", "Only mountain capital", "Only desert fort", "Only glacier town"], 0, "Port."),
        ("Hyderabad is in:", ["Sindh", "Punjab", "KP", "Balochistan"], 0, "Sindh."),
        ("Sukkur is known for:", ["Indus/Sukkur Barrage area", "Only sea port of Gwadar", "Only K2 base camp", "Only Thar oil only"], 0, "Sukkur."),
        ("Larkana is in:", ["Sindh", "Punjab", "KP", "Balochistan"], 0, "Sindh."),
        ("Thatta is historically known for:", ["Makli/heritage", "Only ski resorts", "Only tea gardens of KP only", "Only seaports of Punjab"], 0, "Heritage."),
        ("Sehwan is famous for:", ["Lal Shahbaz Qalandar shrine", "Only assembly building", "Only stock exchange", "Only airport only"], 0, "Sehwan."),
        ("Moenjodaro is UNESCO site in:", ["Sindh", "Punjab", "KP", "Balochistan"], 0, "Sindh."),
        ("Sindhi language is:", ["Provincial language of Sindh", "Only English", "Only Arabic exclusive", "Only Chinese"], 0, "Sindhi."),
        ("Urdu is:", ["National language", "Only provincial of KP exclusive", "Only dead language", "Only programming language"], 0, "National."),
        ("English is used as:", ["Official language in many offices", "Only village dialect exclusive", "Only extinct", "Only sign language"], 0, "Official use."),
        ("Basic computer skill needed in offices often:", ["MS Office", "Only farming", "Only mining", "Only diving"], 0, "Office IT."),
        ("Internet helps offices for:", ["Communication/research", "Only cooking", "Only swimming", "Only sewing"], 0, "ICT."),
        ("Cybercrime includes:", ["Online fraud/hacking etc.", "Only offline theft of cattle", "Only traffic signal jump", "Only littering"], 0, "Cyber offences."),
        ("Digital signature is used to:", ["Authenticate electronic docs", "Only draw art", "Only play music", "Only water plants"], 0, "E-sign."),
        ("E-governance means:", ["Govt services via ICT", "Only paper piles more", "Only closing offices", "Only banning internet"], 0, "E-gov."),
        ("RTI request is for:", ["Accessing public information", "Hiding public info", "Deleting archives", "Selling secrets"], 0, "Transparency."),
        ("Ombudsman deals with:", ["Public complaints against maladministration", "Only sports disputes", "Only cinema", "Only fashion"], 0, "Ombudsman."),
        ("Press is called:", ["Fourth estate (informally)", "Only first estate always", "Only army", "Only judiciary alone"], 0, "Media role."),
        ("Freedom of speech is:", ["A fundamental right (with limits)", "Unlimited to defame always", "Only for officials", "Not a right"], 0, "Fundamental right."),
        ("Equality before law means:", ["No one above law", "Rich exempt", "Officials exempt", "Foreigners exempt always"], 0, "Equality."),
        ("Double jeopardy means:", ["Not tried twice for same offence (principle)", "Tried weekly forever", "No trial ever", "Only civil suits"], 0, "Legal principle."),
        ("Presumption of innocence means:", ["Innocent until proven guilty", "Guilty until proven", "No courts", "Only fines"], 0, "Criminal justice."),
        ("Natural justice includes:", ["Fair hearing", "Secret bias encouraged", "No notice", "No chance to reply"], 0, "Audi alteram partem etc."),
        ("Limitation period relates to:", ["Time limit to file case", "Unlimited delay always allowed", "Only age of judge", "Only court size"], 0, "Limitation."),
        ("Injunction is:", ["Court order to do/not do something", "Only a poem", "Only a tax", "Only a festival"], 0, "Injunction."),
        ("Stay order temporarily:", ["Stops action pending decision", "Ends constitution", "Deletes laws", "Creates new province"], 0, "Stay."),
        ("Decree is:", ["Formal expression of civil court adjudication", "Only FIR", "Only charge sheet", "Only bail bond"], 0, "Decree."),
        ("Execution of decree means:", ["Enforcement of court’s decree", "Writing novel", "Filing FIR only", "Only mediation poem"], 0, "Execution."),
        ("Arbitration is:", ["Alternative dispute resolution", "Only war", "Only election", "Only taxation"], 0, "ADR."),
        ("Mediation aims to:", ["Settle dispute with facilitator", "Increase conflict", "Ignore parties", "Destroy evidence"], 0, "Mediation."),
        ("Lok Adalat style mechanisms promote:", ["Speedy amicable settlement", "Endless delay", "Secret trials only", "No justice"], 0, "ADR."),
        ("Public interest litigation concerns:", ["Broader public issues", "Only private gossip", "Only one secret deal", "Only fashion"], 0, "PIL idea."),
        ("Legal aid helps:", ["Poor access justice", "Only rich clients", "Only destroy cases", "Only hide lawyers"], 0, "Access to justice."),
        ("Bar council regulates:", ["Legal profession", "Only doctors", "Only engineers", "Only teachers"], 0, "Bar."),
        ("Code of conduct for employees stresses:", ["Integrity and duty", "Bribery", "Absenteeism", "Leak of secrets for fun"], 0, "Conduct."),
        ("Punctual attendance is:", ["Professional duty", "Optional always", "Punishable to be on time", "Useless"], 0, "Duty."),
        ("Official email should avoid:", ["Abusive language", "Clear subject", "Polite tone", "Relevant attachment"], 0, "Avoid abuse."),
        ("Record retention means:", ["Keeping records as per policy", "Burning all files daily", "Never filing", "Losing registers"], 0, "Retention."),
        ("Audit ensures:", ["Financial/ procedural check", "Only decoration", "Only parties", "Only holidays"], 0, "Audit."),
        ("Budget is:", ["Financial plan", "Only novel", "Only map", "Only poem"], 0, "Budget."),
        ("Petty cash is for:", ["Small office expenses", "Buying buildings only", "Foreign trips only", "Only salaries of ministers"], 0, "Petty cash."),
        ("Inventory means:", ["Stock list", "Only employee list always", "Only court cause list alone", "Only voter list alone"], 0, "Inventory."),
        ("Procurement should be:", ["Transparent and as per rules", "Secret always", "Based on favoritism", "Without record"], 0, "Procurement."),
        (" Quotation in purchase means:", ["Price offer from supplier", "A poem quote only", "Only court quote", "Only news headline"], 0, "Quotation."),
        ("Tender is:", ["Formal bid invitation", "Only informal chat", "Only rumor", "Only gift"], 0, "Tender."),
        ("Work order authorizes:", ["Vendor to start work", "Only leave", "Only transfer", "Only retirement"], 0, "Work order."),
        ("Bill for payment should be:", ["Verified", "Never checked", "Always paid twice", "Always ignored"], 0, "Verification."),
        ("Acknowledgement receipt proves:", ["Something was received", "Something was never sent", "Only future promise", "Only oral talk"], 0, "Receipt."),
        ("Dispatch number helps:", ["Tracking correspondence", "Cooking", "Sports only", "Weather only"], 0, "Tracking."),
        ("Confidential file marking means:", ["Restricted access", "Public notice board paste", "Social media post", "Open email to all"], 0, "Confidential."),
        ("Weeding of records means:", ["Removing obsolete records as per rules", "Planting trees only", "Deleting evidence illegally", "Hiding forever without rule"], 0, "Weeding."),
        ("Office timing discipline improves:", ["Efficiency", "Chaos", "Losses only", "Conflicts only"], 0, "Discipline."),
        ("Teamwork in office means:", ["Cooperating for goals", "Working against colleagues", "Hiding information always", "Blaming juniors"], 0, "Teamwork."),
        ("Customer/public dealing should be:", ["Courteous", "Rude", "Biased always", "Ignoring"], 0, "Public service."),
        ("Gender discrimination at workplace is:", ["Unacceptable/illegal in principle", "Recommended", "Mandatory", "A promotion criteria"], 0, "Equality."),
        ("Harassment complaint mechanisms exist to:", ["Protect dignity at work", "Encourage abuse", "Hide cases", "Punish victims"], 0, "Protection."),
        ("Whistleblowing (in good faith) relates to:", ["Reporting wrongdoing", "Spreading rumors", "Leaking passwords for fun", "Forging docs"], 0, "Integrity."),
        ("Conflict resolution at work should prefer:", ["Dialogue/rules", "Violence", "Ignoring law", "Bribes"], 0, "Peaceful resolution."),
        ("Time management improves:", ["Productivity", "Only delays", "Only stress forever", "Only errors"], 0, "Time mgmt."),
        ("Note-sheet in files is for:", ["Internal proposals/remarks", "Only external ads", "Only newspapers", "Only posters"], 0, "Noting."),
        ("Flagging a file helps:", ["Mark important pages", "Destroy pages", "Lose pages", "Sell pages"], 0, "Flagging."),
        ("Reference number on letter helps:", ["Identification/tracking", "Decoration only", "Hiding identity", "No purpose"], 0, "Reference."),
        ("Subject line of letter should be:", ["Clear and brief", "Empty always", "Abusive", "Random characters"], 0, "Subject."),
        ("Enclosure means:", ["Attached documents", "Only empty envelope", "Only stamp", "Only address"], 0, "Encl."),
        ("CC on official letter means:", ["Copy to others", "Cancel copy", "Court copy only", "Cash counter"], 0, "Carbon copy."),
        ("Draft letter is:", ["Preliminary version", "Final gazette always", "FIR", "Judgment"], 0, "Draft."),
        ("Fair copy is:", ["Final typed clean version", "Rough notes only", "Only pencil scribble", "Only oral"], 0, "Fair copy."),
        ("Dispatch rider carries:", ["Official dak/packages", "Only personal shopping always", "Only rumors", "Only cash without record always"], 0, "Dak."),
        ("Peon/Qasid traditionally assists in:", ["Office delivery tasks", "Judging cases", "Passing laws", "Commanding army"], 0, "Support staff."),
        ("Reception desk handles:", ["Visitors/front office", "Only Supreme Court benches", "Only foreign policy", "Only nuclear"], 0, "Reception."),
        ("Attendance register records:", ["Presence of staff", "Only visitors’ secrets", "Only court judgments", "Only budgets"], 0, "Attendance."),
        ("Leave application should be:", ["Submitted as per rules", "Never submitted", "Oral only always enough", "After years only"], 0, "Leave rules."),
        ("Casual leave is generally for:", ["Short personal needs as per rules", "Permanent resignation", "Only foreign settlement", "Only study abroad years"], 0, "CL."),
        ("Medical leave requires:", ["Proper medical basis/docs as rules", "No reason", "Only festival", "Only picnic"], 0, "ML."),
        ("Joining report is submitted on:", ["Joining duty", "Resigning only", "Retirement only", "Transfer refusal only"], 0, "Joining."),
        ("Charge handover note is used during:", ["Transfer/relieving", "Only lunch", "Only cricket", "Only holidays"], 0, "Handing/taking over."),
        ("Relieving order allows:", ["Official release from post", "Only promotion ad", "Only newspaper", "Only rumor"], 0, "Relieving."),
        ("Posting order assigns:", ["Place of duty", "Only salary cut", "Only punishment always", "Only leave"], 0, "Posting."),
        ("Seniority list shows:", ["Order of seniority", "Only alphabetical random forever", "Only salaries secret", "Only addresses"], 0, "Seniority."),
        ("ACR/PER relates to:", ["Performance evaluation", "Only attendance joke", "Only canteen menu", "Only sports"], 0, "Appraisal."),
        ("Training improves:", ["Skills/capacity", "Ignorance", "Only delays", "Only conflicts"], 0, "Capacity building."),
        ("Soft skills include:", ["Communication/teamwork", "Only soldering wires", "Only mining", "Only plumbing exclusive"], 0, "Soft skills."),
        ("Hard skills include:", ["Technical abilities like typing/software", "Only attitudes", "Only feelings", "Only rumors"], 0, "Hard skills."),
        ("Keyboard shortcut knowledge increases:", ["Office speed", "Only walking speed", "Only cooking speed", "Only swimming"], 0, "IT skill."),
        ("Data privacy means:", ["Protect personal/official data", "Publish all private data", "Sell CNICs", "Share OTPs"], 0, "Privacy."),
        ("OTP should:", ["Not be shared", "Be posted publicly", "Be given to strangers", "Be ignored as spam always"], 0, "Security."),
        ("Two-factor authentication adds:", ["Extra login security", "Extra viruses", "Extra spam only", "Extra corruption"], 0, "2FA."),
        ("Official stamp misuse is:", ["Serious misconduct", "Recommended", "A joke", "A right"], 0, "Misuse."),
        ("Forgery means:", ["Fake document/signature crime", "Valid notarization", "Legal draft", "Fair copy"], 0, "Forgery."),
        ("Embezzlement means:", ["Misappropriation of funds", "Honest accounting", "Donation", "Audit success"], 0, "Embezzlement."),
        ("Bribery is:", ["Illegal gratification", "Legal salary", "Pension", "Bonus lawful"], 0, "Bribery."),
        ("Extortion is:", ["Obtaining by threats", "Free gift", "Loan with consent fair", "Charity"], 0, "Extortion."),
        ("Perjury is:", ["False evidence under oath", "True testimony", "Silence", "Adjournment"], 0, "Perjury."),
        ("Defamation harms:", ["Reputation", "Only buildings", "Only roads", "Only weather"], 0, "Defamation."),
        ("Libel is often:", ["Written defamation", "Only oral", "Only thoughts", "Only dreams"], 0, "Libel."),
        ("Slander is often:", ["Spoken defamation", "Only written carved in stone", "Only silent", "Only digital hash"], 0, "Slander."),
        ("Cyber defamation can occur via:", ["Social media/posts", "Only offline stone carvings", "Only private diaries never shared", "Only thoughts"], 0, "Online."),
        ("Intellectual property includes:", ["Copyrights/trademarks/patents", "Only land", "Only cash", "Only furniture"], 0, "IP."),
        ("Copyright protects:", ["Original creative works", "Only ideas never expressed", "Only facts alone", "Only blank paper"], 0, "Copyright."),
        ("Trademark protects:", ["Brand identifiers", "Only novels text always", "Only inventions process only", "Only domain DNS only"], 0, "Trademark."),
        ("Patent protects:", ["Inventions", "Only logos always", "Only songs always", "Only company names always"], 0, "Patent."),
        ("Plagiarism is:", ["Copying others’ work without credit", "Original research", "Proper citation", "Fair use always"], 0, "Plagiarism."),
        ("Citation means:", ["Giving credit to sources", "Hiding sources", "Deleting quotes", "Forging authors"], 0, "Citation."),
        ("Official statistics should be:", ["Accurate", "Fabricated", "Hidden always", "Guessed randomly"], 0, "Accuracy."),
        ("Misinformation is:", ["False/misleading info", "Verified facts", "Peer-reviewed truth", "Official gazette truth"], 0, "Misinfo."),
        ("Fact-checking helps:", ["Verify claims", "Spread rumors faster", "Hide truth", "Create panic"], 0, "Fact-check."),
        ("Public records should be:", ["Managed lawfully", "Sold privately", "Burned secretly", "Altered for favor"], 0, "Records mgmt."),
        ("Right to fair trial is:", ["Important legal right", "Optional luxury", "Only for officials", "Against constitution"], 0, "Fair trial."),
        ("Independent judiciary means:", ["Courts free from improper influence", "Courts controlled by parties", "No courts", "Only executive courts"], 0, "Independence."),
        ("Separation of powers divides:", ["Legislature/executive/judiciary", "Only sports teams", "Only school classes", "Only markets"], 0, "Separation."),
        ("Checks and balances prevent:", ["Concentration of power", "Democracy", "Elections", "Constitutions"], 0, "Checks."),
        ("Federal list subjects are:", ["Federation’s domain", "Only union councils", "Only private clubs", "Only NGOs"], 0, "Federal list."),
        ("Provincial autonomy relates to:", ["Provincial powers", "Only foreign embassies", "Only UN seats", "Only IMF"], 0, "Autonomy."),
        ("Local government elections choose:", ["Local representatives", "Only UN SG", "Only FIFA head", "Only WHO DG"], 0, "LG elections."),
        ("Voter registration is needed to:", ["Cast vote", "Drive car", "Open only WhatsApp", "Cook food"], 0, "Franchise."),
        ("Ballot secrecy protects:", ["Voter choice privacy", "Public announcement of each choice live always", "Candidate threats", "Booth capturing"], 0, "Secret ballot."),
        ("Rigging elections is:", ["Electoral fraud", "Fair practice", "Recommended", "Legal always"], 0, "Illegal."),
        ("Code of conduct during elections guides:", ["Fair campaigning", "Violence", "Bribery", "Hate speech"], 0, "CoC."),
        ("Census counts:", ["Population", "Only trees abroad", "Only stars", "Only fish in ocean only"], 0, "Census."),
        ("NADRA biometric is for:", ["Identity verification", "Only games", "Only movies", "Only sports scores"], 0, "Biometric ID."),
        ("SIM verification policies aim to:", ["Security/traceability", "Increase fraud", "Hide criminals", "Disable all phones forever"], 0, "SIM regs."),
        ("Emergency numbers knowledge helps:", ["Quick response", "Only delay", "Only confusion", "Only silence"], 0, "Preparedness."),
        ("First aid basics can:", ["Save lives before hospital", "Replace all doctors forever", "Cure all diseases alone", "Ignore injuries"], 0, "First aid."),
        ("Fire safety includes:", ["Exits/extinguishers awareness", "Blocking exits", "Using lift in fire always", "Hiding alarms"], 0, "Fire safety."),
        ("Earthquake safety: during shaking often advised:", ["Drop, cover, hold on", "Run to windows always", "Use elevators", "Stand under loose shelves"], 0, "Drop-cover-hold."),
        ("Flood preparedness includes:", ["Early warnings/evacuation plans", "Ignoring alerts", "Building in drains", "Blocking drains more"], 0, "DRR."),
        ("Environmental protection is:", ["Shared responsibility", "Nobody’s job", "Only foreign issue", "Against development always"], 0, "Environment."),
        ("Clean drinking water relates to:", ["Public health", "Only fashion", "Only cinema", "Only sports kits"], 0, "Health."),
        ("Polio vaccination campaigns protect:", ["Children’s health", "Only cars", "Only buildings", "Only websites"], 0, "Immunization."),
        ("Traffic rules exist to:", ["Prevent accidents", "Cause chaos", "Ignore signals", "Speed unlimited in cities"], 0, "Road safety."),
        ("Seat belt use:", ["Saves lives", "Is useless", "Is illegal", "Is only for pilots"], 0, "Safety."),
        ("Helmet for riders:", ["Reduces head injury", "Increases injury always", "Is decoration only", "Is banned"], 0, "Helmet."),
        ("Drunk driving is:", ["Dangerous/illegal", "Safe", "Recommended", "A skill test"], 0, "Illegal."),
        ("Pedestrian zebra crossing is for:", ["Safe crossing", "Parking", "Racing", "Advertising only"], 0, "Crossing."),
        ("Office recycling reduces:", ["Waste", "Only salaries", "Only holidays", "Only electricity legally always somehow"], 0, "Environment."),
        ("Energy saving in offices includes:", ["Switching off unused lights/ACs", "Keeping all ACs max always", "Opening all taps", "Printing everything thrice"], 0, "Save energy."),
        ("Paperless initiatives aim to:", ["Reduce paper use via digital", "Increase paper waste", "Ban computers", "Delete all records illegally"], 0, "Digital office."),
        ("Ergonomics in workplace concerns:", ["Healthy posture/setup", "Only wallpaper color fashion", "Only gossip", "Only canteen spices"], 0, "Ergonomics."),
        ("Repetitive strain can be reduced by:", ["Breaks/proper setup", "No breaks ever", "Only more stress", "Ignoring pain always"], 0, "Health."),
        ("Mental health at work matters for:", ["Wellbeing/productivity", "Only machines", "Only furniture", "Only ink"], 0, "Wellbeing."),
        ("Inclusive workplace means:", ["Respect for all", "Exclusion", "Discrimination", "Harassment"], 0, "Inclusion."),
        ("Disability accommodation is:", ["Reasonable support for access", "Punishment", "Ignore needs", "Exclude"], 0, "Inclusion."),
        ("Cultural sensitivity means:", ["Respect diverse backgrounds", "Mock cultures", "Force one culture rudely", "Ignore colleagues"], 0, "Respect."),
        ("Professional email signature may include:", ["Name/designation/contact", "Only emojis spam", "Only jokes", "Only threats"], 0, "Signature."),
        (
            "Out-of-office reply informs:",
            ["Absence/alternative contact", "Passwords", "Secret files", "Personal CNIC"],
            0,
            "OOO auto-reply.",
        ),
    ]
    # fix the botched tuple at the end and the Capital of Sindh weird line
    fixed = []
    for row in bank:
        if len(row) != 4:
            continue
        qtext, options, correct, expl = row
        if "Capital of Sindh" in qtext:
            fixed.append(("Capital of Sindh:", ["Karachi", "Hyderabad", "Sukkur", "Thatta"], 0, "Karachi."))
        elif "Out-of-office" in qtext:
            fixed.append(
                (
                    "Out-of-office reply informs:",
                    ["Absence/alternative contact", "Passwords", "Secret files", "Personal CNIC"],
                    0,
                    "OOO auto-reply.",
                )
            )
        else:
            fixed.append(row)
    out = []
    for i, row in enumerate(fixed, 1):
        out.append(q(f"shc_gen_{i:03d}", "sindh_high_court", "shc_general", *row))
    return dedupe(out)


def main():
    # NTS
    nts = []
    nts.extend(gen_nts_analytics()[:120])
    nts.extend(gen_nts_english()[:120])
    nts.extend(gen_nts_gk()[:120])
    save("nts_questions.json", nts)

    # STS: keep existing GK-heavy file content with correct IDs, add math+english
    existing_sts = load("sts_questions.json")
    # keep only items already tagged sts_* subjects where possible
    kept = [
        x
        for x in existing_sts
        if x.get("subjectId") in {"sts_gk", "sts_math", "sts_english"}
        or x.get("categoryId") == "sts_exam"
    ]
    sts = dedupe(kept + gen_sts_math() + gen_sts_english())
    save("sts_questions.json", sts)

    # SHC
    existing_shc = load("shc_questions.json")
    shc = dedupe(existing_shc + gen_shc_computer() + gen_shc_english() + gen_shc_general())
    save("shc_questions.json", shc)

    print("Part2 complete")


if __name__ == "__main__":
    main()
