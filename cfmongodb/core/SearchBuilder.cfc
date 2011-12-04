<cfcomponent hint="Creates a Domain Specific Language (DSL) for querying MongoDB collections.">
<cfscript>

  /*---------------------------------------------------------------------

    DSL for MongoDB searches:

    query = collection.query().
    				startsWith('name','foo').  //string
                    endsWith('title','bar').   //string
                    like('field','value').   //string
					          regex('field','value').    //string
                    eq('field','value').       //numeric
                    lt('field','value').       //numeric
                    gt('field','value').       //numeric
                    gte('field','value').      //numeric
                    lte('field','value').      //numeric
                    in('field','value').       //array
                    nin('field','value').      //array
                    mod('field','value').      //numeric
                    size('field','value').     //numeric
                    after('field','value').    //date
                    before('field','value');   //date


    results = query.find(keys=[keys_to_return],limit=num,start=num);

-------------------------------------------------------------------------------------*/

builder = '';
pattern = '';
dbCollection = '';
collection = '';
mongoUtil = '';

function init( DBCollection ){
	variables.dbCollection = arguments.DBCollection;
	variables.mongoUtil = DBCollection.getMongoUtil();
	builder = mongoUtil.newDBObjectBuilder();
	pattern = createObject('java', 'java.util.regex.Pattern');
}

function builder(){
  return builder;
}

function start(){
  builder.start();
  return this;
}

function add( key, value ){
	builder.add( key, value );
	return this;
}

function get(){
  return builder.get();
}

function startsWith(element, val){
  var regex = '^' & val;
  builder.add( element, pattern.compile(regex) );
  return this;
}

function endsWith(element, val){
  var regex = val & '$';
  builder.add( element, pattern.compile(regex) );
  return this;
}


function like(element, val){
  var regex = '.*' & val & '.*';
  builder.add( element, pattern.compile(regex) );
  return this;
}


function regex(element, val){
  var regex = val;
  builder.add( element, pattern.compile(regex) );
  return this;
}


//May need at least some exception handling
function where( js_expression ){
 builder.add( '$where', js_expression );
 return this;
}

function inArray(element, val){
  builder.add( element, val );
  return this;
}


 //vals should be list or array
function $in(element, vals){
  if(isArray(vals)) return addArrayCriteria(element, vals,'$in');
  return addArrayCriteria(element, listToArray(vals),'$in');
}

function $nin(element, vals){
  if(isArray(vals)) return addArrayCriteria(element, vals,'$nin');
  return addArrayCriteria(element, listToArray(vals),'$nin');
}


function $eq(element, val){
  builder.add( element, val );
  return this;
}


function $ne(element, val){
   builder.add( element, { "$ne" = val } );
   return  this;
}


function $lt(element, val){
  builder.add( element, { "$lt" = val } );
  return  this;
}


function $lte(element, val){
  builder.add( element, { "$lte" = val } );
  return this;
}


function $gt(element, val){
  builder.add( element, { "$gt" = val } );
  return this;
}


function $gte(element, val){
  builder.add( element, { "$gte" = val } );
  return this;
}

function $exists(element, exists=true){
	var criteria = {"$exists" = javacast("boolean",exists)};
	builder.add( element, criteria );
	return this;
}

function between(element, lower, upper){
	var criteria = {"$gte" = lower, "$lte" = upper};
	builder.add( element, criteria );
	return this;
}

function betweenExclusive(element, lower, upper){
	var criteria = {"$gt" = lower, "$lt" = upper};
	builder.add( element, criteria );
	return this;
}

function before(string element, date val){
	var exp = {};
	var  date = parseDateTime(val);
	exp['$lte'] = date;
	builder.add( element, exp );
	return this;
}

function after(string element, date val){
	var exp = {};
	var  date = parseDateTime(val);
	exp['$gte'] = date;
	builder.add( element, exp );
	return this;
}

/**
* @element The array element in the document we're searching
  @val The value(s) of an element in the array
  @type $in,$nin,etc.
*/
function addArrayCriteria( string element, array val, string type ){
	var exp = {};
	exp[type] = val;
	builder.add( element, exp );
	return this;
}

/**
* @keys A list of keys to return
  @skip the number of items to skip
  @limit Number of the maximum items to return
  @sort A struct or string representing how the items are to be sorted
*/
function find( string keys="", numeric skip=0, numeric limit=0, any sort="#structNew()#" ){
	return  dbCollection.find( criteria=get(), keys=keys, skip=skip, limit=limit, sort=sort );
}

function count(){
	return dbCollection.count( get() );
}

/**
* DEPRECATED. Use find() instead
*/
function search( string keys="", numeric skip=0, numeric limit=0, any sort="#structNew()#" ){
	return  this.find( argumentcollection = arguments );
}

</cfscript>

</cfcomponent>