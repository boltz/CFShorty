<cfcomponent output="false" extends="AbstractFactory" hint="Uses createObject('java', path) to create Java objects. Objects of the requested type must be in CF's classpath">

	<cffunction name="getObject" output="false" access="public" returntype="any" hint="Creates a Java object">
    	<cfargument name="path" type="string" required="true"/>
		<cfreturn createObject("java", path)>
    </cffunction>

</cfcomponent>