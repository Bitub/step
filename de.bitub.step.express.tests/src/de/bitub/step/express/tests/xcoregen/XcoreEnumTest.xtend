package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreEnumTest extends AbstractXcoreGeneratorTest {
	    
    @Test
    def void testGenerateEnum() {
    	
    	val model = 
    		'''
			SCHEMA XCoreEnumGenerator;

			TYPE PartEnum = ENUMERATION OF
				(BRACE
				,CHORD
				,COLLAR
				,MEMBER
				,MULLION
				,PLATE
				,POST
				,PURLIN
				,RAFTER
				,STRINGER
				,STRUT
				,STUD
				,USERDEFINED
				,NOTDEFINED);
			END_TYPE;

			END_SCHEMA;
    		'''
    	val xcore = generateXCore(model)
    	validateXCore(xcore)
    } 
}