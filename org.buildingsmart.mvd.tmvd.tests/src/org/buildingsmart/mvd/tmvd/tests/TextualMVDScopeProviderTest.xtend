package org.buildingsmart.mvd.tmvd.tests

import com.google.inject.Inject
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.MvdXmlPackage
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.scoping.IScopeProvider
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(TextualMVDInjectorProvider))
class TextualMVDIndexTest extends AbstractTextualMVDTest {

	@Inject extension IScopeProvider

	@Test def void testExportedEObjectDescriptions() {

		val mvdXml = "org/buildingsmart/mvd/tmvd/tests/DoorHasSelfClosing.tmvd".loadMvdXML as MvdXML
		mvdXml.views.modelView.head.roots.conceptRoot.head.concepts.concept.head => [
			System::out.println(assertScope(MvdXmlPackage::eINSTANCE.concept_Template))
		]
	}

	def assertScope(EObject context, EReference reference) {
		context.getScope(reference).allElements.map[name].join(" ,")
	}

}
