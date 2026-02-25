const int  MAX_INT  = 2147483647;
const uint MAX_UINT = uint(-1);

dictionary turboPb;

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
    Champion         = 0,
    Warrior          = 1,
#elif TURBO || MP4
    Duck             = 2,
#endif
#if TURBO
    SuperTrackmaster = 3,
    SuperGold        = 4,
    SuperSilver      = 5,
    SuperBronze      = 6,
    Trackmaster      = 7,
#else
    Author           = 8,
#endif
    Gold             = 9,
    Silver           = 10,
    Bronze           = 11,
    Finish           = 12,
    Custom           = 13,
    None             = 14
}

string FormatTime(const uint time, const MapType type) {
#if !TURBO
    switch (type) {
        case MapType::Stunt:
        case MapType::Platform:
            return tostring(time);
    }
#endif
    return Time::Format(time);
}

uint GetChampionTime() {
#if DEPENDENCY_CHAMPIONMEDALS
    return ChampionMedals::GetCMTime();
#else
    return 0;
#endif
}

string GetCustomUnit(const MapType type) {
#if !TURBO
    switch (type) {
        case MapType::Stunt:    return "points";
        case MapType::Platform: return "respawns";
    }
#endif
    return "ms";
}

uint GetDuckTime() {
#if DEPENDENCY_DUCKMEDALS
    return DuckMedals::GetDuckTime();
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

#if TMNEXT
    if (Map.MapType.Contains("TM_Stunt")) {
        return MapType::Stunt;
    }

    if (Map.MapType.Contains("TM_Platform")) {
        return MapType::Platform;
    }
#endif

#if FOREVER
    switch (Map.PlayMode) {
        case 0: return MapType::Race;
        case 1: return MapType::Platform;
        case 2: return MapType::Race;  // puzzle
        case 5: return MapType::Stunt;
    }
#endif

    return MapType::Race;
}

vec3 GetMedalColor(const Medal medal) {
    switch (medal) {
#if TMNEXT
        case Medal::Champion:         return S_ColorChampion;
        case Medal::Warrior:          return S_ColorWarrior;
#elif MP4 || TURBO
        case Medal::Duck:             return S_ColorDuck;
#endif
#if TURBO
        case Medal::SuperTrackmaster: return S_ColorSuperTrackmaster;
        case Medal::SuperGold:        return S_ColorSuperGold;
        case Medal::SuperSilver:      return S_ColorSuperSilver;
        case Medal::SuperBronze:      return S_ColorSuperBronze;
        case Medal::Trackmaster:      return S_ColorTrackmaster;
#else
        case Medal::Author:           return S_ColorAuthor;
#endif
        case Medal::Gold:             return S_ColorGold;
        case Medal::Silver:           return S_ColorSilver;
        case Medal::Bronze:           return S_ColorBronze;
        case Medal::Finish:           return S_ColorFinish;
        case Medal::Custom:           return S_ColorCustom;
    }

    return vec3();
}

