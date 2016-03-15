package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.analyzing.EXPRESSInterpreter
import javax.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreInverseLeftNonUniqueRelationshipTest extends AbstractXcoreGeneratorTest {

	@Inject EXPRESSInterpreter test

    val schema = 
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
	
	@Test
    def void testInfoInverseLeftNonUniqueRelationship() {
    	
		val model = generateEXPRESS(schema)
		val info = test.process(model)
		
		assertEquals(0, info.countInverseNMReferences)
		assertEquals(1, info.countNonUniqueReferences)	    	
    }
	
    @Test
    def void testInverseLeftNonUniqueRelationship() {
    	    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)    		
    } 
}