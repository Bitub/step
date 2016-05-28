package org.buildingsmart.mvd.tmvd.tests

import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import com.google.inject.Inject
import org.eclipse.xtext.junit4.validation.ValidationTestHelper

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(TextualMVDInjectorProvider))
class TextualMVDParserTest extends AbstractTextualMVDTest {

	@Inject extension ValidationTestHelper

//	val packageName = "src/org.buildingsmart.mvd.tmvd.tests".replace(".", "/")
	val mvdFolder = "mvd-files"
	val tmvdFolder = "tmvd-files"

	@Test
	def testParsingMvdXML() {
		val model = (mvdFolder + "/DoorHasSelfClosing.mvdxml").loadMvdXML as MvdXML
		Assert::assertNotNull(model)

		val templates = model.templates
		Assert::assertNotNull(templates)
		Assert::assertEquals("SinglePropertyValue", templates.conceptTemplate.get(0).name)

		val views = model.views
		Assert::assertNotNull(views)
		Assert::assertEquals("ModelViewExample", views.modelView.get(0).name)
	}

	@Test
	def testCorrectParsingOfTextualMVD() {
		val model = (tmvdFolder + "/DoorHasSelfClosing.tmvd").loadTextualMVD as MvdXML
		model.assertNoErrors
	}

	@Test
	def testMvdXml2Tmvd() {
		val model = (mvdFolder + "/DesignTransferView_V2-corrected.mvdxml").loadMvdXML as MvdXML
		model.saveTextualMVD(tmvdFolder + "/DesignTransferView_V2-corrected.tmvd")
	}

	@Test
	def testParsingTextualMVD() {
		val model = (tmvdFolder + "/DoorHasSelfClosing.tmvd").loadTextualMVD as MvdXML
		Assert::assertNotNull(model)

		val templates = model.templates
		Assert::assertNotNull(templates)
		Assert::assertEquals("SinglePropertyValue", templates.conceptTemplate.get(0).name)

		val views = model.views
		Assert::assertNotNull(views)
		Assert::assertEquals("ModelViewExample", views.modelView.get(0).name)
	}
}
