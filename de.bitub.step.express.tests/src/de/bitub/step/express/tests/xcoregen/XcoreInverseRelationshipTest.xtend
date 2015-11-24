package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XCoreInverseRelationshipTest extends AbstractXcoreGeneratorTest {
	
    
    @Test
    def void testInverseRelationship() {
    	
    	val model = 
    		'''
    		SCHEMA XCoreInverseRelationshipTest;
    		
    		ENTITY EntityA;
    		INVERSE
    		  RelationA : LIST [0:?] OF EntityB FOR RelationB;
    		END_ENTITY;
    		
    		ENTITY EntityB;
    		  RelationB : LIST [0:?] OF EntityA;
    		END_ENTITY;

    		    		
    		END_SCHEMA;
    		'''

		val xcore = generateXCore(model)
		validateXCore(xcore)    		
    } 
}