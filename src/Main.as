const string  pluginColor = "\\$F5F";
const string  pluginIcon  = Icons::Gamepad;
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

#if TMNEXT
        if (App.CurrentPlayground.GameTerminals[0].UISequence_Current != SGamePlaygroundUIConfig::EUISequence::Finish) {
            continue;
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
        // TODO detect finish sequence
#endif

        newPB = GetPB();

        if (lastPB != newPB) {
            lastPB = newPB;
            target = GetTargetTime();

            if (newPB == MAX_UINT) {
                continue;
            }

            if (true
                and lastPB > target
                and newPB <= target
            ) {
                NotifyAchieved(newPB, target);
            } else {
                NotifyTooSlow(newPB, target);
            }
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

#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        if (cm <= wm) {
            MenuRadioButton(Medal::Champion, cm);
            MenuRadioButton(Medal::Warrior, wm);
        } else {  // just swap order
            MenuRadioButton(Medal::Warrior, wm);
            MenuRadioButton(Medal::Champion, cm);
        }
#elif DEPENDENCY_CHAMPIONMEDALS
        MenuRadioButton(Medal::Champion, cm);
#elif DEPENDENCY_WARRIORMEDALS
        MenuRadioButton(Medal::Warrior, wm);
#endif

#if DEPENDENCY_DUCKMEDALS
        MenuRadioButton(Medal::Duck, dm);
#endif

#if TURBO
        MenuRadioButton(Medal::SuperTrackmaster, stm);
        MenuRadioButton(Medal::SuperGold, sg);
        MenuRadioButton(Medal::SuperSilver, ss);
        MenuRadioButton(Medal::SuperBronze, sb);
        MenuRadioButton(Medal::Trackmaster, tm);
#else
        MenuRadioButton(Medal::Author, at);
#endif

        MenuRadioButton(Medal::Gold, gt);
        MenuRadioButton(Medal::Silver, st);
        MenuRadioButton(Medal::Bronze, bt);
        MenuRadioButton(Medal::Finish, 0);

        MenuRadioButton(Medal::Custom, S_Custom);
        UI::BeginDisabled(S_Medal != Medal::Custom);
        UI::SetNextItemWidth(UI::GetScale() * 200.0f);
        S_Custom = Math::Clamp(UI::InputInt("ms", S_Custom), 0, MAX_INT);
        UI::EndDisabled();

        UI::EndMenu();
    }
}

void RenderWindow() {
    // TODO
}
