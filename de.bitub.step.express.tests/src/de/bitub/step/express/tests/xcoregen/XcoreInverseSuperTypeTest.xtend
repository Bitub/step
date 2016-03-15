package de.bitub.step.express.tests.xcoregen

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.analyzing.EXPRESSInterpreter
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreInverseSuperTypeTest extends AbstractXcoreGeneratorTest {


	@Inject EXPRESSInterpreter test

    val schema = 
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
    		
    @Test
    def void testInfoInverseSuperTypeTest() {
    	
		val model = generateEXPRESS(schema)
		val info = test.process(model)
		
		assertEquals(0, info.countInverseNMReferences)
		assertEquals(1, info.countNonUniqueReferences)	 		   
    }
	    
    @Test
    def void testXcoreInverseSuperTypeTest() {
    	
    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)    		
    } 
}