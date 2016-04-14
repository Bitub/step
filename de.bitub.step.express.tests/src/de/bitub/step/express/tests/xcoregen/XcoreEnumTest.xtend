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
import de.bitub.step.express.EnumType
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

import static extension de.bitub.step.util.EXPRESSExtension.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreEnumTest extends AbstractXcoreGeneratorTest {

	/**
	 * A simple enumeration.
	 */
   	val scheme = 
    		'''
			SCHEMA XCoreEnumGenerator;

			TYPE PartEnum = ENUMERATION OF
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

			END_SCHEMA;
    		'''
    	
    @Test
	def void testInfoEnum(){
		
		val model = generateEXPRESS(scheme)		
		val enumType = model.type.findFirst[ datatype instanceof EnumType]
		
		assertTrue(!enumType.datatype.referable)
	}
	    
    @Test
    def void testGenerateEnum() {
    	
    	val xcore = generateXCore(scheme)
    	validateXCore(xcore)
    } 
}