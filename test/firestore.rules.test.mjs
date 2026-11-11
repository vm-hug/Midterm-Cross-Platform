import { createMockUserToken } from '@firebase/util';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { after, before, beforeEach, test } from 'node:test';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, getDocs, collection, updateDoc, deleteDoc } from 'firebase/firestore';
let env;
const uid='kmRuft7UYMb3Qihsqzqaa691hkr1';
const product={name:'Bút bi',price:12500.5,soluong:3,image:'https://res.cloudinary.com/dqv9sna9b/image/upload/test.png'};
before(async()=>{env=await initializeTestEnvironment({projectId:'demo-userspace',firestore:{rules:await readFile('firestore.rules','utf8')}});});
after(async()=>{await env?.cleanup();});
beforeEach(async()=>{await env.clearFirestore();});
test('Unauthenticated and non-admin cannot read, list or write products in product',async()=>{
 for(const ctx of [env.unauthenticatedContext(),env.authenticatedContext('other-uid')]){
  const db=ctx.firestore();await assertFails(getDoc(doc(db,'product','test')));await assertFails(getDocs(collection(db,'product')));
  await assertFails(setDoc(doc(db,'product','test'),product));await assertFails(deleteDoc(doc(db,'product','test')));
 }
});
test('Admin CRUD accepts numeric prices, integer quantities and zero values',async()=>{
 const db=env.authenticatedContext(uid).firestore();const ref=doc(db,'product','test');
 await assertSucceeds(setDoc(ref,product));await assertSucceeds(getDoc(ref));await assertSucceeds(getDocs(collection(db,'product')));
 await assertSucceeds(updateDoc(ref,{name:'Sổ tay',soluong:0}));await assertSucceeds(deleteDoc(ref));
});
test('Reject old schema, extra/missing fields, numeric strings, negatives and fractional quantity',async()=>{
 const db=env.authenticatedContext(uid).firestore();const {image,...missing}=product;
 for(const bad of [
  {email:'an@example.com',matkhau:'demo',hoten:'An',hinhanh:product.image},
  {...product,role:'admin'},missing,{...product,name:''},{...product,name:' '.repeat(3)},
  {...product,name:'a'.repeat(101)},{...product,price:'12500'},{...product,soluong:'3'},
  {...product,price:-1},{...product,price:NaN},{...product,price:Infinity},
  {...product,soluong:-1},{...product,soluong:1.5},{...product,soluong:9007199254740992},
  {...product,image:'http://res.cloudinary.com/dqv9sna9b/image/upload/a.png'},
  {...product,image:'https://res.cloudinary.com/other/image/upload/a.png'},
 ]){await assertFails(setDoc(doc(db,'product','invalid'),bad));}
 const ref=doc(db,'product','valid');await assertSucceeds(setDoc(ref,product));
 await assertFails(updateDoc(ref,{email:'a@example.com'}));await assertFails(updateDoc(ref,{price:'2'}));
});
test('Other collections remain inaccessible even to Admin',async()=>{
 const db=env.authenticatedContext(uid).firestore();await assertFails(setDoc(doc(db,'admins','test'),{role:'admin'}));await assertFails(getDocs(collection(db,'admins')));
});

test('Typed REST keeps whole-valued/zero prices double; old collection and integer price are rejected', async()=>{
 const token=createMockUserToken({sub:uid,user_id:uid},'demo-userspace');
 const endpoint='http://127.0.0.1:8080/v1/projects/demo-userspace/databases/(default)/documents:commit';
 for(const price of [0,200]){
  const response=await fetch(endpoint,{method:'POST',headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:JSON.stringify({writes:[{update:{name:`projects/demo-userspace/databases/(default)/documents/product/rest-${price}`,fields:{name:{stringValue:'REST'},price:{doubleValue:price},soluong:{integerValue:'3'},image:{stringValue:product.image}}},currentDocument:{exists:false}}]})});
  assert.equal(response.status,200,await response.text());
  const raw=await fetch(`http://127.0.0.1:8080/v1/projects/demo-userspace/databases/(default)/documents/product/rest-${price}`,{headers:{Authorization:`Bearer ${token}`}});
  assert.deepEqual((await raw.json()).fields.price,{doubleValue:price});
 }
 const db=env.authenticatedContext(uid).firestore();
 await assertFails(setDoc(doc(db,'product','integer-price'),{...product,price:200}));
 await assertFails(getDocs(collection(db,'users')));
 await assertFails(setDoc(doc(db,'users','old-path'),product));
});
