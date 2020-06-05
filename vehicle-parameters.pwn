#if defined _included_veh_param_game
    #endinput
#endif

#define _included_veh_param_game

#include <a_samp>

#include <Pawn.CMD>


enum
{
    vehicleMenuDialog
}


enum vInfo
{
	bool:vEngine,
	bool:vLights,
	bool:vDoors,
	bool:vAlarm,
	bool:vBonnet,
	bool:vBoot,
	vFuel,
	Float:vPos_X,
	Float:vPos_Y,
	Float:vPos_Z
}
static vehicleInfo[MAX_VEHICLES][vInfo];


new transportWithoutEngine[3] = {481, 509, 510};

stock transportHasEngine(vehicleid)
{
	new vehicleModel = GetVehicleModel(vehicleid);

	for(new i = 0; i < sizeof transportWithoutEngine; i++)
	{
	    if(vehicleModel == transportWithoutEngine[i]) return 0;
	}

	return 1;
}


static playerTimer[MAX_PLAYERS] = -1;

static deletePlayerTimer(playerid)
{
    if(playerTimer[playerid] != -1)
    {
		KillTimer(playerTimer[playerid]);
        playerTimer[playerid] = -1;
    }

    return 1;
}


forward updateVehicleInformation(playerid);
public updateVehicleInformation(playerid)
{
	new vehicleid = GetPlayerVehicleID(playerid);

	if(getPlayerVehicleSpeed(playerid) && getVehicleEngineStatus(vehicleid))
	{
		new distance = getPlayerTravelDistance(playerid, vehicleInfo[vehicleid][vPos_X], vehicleInfo[vehicleid][vPos_Y], vehicleInfo[vehicleid][vPos_Z]);

		if(distance)
		{
		    vehicleInfo[vehicleid][vFuel]--;
		    GetVehiclePos(vehicleid, vehicleInfo[vehicleid][vPos_X], vehicleInfo[vehicleid][vPos_Y], vehicleInfo[vehicleid][vPos_Z]);
		}
	}
	
	if(getVehicleEngineStatus(vehicleid) && getVehicleFuel(vehicleid) < 1)
	{
	    setVehicleEngineStatus(vehicleid, false);
		setVehicleFuel(vehicleid, 0);
	}

	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == vehicleMenuDialog)
    {
		if(response)
		{
		    new vehicleId = GetPlayerVehicleID(playerid), bool:newStatus;
		    
			switch(listitem)
		    {
				case 0: callcmd::engine(playerid);
				case 1: callcmd::lights(playerid);
				case 2:
				{
				    newStatus = getVehicleBonnetStatus(vehicleId) ? false : true;
					setVehicleBonnetStatus(vehicleId, newStatus);
				}
				case 3:
				{
				    newStatus = getVehicleBootStatus(vehicleId) ? false : true;
					setVehicleBootStatus(vehicleId, newStatus);					
				}
			}
		}
    }

	#if defined vp_OnDialogResponse
		return vp_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	#else
		return 0;
	#endif
}

#if defined _ALS_OnDialogResponse
	#undef OnDialogResponse
#else
	#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse vp_OnDialogResponse
#if defined vp_OnDialogResponse
	forward vp_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
   	if(newkeys == KEY_SUBMISSION)
	{
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
		    callcmd::engine(playerid);
        }
    }

    if(newkeys == KEY_FIRE)
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            callcmd::lights(playerid);
		}
	}

	#if defined vp_OnPlayerKeyStateChange
		return vp_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnPlayerKeyStateChange
	#undef OnPlayerKeyStateChange
#else
	#define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange vp_OnPlayerKeyStateChange
#if defined vp_OnPlayerKeyStateChange
	forward vp_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER)
	{
        new vehicleId = GetPlayerVehicleID(playerid);
	    
	    if(!transportHasEngine(vehicleId))
	    {
            setVehicleEngineStatus(vehicleId, true);
	    }
	    else
	    {
	        if(!getVehicleEngineStatus(vehicleId)) SendClientMessage(playerid, -1, "{E3801D}[Information]{FFFFFF} Dzravis dasaqoqad gamoiyenet {FF9900}/carmenu{FFFFFF} an daachiret {FF9900}2{FFFFFF}.");
	    }

        playerTimer[playerid] = SetTimerEx("updateVehicleInformation", 200, true, "i", playerid);
    }

    if(newstate == PLAYER_STATE_ONFOOT)
	{
        deletePlayerTimer(playerid);
    }

	#if defined vp_OnPlayerStateChange
		return vp_OnPlayerStateChange(playerid, newstate, oldstate);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnPlayerStateChange
	#undef OnPlayerStateChange
