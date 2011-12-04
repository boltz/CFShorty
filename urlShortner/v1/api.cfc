<cfcomponent>
	<cfscript>
	 	variables.dbName = "cfmlShorty";
		variables.useJavaLoader = "true";
		javaloaderFactory = createObject('component','cfmongodb.core.JavaloaderFactory').init();
		mongoConfig = createObject('component','cfmongodb.core.MongoConfig').init(dbName=variables.dbName, mongoFactory=javaloaderFactory);
	
		//initialize the core cfmongodb Mongo object
		mongo = createObject('component','cfmongodb.core.Mongo').init(mongoConfig);
		application.mongo=mongo;
		application.collection="url_list";
	</cfscript>	
	<cfset Link = application.mongo.getDBCollection( "LINK" )>		
	<cfset nextLink = application.mongo.getDBCollection( "NEXTLINK" )>	
	
	
	<cfset emptystruct = structNew()>
	<cfset emptyStruct.HTTP_REFERER ="">
	<cfset emptyStruct.HTTP_USER_AGENT ="">
	<cfset emptyStruct.REMOTE_ADDR ="">
	<cfset emptyDoc = {
			KIND = "",
			MONGOID="",
			ID="",
			SHORTURL= "",
			LONGURL = "",
			STATUS = "",
			CREATED = "",
			LABEL= "",
			HTTP_REFERER="",
			HTTP_USER_AGENT="",
			REMOTE_ADDR=""
		}>
	
	<cffunction name="shortenURL">
		<cfargument name="longURL" type="string" required="true">
		<cfargument name="label" type="string" required="true" default="">
		<cfargument name="key" type="string" required="true" default="noKey">
		<cfargument name="cgi" type="struct" required="true" default="#emptystruct#">
		
		<cfset var newURL = insertURL(longURL=longURL, label=label, key=key, cgi=cgi)>
		<cfset newURL = deserializeJSON(newURL)>
		<cfreturn newURL.shortURL>
	</cffunction>
	
	<cffunction name="insert" access="remote" returnformat="JSON">
		<cfargument name="longURL" type="string" required="true">
		<cfargument name="label" type="string" required="true" default="">
		<cfargument name="key" type="string" required="true" default="noKey">
		<cfargument name="cgi" type="struct" required="true" default="#emptystruct#">
		<cfset size = link.count() + 1>
		<cfset var shortID = getNextLink()>
		
		
		<cfset doc = {
			KIND = "",
			MONGOID="",
			ID="#shortID#",
			SHORTURL= "cfml.us/#shortID#",
			LONGURL = "#arguments.longURL#",
			STATUS = "",
			CREATED = "#now()#",
			LABEL= "#LEFT(arguments.label, 255)#",
			HTTP_REFERER="#arguments.cgi.HTTP_REFERER#",
			HTTP_USER_AGENT="#arguments.cgi.HTTP_USER_AGENT#",
			REMOTE_ADDR="#arguments.cgi.REMOTE_ADDR#"
		}>
		
		<!--- Save the document --->
		<cfset var savedDoc = link.save(doc)>
		
		<!--- get the _id for our saved doc, find it and update our struct with the unique _id --->
		<cfset var id = savedDoc.toString()>
		<cfset var byID = link.findById( id )>
		<cfset byID.MONGOID = id>
		<cfset link.update(byID)>
		<cfset structDelete(byID, "_id")>
		<cfreturn serializeJSON(byID)>
	</cffunction>
	
	<cffunction name="insertURL" access="remote" returnformat="JSON">
		<cfargument name="longURL" type="string" required="true">
		<cfargument name="label" type="string" required="true" default="">
		<cfargument name="key" type="string" required="true" default="noKey">
		<cfargument name="cgi" type="struct" required="true" default="#emptystruct#">
		<cfset size = link.count() + 1>
		<cfset var shortID = getNextLink()>
		
		
		<cfset doc = {
			KIND = "",
			MONGOID="",
			ID="#shortID#",
			SHORTURL= "cfml.us/#shortID#",
			LONGURL = "#arguments.longURL#",
			STATUS = "",
			CREATED = "#now()#",
			LABEL= "#LEFT(arguments.label, 255)#",
			HTTP_REFERER="#arguments.cgi.HTTP_REFERER#",
			HTTP_USER_AGENT="#arguments.cgi.HTTP_USER_AGENT#",
			REMOTE_ADDR="#arguments.cgi.REMOTE_ADDR#"
		}>
		
		<!--- Save the document --->
		<cfset var savedDoc = link.save(doc)>
		
		<!--- get the _id for our saved doc, find it and update our struct with the unique _id --->
		<cfset var id = savedDoc.toString()>
		<cfset var byID = link.findById( id )>
		<cfset byID.MONGOID = id>
		<cfset link.update(byID)>
		<cfset structDelete(byID, "_id")>
		<cfreturn serializeJSON(byID)>
	</cffunction>
	
	
	<cffunction name="get" access="remote">
		<cfargument name="shortURL" type="string" required="true" hint="The short URL (using the shortUrl query parameter). Note: The short URL should include the protocol, e.g. http://goo.gl/fbsS">
		<cfargument name="FULL" type=string required="true" default=false hint="FULL - returns the creation timestamp and all available analytics">
		<cfargument name="ANALYTICS_CLICKS" type=string required="true" default=false hint="returns only click counts">
		<cfargument name="ANALYTICS_TOP_STRINGS" type=string required="true" default=false hint="returns only top string counts (e.g. referrers, countries, etc)">
		<cfargument name="cgi" type="struct" required="true" default="#emptystruct#">
		<cfset var results ="">
		<cfset var ID = listLast(arguments.shortURL, "/")>
		
		
		<cfset results = Link.query().$eq("ID", "#id#").find()>
		<cfset results = results.asArray()>
		<cfif arraylen(results) LT 1>
			<cfreturn serializeJSON(emptyDoc)>
		</cfif>
		<cfset results = results[1]>
		
		<cfset structDelete(results, "_id")>
		<cfreturn serializeJSON(results)>
	
	</cffunction>
	
	<cffunction name="init">
	
		<cfreturn this>
	</cffunction>
	
	<cffunction name="initializeNextLink" access="remote">
		<cfreturn "No thanks">
			<cfset nextLink.remove({})>	
		<cfset doc = {nextLink = "999"}>
		<cfset var savedDoc = nextLink.save(doc)>
		<cfset results  = nextLink.query().find(skip = 0, limit = 25, sort = {"NEXTLINK" =1})>
		<cfset results = results.asArray()>
		<cfdump var="#results#">
	</cffunction>
	
	<cffunction name="getNextLink" access="Remote">
		<cfset var results = "">
		<cfset var nextNum = "">
		<cfset results  = nextLink.query().find(skip = 0, limit = 25, sort = {"NEXTLINK" =1})>
		<cfset results = results.asArray()>
		<cfset nextNum = numberFormat(results[1].nextLink, "0")>
		<cfset nextNum = getShorty(nextNum)>
		
		<cfset addOne = {"$inc" = {NEXTLINK = 1}}>
		<cfset strQry = {NEXTLINK = {"$gt" = 1}}>
		<cfset nextLink.update( doc = addOne, query = strQry, multi = false )>	
		
		<cfreturn nextNum>
	</cffunction>

	<cffunction name="getShorty" access="remote">
		<cfargument name="value" type="numeric" required="true">
		<cfset var arrCharacters = ListToArray("a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9", " ") />
		<cfreturn FormatBaseNData( arguments.value, arrCharacters )>
	</cffunction>


