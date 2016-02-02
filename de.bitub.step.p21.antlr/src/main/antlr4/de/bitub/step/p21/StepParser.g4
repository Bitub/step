/**
 * This is a grammar for parsing exchange files for
 * data models specified in EXPRESS. Its especially for
 * the exchange file of the IFC2x3 specification.
 * 
 * @author Sebastian Riemschüssel
 * 
 */
parser grammar StepParser;

 options {
 	tokenVocab = StepLexer;
 }

 @members {
  	private boolean isVersion3 = true;
  	
 	private List<Integer> entitiyKeys = new ArrayList<Integer>();
 	private List<Integer> forwardReferences = new ArrayList<Integer>();
 	private List<Integer> backwardReferences = new ArrayList<Integer>();
}

/** 
 * This is the starting rule for an .ifc file 
 * 
 */
 exchangeFile
 :
 	ISO_10303_21 headerSection dataSection+ END_ISO_10303_21 EOF
 	|
 	{isVersion3}?

 	ISO_10303_21 headerSection dataSection+ END_ISO_10303_21 EOF
 ;

 /** 
  * HEADER section of IFC file
  * 
  * TODO:
  *  - filter headerEntityList if version is not 3
  */
 headerSection
 :
 	HEADER fileDesciption = headerEntity
 	{
	 	// description -> list of STRING
	 	// implementation level -> STRING
 	}

 	fileName = headerEntity
 	{
 		
 	}

 	fileSchema = headerEntity
 	{
 		
 	}

 	headerEntityList? ENDSEC
 ;

 /**
 * Followed by file_population, section_language and section_context.
 * In the end their can follow user defined header section entities.
 */
 headerEntityList
 :
 	headerEntity+
 ;

 headerEntity
 :
 	keyword LPAREN parameterList? RPAREN SEMICOLON
 	{
		// multiple data sections only allowed when level is 3
		//
		if($keyword.text.equals("FILE_DESCRIPTION")){
			
			String[] implLevelDetails = $parameterList.ctx.parameters.get(1).getText().split(";");
        	if(Integer.parseInt(implLevelDetails[0]) == 3){
        		isVersion3 = true;
        	}
			System.out.println("Version: " + implLevelDetails[0]);
		}				
	}

 ;

 parameter
 :
 	(
 		typed
 		| untyped
 		| omitted
 	)
 ;

 /**
 * Instance of a SELECT type
 */
 typed
 :
 	keyword LPAREN parameter RPAREN
 ;

 untyped
 :
 	DERIVED
 	| integer
 	| real
 	| string
 	| ENTITY_INSTANCE_NAME
 	| ENUMERATION
 	| BINARY
 	| list
 ;

 omitted
 :
 	OMITTED
 ;

 string
 :
 	STRING
 ;

 real
 :
 	REAL
 ;

 integer
 :
 	INTEGER
 ;

 list
 :
 	LPAREN
 	(
 		parameters += parameter
 		(
 			COMMA parameters += parameter
 		)*
 	)? RPAREN
 ;

 /** 
 * DATA section of IFC file
 * 
 * TODO:
 *  - use predicate to filter parameterList if version is not 3
 */
 dataSection
 :
 	DATA
 	(
 		LPAREN parameterList RPAREN
 	)? SEMICOLON entityInstanceList ENDSEC
 ;

 entityInstanceList
 :
 	entities += entityInstance*
 ;

 entityInstance
 :
 	id = ENTITY_INSTANCE_NAME EQUAL simpleRecord SEMICOLON # simpleEntityInstance
 	| id = ENTITY_INSTANCE_NAME EQUAL subsuperRecord SEMICOLON #
 	complexEntityInstance
 ;

 subsuperRecord
 :
 	LPAREN simpleRecordList RPAREN
 ;

 simpleRecordList
 :
 	simpleRecords += simpleRecord+
 ;

 simpleRecord
 :
 	keyword LPAREN parameterList? RPAREN
 ;

 parameterList
 :
 	parameters += parameter
 	(
 		COMMA parameters += parameter
 	)*
 ;

 keyword
 :
 	(
 		USER_DEFINED_KEYWORD
 		| STANDARD_KEYWORD
 	)
 ;
 