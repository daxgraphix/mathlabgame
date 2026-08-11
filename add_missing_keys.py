import json

# Missing keys with English values and Swahili translations
missing_keys = {
    "gameMode": {"en": "Game Mode", "sw": "Hali ya Mchezo"},
    "intensity": {"en": "Intensity", "sw": "Uwiano"},
    "initializeMix": {"en": "Initialize Mix", "sw": "Anza Mchanganyiko"},
    "standard": {"en": "Standard", "sw": "Kawaida"},
    "suddenDeath": {"en": "Sudden Death", "sw": "Kifo Ghafla"},
    "zen": {"en": "Zen", "sw": "Zen"},
    "timeAttack": {"en": "Time Attack", "sw": "Shambulizi la Muda"},
    "modeProtocols": {"en": "Mode Protocols", "sw": "Itifaki za Hali"},
    "standardDesc": {"en": "Standard: Solve problems at your own pace with no time limit.", "sw": "Kawaida: Suluhisha matatizo kwa kasi yako bila kikomo cha muda."},
    "suddenDeathDesc": {"en": "Sudden Death: One mistake and it's game over!", "sw": "Kifo Ghafla: Kosa moja na mchezo umekwisha!"},
    "zenDesc": {"en": "Zen: Relaxed mode with no scoring, just practice.", "sw": "Zen: Hali ya uwelevu bila alama, mazoezi tu."},
    "timeAttackDesc": {"en": "Time Attack: Solve as many problems as possible in 60 seconds.", "sw": "Shambulizi la Muda: Suluhisha matatizo mengi iwezekanavyo katika sekunde 60."},
    "elapsed": {"en": "Elapsed", "sw": "Imetumika"},
    "getHint": {"en": "Get Hint", "sw": "Pata Kidokezo"},
    "challengesSummary": {"en": "Challenges Summary", "sw": "Muhtasari wa Changamoto"},
    "dailyChallenges": {"en": "Daily Challenges", "sw": "Changamoto za Kila Siku"},
    "weeklyChallenges": {"en": "Weekly Challenges", "sw": "Changamoto za Kila Wiki"},
    "claimed": {"en": "Claimed", "sw": "Imechukuliwa"},
    "mathRiddles": {"en": "Math Riddles", "sw": "Vitendawili vya Hesabu"},
    "timeToFirstAnswer": {"en": "Time to First Answer", "sw": "Muda wa Jibu la Kwanza"},
    "timingByMode": {"en": "Timing by Mode", "sw": "Muda kwa Hali"},
    "timingTrend": {"en": "Timing Trend", "sw": "Mwelekeo wa Muda"},
    "areYouGettingFaster": {"en": "Are you getting faster?", "sw": "Je, unakua kwa kasi?"},
}

# Read both files
with open('lib/l10n/app_en.arb', encoding='utf-8') as f:
    en = json.load(f)
with open('lib/l10n/app_sw.arb', encoding='utf-8-sig') as f:
    sw = json.load(f)

# Add missing keys to English file
for key, values in missing_keys.items():
    if key not in en:
        en[key] = values["en"]
        en[f"@{key}"] = {
            "description": "",
            "placeholders": {}
        }

# Add missing keys to Swahili file
for key, values in missing_keys.items():
    if key not in sw:
        sw[key] = values["sw"]
        sw[f"@{key}"] = {
            "description": "",
            "placeholders": {}
        }

# Fix placeholder types for numeric placeholders to "int"
# These are the placeholders that receive int values in Dart code
numeric_placeholders = {
    "pts": "int",
    "level": "int",
    "hours": "int",
    "minutes": "int",
    "seconds": "int",
    "points": "int",
    "percentage": "int",
    "count": "int",
    "multiplier": "int",
    "xp": "int",
    "stars": "int",
    "total": "int",
}

for arb in [en, sw]:
    for key, value in arb.items():
        if key.startswith('@') and not key.startswith('@@'):
            md = arb[key]
            if 'placeholders' in md:
                for ph_name in list(md['placeholders'].keys()):
                    if ph_name in numeric_placeholders:
                        md['placeholders'][ph_name]['type'] = numeric_placeholders[ph_name]

# Write updated files
with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    json.dump(en, f, ensure_ascii=False, indent=2)
    f.write('\n')

with open('lib/l10n/app_sw.arb', 'w', encoding='utf-8') as f:
    json.dump(sw, f, ensure_ascii=False, indent=2)
    f.write('\n')

print("Added missing keys and fixed placeholder types")
