// Extract literal data from a reference addon without executing its code.
const fs=require('fs'), path=require('path');
const lua=require(process.env.FGM_LUAPARSE || 'luaparse');
const root=process.argv[2];
if(!root)throw new Error('Usage: inspect_reference.js <NightVibesGMPanel folder>');
function literal(node){
 if(!node)return null;
 if(node.type==='NumericLiteral'||node.type==='BooleanLiteral')return node.value;
 if(node.type==='UnaryExpression'&&node.operator==='-')return -literal(node.argument);
 if(node.type==='StringLiteral')return JSON.parse(node.raw);
 if(node.type==='TableConstructorExpression'){
  const result={};let index=1;
  for(const field of node.fields){
   const key=field.type==='TableKeyString'?field.key.name:field.type==='TableKey'?literal(field.key):index++;
   result[key]=literal(field.value);
  }
  return result;
 }
 throw new Error('Non-literal data: '+node.type);
}
const output={source:'NightVibesGMPanel 5.13.0; literal data only',items:{},trainer:{},quests:{},racials:{},sets:{}};
const mappings={CLASS_TRAINER_SPELLS:'trainer',CLASS_QUEST_SPELLS:'quests',RACIAL_SPELLS:'racials',ITEM_SETS:'sets'};
function walk(node){
 if(!node||typeof node!=='object')return;
 if(node.type==='AssignmentStatement')node.variables.forEach((v,i)=>{
  const property=v.type==='MemberExpression'&&v.identifier.name;
  if(mappings[property])output[mappings[property]]=literal(node.init[i]);
 });
 if(node.type==='CallExpression'&&node.base.type==='MemberExpression'&&node.base.identifier.name==='RegisterItemChunk')Object.assign(output.items,literal(node.arguments[0]));
 for(const value of Object.values(node))if(Array.isArray(value))value.forEach(walk);else if(value&&typeof value==='object')walk(value);
}
for(const file of fs.readdirSync(path.join(root,'Data')).filter(f=>/^ItemsExported_.*\.lua$/.test(f)||['ClassLearningExported.lua','ClassQuestSpellsExported.lua','RacialSpells.lua','ItemSetsExported.lua'].includes(f))){
 walk(lua.parse(fs.readFileSync(path.join(root,'Data',file),'utf8'),{luaVersion:'5.1'}));
}
process.stdout.write(JSON.stringify(output));
