/* 
 * Copyright (c) 2015,2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */
 
package de.bitub.step.express.tests.xcoregen

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.analyzing.EXPRESSInterpreter
import de.bitub.step.util.EXPRESSExtension
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreInverseSuperTypeTest extends AbstractXcoreGeneratorTest {

	@Inject EXPRESSInterpreter test

	/**
	 * Inverse supertype EntityA <- EntityB => EntityC => EntityA.
	 */
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
		
		val a = model.entity.findFirst[name == "EntityA"]
		val b = model.entity.findFirst[name == "EntityB"]
		val c = model.entity.findFirst[name == "EntityC"]
		
		assertTrue(EXPRESSExtension.isSupertypeOf(a,b))
		assertTrue(EXPRESSExtension.isSubtypeOf(b,a))	
		assertTrue(info.isSupertypeOppositeDirectedRelation(c.attribute.findFirst[true])) 		   
    }
	    
    @Test
    def void testXcoreInverseSuperTypeTest() {
    	
    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)    		
    } 
}