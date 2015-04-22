package de.bitub.step.express.tests.generating

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.express.Schema
import de.bitub.step.generator.XcoreGenerator
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xcore.validation.XcoreResourceValidator
import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import org.osgi.resource.Resource
import org.eclipse.emf.common.util.URI
import java.io.CharArrayReader

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XCoreNestedCollection {
		
	@Inject XcoreResourceValidator xcoreResourceValidator	
	@Inject XcoreGenerator underTest
    @Inject ParseHelper<Schema> parseHelper
    
    @Test
    def void testNestedCollection() {
    	
    	val model = parseHelper.parse(
    		'''
    		SCHEMA XCoreNestedCollectionsTest;
    		
    		TYPE TypeWithNestedPrimitive = LIST [0:5] OF LIST [0:5] OF INTEGER;
    		END_TYPE;
    		
    		TYPE TypeWithNestedEntity = LIST [0:5] OF LIST [0:5] OF RefEntity;
    		END_TYPE;
    		
    		TYPE TypeWithNestedNestedEntity = LIST [0:5] OF LIST [0:5] OF LIST[0:5] OF RefEntity;
    		END_TYPE;    		
    		
    		
    		ENTITY HostEntity;
    		  nestedPrimitiveList : TypeWithNestedPrimitive;
    		  nestedEntityList : TypeWithNestedEntity;
    		  nestedNestedEntityList : TypeWithNestedNestedEntity;
    		END_ENTITY;
    		  
    		END_SCHEMA;
    		''')
    		
    	val fsa = new InMemoryFileSystemAccess()
        underTest.doGenerate(model.eResource, fsa)
		
		assertEquals(1, fsa.textFiles.size)
		
//		var rs = new ResourceSetImpl();
//        var xtextResource = rs.getResource(URI.createURI("test"), false)
//        xtextResource.load( fsa.readBinaryFile(fsa.binaryFiles.keySet.findFirst[it!=null] ) )
		
		println(fsa.textFiles.values.findFirst[true])
    } 
}