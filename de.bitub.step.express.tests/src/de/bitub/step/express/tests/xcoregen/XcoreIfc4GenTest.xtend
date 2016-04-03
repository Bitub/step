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
import de.bitub.step.xcore.XcoreGenerator

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreIfc4GenTest extends AbstractXcoreGeneratorTest {

	@Test
	def void testRunIfc4Conversion() {

		val ifc4stream = class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/IFC4.exp")
		val ifc4Schema = readModel(ifc4stream)
		super.generateXCore(ifc4Schema)
	}

	/**
	 * Generates an Xcore model.
	 */
	override generateXCore(CharSequence schema) {

		val model = generateEXPRESS(schema)
		generator.options.put(XcoreGenerator.Options.PACKAGE, '''org.buildingsmart.«model.name.toLowerCase»''')
		val xcoreModel = generator.compileSchema(model)

		saveXcore(model.name, xcoreModel)

		return xcoreModel
	}

	@Test
	def void testRunIfc4Add1Conversion() {

		val ifc4stream = class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/IFC4_ADD1.exp")
		val ifc4Schema = readModel(ifc4stream)
		this.generateXCore(ifc4Schema)
	}
}
