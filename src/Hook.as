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
                    const string msg = "congrats! " + tostring(S_Medal) + " achieved by " + Time::Format(target - ebp);
                    print(msg);
                    UI::ShowNotification(pluginTitle, msg);
                } else {
                    const string msg = "bummer! you still need " + Time::Format(ebp - target) + " for " + tostring(S_Medal);
                    print(msg);
                    UI::ShowNotification(pluginTitle, msg);
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

#endif
