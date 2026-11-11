// Read-only export using the project owner's existing Firebase CLI session.
const fs=require('node:fs/promises');
const path=require('node:path');
const auth=require('firebase-tools/lib/auth');
const {requireAuth}=require('firebase-tools/lib/requireAuth');
const {Client}=require('firebase-tools/lib/apiv2');
(async()=>{
 const project='giuaki-13b9b';await requireAuth({project,...auth.getGlobalDefaultAccount()});
 const client=new Client({urlPrefix:'https://firestore.googleapis.com',apiVersion:'v1'});
 const products=[];let pageToken;
 do {
  const res=await client.get(`projects/${project}/databases/(default)/documents/product`,{queryParams:{pageSize:300,...(pageToken?{pageToken}:{})}});
  for(const d of res.body.documents||[]){
   const f=d.fields||{};const price=Number(f.price?.doubleValue??f.price?.integerValue??NaN);const soluong=Number(f.soluong?.integerValue??NaN);
   if(Object.keys(f).length!==4||typeof f.name?.stringValue!=='string'||typeof f.image?.stringValue!=='string'||!Number.isFinite(price)||price<0||price>Number.MAX_SAFE_INTEGER||!Number.isSafeInteger(soluong)||soluong<0){throw new Error('Dữ liệu không khớp schema sản phẩm; dừng export.');}
   products.push({name:f.name.stringValue,price,soluong,image:f.image.stringValue});
  }
  pageToken=res.body.nextPageToken;
 }while(pageToken);
 const output=path.join(__dirname,'../database_products.json');
 await fs.writeFile(output,JSON.stringify(products,null,2)+'\n');
 console.log(`Exported ${products.length} product(s), exactly four fields with numeric price/soluong, to ${output}`);
})().catch(e=>{console.error(e.message);process.exitCode=1;});
