<cfset queryString = cgi.query_string>

<!--- remove empty trailing / --->
<cfif right(queryString, 1) IS "/">
	<cfset queryString = mid(queryString, 1, len(queryString)-1)>
</cfif>

<!--- remove any parameters passed in 
<cfif findNocase("?", queryString)>
	<cfset queryString = mid(queryString, 1, find("?", queryString)-1) >
</cfif>--->
<!--- get the short ID --->
<cfset ID = listLast(queryString, "/")>
<cfset get = application.api.get(shortURL=id, cgi=cgi)>
<cfset get = deserializeJSON(get)>

<!--- If no shortURL is found send to 404 --->
<cfif get.shortURL IS "">
	<cflocation url="http://cfml.us/404.html">
</cfif>

<!--- Redirect to the found long URL --->
<cflocation url="#get.longURL#">

