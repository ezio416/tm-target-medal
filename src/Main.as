// c 2024-02-18
// m 2024-02-18

const string title = "\\$FF0" + Icons::Circle + "\\$G Target Medal";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Main() {
}

void Render() {
}