#else
	#define _ALS_OnPlayerStateChange
#endif
#define OnPlayerStateChange vp_OnPlayerStateChange
#if defined vp_OnPlayerStateChange
	forward vp_OnPlayerStateChange(playerid, newstate, oldstate);
#endif

public OnVehicleSpawn(vehicleid)
{
	setVehicleEngineStatus(vehicleid, false);
	setVehicleLightsStatus(vehicleid, false);
	setVehicleBonnetStatus(vehicleid, false);
	setVehicleBootStatus(vehicleid, false);
	setVehicleAlarmStatus(vehicleid, false);
	setVehicleDoorsStatus(vehicleid, false);

	#if defined vp_OnVehicleSpawn
		return vp_OnVehicleSpawn(vehicleid);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnVehicleSpawn
	#undef OnVehicleSpawn
#else
	#define _ALS_OnVehicleSpawn
#endif
#define OnVehicleSpawn vp_OnVehicleSpawn
#if defined vp_OnVehicleSpawn
	forward vp_OnVehicleSpawn(vehicleid);
#endif

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	if(getVehicleBootStatus(vehicleid)) setVehicleBootStatus(vehicleid, false);
	if(getVehicleBonnetStatus(vehicleid)) setVehicleBonnetStatus(vehicleid, false);

	new Float:vehHealth;
	GetVehicleHealth(vehicleid, vehHealth);

	if(vehHealth && vehHealth <= 400)
	{
 		GameTextForPlayer(playerid,"~r~ENGINE HAS BROKEN", 5000, 3);
 		SetVehicleHealth(vehicleid, 400);
 		setVehicleEngineStatus(vehicleid, false);
	}

	#if defined vp_OnVehicleDamageStatusUpdate
		return vp_OnVehicleDamageStatusUpdate(vehicleid, playerid);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnVehicleDamageStatusUpdat\
	|| defined _ALS_OnVehicleDamageStatusUpd
	#undef OnVehicleDamageStatusUpdate
#else
	#define _ALS_OnVehicleDamageStatusUpdat
	#define _ALS_OnVehicleDamageStatusUpd
#endif
#define OnVehicleDamageStatusUpdate vp_OnVehicleDamageStatusUpdate
#if defined vp_OnVehicleDamageStatusUpdate
	forward vp_OnVehicleDamageStatusUpdate(vehicleid, playerid);
#endif    

public OnPlayerDisconnect(playerid, reason)
{
    deletePlayerTimer(playerid);

	#if defined vp_OnPlayerDisconnect
		return vp_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect vp_OnPlayerDisconnect
#if defined vp_OnPlayerDisconnect
	forward vp_OnPlayerDisconnect(playerid, reason);
#endif

stock getPlayerVehicleSpeed(playerid)
{
    if(IsPlayerInAnyVehicle(playerid))
    {
        new Float:X, Float:Y, Float:Z;
        new vehicleId = GetPlayerVehicleID(playerid);
        GetVehicleVelocity(vehicleId, X, Y, Z);
        return floatround( floatsqroot( X * X + Y * Y + Z * Z ) * 180.0 );
    }

    return -1;
}

stock getPlayerTravelDistance(playerid, Float:startX, Float:startY, Float:startZ)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	
	new distance = floatround(GetDistanceBetweenPoints(startX, startY, startZ, x, y, z), floatround_round);

	if(distance > 200)
	{
	    return 1;
	}
		
	return 0;
}

stock updateVehicleParams(vehicleid)
{
    SetVehicleParamsEx(vehicleid, vehicleInfo[vehicleid][vEngine], vehicleInfo[vehicleid][vLights], vehicleInfo[vehicleid][vAlarm], vehicleInfo[vehicleid][vDoors], vehicleInfo[vehicleid][vBonnet], vehicleInfo[vehicleid][vBoot], false);

	return 1;
}


stock getVehicleEngineStatus(vehicleid)
{
	return vehicleInfo[vehicleid][vEngine];
}

stock setVehicleEngineStatus(vehicleid, bool:status)
{
    vehicleInfo[vehicleid][vEngine] = status;

	updateVehicleParams(vehicleid);

	return 1;
}

stock getVehicleLightsStatus(vehicleid)
{
	return vehicleInfo[vehicleid][vLights];
}

stock setVehicleLightsStatus(vehicleid, bool:status)
{
    vehicleInfo[vehicleid][vLights] = status;

    updateVehicleParams(vehicleid);
    
	return 1;
}

stock getVehicleDoorsStatus(vehicleid)
{
	return vehicleInfo[vehicleid][vDoors];
}

stock setVehicleDoorsStatus(vehicleid, bool:status)
{
	vehicleInfo[vehicleid][vDoors] = status;

	updateVehicleParams(vehicleid);

	return 1;
}

stock getVehicleBonnetStatus(vehicleid)
{
	return vehicleInfo[vehicleid][vBonnet];
}

stock setVehicleBonnetStatus(vehicleid, bool:status)
{
	vehicleInfo[vehicleid][vBonnet] = status;

	updateVehicleParams(vehicleid);

	return 1;
}

stock getVehicleBootStatus(vehicleid)
{
	return vehicleInfo[vehicleid][vBoot];
}

stock setVehicleBootStatus(vehicleid, bool:status)
{
	vehicleInfo[vehicleid][vBoot] = status;

	updateVehicleParams(vehicleid);

	return 1;
}

stock getVehicleAlarmStatus(vehicleid)
{
	return vehicleInfo[vehicleid][vAlarm];
}

stock setVehicleAlarmStatus(vehicleid, bool:status)
{
	vehicleInfo[vehicleid][vAlarm] = status;

	updateVehicleParams(vehicleid);

	return 1;
}

stock getVehicleFuel(vehicleid)
{
	return vehicleInfo[vehicleid][vFuel];
}

stock setVehicleFuel(vehicleid, amount)
{
	vehicleInfo[vehicleid][vFuel] = amount;

	return 1;
}


CMD:carmenu(playerid)
{
	if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	    new vehicleId = GetPlayerVehicleID(playerid);
	    
		new list[128], item[32];
        strcat(list, "Parameter\tStatus\n");

		format(item, sizeof item, "Engine\t%s\n", getVehicleEngineStatus(vehicleId) ? ("{9ACD44}On{FFFFFF}") : ("{FF7447}Off{FFFFFF}"));
		strcat(list, item);

		format(item, sizeof item, "Lights\t%s\n", getVehicleLightsStatus(vehicleId) ? ("{9ACD44}On{FFFFFF}") : ("{FF7447}Off{FFFFFF}"));
		strcat(list, item);

		format(item, sizeof item, "Bonnet\t%s\n", getVehicleBonnetStatus(vehicleId) ? ("{9ACD44}On{FFFFFF}") : ("{FF7447}Off{FFFFFF}"));
		strcat(list, item);

		format(item, sizeof item, "Boot\t%s\n", getVehicleBootStatus(vehicleId) ? ("{9ACD44}On{FFFFFF}") : ("{FF7447}Off{FFFFFF}"));
		strcat(list, item);

		ShowPlayerDialog(playerid, vehicleMenuDialog, DIALOG_STYLE_TABLIST_HEADERS, "Car Menu", list, "Change", "Close");
	}
	
	return 1;
}

