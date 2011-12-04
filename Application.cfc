<cfcomponent output="true">
<cfset this.name = "cfmlShorty">
<cfset this.ApplicationTimeOut = createTimeSpan(0,2,0,0)>


<cffunction name="onApplicationStart">
	<cfset application.dsn = "cfmlShorty">
	<cfset application.api = createObject("component","urlShortner.v1.api").init()>
	
</cffunction>


<cffunction name="onRequestStart">
	<cfset var insert = "">
	<cfparam name="url.label" default="">
	<cfif structKeyExists(url,"kickstart")>
		<cfset onApplicationStart()>
	</cfif>
	<cfif structKeyExists(url,"url")>
		<cfset insert = application.api.insert(longURL=url.url, cgi=cgi, label=url.label)>
		<cfset insert = deserializeJSON(insert)>
		<cfoutput>http://#insert.shortURL#</cfoutput>
		<cfabort>
		<cfreturn>
	</cfif>
	<cfif structKeyExists(url, "shortURL")>
		<cfset var get ="">
		<cfset get = application.api.get(shortURL=url.shortURL, cgi=cgi)>
		<cfdump var="#get#">
	</cfif>
</cffunction>

<cffunction name="onApplicationStop">
	<cfset application.mongo.close()>
	<cfreturn>
</cffunction>



</cfcomponent>
