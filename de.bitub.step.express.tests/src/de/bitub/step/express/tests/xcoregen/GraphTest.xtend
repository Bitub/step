package de.bitub.step.express.tests.xcoregen

import de.bitub.riemi.graph.main.GraphConstructionTest
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.express.Schema
import de.bitub.step.generator.util.EXPRESSSchemaBundler
import java.io.PrintWriter
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class GraphTest extends AbstractXcoreGeneratorTest {

	Schema ifc4Add1 = null;
	EXPRESSSchemaBundler bundler = null;

	def PrintWriter pr(String fileName) {
		new PrintWriter(fileName)
	}

	@Before
	def void loadSchema() {
		val fileName = "de/bitub/step/express/tests/xcoregen/" + "IFC4_ADD1.exp";
		ifc4Add1 = parseSchema(readModel(class.classLoader.getResourceAsStream(fileName)))
		bundler = new EXPRESSSchemaBundler(ifc4Add1);
	}

	@Test
	def void testNodeCreation() {

		val graph = bundler.graph

		Assert.assertEquals((768 /* entities */ + 206 /* enums */ + 60 /* selects */), graph.vertices.size)
		GraphConstructionTest.storeAsXMI(graph);
	}

	@Test
	def testInverseComponentCreation() {
		newArrayList("IfcProperty", "IfcElement").forEach [
			val set = bundler.inverseComponent(it)
			set.forEach [
				System::out.println(it)
			]
			System::out.println(set.size)
		]
	}

}
