if (!isServer and hasInterface) exitWith {};

params ["_marker"];

private ["_groupType", "_group", "_allGroups"];

diag_log format ["Supply crate at %1 spawning in troups", _marker];

_allGroups = [];
_allSoldiers = [];
_allVehicles = [];

_spawnPosition = getmarkerpos _marker;
_groupType = [infSquad, side_green] call AS_fnc_pickGroup;
_group = [_spawnPosition, side_green, _groupType] call BIS_Fnc_spawnGroup;
_dog = _group createUnit ["Fin_random_F",_spawnPosition,[],0,"FORM"];
[_dog] spawn guardDog;

{
	_group = _x;
	{
		[_x] spawn genInit;
		_allSoldiers pushBack _x;
	} forEach units _group;
} forEach _allGroups;

// TODO: dirty quickfix need to check why they dont despawn properly and use distancias3 like everyone else !
_group deleteGroupWhenEmpty true;
["_group"] spawn {
    params ["_group"];
    diag_log format ["debug: spawn delete 30s _group %1", _group];
    sleep 30;
    {
        deleteVehicle _object;
        [_x] call {
            deleteVehicle (_this select 0);
        };
    } forEach units _group;

    // [_x] spawn {
    //     deleteVehicle _this;
    // }  forEach units _group;
    diag_log format ["debug: Actual delete _group %1", _group];
};

sleep 5;
//waitUntil {sleep 1; spawner getVariable _marker > 1}; //Activate when merged with new spawn system
waitUntil {sleep 1; !(spawner getVariable _marker);};

[_allGroups, _allSoldiers, _allVehicles] spawn AS_fnc_despawnUnits;
