// c 2024-02-18
// m 2024-03-08

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered())
        return;

    UI::BeginTooltip();
        UI::Text(msg);
    UI::EndTooltip();
}

bool InMap() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return App.Editor is null
        && App.RootMap !is null
        && App.CurrentPlayground !is null
        && App.Network.ClientManiaAppPlayground !is null;
}

void Notify(const uint prevTime, const uint pb, const uint[] times) {
    if (prevTime > 0 && pb >= prevTime)
        return;

    const uint target = times[int(S_Medal)];

    if (prevTime <= target)
        return;

    vec4 colorNotif;

    switch (S_Medal) {
        case Medal::Author: colorNotif = vec4(S_ColorAuthor.x, S_ColorAuthor.y, S_ColorAuthor.z, 0.8f); break;
        case Medal::Gold:   colorNotif = vec4(S_ColorGold.x,   S_ColorGold.y,   S_ColorGold.z,   0.8f); break;
        case Medal::Silver: colorNotif = vec4(S_ColorSilver.x, S_ColorSilver.y, S_ColorSilver.z, 0.8f); break;
        case Medal::Bronze: colorNotif = vec4(S_ColorBronze.x, S_ColorBronze.y, S_ColorAuthor.z, 0.8f); break;
        default:            colorNotif = vec4(S_ColorCustom.x, S_ColorCustom.y, S_ColorCustom.z, 0.8f);
    }

    if (pb <= target)
        UI::ShowNotification(title, "Congrats! " + tostring(S_Medal) + " medal achieved", colorNotif);
    else
        UI::ShowNotification(title, "Bummer! You still need " + Time::Format(pb - target) + " for the " + tostring(S_Medal) + " medal");
}

uint OnEnteredMap() {
    trace("entered map, getting PB...");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.UserManagerScript is null || App.UserManagerScript.Users.Length == 0)
        return 0;

    const uint best = App.Network.ClientManiaAppPlayground.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, App.RootMap.EdChallengeId, "PersonalBest", "", "TimeAttack", "");

    if (best == uint(-1))
        best = 0;

    trace("PB: " + Time::Format(best));

    return best;
}