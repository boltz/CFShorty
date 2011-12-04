<cfcomponent accessors="true">

	<cfproperty name="mongoFactory">

<cfscript>

	/**
	* initialize the MongoUtil. Pass an instance of JavaLoaderFactory to bypass the default MongoFactory
	  Using a JavaLoaderFactory lets you use the libs provided with cfmongodb without adding them to your
	  path and restarting CF
	*/
	function init(mongoFactory=""){
		if(isSimpleValue(mongoFactory)){
			arguments.mongoFactory = createObject("component", "DefaultFactory");
		}
		variables.mongoFactory = arguments.mongoFactory;
		variables.dboFactory = mongoFactory.getObject('com.mongodb.CFBasicDBObject');
		variables.dboBuilderFactory = mongoFactory.getObject('com.mongodb.CFBasicDBObjectBuilder');
		variables.typerClass = getDocumentTyperClass();
		variables.operationTyperClass = getOperationTyperClass();
		variables.typer = mongoFactory.getObject(typerClass).getInstance();
		variables.operationTyper = mongoFactory.getObject(operationTyperClass).getInstance();
	}

	/**
	* returns the typer class name to use for Document and Query objects.

		For Adobe ColdFusion, we need the CFStrictTyper because Adobe CF will treat numbers and booleans as strings.

		For Railo, we can use the "NoTyper" because Railo treats numbers as numbers and booleans as booleans
	*/
	public function getDocumentTyperClass(){
		if( server.coldfusion.productname eq "Railo") return "net.marcesher.NoTyper";
		return "net.marcesher.CFStrictTyper";
	}

	/**
	* returns a simple typer class that only concerns itself with 1, -1, and 0, which MongoDB uses
	  for operation decision making such as sorting and field selection
	*/
	public function getOperationTyperClass(){
		return "net.marcesher.MongoDBOperationOnlyTyper";
	}

	/**
	* Create a new instance of the CFBasicDBObject. You use these anywhere the Mongo Java driver takes a DBObject
	*/
	function newDBObject(){
		return dboFactory.newInstance(variables.typer);
	}

	/**
	* Create a new instance of the CFBasicDBObject for use in operational (i.e. non-document-save) situations
	*/
	function newOperationalDBObject(){
		return dboFactory.newInstance(variables.operationTyper);
	}

	/**
	* Create a new instance of a CFBasicDBObjectBuilder
	*/
	function newDBObjectBuilder(){
		return dboBuilderFactory.newInstance();
	}

	/**
	* Converts a ColdFusion structure to a CFBasicDBobject, which  the Java drivers can use
	*/
	function toMongo(any data){
		//for now, assume it's a struct to DBO conversion
		if( isCFBasicDBObject(data) ) return data;
		var dbo = newDBObject();
		dbo.putAll( data );
		return dbo;
	}

	/**
	* Converts a ColdFusion structure to a CFBasicDBobject which ensures 1 and -1 remain ints
	*/
	function toMongoOperation( struct data ){
		if( isCFBasicDBObject(data) ) return data;
		var dbo = newOperationalDBObject();
		dbo.putAll( data );
		return dbo;
	}

	/**
	* Converts a Mongo DBObject to a ColdFusion structure
	*/
	function toCF(BasicDBObject){
		var s = {};
		s.putAll(BasicDBObject);
		return s;
	}

	/**
	* Convenience for turning a string _id into a Mongo ObjectId object
	*/
	function newObjectIDFromID(String id){
		if( not isSimpleValue( id ) ) return id;
		return mongoFactory.getObject("org.bson.types.ObjectId").init(id);
	}

	/**
	* Convenience for creating a new criteria object based on a string _id
	*/
	function newIDCriteriaObject(String id){
		return newDBObject().put("_id",newObjectIDFromID(id));
	}

	/**
	* Creates a Mongo CFBasicDBObject whose order matches the order of the keyValues argument
	  keyValues can be:
	  	1) a string in k,k format: "STATUS,TS". This will set the value for each key to "1". Useful for creating Mongo's 'all true' structs, like the "keys" argument to group()
	    2) a string in k=v format: STATUS=1,TS=-1
		3) an array of strings in k=v format: ["STATUS=1","TS=-1"]
		4) an array of structs (often necessary when creating "command" objects for passing to db.command()):
		  createOrderedDBObject( [ {"mapreduce"="tasks"}, {"map"=map}, {"reduce"=reduce} ] )
	*/
	function createOrderedDBObject( keyValues, dbObject="" ){
		if( isSimpleValue(dbObject) ){
			dbObject = newDBObject();
		}
		var kv = "";
		if( isSimpleValue(keyValues) ){
			keyValues = listToArray(keyValues);
		}
		for(kv in keyValues){
			if( isSimpleValue( kv ) ){
				var key = listFirst(kv, "=");
				var value = find("=",kv) ? listRest(kv, "=") : 1;
			} else {
				var key = structKeyList(kv);
				var value = kv[key];
			}

			dbObject.append( key, value );
		}
		return dbObject;
	}

	function listToStruct(list){
		var item = '';
		var s = {};
		var i = 1;
		var items = listToArray(list);
		var itemCount = arrayLen(items);
		for(i; i lte itemCount; i++) {
			s.put(items[i],1);
		}
		return s;
	}

	/**
	* Extracts the timestamp from the Doc's ObjectId. This represents the time the document was added to MongoDB
	*/
	function getDateFromDoc( doc ){
		var ts = doc["_id"].getTime();
		return createObject("java", "java.util.Date").init(ts);
	}

	/**
	* Whether this doc is an instance of a CFMongoDB CFBasicDBObject
	*/
	function isCFBasicDBObject( doc ){
		return NOT isSimpleValue( doc ) AND getMetadata( doc ).getCanonicalName() eq "com.mongodb.CFBasicDBObject";
	}
</cfscript>
</cfcomponent>