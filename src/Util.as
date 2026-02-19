const uint MAX_UINT = uint(-1);

enum MapType {
    Race,
#if !TURBO
    Stunt,
    Platform,
#endif
#if TMNEXT
    Clones,
#endif
    None
}

enum Medal {
#if TMNEXT
    Champion,
    Warrior,
#elif TURBO
    SuperTrackmaster,
    SuperGold,
    SuperSilver,
    SuperBronze,
    Trackmaster,
#endif
#if !TURBO
    Author,
#endif
    Gold,
    Silver,
    Bronze,
    Custom,
    None
}

uint GetChampionTime() {
#if DEPENDENCY_CHAMPIONMEDALS
    return ChampionMedals::GetCMTime();
#else
    return 0;
#endif
}

CGameCtnChallenge@ GetMap() {
#if TMNEXT || MP4
    return GetApp().RootMap;
#elif TURBO || FOREVER
    return GetApp().Challenge;
#endif
}

MapType GetMapType() {
    CGameCtnChallenge@ Map = GetMap();

    if (Map is null) {
        return MapType::None;
    }

#if TMNEXT
    if (true
        and Map.MapInfo !is null
        and Map.MapInfo.TMObjective_NbClones > 0
    ) {
        return MapType::Clones;
    }
#endif

#if !TURBO
    if (Map.MapType.Contains("TM_Stunt")) {
        return MapType::Stunt;
    }

    if (Map.MapType.Contains("TM_Platform")) {
        return MapType::Platform;
    }
#endif

    return MapType::Race;
}

uint GetMedalTime(const Medal medal) {
    CGameCtnChallenge@ Map = GetMap();

    if (Map is null) {
        return 0;
    }

    switch (medal) {
#if TMNEXT
        case Medal::Champion:
            return GetChampionTime();
        case Medal::Warrior:
            return GetWarriorTime();
#elif TURBO
        case Medal::SuperTrackmaster:
            return 0;  // TODO
        case Medal::SuperGold:
            return 0;  // TODO
        case Medal::SuperSilver:
            return 0;  // TODO
        case Medal::SuperBronze:
            return 0;  // TODO
        case Medal::Trackmaster:
            return Map.TMObjective_AuthorTime;
#endif
#if !TURBO
        case Medal::Author:
            return Map.TMObjective_AuthorTime;
#endif
        case Medal::Gold:
            return Map.TMObjective_GoldTime;
        case Medal::Silver:
            return Map.TMObjective_SilverTime;
        case Medal::Bronze:
            return Map.TMObjective_BronzeTime;
        case Medal::Custom:
            return S_Custom;
        default:
            return 0;
    }
}

uint GetPB() {
    auto App = cast<CTrackMania>(GetApp());

#if TMNEXT
    CGameManiaAppPlayground@ CMAP = App.Network.ClientManiaAppPlayground;

    if (false
        or !InMap()
        or CMAP is null
        or CMAP.ScoreMgr is null
        or App.UserManagerScript is null
        or App.UserManagerScript.Users.Length == 0
        or App.UserManagerScript.Users[0] is null
    ) {
        return MAX_UINT;
    }

    string mode;
    switch (GetMapType()) {
        case MapType::Race:
            mode = "TimeAttack";
            break;
        case MapType::Stunt:
            mode = "Stunt";
            break;
        case MapType::Platform:
            mode = "Platform";
            break;
        case MapType::Clones:
            mode = "TimeAttackClone";
    }

    return CMAP.ScoreMgr.Map_GetRecord_v2(
        App.UserManagerScript.Users[0].Id,
        App.RootMap.EdChallengeId,
        "PersonalBest",
        "",
        mode,
        ""
    );

#else
    return MAX_UINT;  // TODO
#endif
}

Medal GetPBMedal() {
    const uint pb = GetPB();
    if (pb == MAX_UINT) {
        return Medal::None;
    }

    CGameCtnChallenge@ Map = GetMap();

    switch (GetMapType()) {
        case MapType::Race:
        case MapType::Clones: {
            const uint cm = GetChampionTime();
            const uint wm = GetWarriorTime();

#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
            if (true
                and cm > 0
                and wm > 0
            ) {
                if (cm <= wm) {
                    if (pb <= cm) {
                        return Medal::Champion;
                    } else if (pb <= wm) {
                        return Medal::Warrior;
                    }
                } else {
                    if (pb <= wm) {
                        return Medal::Warrior;
                    } else if (pb <= cm) {
                        return Medal::Champion;
                    }
                }

            } else if (true
                and cm > 0
                and pb <= cm
            ) {
                return Medal::Champion;

            } else if (true
                and wm > 0
                and pb <= wm
            ) {
                return Medal::Warrior;
            }

#elif DEPENDENCY_CHAMPIONMEDALS
            if (true
                and cm > 0
                and pb <= cm
            ) {
                return Medal::Champion;
            }

#elif DEPENDENCY_WARRIORMEDALS
            if (true
                and wm > 0
                and pb <= wm
            ) {
                return Medal::Warrior;
            }
#endif
        }

#if !TURBO
        case MapType::Platform:
#endif
            if (pb <= Map.TMObjective_AuthorTime) {
#if TURBO
                return Medal::Trackmaster;
#else
                return Medal::Author;
#endif
            }
            if (pb <= Map.TMObjective_GoldTime) {
                return Medal::Gold;
            }
            if (pb <= Map.TMObjective_SilverTime) {
                return Medal::Silver;
            }
            if (pb <= Map.TMObjective_BronzeTime) {
                return Medal::Bronze;
            }
            return Medal::None;

#if !TURBO
        case MapType::Stunt:
            if (pb >= Map.TMObjective_AuthorTime) {
                return Medal::Author;
            }
            if (pb >= Map.TMObjective_GoldTime) {
                return Medal::Gold;
            }
            if (pb >= Map.TMObjective_SilverTime) {
                return Medal::Silver;
            }
            if (pb >= Map.TMObjective_BronzeTime) {
                return Medal::Bronze;
            }
            return Medal::None;
#endif

        default:
            return Medal::None;
    }
}

uint GetTargetTime() {
    return GetMedalTime(S_Medal);
}

uint GetWarriorTime() {
#if DEPENDENCY_WARRIORMEDALS
    return WarriorMedals::GetWMTime();
#else
    return 0;
#endif
}

bool InMap() {
    CGameCtnApp@ App = GetApp();

    return true
        and GetMap() !is null
        and App.CurrentPlayground !is null
        and App.Editor is null
    ;
}

void OnEnteredMap() {
    print("OnEnteredMap");

    const uint pb = GetPB();
    // TODO
}

void OnExitedMap() {
    print("OnExitedMap");
}

void PBLoopAsync() {
    while (true) {
        sleep(100);

        if (false
            or !S_Enabled
            or !InMap()
        ) {
            continue;
        }

        // TODO
    }
}
