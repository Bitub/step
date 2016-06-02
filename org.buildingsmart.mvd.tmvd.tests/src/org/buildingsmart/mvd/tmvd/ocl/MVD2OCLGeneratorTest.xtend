package org.buildingsmart.mvd.tmvd.ocl

import com.google.inject.Inject
import de.bitub.step.p21.util.IOHelper
import org.buildingsmart.ifc4.IFC4
import org.buildingsmart.ifc4.Ifc4Package
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.buildingsmart.mvd.tmvd.generator.MVD2OCLGenerator
import org.eclipse.emf.common.util.URI
import org.eclipse.ocl.OCL
import org.eclipse.ocl.ParserException
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import org.buildingsmart.mvd.mvdxml.MvdXmlPackage
import org.buildingsmart.mvd.expressions.expressionStrings.ExpressionStringsPackage

@RunWith(XtextRunner)
@InjectWith(TextualMVDInjectorProvider)
class MVD2OCLGeneratorTest {

	@Inject
	extension MVD2OCLGenerator

	@Inject
	extension org.buildingsmart.mvd.tmvd.util.IOHelper io

	@Test
	def void parseSingleBooleanTermExpr() {
		val pkg = MvdXmlPackage.eINSTANCE
		val exprPkg = ExpressionStringsPackage.eINSTANCE

		var oclExpr = io.loadMvdXML("mvd-files/mvdXML_V1-1-Final_Validation.mvdxml").
			compile

		var expected = "IfcWall::allInstances() -> forAll(O_PsetName='Pset_WallCommon' and O_PName='FireRating' and O_PSingleValue.oclIsUndefined()T_PsetName='Pset_WallCommon' and T_PName='FireRating' and T_PSingleValue.oclIsUndefined())"
		var actual = oclExpr.toString

		assertEquals(expected, actual)
	}

	def oclExpressionEvaluationTest() {

		var ifc4 = IOHelper.load(URI.createFileURI("ifc-files/WallWithOpeningAndWindow.ifc"),
			Ifc4Package.eINSTANCE) as IFC4

		try {
			// create an OCL instance for Ecore
			val ocl = OCL.newInstance(EcoreEnvironmentFactory.INSTANCE);

			// create an OCL helper object
			val helper = ocl.createOCLHelper();

			// set the OCL context classifier
			helper.setContext(Ifc4Package.eINSTANCE.getIFC4);

			var query = helper.createQuery("IfcCartesianPoint::coordinates");
			var eval = ocl.createQuery(query)
//			helper.createInvariant("")
//			val check = eval.check(query)
			var ok = eval.evaluate(ifc4)

			println(ok)

		} catch (ParserException e) {
			// record failure to parse
			System.err.println(e.getLocalizedMessage());
		}
	}
}
