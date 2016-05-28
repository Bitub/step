package org.buildingsmart.mvd.tmvd

import com.google.inject.Inject
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.buildingsmart.mvd.tmvd.util.IOHelper
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(TextualMVDInjectorProvider))
class AbstractTextualMVDTest {

	@Inject extension IOHelper io

	def loadTextualMVD(String pathToFile) {
		io.loadTextualMVD(pathToFile)
	}

	def loadMvdXML(String pathToFile) {
		io.loadMvdXML(pathToFile)
	}

	def saveMvdXML(EObject root, String pathToFile) {
		io.storeAsMVDXML(root, pathToFile)
	}

	def saveTextualMVD(EObject root, String pathToFile) {
		io.storeAsTMVD(root, pathToFile)
	}

}
