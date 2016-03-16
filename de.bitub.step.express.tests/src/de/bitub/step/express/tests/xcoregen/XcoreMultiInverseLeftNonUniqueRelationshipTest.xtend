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
class XcoreMultiInverseLeftNonUniqueRelationshipTest extends AbstractXcoreGeneratorTest {
	
	@Inject EXPRESSInterpreter test
	
	/**
	 * Inverse non-unique left hand relations with multiple cardinalities (here lists). The branch on right hand is modeled by
	 * a SELECT construction of two left hand entities.
	 */
	val schema = 
    		'''
			SCHEMA XCoreMultiInverseLeftNonUniqueRelationshipTest;
			
			TYPE RightHandMultiBranch = SELECT
				(EntityMultiA
				,EntityMultiB);
			END_TYPE;


			ENTITY EntityMultiA;
			INVERSE
			  RelationA : LIST [0:?] OF EntityMultiC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityMultiB;
			INVERSE
			  RelationB : LIST [0:?] OF EntityMultiC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityMultiC;
			  RelationC : LIST [0:?] OF RightHandMultiBranch;
			END_ENTITY;
			
			END_SCHEMA;
    		'''
	@Test
    def void testInfoMultiInverseLeftNonUniqueRelationship() {
    	
		val model = generateEXPRESS(schema)
		val info = test.process(model)
		
		assertEquals(1, info.countInverseNMReferences)
		assertEquals(1, info.countNonUniqueReferences)	    	
    }
	
	
    @Test
    def void testMultiInverseLeftNonUniqueRelationship() {
    	    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)    		
    } 
}