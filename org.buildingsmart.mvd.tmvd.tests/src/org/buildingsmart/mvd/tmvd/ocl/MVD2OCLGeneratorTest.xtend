package org.buildingsmart.mvd.tmvd.ocl

import com.google.inject.Inject
import de.bitub.step.p21.util.IOHelper
import org.buildingsmart.ifc4.IFC4
import org.buildingsmart.ifc4.Ifc4Factory
import org.buildingsmart.ifc4.Ifc4Package
import org.buildingsmart.ifc4.IfcPropertySet
import org.buildingsmart.ifc4.IfcPropertySingleValue
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.buildingsmart.mvd.tmvd.analyzing.MVDModelInfo
import org.buildingsmart.mvd.tmvd.generator.MVD2OCLGenerator
import org.eclipse.emf.common.util.URI
import org.eclipse.ocl.OCL
import org.eclipse.ocl.ParserException
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import org.buildingsmart.mvd.tmvd.generator.ConceptTemplateTree2OCL

@RunWith(XtextRunner)
@InjectWith(TextualMVDInjectorProvider)
class MVD2OCLGeneratorTest {

	@Inject
	extension MVD2OCLGenerator generator

	@Inject
	extension org.buildingsmart.mvd.tmvd.util.IOHelper io

	var filePath = "mvd-files/mvdXML_V1-1-Final_Validation.mvdxml"

	var MvdXML mvd = null

	@Before
	def void before() {
		mvd = io.loadMvdXML(filePath) as MvdXML
		generator.init(mvd)
	}

	@Test
	def void parse() {

		var mvd = io.loadMvdXML(filePath) as MvdXML // "mvd-files/DoorHasSelfClosing.mvdxml") as MvdXML
		generator.info = new MVDModelInfo(mvd)
		val tree = new ConceptTemplateTree2OCL(mvd)

		generator.info.ruleIds.forEach [
			tree.compile(it, '''''')
		]
		tree.exprMap.values.forEach[println(it)]
	}

	@Test(expected=UnsupportedOperationException)
	def void parseSingleBooleanTermExpr() {
		var oclExpr = mvd.
			compile

		var expected = "IfcWall::allInstances() -> forAll(O_PsetName='Pset_WallCommon' and O_PName='FireRating' and O_PSingleValue.oclIsUndefined()T_PsetName='Pset_WallCommon' and T_PName='FireRating' and T_PSingleValue.oclIsUndefined())"
		var actual = oclExpr.toString

		assertEquals(expected, actual)
	}

	@Test
	def void generateOCLExprPartForConcept() {

		val conceptRoot = mvd.views.modelView.get(0).roots.conceptRoot.get(0)
		var oclExpr = conceptRoot.
			compileValidation [ // search for specific concept
				it.uuid.equals("e9941408-82a6-4c00-a397-11087e6c5d1f")
			]

		var letExpr = "let O_PName : Sequence(String) = IfcWall::allInstances().isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition.getRelatingPropertyDefinition() -> selectByType(IfcPropertySet).hasProperties -> selectByType(IfcPropertySingleValue).name"
		var expected = letExpr + "in O_PName -> forAll(i | i='ThermalTransmittance')"
		var actual = oclExpr.toString

		assertEquals(expected, actual)
	}

	@Test
	def void generateOCLExprPartForConceptTemplate() {

		val conceptRoot = mvd.views.modelView.get(0).roots.conceptRoot.get(0)
		var oclExpr = conceptRoot.concepts.concept.get(0).template.ref.compileTree("PName",
			"O_")

		var expected = "let O_PName : Sequence(String) = isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition.getRelatingPropertyDefinition() -> selectByType(IfcPropertySet).hasProperties -> selectByType(IfcPropertySingleValue).name"
		var actual = oclExpr.toString

		assertEquals(expected, actual)
	}

	@Test
	def void ifcWallRelationsWalkthroughTest() {

		var ifc4 = Ifc4Factory.eINSTANCE.createIFC4
		var ifcWall = Ifc4Factory.eINSTANCE.createIfcWall

		var selectDel = Ifc4Factory.eINSTANCE.createDelegateIfcPropertySetDefinitionIfcRelDefinesByProperties
		var relDelegate = Ifc4Factory.eINSTANCE.createDelegateIfcObjectIfcRelDefinesByProperties

		var relation = Ifc4Factory.eINSTANCE.createIfcRelDefinesByProperties
		var propertySet = Ifc4Factory.eINSTANCE.createIfcPropertySet
		var property = Ifc4Factory.eINSTANCE.createIfcPropertySingleValue

		relDelegate.ifcRelDefinesByProperties = relation
		relDelegate.relatedObjects = ifcWall
		ifcWall.isDefinedBy.add(relDelegate)

		selectDel.ifcRelDefinesByProperties = relation
		selectDel.relatingPropertyDefinition = propertySet
		relation.relatingPropertyDefinition = selectDel

		property.name = 'ThermalTransmittance'
		propertySet.hasProperties.add(property)

		ifc4.ifcWall.add(ifcWall)

		ifc4.ifcWall.forEach [ wall |

			wall.isDefinedBy.map[ifcRelDefinesByProperties].map [
				relatingPropertyDefinition.relatingPropertyDefinition
			].filter(typeof(IfcPropertySet)).map [
				hasProperties
			].flatten.filter(typeof(IfcPropertySingleValue)).forEach [
				println(it.name)
			]

		]
	}

	@Test
	def void oclExpressionEvaluationTest() {

		var ifc4 = IOHelper.load(URI.createFileURI("ifc-files/WallWithOpeningAndWindow.ifc"),
			Ifc4Package.eINSTANCE) as IFC4

		try {
			// create an OCL instance for Ecore
			val ocl = OCL.newInstance(EcoreEnvironmentFactory.INSTANCE);

			// create an OCL helper object
			val helper = ocl.createOCLHelper();

			// set the OCL context classifier
			helper.setContext(Ifc4Package.eINSTANCE.IFC4); // FIXME throws NullPointerException, WHY?
			var expr = '''
				self.ifcWalls.isDefinedBy.ifcRelDefinesByProperties.relatingPropertyDefinition.getRelatingPropertyDefinition() 
					 	-> selectByType(IfcPropertySet).hasProperties
					 	-> selectByType(IfcPropertySingleValue)
					 	-> forAll(name='ThermalTransmittance')
			'''.toString

			var query = helper.createQuery(expr);
			var eval = ocl.createQuery(query)
			var ok = eval.evaluate(ifc4) as Boolean

			assertFalse(ok)

		} catch (ParserException e) {
			// record failure to parse
			println(e.getLocalizedMessage());
		}
	}
}
