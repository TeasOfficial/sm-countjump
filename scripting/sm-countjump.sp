#include <sourcemod>
#include <sdktools>

int g_iPrevButtons[MAXPLAYERS + 1];
ConVar gCV_CJEnabled;
ConVar gCV_CJoffset;
ConVar gCV_CJAutoMode;

public OnPluginStart() {
    gCV_CJEnabled = CreateConVar("sm_countjump_enabled", "1", "Enable Count Jump (Default: 1)");
    gCV_CJoffset = CreateConVar("sm_countjump_offset", "30", "Count Jump Height (Default: 30)");
    gCV_CJAutoMode = CreateConVar("sm_countjump_automode", "0", "Auto Count Jump (Default: 0)");
    AutoExecConfig(true, "plugin.sm-countjump", "sourcemod");
}

public Plugin myinfo = {
	name = "sm-countjump",
	author = "NekoGan",
	description = "Bringing CounterJump from CS1.6 back to SourceEngine!",
	version = "1.0",
	url = "https://github.com/TeasOfficial/sm-countjump"
};

public Action OnPlayerRunCmd(int client, int &buttons){
    if(!IsClientConnected(client) || !IsClientInGame(client) || IsFakeClient(client) || !gCV_CJEnabled.IntValue) {
        return Plugin_Continue;
    }

    int flags = GetEntProp(client, Prop_Data, "m_fFlags");
    int prev = g_iPrevButtons[client];
    bool justReleased = (!(buttons & IN_DUCK) && (prev & IN_DUCK));

    if (flags & FL_ONGROUND) {
        if (justReleased) {
            int ducking = GetEntProp(client, Prop_Send, "m_bDucking");
            if(ducking) {
                DoCJ(client);
            }
        }
    }

    if(gCV_CJAutoMode.FloatValue){
        if (buttons & IN_DUCK) {
            if (flags & FL_ONGROUND && buttons & IN_JUMP) {
                SetEntProp(client, Prop_Send, "m_bDucked", 0);
                SetEntProp(client, Prop_Send, "m_bDucking", 0);

                float pos[3];
                GetClientAbsOrigin(client, pos);

                pos[2] += gCV_CJoffset.FloatValue;

                TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
            }
        }
    }
    g_iPrevButtons[client] = buttons;
    return Plugin_Continue;
}

void DoCJ(int client){
    SetEntProp(client, Prop_Send, "m_bDucked", 0);
    SetEntProp(client, Prop_Send, "m_bDucking", 0);

    float pos[3];
    GetClientAbsOrigin(client, pos);

    pos[2] += gCV_CJoffset.FloatValue;

    TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
}