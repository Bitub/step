package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreInverseLeftNonUniqueRelationshipTest extends AbstractXcoreGeneratorTest {
	
    @Test
    def void testInverseLeftNonUniqueRelationship() {
    	
    	val model = 
    		'''
			SCHEMA XCoreInverseLeftNonUniqueRelationshipTest;
			
			TYPE RightHandBranch = SELECT
				(EntityA
				,EntityB);
			END_TYPE;

			ENTITY EntityA;
			INVERSE
			  RelationA : LIST [0:?] OF EntityC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityB;
			INVERSE
			  RelationB : LIST [0:?] OF EntityC FOR RelationC;
			END_ENTITY;
			
			
			ENTITY EntityC;
			  RelationC : LIST [0:?] OF RightHandBranch;
			END_ENTITY;

			END_SCHEMA;
    		'''
    		
		val xcore = generateXCore(model)
		validateXCore(xcore)    		
    } 
}