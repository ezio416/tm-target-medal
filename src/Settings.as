[Setting hidden category="General"] uint  S_Custom        = 0;
[Setting hidden category="General"] bool  S_Enabled       = true;
[Setting hidden category="General"] bool  S_HideWithGame  = true;
[Setting hidden category="General"] bool  S_HideWithOP    = false;
[Setting hidden category="General"] Medal S_Medal         = Medal::Finish;
[Setting hidden category="General"] bool  S_NotifyOnEnter = false;

#if TMNEXT
[Setting hidden category="Colors"] vec3  S_ColorChampion         = vec3(1.0f, 0.267f, 0.467f);
[Setting hidden category="Colors"] vec3  S_ColorWarrior          = vec3(0.18f, 0.58f, 0.8f);
#elif MP4 || TURBO
[Setting hidden category="Colors"] vec3  S_ColorDuck             = vec3(0.94f, 0.0f, 0.0f);
#endif
#if TURBO
[Setting hidden category="Colors"] vec3  S_ColorSuperTrackmaster = vec3(0.0f, 1.0f, 1.0f);
[Setting hidden category="Colors"] vec3  S_ColorSuperGold        = vec3(1.0f, 0.87f, 0.0f);
[Setting hidden category="Colors"] vec3  S_ColorSuperSilver      = vec3(0.75f);
[Setting hidden category="Colors"] vec3  S_ColorSuperBronze      = vec3(0.69f, 0.5f, 0.0f);
[Setting hidden category="Colors"] vec3  S_ColorTrackmaster      = vec3(0.17f, 0.75f, 0.0f);
#else
[Setting hidden category="Colors"] vec3  S_ColorAuthor           = vec3(0.17f, 0.75f, 0.0f);
#endif
[Setting hidden category="Colors"] vec3  S_ColorGold             = vec3(1.0f, 0.87f, 0.0f);
[Setting hidden category="Colors"] vec3  S_ColorSilver           = vec3(0.75f);
[Setting hidden category="Colors"] vec3  S_ColorBronze           = vec3(0.69f, 0.5f, 0.0f);
[Setting hidden category="Colors"] vec3  S_ColorFinish           = vec3(1.0f, 0.0f, 0.0f);
[Setting hidden category="Colors"] vec3  S_ColorCustom           = vec3(1.0f, 0.0f, 1.0f);

[SettingsTab name="Main" icon="Cog" order=0]
void SettingsTab_Main() {
    UI::SeparatorText("General");

    if (UI::Button("Reset to default##general")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "General") {
                settings[i].Reset();
            }
        }
    }

    S_Enabled = UI::Checkbox("Enabled", S_Enabled);
    S_NotifyOnEnter = UI::Checkbox("Notify when entering map", S_NotifyOnEnter);

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
        for (int i = Medal::Duck; i <= Medal::Trackmaster; i++) {
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

    if (S_Medal == Medal::Custom) {
        S_Custom = Math::Clamp(UI::InputInt("ms", S_Custom), 0, MAX_INT);
    }

    UI::SeparatorText("Colors");

    if (UI::Button("Reset to default##colors")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "Colors") {
                settings[i].Reset();
            }
        }
    }

#if DEPENDENCY_CHAMPIONMEDALS
    S_ColorChampion         = UI::InputColor3("Champion",          S_ColorChampion);
#endif
#if DEPENDENCY_WARRIORMEDALS
    S_ColorWarrior          = UI::InputColor3("Warrior",           S_ColorWarrior);
#endif
#if DEPENDENCY_DUCKMEDALS
    S_ColorChampion         = UI::InputColor3("Duck",              S_ColorDuck);
#endif
#if TURBO
    S_ColorSuperTrackmaster = UI::InputColor3("Super Trackmaster", S_ColorSuperTrackmaster);
    S_ColorSuperGold        = UI::InputColor3("Super Gold",        S_ColorSuperGold);
    S_ColorSuperSilver      = UI::InputColor3("Super Silver",      S_ColorSuperSilver);
    S_ColorSuperBronze      = UI::InputColor3("Super Bronze",      S_ColorSuperBronze);
#else
    S_ColorAuthor           = UI::InputColor3("Author",            S_ColorAuthor);
#endif
    S_ColorGold             = UI::InputColor3("Gold",              S_ColorGold);
    S_ColorSilver           = UI::InputColor3("Silver",            S_ColorSilver);
    S_ColorBronze           = UI::InputColor3("Bronze",            S_ColorBronze);
    S_ColorFinish           = UI::InputColor3("Finish",            S_ColorFinish);
    S_ColorCustom           = UI::InputColor3("Custom",            S_ColorCustom);
}

[SettingsTab name="Debug" icon="Bug" order=1]
void SettingsTab_Debug() {
    UI::Text("map type: " + tostring(GetMapType()));
    UI::Text("PB: " + GetPB());
    UI::Text("PB medal: " + tostring(GetPBMedal()));

    UI::Separator();

    if (InMap()) {
#if DEPENDENCY_CHAMPIONMEDALS
        UI::Text("champion: " + GetChampionTime());
#endif
#if DEPENDENCY_WARRIORMEDALS
        UI::Text("warrior: " + GetWarriorTime());
#endif
#if TURBO
        UI::Text("super trackmaster: " + GetMedalTime(Medal::SuperTrackmaster));
        UI::Text("super gold: "        + GetMedalTime(Medal::SuperGold));
        UI::Text("super silver: "      + GetMedalTime(Medal::SuperSilver));
        UI::Text("super bronze: "      + GetMedalTime(Medal::SuperBronze));
        UI::Text("trackmaster: "       + GetMedalTime(Medal::Trackmaster));
#else
        UI::Text("author: "            + GetMedalTime(Medal::Author));
#endif
        UI::Text("gold: "              + GetMedalTime(Medal::Gold));
        UI::Text("silver: "            + GetMedalTime(Medal::Silver));
        UI::Text("bronze: "            + GetMedalTime(Medal::Bronze));
        UI::Text("custom: "            + S_Custom);
    }
}
