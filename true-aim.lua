local LoadStringFunction = loadstring or load
if type(LoadStringFunction) ~= "function" then
	error("true-aim: loadstring is unavailable in this environment", 0)
end

local RepositoryFullNameString = "theneutral0ne/true-aim"
local BranchNameString = "main"
local ModulePathsTable = {
    "src/shared/00_bootstrap.lua",
    "src/games/00_registry.lua",
    "src/shared/05_runtime_state.lua",
    "src/games/bloodzone/00_settings.lua",
    "src/shared/10_core.lua",
    "src/games/bloodzone/10_ballistics.lua",
    "src/games/bloodzone/20_shield_mode.lua",
    "src/shared/20_ui.lua",
    "src/shared/30_visibility_targeting.lua",
    "src/shared/40_runtime.lua"
}

local SourceChunksTable = {}
local CacheBustString = tostring(os.clock()):gsub("%.", "")
for IndexNumber, RelativePathString in ipairs(ModulePathsTable) do
	local RawUrlString = ("https://raw.githubusercontent.com/%s/%s/%s"):format(
		RepositoryFullNameString,
		BranchNameString,
		RelativePathString
	)
	local SuccessBoolean, ResultValue = pcall(game.HttpGet, game, RawUrlString .. "?v=" .. CacheBustString)
	if not SuccessBoolean then
		error(("true-aim: failed to fetch %s (%s)"):format(RelativePathString, tostring(ResultValue)), 0)
	end
	SourceChunksTable[IndexNumber] = ResultValue
end

local ChunkFunction, CompileErrorString = LoadStringFunction(table.concat(SourceChunksTable, "\n"))
if type(ChunkFunction) ~= "function" then
	error(("true-aim: failed to compile remote source (%s)"):format(tostring(CompileErrorString)), 0)
end

return ChunkFunction()