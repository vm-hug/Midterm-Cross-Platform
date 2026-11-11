// Uses the existing Firebase CLI login. No credentials are written into this project.
// Default is a read-only preview; --apply backs up and converts the one approved legacy document.
const fs = require('node:fs/promises');
const path = require('node:path');
const auth = require('firebase-tools/lib/auth');
const { requireAuth } = require('firebase-tools/lib/requireAuth');
const { Client } = require('firebase-tools/lib/apiv2');
const project = 'giuaki-13b9b';
const base = `projects/${project}/databases/(default)/documents`;
const hasKeys = (fields, keys) => Object.keys(fields).length === keys.length && keys.every(k => k in fields);
async function main() {
  const options = { project, ...auth.getGlobalDefaultAccount() };
  await requireAuth(options);
  const client = new Client({urlPrefix:'https://firestore.googleapis.com',apiVersion:'v1'});
  const documents = []; let pageToken;
  do {
    const res = await client.get(`${base}/users`, {queryParams:{pageSize:300,...(pageToken ? {pageToken}: {})}});
    documents.push(...(res.body.documents || [])); pageToken = res.body.nextPageToken;
  } while (pageToken);
  const legacy = documents.filter(d => hasKeys(d.fields || {}, ['email','matkhau','hoten','hinhanh']));
  const unknown = documents.filter(d => !legacy.includes(d) && !hasKeys(d.fields || {}, ['name','price','soluong','image']));
  if (unknown.length) throw new Error('Có bản ghi cấu trúc không xác định; dừng để giữ nguyên dữ liệu.');
  if (legacy.length > 1) throw new Error('Số bản ghi cũ đã thay đổi. Chỉ 1 bản ghi được phê duyệt chuyển đổi.');
  for (const d of legacy) {
    if (Object.values(d.fields).some(v => typeof v.stringValue !== 'string')) throw new Error('Bản ghi cũ sai kiểu dữ liệu.');
    const name = d.fields.hoten.stringValue.trim();
    const image = d.fields.hinhanh.stringValue;
    if (!name || name.length > 100 || image.length > 2048 || !/^https:\/\/res\.cloudinary\.com\/dqv9sna9b\/image\/upload\/.+/.test(image)) {
      throw new Error('Tên hoặc URL ảnh cũ chưa hợp lệ; không chuyển tự động.');
    }
  }
  console.log(JSON.stringify({project,collection:'users',total:documents.length,legacy:legacy.length,alreadyUpdated:documents.length-legacy.length,apply:process.argv.includes('--apply')}));
  if (!process.argv.includes('--apply') || !legacy.length) return;
  const backupDir = path.join(__dirname,'../.local/backups');
  await fs.mkdir(backupDir,{recursive:true,mode:0o700});
  const backupPath = path.join(backupDir,`users-before-products-${Date.now()}.json`);
  await fs.writeFile(backupPath,JSON.stringify({project,collection:'users',savedAt:new Date().toISOString(),documents:legacy},null,2),{flag:'wx',mode:0o600});
  console.log(`Backup saved: ${backupPath}`);
  const writes = legacy.map(d => ({update:{name:d.name,fields:{
    name:{stringValue:d.fields.hoten.stringValue.trim()}, price:{doubleValue:0},
    soluong:{integerValue:'0'}, image:{stringValue:d.fields.hinhanh.stringValue}
  }}, currentDocument:{updateTime:d.updateTime}}));
  await client.post(`${base}:commit`,{writes});
  for (const d of legacy) {
    const res = await client.get(d.name);
    if (!hasKeys(res.body.fields || {},['name','price','soluong','image']) ||
        res.body.fields.soluong.integerValue !== '0' ||
        Number(res.body.fields.price.doubleValue ?? res.body.fields.price.integerValue) !== 0) {
      throw new Error('Không xác minh được bản ghi sau chuyển đổi. Giữ lại backup để kiểm tra.');
    }
  }
  console.log(`Verified ${legacy.length} document(s), same IDs, exactly four new fields, price=0 and soluong=0.`);
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
