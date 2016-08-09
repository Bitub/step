/* 
 * Copyright (c) 2016  Bernold Kraft and others (Berlin, Germany).
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
import de.bitub.step.xcore.XcoreGenerator
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import de.bitub.step.xcore.XcoreMultiPartitionDelegate
import org.eclipse.xtext.naming.QualifiedName

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcorePackagePartitioningTests extends AbstractXcoreGeneratorTest {
	
	@Inject EXPRESSInterpreter underTest
	
	val testSchema = 
			'''
			SCHEMA XcorePackagePartitioningTests;
			
			(* An enumeration *)
			TYPE EnumType = ENUMERATION OF
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
						
			
			(* An inverse select branch *)
			TYPE SelectOfAB = SELECT
				(EntityA
				,EntityB);
			END_TYPE;

			ENTITY EntityA;
			  UseOfEnum : EnumType;
			INVERSE
			  RelationAToC : EntityC FOR RelationToSelect;
			END_ENTITY;
			
			ENTITY EntityB;
			INVERSE
			  RelationBToC : EntityC FOR RelationToSelect;
			END_ENTITY;
			
			ENTITY EntityC;
			  RelationToSelect : SelectOfAB;
			END_ENTITY;			

			ENTITY EntityD;
			  SimpleSelect : SelectOfAB;
			END_ENTITY;

			END_SCHEMA;
			'''
		
	@Test	
	def void test() {
		
		val xcoreFiles = generateXCore(testSchema)
		validateXCore(xcoreFiles)    				
	}

	@Before
	def void setup() {

		val packageQN = class.name.toLowerCase
		generator.options.put(XcoreGenerator.Options.PACKAGE, packageQN)
		generator.options.put(XcoreGenerator.Options.NS_URI, packageQN)
		generator.options.put(XcoreGenerator.Options.NS_PREFIX, packageQN)
		generator.partitioningDelegate = new XcoreMultiPartitionDelegate(packageQN, QualifiedName.create(packageQN), packageQN)
	}

}
