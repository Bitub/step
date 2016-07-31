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
	val schema_noSuper = 
    		'''
			SCHEMA XCoreSelectRelationTestNoSuper;
			
			TYPE SelectAB = SELECT
				(EntityA
				,EntityB);
			END_TYPE;
			
			ENTITY EntityA;
			INVERSE
			  RelationA : LIST [0:?] OF EntityC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityB;
			INVERSE
			  RelationB : LIST [0:?] OF EntityC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityC;
			  RelationC : LIST [0:?] OF SelectAB;
			END_ENTITY;
			
			END_SCHEMA;
    		'''
    		
	val schema_hasSuper = 
    		'''
			SCHEMA XCoreSelectRelationTestWithSuper;
			
			TYPE SelectAB = SELECT
				(EntityA
				,EntityB);
			END_TYPE;
			
			ENTITY EntitySuperAB
				SUPERTYPE OF (ONEOF (EntityA,EntityB));
			END_ENTITY;


			ENTITY EntityA
				SUBTYPE OF (EntitySuperAB);
			INVERSE
			  RelationA : LIST [0:?] OF EntityC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityB
				SUBTYPE OF (EntitySuperAB);
			INVERSE
			  RelationB : LIST [0:?] OF EntityC FOR RelationC;
			END_ENTITY;
			
			ENTITY EntityC;
			  RelationC : LIST [0:?] OF SelectAB;
			END_ENTITY;
			
			END_SCHEMA;
    		'''
    		
	@Test
    def void testInfo_XCoreSelectRelationTestNoSuper() {
    	
		val model = generateEXPRESS(schema_noSuper)
		val info = test.process(model)
		
		assertEquals(2, info.countInverseNMReferences)
		assertEquals(1, info.countNonUniqueReferences)	    	
    }

	@Test
    def void testInfo_XCoreSelectRelationTestHasSuper() {
    	
		val model = generateEXPRESS(schema_hasSuper)
		val info = test.process(model)
		
		assertEquals(2, info.countInverseNMReferences)
		assertEquals(1, info.countNonUniqueReferences)	    	
    }
	
	
    @Test
    def void testGenerate_XCoreSelectRelationTestNoSuper() {
    	    		
		val xcore = generateXCore(schema_noSuper)
		validateXCore(xcore)    		
    }
    
    @Test
    def void testGenerate_XCoreSelectRelationTestHasSuper() {
    	    		
		val xcore = generateXCore(schema_hasSuper)
		validateXCore(xcore)    		
    } 
     
}