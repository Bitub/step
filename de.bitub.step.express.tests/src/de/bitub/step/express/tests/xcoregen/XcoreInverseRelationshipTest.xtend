package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import javax.inject.Inject
import de.bitub.step.analyzing.EXPRESSInterpreter

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XCoreInverseRelationshipTest extends AbstractXcoreGeneratorTest {
	
	
	@Inject EXPRESSInterpreter test 

   	val schema = 
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
	
	@Test
	def void testInfoInverseRelationship() {
		
		val model = generateEXPRESS(schema)
		val info = test.process(model)
		
		assertEquals(1, info.countInverseNMReferences)
		assertEquals(0, info.countNonUniqueReferences)	
	}
    
    
    def void testGenerateInverseRelationship() {
    	

		val xcore = generateXCore(schema)
		validateXCore(xcore)    		
    } 
}