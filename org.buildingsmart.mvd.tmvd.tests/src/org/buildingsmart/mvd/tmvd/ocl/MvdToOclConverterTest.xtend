package org.buildingsmart.mvd.tmvd.ocl

import de.bitub.step.p21.util.IOHelper
import org.buildingsmart.ifc4.IFC4
import org.buildingsmart.ifc4.Ifc4Package
import org.eclipse.emf.common.util.URI
import org.eclipse.ocl.OCL
import org.eclipse.ocl.ParserException
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory

class MvdToOclConverterTest {

	def static void main(String[] args) {
		new MvdToOclConverterTest().test()
	}

	def test() {

		var ifc4 = IOHelper.load(URI.createFileURI("ifc-files/WallWithOpeningAndWindow.ifc"),
			Ifc4Package.eINSTANCE) as IFC4

		try {
			// create an OCL instance for Ecore
			val ocl = OCL.newInstance(EcoreEnvironmentFactory.INSTANCE);

			// create an OCL helper object
			val helper = ocl.createOCLHelper();

			// set the OCL context classifier
			helper.setContext(Ifc4Package.eINSTANCE.IFC4);

			var query = helper.createQuery("IfcCartesianPoint::coordinates");
			var eval = ocl.createQuery(query)
//			helper.createInvariant("")
//			val check = eval.check(query)
			var ok = eval.evaluate(ifc4)

//			println(check)
			println(ok)

		} catch (ParserException e) {
			// record failure to parse
			System.err.println(e.getLocalizedMessage());
		}
	}
}
