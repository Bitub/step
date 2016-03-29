package org.buildingsmart.mvd.tmvd.tests

import java.io.InputStream
import java.io.BufferedReader
import java.io.InputStreamReader
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.eclipse.xtext.junit4.util.ParseHelper
import com.google.inject.Inject
import org.eclipse.xtext.junit4.XtextRunner
import org.buildingsmart.mvd.tmvd.TextualMVDInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(TextualMVDInjectorProvider))
class AbstractTextualMVDTest {

	@Inject extension ParseHelper<MvdXML>

	val protected ResourceSet resourceSet = new ResourceSetImpl

	def readMvdXml(String path) {
		class.classLoader.getResourceAsStream(path)
	}

	def CharSequence readModel(InputStream in) {

		val reader = new BufferedReader(new InputStreamReader(in))

		var String line
		var StringBuilder buffer = new StringBuilder
		while ((line = reader.readLine()) != null) {
			buffer.append(line).append('\n');
		}
		return buffer
	}

	def generateTextualMVD(CharSequence tmvd) {
		tmvd.parse(resourceSet)
	}
}
