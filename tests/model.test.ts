import {test} from 'node:test';
import assert from 'node:assert/strict';
import {schema,summary,duplicate,days,today} from '../lib/model';
const record=(kind:string,name='Example')=>schema.parse({id:crypto.randomUUID(),kind,name});
test('outreach counts recorded events, not professor stages',()=>{const p={...record('professor'),status:'Contacted'};assert.equal(summary([p]).sent,0);assert.equal(summary([p,{...record('event'),details:{direction:'outbound'}}]).sent,1)});
test('archive excludes records from dashboard',()=>assert.equal(summary([{...record('professor'),archived:true}]).professors,0));
test('CSV duplicates ignore case and surrounding whitespace',()=>assert.equal(duplicate(record('professor',' Avery '),record('professor','avery')),true));
test('unsafe source links and empty names are rejected',()=>{assert.throws(()=>schema.parse({...record('professor'),source:'javascript:alert(1)'}));assert.throws(()=>schema.parse({...record('professor'),name:' '}))});
test('date-only day calculations do not shift dates',()=>assert.equal(days(today('America/New_York'),'America/New_York'),0));
