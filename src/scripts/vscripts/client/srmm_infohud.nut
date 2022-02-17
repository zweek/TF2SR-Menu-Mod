global function SRMM_InfoHUD_Init

global struct InfoDisplay
{
    var infoTitle
}

int displayLines = 3 // maximum number of lines that can be displayed

struct
{
    array<InfoDisplay> infoDisplays
    table<string, string> infoNames = {}
    array<string> displayInfos = []
    array<string> moddedVars = []
    array<InfoDisplay> UCKF_infoDisplay
} file

void function SRMM_InfoHUD_Init()
{
    RegisterInfo("sv_cheats")
    RegisterInfo("host_timescale")
    RegisterInfo("player_respawnInputDebounceDuration")

    for (int i = 0; i < displayLines; i++)
    {
        file.infoDisplays.append(CreateInfoDisplay(i))
    }
    file.UCKF_infoDisplay.append(CreateUCKFInfoDisplay())
    thread SRMM_InfoHUD_Thread()
}

void function SRMM_InfoHUD_Thread()
{
    while (true)
    {
        WaitFrame()
        // check for TAS mode & clear info display
        if (SRMM_getSetting(SRMM_settings.TASmode))
        {
            SetInfoName(file.infoDisplays[0], "TAS")
            for (int i = 1; i < displayLines; i++) {
                SetInfoName(file.infoDisplays[i], "")
            }
        }
        else 
        {
            GetModdedVars()
            int slot = 0
            foreach(string m in file.moddedVars){
                if (!file.displayInfos.contains(m) || slot >= displayLines) {
                    continue;
                }
                // display names and values of modded ConVars
                SetInfoName(file.infoDisplays[slot], file.infoNames[m] + " " + GetConVarFloat(file.infoNames[m]).tostring())
                slot++
            }
            for (int i = displayLines - 1; i >= slot; i--)
            {
                SetInfoName(file.infoDisplays[i], "")
            }
        }
        for (int i = 0; i < displayLines; i++)
        {
            SetHudPos(file.infoDisplays[i], i)
        }

        if (SRMM_getSetting(SRMM_settings.CKfix)) {
            SetInfoName(file.UCKF_infoDisplay[0], "UCKF")
        } else {
            SetInfoName(file.UCKF_infoDisplay[0], "")
        }
    }
}

void function SetInfoName(InfoDisplay display, string name)
{
    RuiSetString( display.infoTitle, "msgText", name )
}

void function SetHudPos(InfoDisplay display, int line) {
    float ypos = 0.0
    float xpos = 0.0
    float aspectRatio = GetScreenSize()[0] / GetScreenSize()[1]
    
    if (GetConVarInt("cl_showpos") > 0) ypos += 0.07
    if (GetConVarInt("cl_showfps") > 1) ypos += 0.02
    // scale vertical position with screen size since cl_showpos scales badly
    ypos *= 3 - GetScreenSize()[1] / 540
    // scale horizontal position wth aspect ratio
    xpos = -0.2 * (aspectRatio - 1.777)
    RuiSetFloat2( display.infoTitle, "msgPos", <xpos, 0.05 * line + ypos, 0.0> )
}

InfoDisplay function CreateInfoDisplay(int line)
{
    InfoDisplay display
    var rui
    rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 1 )
    RuiSetFloat2( rui, "msgPos", <0.0, 0.05 * line, 0.0> )
    RuiSetString( rui, "msgText", "" )
    RuiSetFloat( rui, "msgFontSize", 40.0 )
    RuiSetFloat( rui, "msgAlpha", 0.7 )
    RuiSetFloat( rui, "thicken", 0.0 )
    RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> )
    display.infoTitle = rui

    return display
}

InfoDisplay function CreateUCKFInfoDisplay()
{
    InfoDisplay display
    var rui
    rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
    RuiSetFloat2( rui, "msgPos", <0.15, 0.86, 0.0> )
    RuiSetString( rui, "msgText", "" )
    RuiSetFloat( rui, "msgFontSize", 35.0 )
    RuiSetFloat( rui, "msgAlpha", 0.7 )
    RuiSetFloat( rui, "thicken", 0.0 )
    RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> )
    display.infoTitle = rui

    return display
}

void function RegisterInfo( string infoName )
{
    file.infoNames[infoName] <- infoName
    file.displayInfos.append(infoName)
}

void function GetModdedVars()
{
    file.moddedVars = []

    AddVarIfModded("sv_cheats", 0)
    AddVarIfModded("host_timescale", 1)
    AddVarIfModded("player_respawnInputDebounceDuration", 0.5)
}

void function AddVarIfModded(string ConVar, float defautValue) {
    if (GetConVarFloat(ConVar) != defautValue) file.moddedVars.append(ConVar)
}