uint GetMedalTime(const Medal medal) {
    CGameCtnChallenge@ Map = GetMap();

    if (false
        or Map is null
        or Map.ChallengeParameters is null
    ) {
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
#elif TURBO || MP4
        case Medal::Duck:
            return GetDuckTime();
#if TURBO
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
#endif
#if !TURBO
        case Medal::Author:
#if FOREVER
            switch (GetMapType()) {
                case MapType::Stunt:
                case MapType::Platform:
                    return Map.ChallengeParameters.AuthorScore;
            }
#endif
            return Map.ChallengeParameters.AuthorTime;
#endif
        case Medal::Gold:
            return Map.ChallengeParameters.GoldTime;
        case Medal::Silver:
            return Map.ChallengeParameters.SilverTime;
        case Medal::Bronze:
            return Map.ChallengeParameters.BronzeTime;
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
    auto Network = cast<CTrackManiaNetwork>(App.Network);

#if TMNEXT
    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

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
    if (true
        and Network.PlayerInfo !is null
        and Network.TmRaceRules !is null
        and Network.TmRaceRules.ScoreMgr !is null
    ) {
        return Network.TmRaceRules.ScoreMgr.Map_GetRecord(
            Network.PlayerInfo.Id,
            App.RootMap.EdChallengeId,
            ""
        );

    } else {
        if (true
            and App.CurrentPlayground !is null
            and App.CurrentPlayground.GameTerminals.Length > 0
            and App.CurrentPlayground.GameTerminals[0] !is null
        ) {
            auto Player = cast<CTrackManiaPlayer>(App.CurrentPlayground.GameTerminals[0].GUIPlayer);
            if (true
                and Player !is null
                and Player.Score !is null
            ) {
                return Player.Score.BestTime;
            }
        }
    }

#elif FOREVER
    if (Network.PlayerInfo !is null) {
        switch (GetMapType()) {
            case MapType::Race:
                // TODO only returns session pb on servers
                return Network.PlayerInfo.RaceBestTime;

            case MapType::Platform:
                return Network.PlayerInfo.MinRespawns;

            case MapType::Stunt:
                if (Network.PlayerInfo.BestStuntsScore > 0) {
                    return Network.PlayerInfo.BestStuntsScore;
                }
        }
    }
#endif

#if !TMNEXT
    return MAX_UINT;
#endif
}

#if TURBO
uint GetPBAsync() {
    auto App = cast<CTrackMania>(GetApp());
    auto Network = cast<CTrackManiaNetwork>(App.Network);

    if (true
        and Network.PlayerInfo !is null
        and Network.TmRaceRules !is null
        and Network.TmRaceRules.DataMgr !is null
    ) {
        uint pb = MAX_UINT;
        if (turboPb.Exists(App.Challenge.EdChallengeId)) {
            turboPb.Get(App.Challenge.EdChallengeId, pb);
        }

        while (!Network.TmRaceRules.DataMgr.Ready) {
            yield();

            if (false
                or Network.PlayerInfo is null
                or Network.TmRaceRules is null
                or Network.TmRaceRules.DataMgr is null
            ) {
                warn("something went null");
                return pb;
            }
        }

        for (int i = Network.TmRaceRules.DataMgr.Ghosts.Length - 1; i >= 0; i--) {
            CGameGhostScript@ Ghost = Network.TmRaceRules.DataMgr.Ghosts[i];
            if (true
                and Ghost !is null
                and Ghost.RaceResult !is null
                and Ghost.RaceResult.Time > 0
                and uint(Ghost.RaceResult.Time) < pb
                and Ghost.Nickname == Network.PlayerInfo.Name
            ) {
                trace("using PB from ghosts");
                pb = uint(Ghost.RaceResult.Time);
                break;
            }
        }

        for (int i = Network.TmRaceRules.DataMgr.Records.Length - 1; i >= 0; i--) {
            CGameHighScore@ Score = Network.TmRaceRules.DataMgr.Records[i];
            if (true
                and Score !is null
                and Score.Time < pb
                and Score.GhostName == "Solo_BestGhost"
            ) {
                trace("using PB from records");
                pb = Score.Time;
                break;
            }
        }

        if (pb != MAX_UINT) {
            turboPb.Set(App.Challenge.EdChallengeId, pb);
        }

        return pb;
    }

    return MAX_UINT;
}
#endif

Medal GetPBMedal() {
    const uint pb = GetPB();
    if (pb == MAX_UINT) {
        return Medal::None;
    }

    CGameCtnChallenge@ Map = GetMap();
    if (Map is null) {
        return Medal::None;
    }

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

#if DEPENDENCY_DUCKMEDALS
            const uint dm = GetDuckTime();
            if (true
                and dm > 0
                and pb <= dm
            ) {
                return Medal::Duck;
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
#if TURBO
            if (pb <= GetMedalTime(Medal::Trackmaster)) {
                return Medal::Trackmaster;
            }
#else
            if (pb <= GetMedalTime(Medal::Author)) {
                return Medal::Author;
            }
#endif
            if (pb <= GetMedalTime(Medal::Gold)) {
                return Medal::Gold;
            }
            if (pb <= GetMedalTime(Medal::Silver)) {
                return Medal::Silver;
            }
            if (pb <= GetMedalTime(Medal::Bronze)) {
                return Medal::Bronze;
            }
            if (pb < MAX_UINT) {
                return Medal::Finish;
            }
            return Medal::None;
#if TURBO
        }  // Platform
#endif

#if !TURBO
        case MapType::Stunt:
            if (pb >= GetMedalTime(Medal::Author)) {
                return Medal::Author;
            }
            if (pb >= GetMedalTime(Medal::Gold)) {
                return Medal::Gold;
            }
            if (pb >= GetMedalTime(Medal::Silver)) {
                return Medal::Silver;
            }
            if (pb >= GetMedalTime(Medal::Bronze)) {
                return Medal::Bronze;
            }
            if (pb > 0) {
                return Medal::Finish;
            }
            return Medal::None;
#endif

        default:
            return Medal::None;
    }
}

