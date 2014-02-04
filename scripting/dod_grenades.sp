/**
* DoD:S Grenades Giver by Root
*
* Description:
*   Simply gives desired amount of frag grenades to desired player classes.
*
* Version 1.0
* Changelog & more info at http://goo.gl/4nKhJ
*/

// GivePlayerItem is used in this include
#include <sdktools_functions>

// ====[ CONSTANTS ]=========================================================
#define PLUGIN_NAME    "DoD:S Grenades Giver"
#define PLUGIN_VERSION "1.0"
#define DOD_MAXCLASSES 6

// ====[ VARIABLES ]=========================================================
new	Handle:nades_enabled,
	Handle:nades_classes,
	Handle:nades_amount,
	m_iAmmo;

// ====[ PLUGIN ]===================================================
public Plugin:myinfo =
{
	name        = PLUGIN_NAME,
	author      = "Root",
	description = "Simply gives desired amount of frag grenades to desired player classes",
	version     = PLUGIN_VERSION,
	url         = "http://dodsplugins.com/",
}


/* OnPluginStart()
 *
 * When the plugin starts up.
 * -------------------------------------------------------------------------- */
public OnPluginStart()
{
	// Get m_iAmmo array offset. If it was not found, disable plugin and log error (unsupported mod maybe)
	if ((m_iAmmo = FindSendPropOffs("CDODPlayer", "m_iAmmo")) == -1)
		SetFailState("Fatal Error: Unable to find prop offset \"CDODPlayer::m_iAmmo\" !");

	// Convar will not be saved in plugin's config if its having FCVAR_DONTRECORD flag
	CreateConVar("dod_grenades_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);

	nades_enabled  = CreateConVar("dod_grenades_enable",  "1",     "Whether or not enable DoD:S Grenades Giver", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	// 1 = Rifleman, 2 = Assault, 3 = Support, 4 = Sniper, 5 = MG, 6 = Rocket
	nades_classes  = CreateConVar("dod_grenades_classes", "4 5 6", "Give grenades to # classes\n1 = Rifleman, 2 = Assault...",   FCVAR_PLUGIN);
	nades_amount   = CreateConVar("dod_grenades_amount",  "1",     "Determines amount of grenades to give to a desired classes", FCVAR_PLUGIN, true, 1.0);

	// Equip grenades after spawn
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);

	// Create and exec config
	AutoExecConfig();
}

/* OnPlayerSpawn()
 *
 * When the player spawns.
 * -------------------------------------------------------------------------- */
public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Plugin is enabled
	if (GetConVarBool(nades_enabled))
	{
		// Retrieve the client, his class and team
		new client = GetClientOfUserId(GetEventInt(event, "userid")), team;
		new class  = GetEntProp(client, Prop_Send, "m_iPlayerClass") + 1;

		// Make sure player got valid team (neither unassigned nor spectator)
		if ((team = GetClientTeam(client)))
		{
			// Get the desired classes from convar string (e.g. get the numbers)
			decl String:classes[13], String:pieces[DOD_MAXCLASSES][sizeof(classes)];
			GetConVarString(nades_classes, classes, sizeof(classes));

			// Remove all spaces from convar string and retrieve all 'pieces' between spaces
			if (ExplodeString(classes, " ", pieces, sizeof(pieces), sizeof(pieces[])))
			{
				// Loop through all available classes
				for (new i; i < DOD_MAXCLASSES; i++)
				{
					// If any number from convar string is equal to current player class...
					if (StringToInt(pieces[i]) == class)
					{
						GivePlayerItem(client, team == 2 ? "weapon_frag_us" : "weapon_frag_ger");

						// ...give appropriate grenades and set their amount in inventory
						SetEntData(client, m_iAmmo + (team == 2 ? 52 : 56), GetConVarInt(nades_amount));
					}
				}
			}
		}
	}
}