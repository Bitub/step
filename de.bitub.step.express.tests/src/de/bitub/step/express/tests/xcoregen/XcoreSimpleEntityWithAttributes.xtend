package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreSimpleEntityWithAttributes extends AbstractXcoreGeneratorTest {
	    
    @Test
    def void testSimpleRelationship() {
    	
    	val model = 
    		'''
    		SCHEMA XcoreSimpleEntityWithAttributes;
    		
    		TYPE EnumA = ENUMERATION OF (
    			Value1, Value2);
    		END_TYPE;
    		
    		TYPE Alias = STRING;
    		END_TYPE;
    		
    		ENTITY ChildEntity;
    		END_ENTITY;
    		
    		ENTITY Entity;
    		  State : EnumA;
    		  Label : Alias;
    		  Value : INTEGER;
    		  Field : LIST[0:?] OF INTEGER;
    		  Child : ChildEntity;
    		DERIVE
    		  DState : EnumA := ?;
    		  DLabel : Alias := ?;
    		  DValue : INTEGER := ?;
    		  DField : LIST[0:?] OF INTEGER := ?;
    		  DChild : ChildEntity := ?;
    		END_ENTITY;

    		END_SCHEMA;
    		'''
    		
		val xcore = generateXCore(model)
		validateXCore(xcore)    		
    } 
}