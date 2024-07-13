// c 2024-02-18
// m 2024-07-13

string       currentAuthor;
string       currentBronze;
string       currentChampion;
string       currentCustom;
string       currentGold;
string       currentSilver;
uint         pb     = 0;
const float  scale  = UI::GetScale();
bool         stunt  = false;
string       targetText;
const string title  = "\\$FC0" + Icons::Circle + "\\$G Target Medal";

void Main() {
    bool inMap;
    bool wasInMap = InMap();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CGameCtnChallenge@ Map = App.RootMap;

    if (wasInMap) {
        stunt = string(Map.MapType).Contains("TM_Stunt");
        pb = OnEnteredMap();
    }

    OnSettingsChanged();

    while (true) {
        yield();

        inMap = InMap();

        if (!inMap) {
            currentChampion = "";
            currentAuthor   = "";
            currentGold     = "";
            currentSilver   = "";
            currentBronze   = "";
            pb = 0;
            stunt = false;
            wasInMap = false;
            continue;
        }

        @Map = App.RootMap;

        if (!wasInMap) {
            stunt = string(Map.MapType).Contains("TM_Stunt");
            pb = OnEnteredMap();
            wasInMap = true;
        }

#if DEPENDENCY_CHAMPIONMEDALS
        if (currentChampion.Length == 0) {
            const uint cm = ChampionMedal();
            if (cm > 0)
                currentChampion = Time::Format(cm);
        }
#endif

        if (currentAuthor.Length == 0)
            currentAuthor = stunt ? tostring(Map.TMObjective_AuthorTime) : Time::Format(Map.TMObjective_AuthorTime);

        if (currentGold.Length == 0)
            currentGold   = stunt ? tostring(Map.TMObjective_GoldTime) : Time::Format(Map.TMObjective_GoldTime);

        if (currentSilver.Length == 0)
            currentSilver = stunt ? tostring(Map.TMObjective_SilverTime) : Time::Format(Map.TMObjective_SilverTime);

        if (currentBronze.Length == 0)
            currentBronze = stunt ? tostring(Map.TMObjective_BronzeTime) : Time::Format(Map.TMObjective_BronzeTime);

        if (!S_Enabled)
            continue;

        CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

        if (false
            || CMAP is null
            || CMAP.ScoreMgr is null
            || CMAP.UI is null
            || (!stunt && CMAP.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Finish)
            || (stunt && CMAP.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::UIInteraction)
            || App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
            || App.UserManagerScript.Users[0] is null
        )
            continue;

        const uint prevTime = pb;

        sleep(500);  // allow game to process PB, 500ms should be enough time

        pb = GetPB(Map);
        if (pb == uint(-1)) {
            warn("run finished but PB is 0");
            pb = 0;
            continue;
        }

        uint[] times = {
            Map.TMObjective_AuthorTime,
            Map.TMObjective_GoldTime,
            Map.TMObjective_SilverTime,
            Map.TMObjective_BronzeTime,
            S_CustomTarget
        };

#if DEPENDENCY_CHAMPIONMEDALS
        const uint cm = ChampionMedal();
        if (cm > 0)
            times.InsertAt(0, cm);
#endif

        Notify(prevTime, pb, times);

        try {
            while (false
                || (!stunt && (false
                    || CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Finish
                    || CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
                ))
                || (stunt && CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::UIInteraction)
            )
                yield();
        } catch { }  // easier this way in case CMAP or CMAP.UI goes null
    }
}

void OnSettingsChanged() {
    currentCustom = stunt ? tostring(S_CustomTarget) : Time::Format(S_CustomTarget);

#if DEPENDENCY_CHAMPIONMEDALS
    ResetChampionIfNotExist();
    colorChampion = Text::FormatOpenplanetColor(S_ColorChampion);
#endif

    colorAuthor   = Text::FormatOpenplanetColor(S_ColorAuthor);
    colorGold     = Text::FormatOpenplanetColor(S_ColorGold);
    colorSilver   = Text::FormatOpenplanetColor(S_ColorSilver);
    colorBronze   = Text::FormatOpenplanetColor(S_ColorBronze);
    colorCustom   = Text::FormatOpenplanetColor(S_ColorCustom);
}

void OnSettingsSave(Settings::Section& section) {  // if a plugin is toggled, settings will save as of 1.26.23
    OnSettingsChanged();
}

void RenderMenu() {
    if (UI::BeginMenu(title + targetText)) {
        S_Enabled = UI::Checkbox("Enabled", S_Enabled);

        if (S_ExtendedMenu) {
            S_NotifyAlways = UI::Checkbox("Notify every run", S_NotifyAlways);
            S_NotifyOnEnter = UI::Checkbox("Notify on enter map", S_NotifyOnEnter);
        }

        UI::Separator();

#if DEPENDENCY_CHAMPIONMEDALS
        UI::PushStyleColor(UI::Col::CheckMark, vec4(S_ColorChampion, 1.0f));
        if (true
            && (ChampionMedal() > 0 || !InMap())
            && UI::RadioButton(colorChampion + "\\$SChampion" + (currentChampion.Length > 0 ? " (" + currentChampion + ")" : ""), S_Medal == Medal::Champion)
        )
            S_Medal = Medal::Champion;
        UI::PopStyleColor();
#endif

        UI::PushStyleColor(UI::Col::CheckMark, vec4(S_ColorAuthor, 1.0f));
        if (UI::RadioButton(colorAuthor + "\\$SAuthor" + (currentAuthor.Length > 0 ? " (" + currentAuthor + ")" : ""), S_Medal == Medal::Author))
            S_Medal = Medal::Author;
        UI::PopStyleColor();

        UI::PushStyleColor(UI::Col::CheckMark, vec4(S_ColorGold, 1.0f));
        if (UI::RadioButton(colorGold + "\\$SGold" + (currentGold.Length > 0 ? " (" + currentGold + ")" : ""), S_Medal == Medal::Gold))
            S_Medal = Medal::Gold;
        UI::PopStyleColor();

        UI::PushStyleColor(UI::Col::CheckMark, vec4(S_ColorSilver, 1.0f));
        if (UI::RadioButton(colorSilver + "\\$SSilver" + (currentSilver.Length > 0 ? " (" + currentSilver + ")" : ""), S_Medal == Medal::Silver))
            S_Medal = Medal::Silver;
        UI::PopStyleColor();

        UI::PushStyleColor(UI::Col::CheckMark, vec4(S_ColorBronze, 1.0f));
        if (UI::RadioButton(colorBronze + "\\$SBronze" + (currentBronze.Length > 0 ? " (" + currentBronze + ")" : ""), S_Medal == Medal::Bronze))
            S_Medal = Medal::Bronze;
        UI::PopStyleColor();

        if (S_ExtendedMenu) {
            UI::Separator();

            UI::PushStyleColor(UI::Col::CheckMark, vec4(S_ColorCustom, 1.0f));
            if (UI::RadioButton(colorCustom + "\\$SCustom" + (currentCustom.Length > 0 ? " (" + currentCustom + ")" : ""), S_Medal == Medal::Custom))
                S_Medal = Medal::Custom;
            UI::PopStyleColor();

            if (S_Medal == Medal::Custom) {
                const uint pre = S_CustomTarget;

                UI::SetNextItemWidth(scale * 110.0f);
                S_CustomTarget = UI::InputInt("##input-custom", S_CustomTarget);

                if (S_CustomTarget != pre)
                    OnSettingsChanged();
            }
        }

        UI::EndMenu();
    }
}
