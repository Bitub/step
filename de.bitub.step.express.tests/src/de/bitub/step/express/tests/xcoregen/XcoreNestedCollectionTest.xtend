package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreNestedCollectionTest extends AbstractXcoreGeneratorTest {
		
    
    @Test
    def void testNestedCollection() {
    	
    	val model =
    		'''
    		SCHEMA XCoreNestedCollectionsTest;
    		
    		TYPE TypeWithNestedPrimitive = LIST [0:?] OF LIST [0:?] OF INTEGER;
    		END_TYPE;

    		TYPE TypeWithEntityList = LIST [0:?] OF EntityB;
    		END_TYPE;
    		
    		TYPE TypeWithNestedEntityList = LIST [0:?] OF LIST [0:?] OF EntityB;
    		END_TYPE;
    		
    		TYPE TypeWithNestedNestedEntityList = LIST [0:?] OF LIST [0:?] OF LIST[0:?] OF EntityB;
    		END_TYPE;    		
    		
    		
    		ENTITY EntityA;
    		  NestedPrimitiveList : TypeWithNestedPrimitive;
    		  EntityList : TypeWithEntityList;
    		  NestedEntityList : TypeWithNestedEntityList;
    		  NestedNestedEntityList : TypeWithNestedNestedEntityList;
    		  InlineNestedEntityList : LIST[0:?] OF LIST[0:?] OF EntityB;
    		END_ENTITY;
    		
    		ENTITY EntityB;
    		END_ENTITY;
    		  
    		END_SCHEMA;
    		'''
    		
		val xcore = generateXCore(model)
		validateXCore(xcore)    		
    } 
}