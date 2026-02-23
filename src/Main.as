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

        UI::Separator();

        // TODO

        UI::EndMenu();
    }
}

void RenderWindow() {
    // TODO
}
