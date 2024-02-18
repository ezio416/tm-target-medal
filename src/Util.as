// c 2024-02-18
// m 2024-02-18

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

    uint target = times[int(S_Medal)];

    if (pb <= target)
        UI::ShowNotification(title, "Congrats! " + tostring(S_Medal) + " medal achieved");
    else
        UI::ShowNotification(title, "Bummer! You still need " + Time::Format(pb - target) + " for the " + tostring(S_Medal) + " medal");
}

uint OnEnteredMap() {
    trace("entered map, getting PB...");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.UserManagerScript is null || App.UserManagerScript.Users.Length == 0)
        return 0;

    uint best = App.Network.ClientManiaAppPlayground.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, App.RootMap.EdChallengeId, "PersonalBest", "", "TimeAttack", "");

    if (best == uint(-1))
        best = 0;

    trace("PB: " + Time::Format(best));

    return best;
}