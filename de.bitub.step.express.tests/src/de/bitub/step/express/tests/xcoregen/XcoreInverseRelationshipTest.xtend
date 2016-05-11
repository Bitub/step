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
    
    
    @Test
    def void testGenerateInverseRelationship() {
    	

		val xcore = generateXCore(schema)
		validateXCore(xcore)    		
    } 
}