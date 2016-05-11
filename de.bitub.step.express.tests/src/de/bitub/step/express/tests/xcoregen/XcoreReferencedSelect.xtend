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
class XcoreReferencedSelect extends AbstractXcoreGeneratorTest {
		
   	val schema =
    		'''
    		SCHEMA XcoreReferencedSelect;
    		
    		(* An alternative *)
    		TYPE PersonOrCompany = SELECT (
    			Person,
    			Company,
    		);
    		END_TYPE;
    		
    		(* A person *)
    		ENTITY Person;
    		
    			Address : LIST[0:?] OF Address
    		END_ENTITY;
    		
    		(* A person *)
    		ENTITY Company;
    		
    			Address : LIST[0:?] OF Address
    		END_ENTITY;
    		
    		
    		(* An address *)
    		ENTITY Address;
    		 	
    		 	HomeOf : LIST[0:?] OF PersonOrCompany;
    		END_ENTITY;
    		
    		END_SCHEMA;
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