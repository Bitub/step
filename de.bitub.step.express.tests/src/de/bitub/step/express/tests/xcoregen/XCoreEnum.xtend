package de.bitub.step.express.tests.xcoregen

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.express.Schema
import de.bitub.step.generator.XcoreGenerator
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XCoreEnum {
	
	@Inject XcoreGenerator underTest
    @Inject ParseHelper<Schema> parseHelper
    
    @Test
    def void testGenerateEnum() {
    	
    	val model = parseHelper.parse(
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
    		''')
    		
    	val fsa = new InMemoryFileSystemAccess()
        underTest.doGenerate(model.eResource, fsa)
		
		assertEquals(1, fsa.textFiles.size)		
		
		//ResourcesPlugin.getWorkspace().getRoot().getLocationURI().toASCIIString()
		
		println(fsa.textFiles.values.findFirst[true])
    } 
}