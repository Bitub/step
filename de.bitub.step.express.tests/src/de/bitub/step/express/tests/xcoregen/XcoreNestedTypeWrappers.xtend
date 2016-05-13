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

import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.express.CollectionType
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

import static extension de.bitub.step.util.EXPRESSExtension.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreNestedTypeWrappers extends AbstractXcoreGeneratorTest {
		
   	val schema =
    		'''
    		SCHEMA XcoreNestedTypeWrappers;

    		
    		TYPE Integer2D = LIST [0:?] OF LIST [0:?] OF INTEGER;
    		END_TYPE;
    		
    		
    		ENTITY EntityA;
    		  Integer2D : Integer2D;
    		  Integer1D : ARRAY [0:?] OF INTEGER;
    		END_ENTITY;
    		
    		END_SCHEMA;
    		'''
    
    @Test
    def void testInfoNestedCollection() {
    	
    	val model = generateEXPRESS(schema)
    	val typeWithNestedEntityList = model.type.findFirst[name == "Integer2D"]
    	
    	val cType = typeWithNestedEntityList.datatype as CollectionType
    	
    	assertTrue(cType.nestedAggregation)
    }
    
    @Test
    def void testNestedCollection() {
    	    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)
    } 
}