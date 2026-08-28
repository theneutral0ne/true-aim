local LoadStringFunction = loadstring or load
if type(LoadStringFunction) ~= "function" then
	error("true-aim: loadstring is unavailable in this environment", 0)
end

local RepositoryFullNameString = "theneutral0ne/true-aim"
local BranchNameString = "main"
local BundleRelativePathString = "dist/true-aim.bundle.lua"
local CacheBustString = tostring(os.clock()):gsub("%.", "")
local RawUrlString = ("https://raw.githubusercontent.com/%s/%s/%s"):format(
	RepositoryFullNameString,
	BranchNameString,
	BundleRelativePathString
)
local SuccessBoolean, ResultValue = pcall(game.HttpGet, game, RawUrlString .. "?v=" .. CacheBustString)
if not SuccessBoolean then
	error(("true-aim: failed to fetch bundle (%s)"):format(tostring(ResultValue)), 0)
end

local ChunkFunction, CompileErrorString = LoadStringFunction(ResultValue, "@" .. BundleRelativePathString)
if type(ChunkFunction) ~= "function" then
	error(("true-aim: failed to compile bundle (%s)"):format(tostring(CompileErrorString)), 0)
end

return ChunkFunction()
