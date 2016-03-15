package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.generator.util.EXPRESSSchemaBundler
import java.io.PrintWriter
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class CsvTest extends AbstractXcoreGeneratorTest {

	EXPRESSSchemaBundler bundler = null;

	def PrintWriter pr(String fileName) {
		new PrintWriter(fileName)
	}

	@Before
	def void before() {

		val ifc4SchemaText = readModel(
			class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/" + "IFC4_ADD1.exp"))

		bundler = new EXPRESSSchemaBundler(parseSchema(ifc4SchemaText));
	}

	@Test
	def void printNodesCSV() {

		val pr = pr("./csv/nodes.csv")

		pr.println(":ID,:LABEL,Name") // header

		bundler.graph.vertices.forEach [ vertex |
			pr.println(String.format("%s,%s,%s", vertex.name, vertex.name + ";" + vertex.labels.join(";"), vertex.name))
		]
		pr.close
	}

	@Test
	def void printEdgesCSV() {

		val pr = pr("./csv/edges.csv")

		pr.println(":START_ID,:END_ID,:TYPE,Name"); // header

		bundler.graph.vertices.forEach [ vertex |
			vertex.outgoing.forEach [ edge |
				var name = edge.getProperty("name")
				if (name == null) {
					name = ""
				}
				pr.println(
					String.format("%s,%s,%s,%s", edge.tail.name, edge.head.name, edge.edgeType.toUpperCase, name))
			]
		]
		pr.close
	}
}
