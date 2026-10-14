# Compatibility

## Verified target

- Client executable: `<WoW client>/_classic_beta_/WowB.exe`
- Product and file version: **1.60.1.70338**
- Addon interface: **16001**, verified from the installed `ForeverRecap.toc`
- Server: the packaged `ForeverCore-source-1.5.0-20261014-000613` fork
- Repack readme description: WoW Classic beta 1.60.1, with setup notes that support build 70291 and later
- Realm database inspected: the running local `world`, `auth`, and `hotfixes` schemas on port 3317

The TOC intentionally targets interface 16001. At login, ForeverGM compares `GetBuildInfo()` with that interface and shows a warning if it differs.

## Client API policy

ForeverGM uses stable addon APIs present in the installed client family: `CreateFrame`, events, `SendChatMessage`, `GetBuildInfo`, `GetLocale`, `GameTooltip`, `StaticPopupDialogs`, SavedVariables, slash commands, and the minimap frame. Optional APIs and templates have guards or fallbacks. `BackdropTemplateMixin`, `C_Map`, and `C_AddOns` are detected rather than assumed.

The addon never reads SQL, files, or HTTP at runtime. The generator performs database/source access offline and writes plain Lua tables.

## Execution limitations

- A dispatched chat command is not treated as success. The UI distinguishes prepared, dispatched, response received, and detected failure states.
- Unstructured `CHAT_MSG_SYSTEM` output cannot always prove success. Non-error responses are therefore reported as “response received; outcome not inferred.”
- Server RBAC is authoritative. Client-side role labels are informative and derived from default RBAC links.
- Selected-target behavior is controlled by each ForeverCore handler. ForeverGM does not bypass or emulate it.
- Actual in-game loading and visual interaction remain to be confirmed on the client. Static validation is not a substitute for play testing.

## Optional libraries

No external libraries are required. LibDataBroker/LibDBIcon can be integrated later, but the native minimap launcher is used to avoid an unverified dependency.
