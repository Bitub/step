package de.bitub.step.express.tests.generating

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.express.Schema
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import de.bitub.step.generator.XcoreGenerator

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XCoreNestedCollection {
	
	@Inject XcoreGenerator underTest
    @Inject ParseHelper<Schema> parseHelper
    
    @Test
    def void testNestedCollection() {
    	
    	val model = parseHelper.parse(
    		'''
    		SCHEMA Test;
    		TYPE TypeWithNestedPrimitive = LIST [0:5] OF LIST [0:5] OF INTEGER;
    		END_TYPE;
    		TYPE TypeWithNestedEntity = LIST [0:5] OF LIST [0:5] OF RefEntity;
    		END_TYPE;
    		TYPE TypeWithNestedNestedEntity = LIST [0:5] OF LIST [0:5] OF LIST[0:5] OF RefEntity;
    		END_TYPE;    		
    		ENTITY RefEntity
    		END_SCHEMA;
    		ENTITY HostEntity
    		  primitive : TypeWithNestedPrimitive
    		  reference : TypeWithNestedEntity
    		  reference2: TypeWithNestedNestedEntity
    		END_SCHEMA;
    		''')
    		
    	val fsa = new InMemoryFileSystemAccess()
        underTest.doGenerate(model.eResource, fsa)
		
		assertEquals(1, fsa.textFiles.size)
		
		println(fsa.textFiles.values.findFirst[true])
    } 
}