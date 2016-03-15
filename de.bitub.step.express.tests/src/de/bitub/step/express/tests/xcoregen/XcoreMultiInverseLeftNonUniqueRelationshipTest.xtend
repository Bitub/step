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
class XcoreMultiInverseLeftNonUniqueRelationshipTest extends AbstractXcoreGeneratorTest {
	
	@Inject EXPRESSInterpreter test
	
	val schema = 
    		'''
			SCHEMA XCoreMultiInverseLeftNonUniqueRelationshipTest;
			
			TYPE RightHandMultiBranch = SELECT
				(EntityMultiA
				,EntityMultiB);
			END_TYPE;


			ENTITY EntityMultiA;
			INVERSE
			  RelationA : LIST [0:?] OF EntityMultiC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityMultiB;
			INVERSE
			  RelationB : LIST [0:?] OF EntityMultiC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityMultiC;
			  RelationC : LIST [0:?] OF RightHandMultiBranch;
			END_ENTITY;
			
			END_SCHEMA;
    		'''
	@Test
    def void testInfoMultiInverseLeftNonUniqueRelationship() {
    	
		val model = generateEXPRESS(schema)
		val info = test.process(model)
		
		assertEquals(1, info.countInverseNMReferences)
		assertEquals(1, info.countNonUniqueReferences)	    	
    }
	
	
    @Test
    def void testMultiInverseLeftNonUniqueRelationship() {
    	    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)    		
    } 
}