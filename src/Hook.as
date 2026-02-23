// getting the player's PB in Turbo reliably is such a pain that using a hook is easier
// fortunately, there's a hook that provides the old and new PB for us
// unfortunately, this only works after a finish, not when entering a map

#if TURBO

Dev::HookInfo@ hookSetPB;
const string   hookSetPBPattern = "89 6F 04 89 47 08 E8 E8 F9 FF FF";

void HookSetPB() {
    if (hookSetPB is null) {
        const uint p = Dev::FindPattern(hookSetPBPattern);
        if (p > 0x0) {
            @hookSetPB = Dev::Hook(p, 0x1, "SetPB", Dev::PushRegisters::SSE);
            trace("hooked SetPB");
        } else {
            warn("hookSetPBPattern not found");
        }
    }
}

void SetPB(const uint ebx, const uint ebp) {
    // ebx is the last pb, ebp is the new one
    // sometimes ebx is 0 and ebp is 1 so we compare them first
    if (ebp < ebx) {
        print("SetPB: old " + Time::Format(ebx) + ", new " + Time::Format(ebp));

        if (InMap()) {
            turboPb.Set(GetMap().EdChallengeId, ebp);

            if (S_Enabled) {
                const uint target = GetTargetTime();
                if (true
                    and ebx > target
                    and ebp <= target
                ) {
                    NotifyAchieved(ebp, target);
                } else {
                    NotifyTooSlow(ebp, target);
                }
            }
        }
    }
}

void UnhookSetPB() {
    if (hookSetPB !is null) {
        Dev::Unhook(hookSetPB);
        trace("unhooked SetPB");
    }
}

#elif MP4

// unused but keeping here in case I want to use it in the future
// debugger says the new PB is in eax but my hook always returns 0xCB0840
// sadly there isn't a hook like Turbo that has old and new PB
// all other hooks I can find use xmm registers which aren't accessible yet

// Dev::HookInfo@ hookSetPB;
// const string   hookSetPBPattern = "89 87 B8 00 00 00 48 8D 8F C0 00 00 00";

// void SetPB(const uint64 rax) {
//     if (GetApp().RootMap !is null) {
//         print("SetPB new: " + Time::Format(rax) + " | " + Text::FormatPointer(rax));
//     }
// }

#endif
