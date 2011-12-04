package net.marcesher;

public class MongoDBOperationOnlyTyper implements Typer {

	private final static Typer instance = new MongoDBOperationOnlyTyper();
	
	public static Typer getInstance(){
		return instance;
	}
	
	@Override
	public Object toJavaType( Object value ) {
		if( value instanceof java.lang.String ){
			if( value.equals("1") || value.equals("1.0") ){
				return 1;
			}
			if( value.equals("-1") || value.equals("-1.0") ){
				return -1;
			}
			if( value.equals("0") || value.equals("0.0") ){
				return 0;
			}
		}
		
		return value;
	}

}
