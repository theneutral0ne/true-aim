local SupportedBloodZoneWeaponTypesTable = {
	Gun = true,
	Launcher = true,
}
local ExplosiveProjectileNameSetTable = {
	Firework = true,
	GrenadeShot = true,
	LauncherGrenade = true,
	EggGrenade = true,
	Propaine = true,
	PropaneLauncher = true,
}
local LauncherBallisticsProfileByNameTable = {
	["Grenade Launcher"] = {
		projectileName = "LauncherGrenade",
		launchMode = "force_curve",
		forceDistanceClamp = 100,
		forceDistanceScale = 0.01,
		forceDistanceBias = 1.001,
		useWorkspaceGravity = true,
		simulationStep = 0.05,
		lifetime = 1.5,
		rayHit = false,
		delayedExplosion = true,
		splashAcceptanceScale = 0.6,
		splashRadius = 10.5,
	},
	["Eggsplosive Launcher"] = {
		projectileName = "EggGrenade",
		launchMode = "force_curve",
		forceDistanceClamp = 100,
		forceDistanceScale = 0.01,
		forceDistanceBias = 1.001,
		useWorkspaceGravity = true,
		simulationStep = 0.05,
		lifetime = 1.5,
		rayHit = false,
		delayedExplosion = true,
		splashAcceptanceScale = 0.6,
		splashRadius = 10.5,
	},
	["Propane Launcher"] = {
		projectileName = "PropaneLauncher",
		speed = 140,
		gravity = 36,
		lifetime = 5,
		rayHit = false,
		splashRadius = 12,
	},
}

local function IsSupportedBloodZoneWeaponType(WeaponTypeString)
	return type(WeaponTypeString) == "string"
		and SupportedBloodZoneWeaponTypesTable[WeaponTypeString] == true
end

