// c 2024-02-18
// m 2024-02-18

string       currentAuthor;
string       currentBronze;
string       currentCustom;
string       currentGold;
string       currentSilver;
uint         pb    = 0;
string       targetText;
const string title = "\\$FC0" + Icons::Circle + "\\$G Target Medal";

void Main() {
    bool inMap;
    bool wasInMap = InMap();

    if (wasInMap)
        pb = OnEnteredMap();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

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
            wasInMap = false;
            continue;
        }

        if (!wasInMap) {
            pb = OnEnteredMap();
            wasInMap = true;
        }

        if (currentAuthor.Length == 0)
            currentAuthor = Time::Format(App.RootMap.TMObjective_AuthorTime);

        if (currentGold.Length == 0)
            currentGold   = Time::Format(App.RootMap.TMObjective_GoldTime);

        if (currentSilver.Length == 0)
            currentSilver = Time::Format(App.RootMap.TMObjective_SilverTime);

        if (currentBronze.Length == 0)
            currentBronze = Time::Format(App.RootMap.TMObjective_BronzeTime);

        if (!S_Enabled)
            continue;

        CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

        if (
            CMAP is null
            || CMAP.ScoreMgr is null
            || CMAP.UI is null
            || CMAP.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Finish
            || App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
        )
            continue;

        for (uint i = 0; i < 20; i++)
            yield();  // allow game to process PB

        const uint prevTime = pb;

        pb = CMAP.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, App.RootMap.EdChallengeId, "PersonalBest", "", "TimeAttack", "");
        if (pb == uint(-1)) {
            pb = 0;
            continue;
        }

        const uint[] times = {
            App.RootMap.TMObjective_AuthorTime,
            App.RootMap.TMObjective_GoldTime,
            App.RootMap.TMObjective_SilverTime,
            App.RootMap.TMObjective_BronzeTime,
            S_CustomTarget
        };

        Notify(prevTime, pb, times);

        try {
            while (
                CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Finish ||
                CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
            )
                yield();
        } catch { }
    }
}

void OnSettingsChanged() {
    currentCustom = Time::Format(S_CustomTarget);

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

    UI::Begin(title + " - Custom Time", S_CustomWindow, UI::WindowFlags::AlwaysAutoResize);
        uint pre = S_CustomTarget;
        S_CustomTarget = UI::InputInt("time in ms", S_CustomTarget);
        if (pre != S_CustomTarget)
            OnSettingsChanged();

        UI::Text("Chosen target time: " + currentCustom);
    UI::End();
}