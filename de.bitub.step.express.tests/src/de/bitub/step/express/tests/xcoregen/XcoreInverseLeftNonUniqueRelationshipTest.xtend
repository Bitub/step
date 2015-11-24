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
			

			TYPE RightHandSingleBranch = SELECT
				(EntitySingleA
				,EntitySingleB);
			END_TYPE;

			ENTITY EntitySingleA;
			INVERSE
			  RelationA : EntitySingleC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntitySingleB;
			INVERSE
			  RelationB : EntitySingleC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntitySingleC;
			  RelationC : RightHandSingleBranch;
			END_ENTITY;			

			END_SCHEMA;
    		'''
    		
		val xcore = generateXCore(model)
		validateXCore(xcore)    		
    } 
}