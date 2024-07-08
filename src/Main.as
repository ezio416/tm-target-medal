// c 2024-02-18
// m 2024-07-01

string       currentAuthor;
string       currentBronze;
string       currentCustom;
string       currentGold;
string       currentSilver;
uint         pb     = 0;
bool         stunts = false;
string       targetText;
const string title  = "\\$FC0" + Icons::Circle + "\\$G Target Medal";

void Main() {
    bool inMap;
    bool wasInMap = InMap();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CGameCtnChallenge@ Map = App.RootMap;

    if (wasInMap) {
        stunts = string(Map.MapType) == "TrackMania\\TM_Stunt";
        pb = OnEnteredMap();
    }

    OnSettingsChanged();

    while (true) {
        yield();

        inMap = InMap();

        if (!inMap) {
            currentAuthor = "";
            currentGold   = "";
            currentSilver = "";
            currentBronze = "";
            pb = 0;
            stunts = false;
            wasInMap = false;
            continue;
        }

        @Map = App.RootMap;

        if (!wasInMap) {
            stunts = string(Map.MapType) == "TrackMania\\TM_Stunt";
            pb = OnEnteredMap();
            wasInMap = true;
        }

        if (currentAuthor.Length == 0)
            currentAuthor = stunts ? tostring(Map.TMObjective_AuthorTime) : Time::Format(Map.TMObjective_AuthorTime);

        if (currentGold.Length == 0)
            currentGold   = stunts ? tostring(Map.TMObjective_GoldTime) : Time::Format(Map.TMObjective_GoldTime);

        if (currentSilver.Length == 0)
            currentSilver = stunts ? tostring(Map.TMObjective_SilverTime) : Time::Format(Map.TMObjective_SilverTime);

        if (currentBronze.Length == 0)
            currentBronze = stunts ? tostring(Map.TMObjective_BronzeTime) : Time::Format(Map.TMObjective_BronzeTime);

        if (!S_Enabled)
            continue;

        CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

        if (false
            || CMAP is null
            || CMAP.ScoreMgr is null
            || CMAP.UI is null
            || (!stunts && CMAP.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Finish)
            || (stunts && CMAP.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::UIInteraction)
            || App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
        )
            continue;

        const uint prevTime = pb;

        sleep(500);  // allow game to process PB, 500ms should be enough time

        if (false
            || CMAP is null
            || CMAP.ScoreMgr is null
            || App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
        )
            return;

        pb = CMAP.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, Map.EdChallengeId, "PersonalBest", "", stunts ? "Stunt" : "TimeAttack", "");
        if (pb == uint(-1)) {
            warn("pb is 0");
            pb = 0;
            continue;
        }

        const uint[] times = {
            Map.TMObjective_AuthorTime,
            Map.TMObjective_GoldTime,
            Map.TMObjective_SilverTime,
            Map.TMObjective_BronzeTime,
            S_CustomTarget
        };

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
    currentCustom = stunts ? tostring(S_CustomTarget) : Time::Format(S_CustomTarget);

    colorAuthor = Text::FormatOpenplanetColor(S_ColorAuthor);
    colorGold   = Text::FormatOpenplanetColor(S_ColorGold);
    colorSilver = Text::FormatOpenplanetColor(S_ColorSilver);
    colorBronze = Text::FormatOpenplanetColor(S_ColorBronze);
    colorCustom = Text::FormatOpenplanetColor(S_ColorCustom);
}

void RenderMenu() {
    if (UI::BeginMenu(title + targetText)) {
        if (UI::MenuItem("\\$S" + Icons::Check + " Enabled", "", S_Enabled))
            S_Enabled = !S_Enabled;

        if (UI::MenuItem(colorAuthor + "\\$S" + Icons::Circle + " Author" + (currentAuthor.Length > 0 ? " (" + currentAuthor + ")" : ""), "", S_Medal == Medal::Author, S_Medal != Medal::Author)) {
            S_Medal = Medal::Author;
            S_CustomWindow = false;
        }

        if (UI::MenuItem(colorGold + "\\$S" + Icons::Circle + " Gold" + (currentGold.Length > 0 ? " (" + currentGold + ")" : ""), "", S_Medal == Medal::Gold, S_Medal != Medal::Gold)) {
            S_Medal = Medal::Gold;
            S_CustomWindow = false;
        }

        if (UI::MenuItem(colorSilver + "\\$S" + Icons::Circle + " Silver" + (currentSilver.Length > 0 ? " (" + currentSilver + ")" : ""), "", S_Medal == Medal::Silver, S_Medal != Medal::Silver)) {
            S_Medal = Medal::Silver;
            S_CustomWindow = false;
        }

        if (UI::MenuItem(colorBronze + "\\$S" + Icons::Circle + " Bronze" + (currentBronze.Length > 0 ? " (" + currentBronze + ")" : ""), "", S_Medal == Medal::Bronze, S_Medal != Medal::Bronze)) {
            S_Medal = Medal::Bronze;
            S_CustomWindow = false;
        }

        if (UI::MenuItem(colorCustom + "\\$S" + Icons::Circle + " Custom" + (currentCustom.Length > 0 ? " (" + currentCustom + ")" : ""), "", S_Medal == Medal::Custom)) {
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

        S_CustomTarget = UI::InputInt(stunts ? "score" : "time in ms", S_CustomTarget);

        if (S_CustomTarget != pre)
            OnSettingsChanged();

        UI::Text("Chosen target " + (stunts ? "score" : "time") + ": " + currentCustom);
    }

    UI::End();
}
