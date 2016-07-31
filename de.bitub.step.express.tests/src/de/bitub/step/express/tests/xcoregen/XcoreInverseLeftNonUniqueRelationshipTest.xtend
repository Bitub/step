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
import de.bitub.step.analyzing.EXPRESSInterpreter
import javax.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreInverseLeftNonUniqueRelationshipTest extends AbstractXcoreGeneratorTest {

	@Inject EXPRESSInterpreter test

	/**
	 * Inverse non-unique left hand relations. The branch on right hand is modeled by
	 * a SELECT construction of two left hand entities.
	 */
    val schema = 
    		'''
			SCHEMA XCoreInverseLeftNonUniqueRelationshipTest;
			

			TYPE SelectOfAB = SELECT
				(EntitySingleA
				,EntitySingleB);
			END_TYPE;

			ENTITY EntitySingleA;
			INVERSE
			  RelationAToC : EntitySingleC FOR RelationToSelect;
			END_ENTITY;
			
			ENTITY EntitySingleB;
			INVERSE
			  RelationBToC : EntitySingleC FOR RelationToSelect;
			END_ENTITY;
			
			ENTITY EntitySingleC;
			  RelationToSelect : SelectOfAB;
			END_ENTITY;			

			END_SCHEMA;
    		'''
	
	@Test
    def void testInfoInverseLeftNonUniqueRelationship() {
    	
		val model = generateEXPRESS(schema)
		val info = test.process(model)
		
		assertEquals(0, info.countInverseNMReferences)
		assertEquals(1, info.countNonUniqueReferences)	    	
    }
	
    @Test
    def void testInverseLeftNonUniqueRelationship() {
    	    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)    		
    } 
}