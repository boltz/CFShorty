package net.marcesher;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Vector;
import java.util.regex.Pattern;


public class CFStrictTyper implements Typer {
	
	private final static Typer instance = new CFStrictTyper();
	//props: http://www.regular-expressions.info/floatingpoint.html
	private final Pattern isNumeric = Pattern.compile("[-\\\\+]?[0-9]*.?[0-9]+");
	public static Typer getInstance(){
		return instance;
	}
	
	private CFStrictTyper(){}
	
	/* (non-Javadoc)
	 * @see com.mongodb.Typer#toJavaType(java.lang.Object)
	 */
	@Override
	public Object toJavaType(Object value){
		if( value == null ) return "";
		
		if(value instanceof java.lang.String){
			return handleSimpleValue(value);		
		} else if ( value instanceof List ){			
			return handleArray(value);		
		} else if( value instanceof Map ){			
			return handleMap(value);		
		} 
		
		return value;
	}

	public Object handleSimpleValue(Object value) {
		String stringValue = (java.lang.String) value;
		String stringValueLowerCase = stringValue.toLowerCase();
		
		//CF booleans
		if( stringValueLowerCase.equals("false") ) return false;
		if( stringValueLowerCase.equals("true") ) return true;
		
		//CF numbers. My benchmarks show this is much faster than letting them all fall through and try/catching strings every time.
		if( isNumeric.matcher(stringValue).matches() ){
			try {
				return Integer.parseInt(stringValue);
			} catch (Exception e) {
				//nothing; it's not an int
			}
			
			try {
				return Long.parseLong(stringValue);
			} catch (Exception e){
				//nothing; it's not a long
			}
			
			try {
				return Double.parseDouble(stringValue);
			} catch (Exception e) {
				//nothing; it's not a double
			}
		}
		return value;
	}

	public Object handleArray(Object value) {
		try {
			List array = (List) value;
			Vector newArray = new Vector();
			for (Iterator iterator = array.iterator(); iterator.hasNext();) {
				newArray.add( toJavaType((Object) iterator.next()) );					
			}
			return newArray;
		} catch (Exception e) {
			System.out.println("Exception creating DBObject from Array: " +e.toString());
			return value;
		}
	}

	public Object handleMap(Object value) {
		try {
			Map map = (Map) value;
			Map ts = new TypedStruct( map, instance );
			return ts ;				
		} catch (Exception e) {
			System.out.println("Exception creating DBObject from Map: " + e.toString());
			return value;
		}
	}
	
}
