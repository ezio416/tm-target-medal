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

#if TURBO
    uint stm, sg, ss, sb, tm, num;
    stm = sg = ss = sb = num = 0;
    tm = Map.TMObjective_AuthorTime;
    if (true
        and Map.MapInfo !is null
        and Map.MapInfo.AuthorNickName == "Nadeo"
        and Text::TryParseUInt(Map.MapInfo.NameForUi, num)
    ) {
        stm = STM::GetSuperTrackmaster(num);
        sg = STM::GetSuperGold(num, tm);
        ss = STM::GetSuperSilver(num, tm);
        sb = STM::GetSuperBronze(num, tm);
    }
#endif

    switch (medal) {
#if TMNEXT
        case Medal::Champion:
            return GetChampionTime();
        case Medal::Warrior:
            return GetWarriorTime();
#elif TURBO
        case Medal::SuperTrackmaster:
            return stm;
        case Medal::SuperGold:
            return sg;
        case Medal::SuperSilver:
            return ss;
        case Medal::SuperBronze:
            return sb;
        case Medal::Trackmaster:
            return tm;
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
    if (!InMap()) {
        return MAX_UINT;
    }

    auto App = cast<CTrackMania>(GetApp());

#if TMNEXT
    CGameManiaAppPlayground@ CMAP = App.Network.ClientManiaAppPlayground;

    if (false
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

#elif MP4
    return MAX_UINT;  // TODO

#elif TURBO
    auto Network = cast<CTrackManiaNetwork>(App.Network);
    if (true
        and Network.PlayerInfo !is null
        and Network.TmRaceRules !is null
        and Network.TmRaceRules.DataMgr !is null
    ) {
        uint ghostPb = MAX_UINT;

        for (int i = Network.TmRaceRules.DataMgr.Ghosts.Length - 1; i >= 0; i--) {
            CGameGhostScript@ Ghost = Network.TmRaceRules.DataMgr.Ghosts[i];
            if (true
                and Ghost !is null
                and Ghost.RaceResult !is null
                and Ghost.RaceResult.Time > 0
                and Ghost.Nickname == Network.PlayerInfo.Name
            ) {
                ghostPb = uint(Ghost.RaceResult.Time);
                break;
            }
        }

        for (int i = Network.TmRaceRules.DataMgr.Records.Length - 1; i >= 0; i--) {
            CGameHighScore@ Score = Network.TmRaceRules.DataMgr.Records[i];
            if (true
                and Score !is null
                and Score.Time < ghostPb
                and Score.GhostName == "Solo_BestGhost"
            ) {
                return Score.Time;
            }
        }

        Network.TmRaceRules.DataMgr.RetrieveRecordsNoMedals(App.Challenge.EdChallengeId, Network.PlayerInfo.Id);

        return ghostPb;
    }

    return MAX_UINT;

#elif FOREVER
    return MAX_UINT;  // TODO, no idea

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
#if TMNEXT
        case MapType::Clones:
#endif
        {
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
        }  // Race, Clones

#if !TURBO
        case MapType::Platform:
#else
        {
            const uint stm = GetMedalTime(Medal::SuperTrackmaster);
            if (stm > 0) {
                if (pb <= stm) {
                    return Medal::SuperTrackmaster;
                }
                if (pb <= GetMedalTime(Medal::SuperGold)) {
                    return Medal::SuperGold;
                }
                if (pb <= GetMedalTime(Medal::SuperSilver)) {
                    return Medal::SuperSilver;
                }
                if (pb <= GetMedalTime(Medal::SuperBronze)) {
                    return Medal::SuperBronze;
                }
            }
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
#if TURBO
        }  // Platform
#endif

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