uint GetTargetTime() {  // TODO change target when medal doesn't exist
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
    auto App = cast<CTrackMania>(GetApp());

    return true
        and GetMap() !is null
        and App.CurrentPlayground !is null
#if FOREVER
        and cast<CTrackManiaEditorPuzzle>(App.Editor) !is null
#else
        and App.Editor is null
#endif
    ;
}

void MenuRadioButton(const Medal medal, const uint time, const MapType type) {
    const vec4 color = vec4(GetMedalColor(medal), 1.0f);
    UI::PushStyleColor(UI::Col::CheckMark, color);
    UI::PushStyleColor(UI::Col::Text,      color);

    UI::BeginDisabled(true
        and medal != Medal::Custom
        and medal != Medal::Finish
        and time == 0
#if !TURBO
        and (false
            or type != MapType::Platform
#if TMNEXT
            or medal == Medal::Champion
            or medal == Medal::Warrior
#endif
        )
#endif
        and InMap()
    );

    const bool showTime = false
        or time > 0
#if !TURBO
        or (true
            and type == MapType::Platform
            and (false
                or medal == Medal::Author
#if FOREVER
                or medal == Medal::Gold
#endif
            )
        )
#endif
    ;

    if (UI::RadioButton(
        tostring(medal) + (showTime ? " (" + FormatTime(time, type) + ")" : ""),
        S_Medal == medal
    )) {
        S_Medal = medal;
    }
    UI::EndDisabled();

    UI::PopStyleColor(2);
}

void Notify(const string&in msg, const vec3&in color = vec3()) {
    print(msg);
    UI::ShowNotification(pluginTitle, msg, vec4(color, 1.0f));
}

void NotifyAchieved(const uint pb, const uint target, const MapType type) {
#if !TURBO
    if (type == MapType::Stunt) {
        Notify(
            "congrats! " + tostring(S_Medal) + " achieved by " + tostring(pb - target),
            GetMedalColor(S_Medal)
        );
        return;
    }
#endif

    Notify(
        "congrats! " + tostring(S_Medal) + " achieved by " + FormatTime(target - pb, type),
        GetMedalColor(S_Medal)
    );
}

void NotifyOnEnter(const uint pb) {
    const uint target = GetTargetTime();
    const MapType type = GetMapType();

    if (true
        and target == 0
#if !TURBO
        and type != MapType::Stunt
        and type != MapType::Platform
#endif
    ) {
        return;
    }

#if !TURBO
    if (type == MapType::Stunt) {
        if (false
            or pb == MAX_UINT
            or pb < target
        ) {
            Notify(
                pb == MAX_UINT
                    ? tostring(S_Medal) + " is " + tostring(target)
                    : "You still need " + tostring(target - pb) + " for " + tostring(S_Medal)
            );
        }
        return;
    }
#endif

    if (pb > target) {
        Notify(
            pb == MAX_UINT
                ? tostring(S_Medal) + " is " + FormatTime(target, type)
                : "You still need " + FormatTime(pb - target, type) + " for " + tostring(S_Medal)
        );
    }
}

void NotifyTooSlow(const uint pb, const uint target, const MapType type) {
#if !TURBO
    if (type == MapType::Stunt) {
        Notify("Bummer! You still need " + tostring(target - pb) + " for " + tostring(S_Medal));
        return;
    }
#endif

    Notify("Bummer! You still need " + FormatTime(pb - target, type) + " for " + tostring(S_Medal));
}

uint OnEnteredMap() {
    print("OnEnteredMap");

    const uint pb = GetPB();

    if (true
        and S_Enabled
        and S_NotifyOnEnter
        and S_Medal != Medal::Finish
    ) {
#if TURBO
        startnew(OnEnteredMapAsync);
#else
        NotifyOnEnter(pb);
#endif
    }

    return pb;
}

#if TURBO
void OnEnteredMapAsync() {
    print("OnEnteredMapAsync");
    NotifyOnEnter(GetPBAsync());
}
#endif
