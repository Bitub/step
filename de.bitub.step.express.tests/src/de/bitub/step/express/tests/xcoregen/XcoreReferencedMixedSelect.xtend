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
class XcoreReferencedMixedSelect extends AbstractXcoreGeneratorTest {
		
   	val schema =
    		'''
    		SCHEMA XcoreReferencedMixedSelect;
    		
    		TYPE SimpleDoubleA = REAL;
    		END_TYPE;

    		TYPE SimpleDoubleB = REAL;
    		END_TYPE;

    		TYPE SimpleIntA = INTEGER;
    		END_TYPE;
    		
    		TYPE IntArray1 = ARRAY[0:?] OF INTEGER;
    		END_TYPE;    		

    		TYPE IntArray2 = ARRAY[0:?] OF ARRAY[0:?] OF INTEGER;
    		END_TYPE;    		

    		TYPE InlinePerson1D = LIST[0:?] OF Person;
    		END_TYPE;

    		TYPE InlinePerson2D = LIST[0:?] OF LIST[0:?] OF Person;
    		END_TYPE;

    		(* A really wired alternative *)
    		TYPE SomethingSelect = SELECT (
    			Person,
    			SimpleDoubleA,
    			SimpleDoubleB,
    			SimpleIntA,
    			IntArray1,
    			IntArray2,
    			InlinePerson1D,
    			InlinePerson2D
    		);
    		END_TYPE;
    		
    		
    		ENTITY Person;
    		END_ENTITY;

    		ENTITY HomeOfEverything;
    			Something : SomethingSelect;
    		END_ENTITY;
    		    		    		
    		'''
    
    @Test
    def void testInfoNestedCollection() {
    	
    }
    
    @Test
    def void testNestedCollection() {
    	    		
		val xcore = generateXCore(schema)
		validateXCore(xcore)
    } 
}