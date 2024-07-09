// c 2024-02-18
// m 2024-07-08

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

enum Medal {
#if DEPENDENCY_CHAMPIONMEDALS
    Champion,
#endif
    Author,
    Gold,
    Silver,
    Bronze,
    Custom
}

[Setting category="General" name="Medal target"]
Medal S_Medal = Medal::Author;

[Setting category="General" name="Custom time target (ms)" description="Must choose 'Custom' in above setting. For stunt mode, this is the score."]
uint S_CustomTarget = 0;


#if DEPENDENCY_CHAMPIONMEDALS
[Setting category="Colors" name="Champion" color]
vec3 S_ColorChampion = vec3(1.0f, 0.267f, 0.467f);
string colorChampion;
#endif

[Setting category="Colors" name="Author" color]
vec3 S_ColorAuthor = vec3(0.17f, 0.75f, 0.0f);
string colorAuthor;

[Setting category="Colors" name="Gold" color]
vec3 S_ColorGold = vec3(1.0f, 0.87f, 0.0f);
string colorGold;

[Setting category="Colors" name="Silver" color]
vec3 S_ColorSilver = vec3(0.75f, 0.75f, 0.75f);
string colorSilver;

[Setting category="Colors" name="Bronze" color]
vec3 S_ColorBronze = vec3(0.69f, 0.5f, 0.0f);
string colorBronze;

[Setting category="Colors" name="Custom" color]
vec3 S_ColorCustom = vec3(1.0f, 0.0f, 1.0f);
string colorCustom;


[Setting hidden]
bool S_CustomWindow = false;
