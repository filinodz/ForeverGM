// Execute the real addon modules against the API mock, with Fengari (test only).
const fs = require('fs');
const path = require('path');
const {lua, lauxlib, lualib, to_luastring, to_jsstring} = require(process.env.FGM_FENGARI || 'fengari');
const root = path.resolve(__dirname, '..');
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
function run(code, name, addonArgs=false) {
 if (lauxlib.luaL_loadbuffer(L,to_luastring(code),null,to_luastring(name))) throw new Error(to_jsstring(lua.lua_tostring(L,-1)));
 if (addonArgs) {lua.lua_pushstring(L,to_luastring('ForeverGM'));lua.lua_getglobal(L,to_luastring('FGM_TEST_NS'));}
 if (lua.lua_pcall(L,addonArgs?2:0,0,0)) throw new Error(name+': '+to_jsstring(lua.lua_tostring(L,-1)));
}
run(fs.readFileSync(path.join(__dirname,'runtime.lua'),'utf8'),'mock');
run('FGM_TEST_NS = {}','namespace');
for (const file of fs.readFileSync(path.join(root,'ForeverGM.toc'),'utf8').split(/\r?\n/).map(s=>s.trim()).filter(s=>s&&!s.startsWith('##'))) {
 run(fs.readFileSync(path.join(root,file),'utf8'),file,true);
}
run(fs.readFileSync(path.join(__dirname,'commands.lua'),'utf8'),'command transport tests');
run('print("PASS: " .. (FGM_RUN_TESTS() + FGM_RUN_COMMAND_TESTS()) .. " runtime assertions; browsing, layout, minimap, immediate chat transport, throttling, confirmation and cancellation")','tests');