<cffunction
	name="FormatBaseNData"
	access="public"
	returntype="string"
	output="false"
	hint="I take a demical value and then convert it to the number set defined by the passed in array.">
 
	<!--- Define arguments. --->
	<cfargument
		name="Value"
		type="numeric"
		required="true"
		hint="I am the numberic value that is being converted to a new radix."
		/>
 
	<cfargument
		name="CharacterSet"
		type="array"
		required="true"
		hint="I am the character set used in the conversion. Each character represents the number at it's array index."
		/>
 
	<!--- Define the local scope. --->
	<cfset var LOCAL = {} />
 
	<!--- Create the base string to be returned. --->
	<cfset LOCAL.EncodedValue = "" />
 
	<!---
		Get the length of our array. This will be our radix for
		the conversion. NOTE: Because ColdFusion arrays start at
		1, not zero, we will have to some manual offsetting when
		we perform the conversion.
	--->
	<cfset LOCAL.Radix = ArrayLen( ARGUMENTS.CharacterSet ) />
 
	<!---
		Get a local copy of our value as we will be updating it
		as we divide into it.
	--->
	<cfset LOCAL.Value = ARGUMENTS.Value />
 
	<!---
		When converting to a new radix, we need to keep dividing
		the value passed in until we hit zero (which will never
		have a remainder). However, because we always want to
		perform at least ONE division, we will break from within
		the loop if it hits zero rather than check for that
		loop conditional.
	--->
	<cfloop condition="true">
 
		<!--- Get the division result. --->
		<cfset LOCAL.Result = Fix( LOCAL.Value / LOCAL.Radix ) />
 
		<!--- Get the remainder of radix division. --->
		<cfset LOCAL.Remainder = (LOCAL.Value MOD LOCAL.Radix) />
 
		<!---
			Take the remainder and prepend the Radix-converted
			string to the encoded value. Remember, since we are
			using arrays that start at 1, we need to add one to
			this value.
		--->
		<cfset LOCAL.EncodedValue = (
			ARGUMENTS.CharacterSet[ LOCAL.Remainder + 1 ] &
			LOCAL.EncodedValue
			) />
 
		<!---
			Now that we have gotten the current, store the result
			value back into the value.
		--->
		<cfset LOCAL.Value = LOCAL.Result />
 
		<!---
			Check to see if we have any more value to divide into.
			Once we hit zero, we are out of possible remainders.
		--->
		<cfif NOT LOCAL.Value>
			<cfbreak />
		</cfif>
 
	</cfloop>
 
	<!--- Return the encoded value. --->
	<cfreturn LOCAL.EncodedValue />
