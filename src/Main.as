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
            if (UI::RadioButton(GetMedalTimeText("Champion", cm), S_Medal == Medal::Champion)) {
                S_Medal = Medal::Champion;
            }

            if (UI::RadioButton(GetMedalTimeText("Warrior", wm), S_Medal == Medal::Warrior)) {
                S_Medal = Medal::Warrior;
            }

        } else {
            if (UI::RadioButton(GetMedalTimeText("Warrior", wm), S_Medal == Medal::Warrior)) {
                S_Medal = Medal::Warrior;
            }

            if (UI::RadioButton(GetMedalTimeText("Champion", cm), S_Medal == Medal::Champion)) {
                S_Medal = Medal::Champion;
            }
        }

#elif DEPENDENCY_CHAMPIONMEDALS
        if (UI::RadioButton(GetMedalTimeText("Champion", cm), S_Medal == Medal::Champion)) {
            S_Medal = Medal::Champion;
        }

#elif DEPENDENCY_WARRIORMEDALS
        if (UI::RadioButton(GetMedalTimeText("Warrior", wm), S_Medal == Medal::Warrior)) {
            S_Medal = Medal::Warrior;
        }
#endif

#if DEPENDENCY_DUCKMEDALS
        if (UI::RadioButton(GetMedalTimeText("Duck", dm), S_Medal == Medal::Duck)) {
            S_Medal = Medal::Duck;
        }
#endif

#if TURBO
        if (UI::RadioButton(GetMedalTimeText("Super Trackmaster", stm), S_Medal == Medal::SuperTrackmaster)) {
            S_Medal = Medal::SuperTrackmaster;
        }

        if (UI::RadioButton(GetMedalTimeText("Super Gold", sg), S_Medal == Medal::SuperGold)) {
            S_Medal = Medal::SuperGold;
        }

        if (UI::RadioButton(GetMedalTimeText("Super Silver", ss), S_Medal == Medal::SuperSilver)) {
            S_Medal = Medal::SuperSilver;
        }

        if (UI::RadioButton(GetMedalTimeText("Super Bronze", sb), S_Medal == Medal::SuperBronze)) {
            S_Medal = Medal::SuperBronze;
        }

        if (UI::RadioButton(GetMedalTimeText("Trackmaster", tm), S_Medal == Medal::Trackmaster)) {
            S_Medal = Medal::Trackmaster;
        }

#else
        if (UI::RadioButton(GetMedalTimeText("Author", at), S_Medal == Medal::Author)) {
            S_Medal = Medal::Author;
        }
#endif

        if (UI::RadioButton(GetMedalTimeText("Gold", gt), S_Medal == Medal::Gold)) {
            S_Medal = Medal::Gold;
        }

        if (UI::RadioButton(GetMedalTimeText("Silver", st), S_Medal == Medal::Silver)) {
            S_Medal = Medal::Silver;
        }

        if (UI::RadioButton(GetMedalTimeText("Bronze", bt), S_Medal == Medal::Bronze)) {
            S_Medal = Medal::Bronze;
        }

        UI::EndMenu();
    }
}

void RenderWindow() {
    // TODO
}
