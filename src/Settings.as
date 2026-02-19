[Setting hidden] uint  S_Custom       = 0;
[Setting hidden] bool  S_Enabled      = true;
[Setting hidden] bool  S_HideWithGame = true;
[Setting hidden] bool  S_HideWithOP   = false;
[Setting hidden] Medal S_Medal        = Medal::None;

[SettingsTab name="General" icon="Cog" order=0]
void SettingsTab_General() {
    S_Enabled = UI::Checkbox("Enabled", S_Enabled);

    if (UI::BeginCombo("Medal", tostring(S_Medal), UI::ComboFlags::HeightLargest)) {
#if DEPENDENCY_CHAMPIONMEDALS
        if (UI::Selectable("Champion", S_Medal == Medal::Champion)) {
            S_Medal = Medal::Champion;
        }
#endif

#if DEPENDENCY_WARRIORMEDALS
        if (UI::Selectable("Warrior", S_Medal == Medal::Warrior)) {
            S_Medal = Medal::Warrior;
        }
#endif

        Medal medal;

#if TURBO
        for (int i = Medal::SuperTrackmaster; i <= Medal::Trackmaster; i++) {
            medal = Medal(i);
            if (UI::Selectable(tostring(medal), S_Medal == medal)) {
                S_Medal = medal;
            }
        }
#else
        if (UI::Selectable("Author", S_Medal == Medal::Author)) {
            S_Medal = Medal::Author;
        }
#endif

        for (int i = Medal::Gold; i <= Medal::Custom; i++) {
            medal = Medal(i);
            if (UI::Selectable(tostring(medal), S_Medal == medal)) {
                S_Medal = medal;
            }
        }

        UI::EndCombo();
    }
}

[SettingsTab name="Debug" icon="Bug" order=1]
void SettingsTab_Debug() {
    UI::Text("map type: " + tostring(GetMapType()));
    UI::Text("PB: " + GetPB());
    UI::Text("PB medal: " + tostring(GetPBMedal()));

    UI::Separator();

    CGameCtnChallenge@ Map = GetMap();
    if (Map !is null) {
#if DEPENDENCY_CHAMPIONMEDALS
        UI::Text("champion: " + GetChampionTime());
#endif
#if DEPENDENCY_WARRIORMEDALS
        UI::Text("warrior: " + GetWarriorTime());
#endif
#if TURBO
        UI::Text("super trackmaster: " + 0);  // TODO
        UI::Text("super gold: " + 0);  // TODO
        UI::Text("super silver: " + 0);  // TODO
        UI::Text("super bronze: " + 0);  // TODO
        UI::Text("trackmaster: " + Map.TMObjective_AuthorTime);
#else
        UI::Text("author: " + Map.TMObjective_AuthorTime);
#endif
        UI::Text("gold: " + Map.TMObjective_GoldTime);
        UI::Text("silver: " + Map.TMObjective_SilverTime);
        UI::Text("bronze: " + Map.TMObjective_BronzeTime);
    }
}
