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
import de.bitub.step.xcore.XcoreGenerator
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreIfc2x3GenTest extends AbstractXcoreGeneratorTest {

	@Inject EXPRESSInterpreter interpreter

	def protected readExpressSchema(String name) {

		val ifc4stream = class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/ifc/" + name + ".exp")
		readModel(ifc4stream)
	}
	

	@Test
	def void testRunInfoForIfc2x3() {

		val ifc4 = generateEXPRESS(readExpressSchema("IFC2X3_TC1"))
		val info = interpreter.process(ifc4)
		
		info.printInfoFor(ifc4)
	}
	
		
	@Test
	def void testRunIfc2X3Conversion() {
		generatedXcoreFilename = "ifc2x3.exp.xcore"
		generateXCore(readExpressSchema("IFC2X3_TC1"))
	}
		
	
	@Before
	def void setup() {
	
		generator.options.put(XcoreGenerator.Options.COPYRIGHT_NOTICE, 
			'''Copyright (c) 2016 Bernold Kraft and others. (Berlin, Germany).
			\nAll rights reserved. This program and the accompanying materials
			\nare made available under the terms of the Eclipse Public License v1.0
			\nwhich accompanies this distribution, and is available at
			\n\nhttp://www.eclipse.org/legal/epl-v10.html
			\n\nInitial contributors:\n\n - Bernold Kraft,Sebastian Riemschüssel,Torsten Krämer''')
		generator.options.put(XcoreGenerator.Options.NS_URI, "http://www.bitub.de/IFC2x3")
		generator.options.put(XcoreGenerator.Options.PACKAGE, "org.buildingsmart.ifc2x3")
		generator.options.put(XcoreGenerator.Options.SOURCE_FOLDER, "/org.buildingsmart.ifc2x3/src-gen")
	}
}
