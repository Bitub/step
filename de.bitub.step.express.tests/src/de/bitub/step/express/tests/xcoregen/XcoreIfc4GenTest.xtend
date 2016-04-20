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
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.CollectionType
import de.bitub.step.express.EnumType
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.SelectType
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static extension de.bitub.step.util.EXPRESSExtension.*
import de.bitub.step.analyzing.EXPRESSModelInfo
import de.bitub.step.express.Schema

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreIfc4GenTest extends AbstractXcoreGeneratorTest {

	val static myLog = Logger.getLogger(XcoreIfc4GenTest)

	@Inject EXPRESSInterpreter interpreter

	def protected readExpressSchema(String name) {

		val ifc4stream = class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/" + name + ".exp")
		readModel(ifc4stream)
	}
	
	def protected printInfoFor(EXPRESSModelInfo info, Schema ifc){
		myLog.level = Level.INFO

		myLog.info('''Entities in total «ifc.entity.size»''')
		myLog.info('''	Abstract entities «ifc.entity.filter[abstract].size»''')
		myLog.info(''' 	Non-abstract entities «ifc.entity.filter[!abstract].size»''')
		myLog.info('''Types in total «ifc.type.size»''')
		myLog.info(''' 	Collection types «ifc.type.filter[aggregation].size»''')
		myLog.info(''' 	Enum types «ifc.type.filter[datatype instanceof EnumType].size»''')
		myLog.info(''' 	Select types «ifc.type.filter[datatype instanceof SelectType].size»''')
		myLog.info('''		Contained referenced selects «info.reducedSelectsMap.keySet.size»''')
		myLog.info('''	Aliased builtins «ifc.type.filter[it.refersDatatype instanceof BuiltInType].size»''')
		myLog.info('''	Aliased concepts «ifc.type.filter[it.refersDatatype instanceof ReferenceType].size»''')
		myLog.info('''	Aliased aggregations «ifc.type.filter[it.refersDatatype instanceof CollectionType].size»''')

		myLog.info('''Inverse relations «info.countInverseNMReferences»''')
		myLog.info('''	Non-unique inverse relations «info.countNonUniqueReferences»''')

		val superTypeRefs = info.supertypeInverseRelations.toList
		myLog.info('''		Declaring supertype non-unique inverse relations: «superTypeRefs.size»''')

		for (a : superTypeRefs) {
			myLog.info(
				'''			- «a.hostEntity.name».«a.name» -> «a.opposite.hostEntity.name».«a.opposite.name» -> «a.opposite.
					refersConcept.name»''')
		}

		val invalidRefs = info.invalidNonuniqueInverseRelations.toList
		myLog.info('''		Unknown non-unique inverse relations: «invalidRefs.size»''')

		for (e : invalidRefs) {

			for (inv : e.value) {
				myLog.info('''			- «inv.hostEntity.name».«inv.name» - «e.key.hostEntity.name».«e.key.name»''')
			}
		}

		val incompleteSelectRefs = info.incompleteInverseSelectReferences.toList
		myLog.info('''		Incomplete inverse selects «incompleteSelectRefs.size»''')

		for (e : incompleteSelectRefs) {

			for (inv : e.value) {
				myLog.info('''			- «inv.hostEntity.name».«inv.name» - «e.key.hostEntity.name».«e.key.name»''')
			}
		}
	}

	@Test
	def void testRunInfoForIfc4() {

		val ifc4 = generateEXPRESS(readExpressSchema("IFC4"))
		val info = interpreter.process(ifc4)
		
		info.printInfoFor(ifc4)
	}
	
	@Test
	def void testRunInfoForIfc4Add1() {

		val ifc4 = generateEXPRESS(readExpressSchema("IFC4_ADD1"))
		val info = interpreter.process(ifc4)
		
		info.printInfoFor(ifc4)
	}

	@Test
	def void testRunIfc4Conversion() {
		generateXCore(readExpressSchema("IFC4"))
	}
	
	@Test
	def void testRunIfc4Add1Conversion() {
		generateXCore(readExpressSchema("IFC4_ADD1"))
	}
}