CMD:engine(playerid)
{
	if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	    new vehicleId = GetPlayerVehicleID(playerid);

	    if(!transportHasEngine(vehicleId)) return SendClientMessage(playerid, -1, "Am transports ar aqvs dzravi.");

		if(!getVehicleEngineStatus(vehicleId))
		{
		    if(vehicleInfo[vehicleId][vFuel] < 1) return SendClientMessage(playerid, -1, "Transportshi ar aris sawvavi.");

            setVehicleEngineStatus(vehicleId, true);
            
			GetVehiclePos(vehicleId, vehicleInfo[vehicleId][vPos_X], vehicleInfo[vehicleId][vPos_Y], vehicleInfo[vehicleId][vPos_Z]);

			return 1;
		}
		else
		{
			setVehicleEngineStatus(vehicleId, false);
			
		    return 1;
		}
	}

	return 1;
}

CMD:lights(playerid)
{
	if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	    new vehicleId = GetPlayerVehicleID(playerid);
	    
	   	if(!transportHasEngine(vehicleId)) return SendClientMessage(playerid, -1, "Am transports ar aqvs farebi.");
	    
		if(!getVehicleLightsStatus(vehicleId))
		{
			setVehicleLightsStatus(vehicleId, true);

		    return 1;
		}
		else
		{
		    setVehicleLightsStatus(vehicleId, false);

		    return 1;
		}
	}

	return 1;
}
