// Move users -> product atomically, keep IDs/data and explicitly store price as double.
// Dry-run unless --apply. Uses the existing Firebase CLI login, never writes tokens.
const fs=require('node:fs/promises');
const path=require('node:path');
const auth=require('firebase-tools/lib/auth');
const {requireAuth}=require('firebase-tools/lib/requireAuth');
const {Client}=require('firebase-tools/lib/apiv2');
const project='giuaki-13b9b';const base=`projects/${project}/databases/(default)/documents`;
const keys=['name','price','soluong','image'];
function decode(d){
 const f=d.fields||{};const price=Number(f.price?.doubleValue??f.price?.integerValue??NaN);const quantity=Number(f.soluong?.integerValue??NaN);
 if(Object.keys(f).length!==4||!keys.every(k=>k in f)||typeof f.name?.stringValue!=='string'||typeof f.image?.stringValue!=='string'||!Number.isFinite(price)||price<0||price>Number.MAX_SAFE_INTEGER||!Number.isSafeInteger(quantity)||quantity<0){throw new Error('Schema không hợp lệ; dừng để giữ nguyên dữ liệu.');}
 return {name:f.name.stringValue,price,soluong:quantity,image:f.image.stringValue};
}
const id=d=>d.name.split('/').at(-1);
const fields=p=>({name:{stringValue:p.name},price:{doubleValue:p.price},soluong:{integerValue:String(p.soluong)},image:{stringValue:p.image}});
async function main(){
 await requireAuth({project,...auth.getGlobalDefaultAccount()});
 const client=new Client({urlPrefix:'https://firestore.googleapis.com',apiVersion:'v1'});
 async function list(collection){let result=[],pageToken;do{const res=await client.get(`${base}/${collection}`,{queryParams:{pageSize:300,...(pageToken?{pageToken}:{})}});result.push(...(res.body.documents||[]));pageToken=res.body.nextPageToken;}while(pageToken);return result;}
 const source=await list('users');const target=await list('product');
 const targets=new Map(target.map(d=>[id(d),d]));const writes=[];
 for(const d of [...source,...target])decode(d);
 for(const d of source){
  const nested=await client.post(`${d.name}:listCollectionIds`,{pageSize:1});
  if(nested.body.collectionIds?.length)throw new Error('Document có subcollection, cần kế hoạch chuyển riêng. Chưa ghi dữ liệu.');
  const p=decode(d),dest=targets.get(id(d));
  if(dest&&JSON.stringify(decode(dest))!==JSON.stringify(p))throw new Error('Trùng ID với dữ liệu khác trong product; không ghi đè.');
  if(!dest||!Object.hasOwn(dest.fields.price,'doubleValue'))writes.push({update:{name:`${base}/product/${id(d)}`,fields:fields(p)},currentDocument:dest?{updateTime:dest.updateTime}:{exists:false}});
  writes.push({delete:d.name,currentDocument:{updateTime:d.updateTime}});
 }
 for(const d of target){if(source.some(s=>id(s)===id(d))||Object.hasOwn(d.fields.price,'doubleValue'))continue;writes.push({update:{name:d.name,fields:fields(decode(d))},currentDocument:{updateTime:d.updateTime}});}
 if(writes.length>500)throw new Error('Vượt giới hạn commit atomic 500 writes; chưa chuyển dữ liệu.');
 console.log(JSON.stringify({project,from:'users',to:'product',sourceCount:source.length,targetCount:target.length,writes:writes.length,apply:process.argv.includes('--apply')}));
 if(!process.argv.includes('--apply')||!writes.length)return;
 const backupDir=path.join(__dirname,'../.local/backups');await fs.mkdir(backupDir,{recursive:true,mode:0o700});
 const backup=path.join(backupDir,`users-to-product-${Date.now()}.json`);
 await fs.writeFile(backup,JSON.stringify({project,savedAt:new Date().toISOString(),source,target},null,2),{flag:'wx',mode:0o600});
 console.log(`Backup: ${backup}`);
 await client.post(`${base}:commit`,{writes});
 const remaining=await list('users');const moved=await list('product');const actual=new Map(moved.map(d=>[id(d),d]));
 if(remaining.length)throw new Error('Có document mới trong users sau snapshot; không tự xóa thêm, giữ backup để kiểm tra.');
 for(const d of [...source,...target]){const dest=actual.get(id(d));if(!dest||JSON.stringify(decode(d))!==JSON.stringify(decode(dest))||!Object.hasOwn(dest.fields.price,'doubleValue'))throw new Error('Xác minh sau chuyển đổi không đạt. Giữ backup để kiểm tra.');}
 console.log(`Verified: users empty; product=${moved.length}; original IDs/values kept; every price uses doubleValue.`);
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
