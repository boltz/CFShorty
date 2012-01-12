<cfcomponent displayname="api" output="false" hint="I am the cfmlShorty API service layer.">
		
	<!--- Pseudo constructor --->
	<cfset variables.instance = {} />
		
	<cffunction name="init" access="public" output="false" hint="I am the constructor for the cfmlShorty API.">
		<cfargument name="siteURL" 	required="true" type="string" hint="I am the name of the site URL that will handle the shortener service. For example 'cfml.us'." /> 
		<cfargument name="dbName" 	required="true" type="string" hint="I am the name for the db." />
			<cfscript>
				variables.instance.siteURL 	= 	arguments.siteURL;
				variables.instance.dbName	=	arguments.dbName;
				
				javaloaderFactory 			= createObject('component','cfmongodb.core.JavaloaderFactory').init();
				mongoConfig 				= createObject('component','cfmongodb.core.MongoConfig').init(dbName=variables.instance.dbName, mongoFactory=javaloaderFactory);
			
				// Initialize the core cfmongodb Mongo object
				variables.instance.mongo		=	createObject('component','cfmongodb.core.Mongo').init(mongoConfig);
				variables.instance.collection	=	"url_list";
				
				variables.instance.link 	= variables.instance.mongo.getDBCollection( "LINK" );		
				variables.instance.nextLink = variables.instance.mongo.getDBCollection( "NEXTLINK" );
	
				variables.instance.emptystruct	=	{
					'HTTP_REFERER'		=	'',
					'HTTP_USER_AGENT'	=	'',
					'REMOTE_ADDR'		=	''
				};

				variables.instance.emptyDoc = {
					KIND 			=	"",
					MONGOID			=	"",
					ID				=	"",
					SHORTURL		= 	"",
					LONGURL 		= 	"",
					STATUS 			= 	"",
					CREATED 		= 	"",
					LABEL			= 	"",
					HTTP_REFERER	=	"",
					HTTP_USER_AGENT	=	"",
					REMOTE_ADDR		=	""
				};
				
			</cfscript>			
		<cfreturn this />
	</cffunction>
	
	<!--- Getters Start --->
	<cffunction name="getMongo" access="public" output="false" hint="I return the mongo object.">
		<cfreturn variables.instance.mongo />
	</cffunction>
	<!--- Getters End --->

	<cffunction name="shortenURL" access="remote" output="false" hint="I shorten the provided URL.">
		<cfargument name="longURL" 	type="string" required="true" />
		<cfargument name="label" 	type="string" required="true" default="" />
		<cfargument name="key" 		type="string" required="true" default="noKey" />
		<cfargument name="cgi" 		type="struct" required="true" default="#variables.instance.emptystruct#" />
			<cfset var newURL = insertURL(longURL=arguments.longURL, label=arguments.label, key=arguments.key, cgi=arguments.cgi)>
				<cfset newURL = deserializeJSON(newURL)>
		<cfreturn newURL.shortURL />
	</cffunction>
	
	<cffunction name="insert" access="remote" returnformat="JSON" output="false" hint="">
		<cfargument name="longURL" 	type="string" required="true" />
		<cfargument name="label" 	type="string" required="true" default="" />
		<cfargument name="key" 		type="string" required="true" default="noKey" />
		<cfargument name="cgi" 		type="struct" required="true" default="#variables.instance.emptystruct#" />
		<cfset var size 	= variables.instance.link.count() + 1 />
		<cfset var shortID 	= getNextLink() />
		<cfset var doc = {
			KIND 			= 	"",
			MONGOID			=	"",
			ID				=	"#shortID#",
			SHORTURL		= 	"#variables.instance.siteURL#/#shortID#",
			LONGURL 		= 	"#arguments.longURL#",
			STATUS 			= 	"",
			CREATED 		= 	"#now()#",
			LABEL			= 	"#LEFT(arguments.label, 255)#",
			HTTP_REFERER	=	"#arguments.cgi.HTTP_REFERER#",
			HTTP_USER_AGENT	=	"#arguments.cgi.HTTP_USER_AGENT#",
			REMOTE_ADDR		=	"#arguments.cgi.REMOTE_ADDR#"
		} />
		<!--- Save the document --->
		<cfset var savedDoc 	=	variables.instance.link.save(doc) />
		<!--- Get the _id for our saved doc, find it and update our struct with the unique _id --->
		<cfset var id 			= 	savedDoc.toString() />
		<cfset var byID 		= 	variables.instance.link.findById( id ) />
			<cfset byID.MONGOID = 	id />
			<cfset variables.instance.link.update(byID) />
			<cfset structDelete(byID, "_id") />
		<cfreturn serializeJSON(byID) />
	</cffunction>
	
	<cffunction name="insertURL" access="remote" returnformat="JSON" output="false" hint="">
		<cfargument name="longURL" 	type="string" required="true" />
		<cfargument name="label" 	type="string" required="true" default="" />
		<cfargument name="key" 		type="string" required="true" default="noKey" />
		<cfargument name="cgi" 		type="struct" required="true" default="#variables.instance.emptystruct#" />
		<cfset var size 	= variables.instance.link.count() + 1 />
		<cfset var shortID 	= getNextLink() />
		<cfset var doc = {
			KIND 			= 	"",
			MONGOID			=	"",
			ID				=	"#shortID#",
			SHORTURL		= 	"#variables.instance.siteURL#/#shortID#",
			LONGURL 		= 	"#arguments.longURL#",
			STATUS 			= 	"",
			CREATED 		= 	"#now()#",
			LABEL			= 	"#LEFT(arguments.label, 255)#",
			HTTP_REFERER	=	"#arguments.cgi.HTTP_REFERER#",
			HTTP_USER_AGENT	=	"#arguments.cgi.HTTP_USER_AGENT#",
			REMOTE_ADDR		=	"#arguments.cgi.REMOTE_ADDR#"
		} />
		<!--- Save the document --->
		<cfset var savedDoc 	= variables.instance.link.save(doc) />
		<!--- Get the _id for our saved doc, find it and update our struct with the unique _id --->
		<cfset var id 			= savedDoc.toString() />
		<cfset var byID 		= variables.instance.link.findById( id ) />
			<cfset byID.MONGOID = id />
			<cfset variables.instance.link.update(byID) />
			<cfset structDelete(byID, "_id") />
		<cfreturn serializeJSON(byID) />
	</cffunction>
	
	<cffunction name="getLinkInfo" access="remote" output="false" hint="">
		<cfargument name="shortURL" 				type="string" 	required="true" 				hint="The short URL (using the shortUrl query parameter). Note: The short URL should include the protocol, e.g. http://goo.gl/fbsS" />
		<cfargument name="FULL" 					type=string 	required="true" default=false 	hint="FULL - returns the creation timestamp and all available analytics" />
		<cfargument name="ANALYTICS_CLICKS" 		type=string 	required="true" default=false 	hint="Returns only click counts" />
		<cfargument name="ANALYTICS_TOP_STRINGS" 	type=string 	required="true" default=false 	hint="Returns only top string counts (e.g. referrers, countries, etc)" />
		<cfargument name="cgi" 						type="struct"	required="true" default="#variables.instance.emptystruct#" />
		<cfset var results 	=	"" />
		<cfset var ID 		= 	listLast(arguments.shortURL, "/") />
			<cfset results = variables.instance.link.query().$eq("ID", "#id#").find() />
			<cfset results = results.asArray() />
			<cfif arraylen(results) LT 1>
				<cfreturn serializeJSON(variables.instance.emptyDoc) />
			</cfif>
			<cfset results = results[1] />
			<cfset structDelete(results, "_id") />
		<cfreturn serializeJSON(results) />
	</cffunction>
	
	<cffunction name="initialize" access="remote" output="false" hint="I initialize the database and need to be run before you can start kicking ass and taking links.">
		<cfset variables.instance.nextLink.remove({}) />	
		<cfset var doc 		= {variables.instance.nextLink = "999"} />
		<cfset var savedDoc = variables.instance.nextLink.save(doc) />
		<cfset var results  = variables.instance.nextLink.query().find(skip = 0, limit = 25, sort = {"NEXTLINK" =1}) />
		<cfset results 		= results.asArray() />
		<cfdump var="#results#" />
	</cffunction>
	
	<cffunction name="getNextLink" access="remote" output="false" hint="">
		<cfset var results = "" />
		<cfset var nextNum = "" />
			<cfset results  = variables.instance.nextLink.query().find(skip = 0, limit = 25, sort = {"NEXTLINK" =1}) />
			<cfset results 	= results.asArray() />
			<cfset nextNum 	= numberFormat(results[1].variables.instance.nextLink, "0") />
			<cfset nextNum 	= getShorty(nextNum) />
			<cfset addOne 	= {"$inc" = {NEXTLINK = 1}} />
			<cfset strQry 	= {NEXTLINK = {"$gt" = 1}} />
			<cfset variables.instance.nextLink.update( doc = addOne, query = strQry, multi = false ) />
		<cfreturn nextNum />
	</cffunction>

	<cffunction name="getShorty" access="remote" output="false" hint="">
		<cfargument name="value" type="numeric" required="true" />
		<cfset var arrCharacters = ListToArray("a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9", " ") />
		<cfreturn FormatBaseNData( arguments.value, arrCharacters ) />
	</cffunction>

	<cffunction name="FormatBaseNData" access="public" returntype="string" output="false" hint="I take a demical value and then convert it to the number set defined by the passed in array.">
		<cfargument name="Value" 		type="numeric" 	required="true" hint="I am the numberic value that is being converted to a new radix." />
	 	<cfargument name="CharacterSet" type="array" 	required="true" hint="I am the character set used in the conversion. Each character represents the number at it's array index." />
			<cfset var LOCAL	=	{} />
 				<cfset LOCAL.EncodedValue 	= "" />
				<cfset LOCAL.Radix 			= ArrayLen( ARGUMENTS.CharacterSet ) />
				<cfset LOCAL.Value 			= ARGUMENTS.Value />
				<cfloop condition="true">
					<cfset LOCAL.Result 		= Fix( LOCAL.Value / LOCAL.Radix ) />
 					<cfset LOCAL.Remainder 		= (LOCAL.Value MOD LOCAL.Radix) />
 					<cfset LOCAL.EncodedValue 	= (
									ARGUMENTS.CharacterSet[ LOCAL.Remainder + 1 ] &
									LOCAL.EncodedValue
					) />
					<cfset LOCAL.Value 			= LOCAL.Result />
					<cfif NOT LOCAL.Value>
						<cfbreak />
					</cfif>
				</cfloop>
		<cfreturn LOCAL.EncodedValue />
	</cffunction>

	<cffunction name="InputBaseNData" access="public" returntype="string" output="false" hint="I take an encoded value and convert it back to demical based on the passed in character array.">
		<cfargument name="Value" 		type="string" 	required="true" hint="I am the encode value that is being converted back to a base 10 number." />
 		<cfargument name="CharacterSet" type="array" 	required="true" hint="I am the character set used in the conversion. Each character represents the number at it's array index." />
			<cfset var LOCAL = {} />
				<cfset LOCAL.DecodedValue = 0 />
				<cfset LOCAL.Radix = ArrayLen( ARGUMENTS.CharacterSet ) />
				<cfset LOCAL.CharacterList = ArrayToList( ARGUMENTS.CharacterSet ) />
				<cfset LOCAL.Value = Reverse( ARGUMENTS.Value ) />
				<cfset LOCAL.ValueArray = ListToArray(
											REReplace(
												LOCAL.Value,
												"(.)",
												"\1,",
												"all"
												)
											) />
				<cfloop index="LOCAL.Index" from="1" to="#ArrayLen( LOCAL.ValueArray )#" step="1">
					<cfset LOCAL.DecodedValue += (
								(ListFind( LOCAL.CharacterList, LOCAL.ValueArray[ LOCAL.Index ] ) - 1) *
								(LOCAL.Radix ^ (LOCAL.Index - 1))
					) />
				</cfloop>
		<cfreturn LOCAL.DecodedValue />
	</cffunction>

	<cffunction name="linkCount" access="remote" output="false" hint="I return the total number of links stored within the database.">
		<cfset var count = variables.instance.link.count() />
		<cfreturn numberformat(count, "0") />
	</cffunction>

</cfcomponent>