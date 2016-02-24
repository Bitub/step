package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreInverseSuperTypeTest extends AbstractXcoreGeneratorTest {
	    
    @Test
    def void testXcoreInverseSuperTypeTest() {
    	
    	val model = 
    		'''
    		SCHEMA XcoreInverseSuperTypeTest;
    		
    		ENTITY EntityA
    			SUPERTYPE OF (ONEOF (EntityB));
    		END_ENTITY;
    		
    		ENTITY EntityB
    			SUBTYPE OF (EntityA);
    		INVERSE
    		  RelationB : EntityC FOR RelationC;
    		END_ENTITY;

    		ENTITY EntityC;
    		  RelationC : EntityA;
    		END_ENTITY;
    		
    		END_SCHEMA;
    		'''
    		
		val xcore = generateXCore(model)
		validateXCore(xcore)    		
    } 
}