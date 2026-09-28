# Campus Carnage

A first-person action prototype built in Godot 4, set on a university campus: shoot, break windows and interactable objects, and fight enemies driven by a finite state machine.

## Core Systems

- **First-person controller** — custom physics movement with acceleration/deceleration curves, jump, and a stair-stepping system (`_snap_down_to_stairs_check`) that snaps the player up/down steps within a configurable max step height instead of relying on default `CharacterBody3D` collision response.
- **Enemy AI (FSM)** — enemies run on a small hand-written finite state machine (`finite_state_machine.gd` + `state.gd` base class) with `idle`, `attack`, and `dead` states, keeping each behavior isolated and easy to extend with new states.
- **Weapons** — a shared `gun.gd` base with a `shotgun.gd` implementation, decoupling weapon-specific behavior (spread, ammo, fire rate) from the firing/aiming pipeline.
- **World interaction** — a `shootable.gd` component marks any object as damageable by gunfire, and `window.gd` implements breakable-on-impact geometry, both independent of the player/weapon code.
- **Dialogue bubbles** — a lightweight `dialog_bubble_ui.gd` system for quick, non-blocking NPC lines during gameplay, separate from any full dialogue-tree system.
- **Mouse-driven interaction** — a shared raycast handler (`InteractionHandler` / `mouse_ray_cast.gd`) resolves what the player is looking at, used for both interaction prompts and weapon aiming.

## Requirements

- Engine: Godot 4.x
- Open the project root from the Godot Project Manager and run `scenes/main_menu.tscn`.
