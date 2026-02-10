const string  pluginColor = "\\$F5F";
const string  pluginIcon  = Icons::Gamepad;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

void Main() {
    ;
}

void OnSettingsChanged() {
    ;
}

void OnSettingsSave(Settings::Section&) {
    OnSettingsChanged();
}

void RenderMenu() {
    ;
}
