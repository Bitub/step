package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreSimpleRelationshipTest extends AbstractXcoreGeneratorTest {
	    
    @Test
    def void testSimpleRelationship() {
    	
    	val model = 
    		'''
    		SCHEMA XCoreSimpleInverseRelationsTest;
    		
    		ENTITY EntityA;
    		  RelationA : EntityB;
    		END_ENTITY;
    		
    		ENTITY EntityB;
    		  RelationB : EntityA;
    		END_ENTITY;

    		ENTITY EntityC;
    		INVERSE				
    		  RelationC : EntityD FOR RelationD;
    		END_ENTITY;
    		
    		ENTITY EntityD;
    		  RelationD : EntityC;
    		END_ENTITY;

    		ENTITY EntityE;
    		INVERSE
    		  RelationE : SET [0:?] OF EntityF FOR RelationF;
    		END_ENTITY;
    		
    		ENTITY EntityF;
    		  RelationF : EntityE;
    		END_ENTITY;
    		    		
    		END_SCHEMA;
    		'''
    		
		val xcore = generateXCore(model)
		validateXCore(xcore)    		
    } 
}