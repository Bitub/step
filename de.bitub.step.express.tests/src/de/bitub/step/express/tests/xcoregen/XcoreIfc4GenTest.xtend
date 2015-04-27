package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreIfc4GenTest extends AbstractXcoreGeneratorTest {
	    
    @Test
    def void testRunIfc4Conversion() {
    	
    	val ifc4stream = class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/IFC4.exp")
    	val ifc4Schema = readModel(ifc4stream)
    	
//    	val Resource resource = resourceSet.getResource(
//		    	URI.createURI("platform:/resource/de.bitub.step.express.tests/src/de/bitub/step/express/tests/xcoregen/IFC4.exp"), true);

		generateXCore(ifc4Schema)    	
    } 
}