package org.buildingsmart.mvd.tmvd.tests

import com.google.inject.Inject
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.buildingsmart.mvd.tmvd.scoping.TextualMVDIndex
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(TextualMVDInjectorProvider))
class TextualMVDIndexTest extends AbstractTextualMVDTest {

	@Inject extension TextualMVDIndex

	@Test def void testExportedEObjectDescriptions() {

		val mvdXml = "org/buildingsmart/mvd/tmvd/tests/DoorHasSelfClosing.tmvd".readMvdXml.readModel.generateTextualMVD
		System::out.println(mvdXml.exportedEObjectDescriptions.map[qualifiedName].join(", "))
	}

}
