local GameIntegrationProfilesByPlaceIdTable = {
	-- Keep game-specific behavior place-bound so future integrations can opt in cleanly.
	[13955927965] = {
		id = "bloodzone",
		usesCustomCharacters = true,
		usesCustomScopeCheck = true,
		usesProjectilePrediction = true,
		autoFireCooldown = 0,
		playerListRefreshInterval = 0.12,
		playerListEntryStateCacheDuration = 0.05,
		menuHeight = 572,
	},
}
CurrentGameIntegrationProfileTable = GameIntegrationProfilesByPlaceIdTable[game.PlaceId]
CurrentGameIntegrationIdString = CurrentGameIntegrationProfileTable and CurrentGameIntegrationProfileTable.id or nil
IsBloodZonePlaceBoolean = (CurrentGameIntegrationIdString == "bloodzone")
IsCustomCharacterGameBoolean = CurrentGameIntegrationProfileTable ~= nil
	and CurrentGameIntegrationProfileTable.usesCustomCharacters == true
UseCustomScopeCheckBoolean = CurrentGameIntegrationProfileTable ~= nil
	and CurrentGameIntegrationProfileTable.usesCustomScopeCheck == true
UseProjectilePredictionBoolean = CurrentGameIntegrationProfileTable ~= nil
	and CurrentGameIntegrationProfileTable.usesProjectilePrediction == true
CurrentGameIntegrationMenuHeightNumber = CurrentGameIntegrationProfileTable
	and CurrentGameIntegrationProfileTable.menuHeight or 524
CurrentGameIntegrationPlayerListRefreshIntervalNumber = CurrentGameIntegrationProfileTable
	and CurrentGameIntegrationProfileTable.playerListRefreshInterval or 0.55
CurrentGameIntegrationPlayerListEntryCacheDurationNumber = CurrentGameIntegrationProfileTable
	and CurrentGameIntegrationProfileTable.playerListEntryStateCacheDuration or 0.2
if CurrentGameIntegrationProfileTable
	and type(CurrentGameIntegrationProfileTable.autoFireCooldown) == "number" then
	AutoFireCooldownNumber = CurrentGameIntegrationProfileTable.autoFireCooldown
end

