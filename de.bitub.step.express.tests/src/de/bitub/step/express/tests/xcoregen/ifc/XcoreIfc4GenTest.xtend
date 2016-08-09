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
package de.bitub.step.express.tests.xcoregen.ifc

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.analyzing.EXPRESSInterpreter
import de.bitub.step.xcore.XcoreGenerator
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import de.bitub.step.express.tests.xcoregen.AbstractXcoreGeneratorTest
import de.bitub.step.xcore.XcoreDefaultPartitionDelegate
import de.bitub.step.xcore.XcorePackageDescriptor
import org.eclipse.xtext.naming.QualifiedName

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreIfc4GenTest extends AbstractXcoreGeneratorTest {


	@Inject EXPRESSInterpreter interpreter

	def protected readExpressSchema(String name) {

		val ifc4stream = class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/ifc/" + name + ".exp")
		readModel(ifc4stream)
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
		//generatedXcoreFilename = "ifc4.exp.xcore"
		generateXCore(readExpressSchema("IFC4"))
	}
			
	@Test
	def void testRunIfc4Add1Conversion() {
		//generatedXcoreFilename = "ifc4_add1.exp.xcore"
		generateXCore(readExpressSchema("IFC4_ADD1"))
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
			
		generator.options.put(XcoreGenerator.Options.NS_URI, "http://www.bitub.de/IFC4")
		generator.options.put(XcoreGenerator.Options.PACKAGE, "org.buildingsmart.ifc4")
		generator.options.put(XcoreGenerator.Options.SOURCE_FOLDER, "/org.buildingsmart.ifc4/src-gen")
		
		generator.partitioningDelegate = new IfcPartitioningDelegate(new XcorePackageDescriptor() {
			
			override getNsURI() {
				"http://www.bitub.de/IFC4"
			}
			
			override getName() {
				"ifc4"
			}
			
			override getBasePackage() {
				QualifiedName.create("org.buildingsmart.ifc4".split("\\."))
			}
			
		})
	}
}
