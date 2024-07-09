// c 2024-02-18
// m 2024-07-08

string       currentAuthor;
string       currentBronze;
string       currentChampion;
string       currentCustom;
string       currentGold;
string       currentSilver;
uint         pb     = 0;
bool         stunt  = false;
string       targetText;
const string title  = "\\$FC0" + Icons::Circle + "\\$G Target Medal";

void Main() {
    bool inMap;
    bool wasInMap = InMap();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CGameCtnChallenge@ Map = App.RootMap;

    if (wasInMap) {
        stunt = string(Map.MapType) == "TrackMania\\TM_Stunt";
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
            stunt = string(Map.MapType) == "TrackMania\\TM_Stunt";
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
            warn("pb is 0");
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
            while (
                CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Finish
                || CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
            )
                yield();
        } catch { }
    }
}

void OnSettingsChanged() {
    currentCustom = stunt ? tostring(S_CustomTarget) : Time::Format(S_CustomTarget);

#if DEPENDENCY_CHAMPIONMEDALS
    if (true
        && S_Medal == Medal::Champion
        && ChampionMedal() == 0
        && cast<CTrackMania@>(GetApp()).ActiveMenus.Length == 0
    ) {
        S_Medal = Medal::Author;
        currentChampion = "";
    }

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
        if (UI::MenuItem("\\$S" + Icons::Check + " Enabled", "", S_Enabled))
            S_Enabled = !S_Enabled;

    UI::Separator();

#if DEPENDENCY_CHAMPIONMEDALS
    if (true
        && ChampionMedal() > 0
        && UI::MenuItem(
            colorChampion + "\\$S" + Icons::Circle + " Champion" + (currentChampion.Length > 0 ? " (" + currentChampion + ")" : ""),
            "",
            S_Medal == Medal::Champion,
            S_Medal != Medal::Champion
        )) {
            S_Medal = Medal::Champion;
            S_CustomWindow = false;
        }
#endif

        if (UI::MenuItem(
            colorAuthor + "\\$S" + Icons::Circle + " Author" + (currentAuthor.Length > 0 ? " (" + currentAuthor + ")" : ""),
            "",
            S_Medal == Medal::Author,
            S_Medal != Medal::Author
        )) {
            S_Medal = Medal::Author;
            S_CustomWindow = false;
        }

        if (UI::MenuItem(
            colorGold + "\\$S" + Icons::Circle + " Gold" + (currentGold.Length > 0 ? " (" + currentGold + ")" : ""),
            "",
            S_Medal == Medal::Gold,
            S_Medal != Medal::Gold
        )) {
            S_Medal = Medal::Gold;
            S_CustomWindow = false;
        }

        if (UI::MenuItem(
            colorSilver + "\\$S" + Icons::Circle + " Silver" + (currentSilver.Length > 0 ? " (" + currentSilver + ")" : ""),
            "",
            S_Medal == Medal::Silver,
            S_Medal != Medal::Silver
        )) {
            S_Medal = Medal::Silver;
            S_CustomWindow = false;
        }

        if (UI::MenuItem(
            colorBronze + "\\$S" + Icons::Circle + " Bronze" + (currentBronze.Length > 0 ? " (" + currentBronze + ")" : ""),
            "",
            S_Medal == Medal::Bronze,
            S_Medal != Medal::Bronze
        )) {
            S_Medal = Medal::Bronze;
            S_CustomWindow = false;
        }

        if (UI::MenuItem(
            colorCustom + "\\$S" + Icons::Circle + " Custom" + (currentCustom.Length > 0 ? " (" + currentCustom + ")" : ""),
            "",
            S_Medal == Medal::Custom
        )) {
            S_Medal = Medal::Custom;
            S_CustomWindow = true;
        }
        HoverTooltip(Icons::Pencil + " Click to edit");

        UI::EndMenu();
    }
}

void Render() {
    if (!S_CustomWindow)
        return;

    if (UI::Begin(title + " - Custom Time", S_CustomWindow, UI::WindowFlags::AlwaysAutoResize)) {
        const uint pre = S_CustomTarget;

        S_CustomTarget = UI::InputInt(stunt ? "score" : "time in ms", S_CustomTarget);

        if (S_CustomTarget != pre)
            OnSettingsChanged();

        UI::Text("Chosen target " + (stunt ? "score" : "time") + ": " + currentCustom);
    }

    UI::End();
}