</cffunction>
 
 
<cffunction
	name="InputBaseNData"
	access="public"
	returntype="string"
	output="false"
	hint="I take an encoded value and convert it back to demical based on the passed in character array.">
 
	<!--- Define arguments. --->
	<cfargument
		name="Value"
		type="string"
		required="true"
		hint="I am the encode value that is being converted back to a base 10 number."
		/>
 
	<cfargument
		name="CharacterSet"
		type="array"
		required="true"
		hint="I am the character set used in the conversion. Each character represents the number at it's array index."
		/>
 
	<!--- Define the local scope. --->
	<cfset var LOCAL = {} />
 
	<!--- Create the base number to be returned. --->
	<cfset LOCAL.DecodedValue = 0 />
 
	<!---
		Get the length of our array. This will be our radix for
		the conversion. NOTE: Because ColdFusion arrays start at
		1, not zero, we will have to some manual offsetting when
		we perform the conversion.
	--->
	<cfset LOCAL.Radix = ArrayLen( ARGUMENTS.CharacterSet ) />
 
	<!---
		Convert our character set to a list so that we can easily
		get the numeric value of our encoded digit.
	--->
	<cfset LOCAL.CharacterList = ArrayToList( ARGUMENTS.CharacterSet ) />
 
	<!---
		Reverse the string that was passed in. We are doing this
		because the right-most value is actually the smallest
		place and it will be easier for us to deal with in reverse.
	--->
	<cfset LOCAL.Value = Reverse( ARGUMENTS.Value ) />
 
	<!---
		Now, break the value up into an array so that we can more
		easily iterate over it.
	--->
	<cfset LOCAL.ValueArray = ListToArray(
		REReplace(
			LOCAL.Value,
			"(.)",
			"\1,",
			"all"
			)
		) />
 
	<!---
		Iterate over the array and convert each value to a power
		of our character set defined radix.
	--->
	<cfloop
		index="LOCAL.Index"
		from="1"
		to="#ArrayLen( LOCAL.ValueArray )#"
		step="1">
 
		<!---
			Convert the current digit and add it to the going sum
			of our conversion.
		--->
		<cfset LOCAL.DecodedValue += (
			(ListFind( LOCAL.CharacterList, LOCAL.ValueArray[ LOCAL.Index ] ) - 1) *
			(LOCAL.Radix ^ (LOCAL.Index - 1))
			) />
 
	</cfloop>
 
	<!--- Return the decoded value. --->
	<cfreturn LOCAL.DecodedValue />
</cffunction>

<cffunction name="linkCount" access="remote">
	<cfset var count = link.count()>
	<cfreturn numberformat(count, "0")>
</cffunction>

</cfcomponent>