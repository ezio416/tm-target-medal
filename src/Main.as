const string  pluginColor = "\\$FC0";
const string  pluginIcon  = Icons::Circle;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

void Main() {
#if TURBO
    HookSetPB();
#endif

    bool inMap = false;
    bool wasInMap = false;

    uint lastPB, newPB, target;
    lastPB = newPB = MAX_UINT;

    auto App = cast<CTrackMania>(GetApp());

    // TODO init all turbo PBs

    while (true) {
        yield();

        inMap = InMap();
        if (wasInMap != inMap) {
            wasInMap = inMap;

            if (inMap) {
                lastPB = OnEnteredMap();
            } else {
                // TODO handle plugin medals
            }
        }

#if !TURBO

#if TMNEXT || MP4
        if (false
            or !S_Enabled
            or !inMap
            or App.CurrentPlayground.GameTerminals.Length == 0
            or App.CurrentPlayground.GameTerminals[0] is null
        ) {
            lastPB = newPB = MAX_UINT;
            continue;
        }
#endif

        const MapType type = GetMapType();

#if TMNEXT
        const SGamePlaygroundUIConfig::EUISequence sequence = App.CurrentPlayground.GameTerminals[0].UISequence_Current;
        if (sequence != SGamePlaygroundUIConfig::EUISequence::Finish) {
            if (false
                or type != MapType::Stunt
                or sequence != SGamePlaygroundUIConfig::EUISequence::UIInteraction
            ) {
                continue;
            }
        }

        sleep(500);  // pb doesn't seem to update instantly

#elif MP4
        auto Player = cast<CTrackManiaPlayer>(App.CurrentPlayground.GameTerminals[0].GUIPlayer);
        if (false
            or Player is null
            or Player.RaceState != CTrackManiaPlayer::ERaceState::Finished
        ) {
            continue;
        }

#elif FOREVER
        auto Network = cast<CTrackManiaNetwork>(App.Network);
        if (false
            or Network.PlayerInfo is null
            or Network.PlayerInfo.RaceState != 2
        ) {
            continue;
        }
#endif

        newPB = GetPB();

        if (lastPB != newPB) {
            target = GetTargetTime();

            if (newPB == MAX_UINT) {
                lastPB = newPB;
                continue;
            } else if (S_Medal == Medal::Finish) {
                NotifyAchieved(newPB, target, type);
                lastPB = newPB;
                continue;
            }

            bool achieved = false;

            if (type == MapType::Stunt) {
                achieved = (true
                    and lastPB < target
                    and newPB >= target
                );
            } else {
                achieved = (true
                    and lastPB > target
                    and newPB <= target
                );
            }

            if (achieved) {
                NotifyAchieved(newPB, target, type);
            } else {
                NotifyTooSlow(newPB, target, type);
            }

            lastPB = newPB;
        }

#endif

    }
}

#if TURBO
void OnDestroyed() { UnhookSetPB(); }
void OnDisabled() { UnhookSetPB(); }
void OnEnabled() { HookSetPB(); }
#endif

// void Render() {
//     if (false
//         or !S_Enabled
//         or (true
//             and S_HideWithGame
//             and !UI::IsGameUIVisible()
//         )
//         or (true
//             and S_HideWithOP
//             and !UI::IsOverlayShown()
//         )
//     ) {
//         return;
//     }

//     if (UI::Begin(pluginTitle + "###main-" + pluginMeta.ID, S_Enabled)) {
//         RenderWindow();
//     }
//     UI::End();
// }

void RenderMenu() {
    if (UI::BeginMenu(pluginTitle)) {
        S_Enabled = UI::Checkbox("Enabled", S_Enabled);
        S_NotifyOnEnter = UI::Checkbox("Notify when entering map", S_NotifyOnEnter);

        UI::Separator();

#if TMNEXT
        const uint cm = GetMedalTime(Medal::Champion);
        const uint wm = GetMedalTime(Medal::Warrior);
#elif MP4 || TURBO
        const uint dm = GetMedalTime(Medal::Duck);
#endif
#if TURBO
        const uint stm = GetMedalTime(Medal::SuperTrackmaster);
        const uint sg = GetMedalTime(Medal::SuperGold);
        const uint ss = GetMedalTime(Medal::SuperSilver);
        const uint sb = GetMedalTime(Medal::SuperBronze);
        const uint tm = GetMedalTime(Medal::Trackmaster);
#else
        const uint at = GetMedalTime(Medal::Author);
#endif
        const uint gt = GetMedalTime(Medal::Gold);
        const uint st = GetMedalTime(Medal::Silver);
        const uint bt = GetMedalTime(Medal::Bronze);

        const MapType type = GetMapType();

#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        if (cm <= wm) {
            MenuRadioButton(Medal::Champion, cm, type);
            MenuRadioButton(Medal::Warrior, wm, type);
        } else {  // just swap order
            MenuRadioButton(Medal::Warrior, wm, type);
            MenuRadioButton(Medal::Champion, cm, type);
        }
#elif DEPENDENCY_CHAMPIONMEDALS
        MenuRadioButton(Medal::Champion, cm, type);
#elif DEPENDENCY_WARRIORMEDALS
        MenuRadioButton(Medal::Warrior, wm, type);
#endif

#if DEPENDENCY_DUCKMEDALS
        MenuRadioButton(Medal::Duck, dm, type);
#endif

#if TURBO
        MenuRadioButton(Medal::SuperTrackmaster, stm, type);
        MenuRadioButton(Medal::SuperGold, sg, type);
        MenuRadioButton(Medal::SuperSilver, ss, type);
        MenuRadioButton(Medal::SuperBronze, sb, type);
        MenuRadioButton(Medal::Trackmaster, tm, type);
#else
        MenuRadioButton(Medal::Author, at, type);
#endif

        MenuRadioButton(Medal::Gold, gt, type);
        MenuRadioButton(Medal::Silver, st, type);
        MenuRadioButton(Medal::Bronze, bt, type);
        MenuRadioButton(Medal::Finish, 0, type);

        MenuRadioButton(Medal::Custom, S_Custom, type);
        UI::BeginDisabled(S_Medal != Medal::Custom);
        UI::SetNextItemWidth(UI::GetScale() * 200.0f);
        S_Custom = Math::Clamp(UI::InputInt(GetCustomUnit(type) + "##input-custom", S_Custom), 0, MAX_INT);
        UI::EndDisabled();

        UI::EndMenu();
    }
}

void RenderWindow() {
    // TODO
}
