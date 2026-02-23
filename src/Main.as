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

    while (true) {
        yield();

        inMap = InMap();
        if (wasInMap != inMap) {
            wasInMap = inMap;

            if (inMap) {
                OnEnteredMap();
            } else {
                OnExitedMap();
            }
        }
    }
}

#if TURBO
void OnDestroyed() { UnhookSetPB(); }
void OnDisabled() { UnhookSetPB(); }
void OnEnabled() { HookSetPB(); }
#endif


    if (UI::Begin(pluginTitle + "###main-" + pluginMeta.ID, S_Enabled)) {
        RenderWindow();
    }
    UI::End();
}

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
