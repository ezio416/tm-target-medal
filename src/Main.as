const string  pluginColor = "\\$F5F";
const string  pluginIcon  = Icons::Gamepad;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

void Main() {
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

void Render() {
    if (false
        or !S_Enabled
        or (true
            and S_HideWithGame
            and !UI::IsGameUIVisible()
        )
        or (true
            and S_HideWithOP
            and !UI::IsOverlayShown()
        )
    ) {
        return;
    }

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
