package org.buildingsmart.mvd.tmvd.tests

import com.google.inject.Inject
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.buildingsmart.mvd.tmvd.scoping.TextualMVDIndex
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.xtext.scoping.IScopeProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.buildingsmart.mvd.mvdxml.MvdXmlPackage

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(TextualMVDInjectorProvider))
class TextualMVDIndexTest extends AbstractTextualMVDTest {

	@Inject extension IScopeProvider

	@Test def void testExportedEObjectDescriptions() {

		val mvdXml = "org/buildingsmart/mvd/tmvd/tests/DoorHasSelfClosing.tmvd".readMvdXml.readModel.generateTextualMVD
		mvdXml.views.modelView.head.roots.conceptRoot.head.concepts.concept.head => [
			System::out.println(assertScope(MvdXmlPackage::eINSTANCE.concept_Template))
		]
	}

	def assertScope(EObject context, EReference reference) {
		context.getScope(reference).allElements.map[name].join(" ,")
	}

}
