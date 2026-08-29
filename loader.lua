local SourceUrl = "https://raw.githubusercontent.com/theneutral0ne/true-aim/main/true-aim.lua"

local LoadStringFunction = loadstring or load
if type(LoadStringFunction) ~= "function" then
	error("true-aim loader: loadstring is unavailable in this executor")
end

local FetchSuccessBoolean, SourceString = pcall(function()
	return game.HttpGet(game, SourceUrl)
end)
if not FetchSuccessBoolean then
	error("true-aim loader: failed to fetch remote source: " .. tostring(SourceString))
end
if type(SourceString) ~= "string" or SourceString == "" then
	error("true-aim loader: remote source was empty")
end

local ChunkFunction, CompileErrorString = LoadStringFunction(SourceString, "@true-aim.lua")
if type(ChunkFunction) ~= "function" then
	error("true-aim loader: failed to compile remote source: " .. tostring(CompileErrorString))
end

return ChunkFunction()
