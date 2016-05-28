package de.bitub.step.express.tests.xcoregen

import com.google.inject.Inject
import de.bitub.step.EXPRESSInjectorProvider
import de.bitub.step.express.Entity
import de.bitub.step.express.Schema
import de.bitub.step.generator.util.EXPRESSSchemaBundler
import de.bitub.step.util.EXPRESSExtension
import java.util.Collection
import java.util.function.Function
import java.util.stream.Collectors
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class EXPRESSSchemaBundlerTest extends AbstractXcoreGeneratorTest {

	@Inject extension EXPRESSExtension

	EXPRESSSchemaBundler bundler = null;
	Schema ifc4Add1 = null;
	String fileName = "de/bitub/step/express/tests/xcoregen/" + "IFC4_ADD1.exp";

	String entityName = "IfcAudioVisualAppliance"; //"IfcElement"//

	@Before
	def void before() {

		val ifc4SchemaText = readModel(class.classLoader.getResourceAsStream(fileName))

		ifc4Add1 = ifc4SchemaText.generateEXPRESS
		bundler = new EXPRESSSchemaBundler(ifc4Add1);
	}

	def searchExecAndPrintCollection(String entityName, Function<Entity, Collection<?>> run) {
		entityName.searchOnly.ifPresent[e|run.apply(e).forEach[entity|System.out.println((entity as Entity).name)]];
	}

	def searchOnly(String entityName) {
		ifc4Add1.entity.stream.filter[e|e.name.equalsIgnoreCase(entityName)].findFirst;
	}

//	@Test
//	def void testInverseComponent() {
//		entityName.searchExecAndPrintCollection[e|bundler.inverseComponent(e)]
//	}

//	@Test
//	def void testInverseEntities() {
//		entityName.searchExecAndPrintCollection[e|bundler.inverseEntitiesInInheritanceChain(e)]
//	}

	@Test
	def void testAllSuperTypes() {
		entityName.searchExecAndPrintCollection[e|bundler.allSuperTypes(e)]
	}

//	@Test
//	def testAllInverseEntitySets() {
//
//		val graph = GraphFactory.eINSTANCE.createGraph
//
//		// create all graph nodes (entities)
//		ifc4Add1.entity.map [ entity |
//			val node = GraphFactory.eINSTANCE.createVertex;
//			node.name = entity.name
//			node.add(NodeTypeEnum.ENTITY);
//			node.setGraph(graph);
//			node
//		].toMap[it.name];
//
//		ifc4Add1.entity.forEach [ entity |
//			val from = graph.getById(entity.name)
//			entity.getDeclaringInverseAttribute.forEach [ inverseAttr |
//				val to = graph.getById((inverseAttr.opposite.eContainer as Entity).name)
//				from.createEdgeTo(to, EdgeTypeEnum.INVERSE);
//			];
//		]
//
//		ifc4Add1.entity.forEach [ entity |
//			val sub = graph.getById(entity.name)
//			entity.getDeclaringInverseAttribute.forEach [ inverseAttr |
//				val supers = graph.getById((inverseAttr.opposite.eContainer as Entity).name)
//				sub.createEdgeTo(supers, EdgeTypeEnum.EXTENDS);
//			];
//		]
//
//		GraphConstructionTest.storeAsXMI(graph);
//	}

	def void testAllConnected() {
		entityName.searchOnly.ifPresent[e|
			{
				val rootedEntities = bundler.family(e);

				System.out.println(rootedEntities.size)
				rootedEntities.forEach[entity|System::out.println(entity)]

				val resourceEntities = ifc4Add1.entity.stream().filter(entity|!rootedEntities.contains(entity)).
					collect(Collectors.toList());

				System.out.println(resourceEntities.size)
				resourceEntities.forEach[entity|System.out.println(entity)]
			}]

	}
}
