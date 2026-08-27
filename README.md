# true-aim

The runnable script stays at `bloodzone_aimbot.lua`, but the source is now organized as shared code plus per-game feature modules.

Current layout:

- `src/shared/`
- `src/games/00_registry.lua`
- `src/games/bloodzone/`

Workflow:

1. Put generic aimbot behavior in `src/shared/`.
2. Put game-specific behavior in `src/games/<game>/`.
3. Update `src/games/00_registry.lua` when a new place should enable a game module.
4. Edit the source files instead of editing `bloodzone_aimbot.lua` directly.
5. Run `powershell -ExecutionPolicy Bypass -File .\scripts\build.ps1`.
6. Use the rebuilt `bloodzone_aimbot.lua` as the single-file output.

Current build order:

1. `src/shared/00_bootstrap.lua`
2. `src/games/00_registry.lua`
3. `src/shared/05_runtime_state.lua`
4. `src/games/bloodzone/00_settings.lua`
5. `src/shared/10_core.lua`
6. `src/games/bloodzone/10_ballistics.lua`
7. `src/games/bloodzone/20_shield_mode.lua`
8. `src/shared/20_ui.lua`
9. `src/shared/30_visibility_targeting.lua`
10. `src/shared/40_runtime.lua`

Why this layout:

- `src/shared/` is the base legit/core path that should work anywhere.
- `src/games/<game>/` is where special weapon logic, threat logic, hooks, and other game-specific behavior belongs.
- New games can be added without stuffing more `if placeId` branches into the shared files.

This is the first game-module pass. The next cleanup step is moving the remaining Blood Zone-only UI and targeting branches out of shared files and into `src/games/bloodzone/`.
