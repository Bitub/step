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
import org.apache.log4j.Logger
import de.bitub.step.express.SelectType
import de.bitub.step.analyzing.EXPRESSInterpreter
import com.google.inject.Inject

import org.apache.log4j.Level
import de.bitub.step.util.EXPRESSExtension
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.Attribute
import java.util.Set
import java.util.Map.Entry

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreIfc4GenTest extends AbstractXcoreGeneratorTest {
	    
	val static myLog = Logger.getLogger(XcoreIfc4GenTest)
	
	@Inject EXPRESSInterpreter test
	@Inject extension EXPRESSExtension
	
	def protected readIfc4() {

    	val ifc4stream = class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/IFC4.exp")
    	readModel(ifc4stream)		
	}
	
	@Test
	def void testRunInfo() {
		
		val ifc4 = generateEXPRESS(readIfc4)
		myLog.level = Level.INFO
		
		myLog.info('''Entities in total: «ifc4.entity.size»''')
		myLog.info('''Abstract entities: «ifc4.entity.filter[abstract].size»''')
		myLog.info('''Non-abstract entities: «ifc4.entity.filter[!abstract].size»''')
		myLog.info('''Types: «ifc4.type.size»''')
		myLog.info('''Select types: «ifc4.type.filter[datatype instanceof SelectType].size»''')
		myLog.info('''Aliased builtins: «ifc4.type.filter[it.refersDatatype instanceof BuiltInType].size»''')
		
		val info = test.process(ifc4)
		myLog.info('''Inverse relations: «info.countInverseNMReferences»''')
		myLog.info('''Non-unique inverse relations: «info.countNonUniqueReferences»''')
		
		val invalidRefs = info.invalidNonuniqueInverseRelationsships
		myLog.info('''Unknown non-unique inverse relations: «invalidRefs.size»''')
		
		for( e : invalidRefs) {
			
			for( inv : e.value ) {
				myLog.info(''' «inv.hostEntity.name».«inv.name» - «e.key.hostEntity.name».«e.key.name»''')			
			}
		}
		
		myLog.info('''Incomplete inverse selects: «info.incompleteInverseSelectReferences.size»''')
	}
	    
    
    def void testRunIfc4Conversion() {
    	
    	
//    	val Resource resource = resourceSet.getResource(
//		    	URI.createURI("platform:/resource/de.bitub.step.express.tests/src/de/bitub/step/express/tests/xcoregen/IFC4.exp"), true);

		generateXCore(readIfc4)    	
    } 
    
    
}