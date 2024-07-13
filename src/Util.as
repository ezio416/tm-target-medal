// c 2024-02-18
// m 2024-07-13

uint ChampionMedal() {
    Meta::Plugin@ plugin = Meta::GetPluginFromID("ChampionMedals");
    if (plugin is null || !plugin.Enabled)
        return 0;

#if DEPENDENCY_CHAMPIONMEDALS
    return ChampionMedals::GetCMTime();
#else
    return 0;
#endif
}

uint GetPB(CGameCtnChallenge@ Map) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

    if (false
        || Map is null
        || CMAP is null
        || CMAP.ScoreMgr is null
        || App.UserManagerScript is null
        || App.UserManagerScript.Users.Length == 0
        || App.UserManagerScript.Users[0] is null
    )
        return uint(-1);

    return CMAP.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, Map.EdChallengeId, "PersonalBest", "", stunt ? "Stunt" : "TimeAttack", "");
}

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered())
        return;

    UI::BeginTooltip();
        UI::Text(msg);
    UI::EndTooltip();
}

bool InMap() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return true
        && App.Editor is null
        && App.RootMap !is null
        && App.CurrentPlayground !is null
        && App.Network.ClientManiaAppPlayground !is null
    ;
}

void Notify(const uint prevTime, const uint pb, const uint[] times, bool fromEnterMap = false) {
    if (true
        && !S_NotifyAlways
        && prevTime > 0
        && (false
            || !stunt && pb >= prevTime
            || stunt && pb <= prevTime
        )
    )
        return;

    const uint target = times[int(S_Medal) - (ChampionMedal() == 0 ? 1 : 0)];

    if (false
        || (!stunt && prevTime <= target && prevTime > 0)
        || (stunt && prevTime >= target)
    )
        return;

    vec4 colorNotif;

    switch (S_Medal) {
#if DEPENDENCY_CHAMPIONMEDALS
        case Medal::Champion:
            if (stunt)  // theoretically shouldn't ever happen
                return;
            colorNotif = vec4(S_ColorChampion, 0.8f);
            break;
#endif
        case Medal::Author: colorNotif = vec4(S_ColorAuthor, 0.8f); break;
        case Medal::Gold:   colorNotif = vec4(S_ColorGold,   0.8f); break;
        case Medal::Silver: colorNotif = vec4(S_ColorSilver, 0.8f); break;
        case Medal::Bronze: colorNotif = vec4(S_ColorBronze, 0.8f); break;
        default:            colorNotif = vec4(S_ColorCustom, 0.8f);
    }

    if ((!stunt && pb <= target) || (stunt && pb >= target)) {
        if (!fromEnterMap) {
            const string msg = "Congrats! " + tostring(S_Medal) + " medal achieved";
            UI::ShowNotification(title, msg, colorNotif);
            print(msg);
        }
    } else {
        const string msg = "You still need " + (stunt ? tostring(target - pb) : Time::Format(pb - target)) + " for the " + tostring(S_Medal) + " medal";
        UI::ShowNotification(title, msg);
        print(msg);
    }
}

uint OnEnteredMap() {
    trace("entered map, getting PB...");

#if DEPENDENCY_CHAMPIONMEDALS
    ResetChampionIfNotExist();
#endif

    CGameCtnChallenge@ Map = cast<CTrackMania@>(GetApp()).RootMap;

    uint best = GetPB(Map);
    if (best == uint(-1))
        best = 0;

    trace("PB: " + (stunt ? tostring(best) : Time::Format(best)));

    if (S_NotifyOnEnter) {
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

        Notify(uint(-1), best, times, true);
    }

    return best;
}

#if DEPENDENCY_CHAMPIONMEDALS
void ResetChampionIfNotExist() {
    if (true
        && S_Medal == Medal::Champion
        && ChampionMedal() == 0
        && InMap()
    ) {
        S_Medal = Medal::Author;
        currentChampion = "";
    }
}
#endif
