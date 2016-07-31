/* 
 * Copyright (c) 2015,2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft, Sebastian Riemschüssel - initial implementation and initial documentation
 */
package de.bitub.step.express.tests.xcoregen

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.analyzing.EXPRESSInterpreter
import de.bitub.step.express.CollectionType
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

import static extension de.bitub.step.util.EXPRESSExtension.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreNestedCollectionTest extends AbstractXcoreGeneratorTest {
			
	@Inject EXPRESSInterpreter testInterpreter
		
   	val schema =
    		'''
    		SCHEMA XCoreNestedCollectionsTest;
    		
    		TYPE EntityList1D = LIST [0:?] OF EntityB;
    		END_TYPE;
    		
    		TYPE EntityList2D = LIST [0:?] OF LIST [0:?] OF EntityB;
    		END_TYPE;
    		
    		
    		TYPE EntityList3D = LIST [0:?] OF LIST [0:?] OF LIST[0:?] OF EntityB;
    		END_TYPE;    		
    		
    		
    		ENTITY EntityA;    		  
    		  List : LIST [0:?] OF EntityB;
    		  
    		  ListOfList : EntityList2D;
    		  ListOfListOfList : EntityList3D;
    		  
    		  InlineNestedEntityList : LIST[0:?] OF LIST[0:?] OF EntityB;
    		END_ENTITY;
    		
    		ENTITY EntityB;
    		END_ENTITY;
    		  
    		END_SCHEMA;
    		'''
    
    @Test
    def void testInfoNestedCollection() {
    	
    	val model = generateEXPRESS(schema)
    	val info = testInterpreter.process(model)
    	
    	val list1D = model.type.findFirst[name == "EntityList1D"]
    	val list1Dcol = list1D.datatype as CollectionType
    	val list2D = model.type.findFirst[name == "EntityList2D"]
    	val list2Dcol = list2D.datatype as CollectionType
    	val list3D = model.type.findFirst[name == "EntityList3D"]
    	val list3Dcol = list3D.datatype as CollectionType
    	    	
    	assertTrue(!(list1D.datatype as CollectionType).nestedAggregation)
    	assertEquals("EntityB[]",  info.getQualifiedReference(list1Dcol).segments.join);
    	
    	assertTrue((list2D.datatype as CollectionType).nestedAggregation)
    	assertEquals("EntityB[][]",  info.getQualifiedReference(list2Dcol).segments.join);
    	    	
    	assertTrue((list3D.datatype as CollectionType).nestedAggregation)
    	assertEquals("EntityB[][][]",  info.getQualifiedReference(list3Dcol).segments.join);
    }
    
    @Test
    def void testNestedCollection() {
    	    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)
    } 
}