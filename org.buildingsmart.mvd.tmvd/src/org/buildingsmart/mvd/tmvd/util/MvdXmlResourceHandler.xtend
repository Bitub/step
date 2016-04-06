package org.buildingsmart.mvd.tmvd.util

import java.io.InputStream
import java.util.Map
import org.buildingsmart.mvd.mvdxml.AttributeRule
import org.buildingsmart.mvd.mvdxml.ConceptTemplate
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.emf.ecore.xmi.XMLResource.ResourceHandler
import org.eclipse.emf.ecore.xmi.impl.BasicResourceHandler
import org.buildingsmart.mvd.mvdxml.Definitions

class MvdXmlResourceHandler extends BasicResourceHandler implements ResourceHandler {

	int i = 0

	val unnamedObjects = newArrayList()

	override postLoad(XMLResource resource, InputStream inputStream, Map<?, ?> options) {
		val treeIterator = EcoreUtil::getAllContents(resource, Boolean::TRUE)

		while (treeIterator.hasNext) {
			val next = treeIterator.next as EObject

			// remove definitions for now
			if (next instanceof Definitions) {
				EcoreUtil.remove(next);
			}

			val codeFeature = next.eClass.getEStructuralFeature("code")
			if (null != codeFeature) {
				var code = next.eGet(codeFeature) as String
				System::out.println(code + " ->" + next.eIsSet(codeFeature))

				if (null == code || code.isEmpty) {
					next.eUnset(codeFeature) //.remove(next, codeFeature, code);
				}
			}

			// fill empty names
			val nameFeature = next.eClass.getEStructuralFeature("name")
			if (null != nameFeature) {
				var name = next.eGet(nameFeature) as String
				if (name.length == 0) {
					name = next.eClass.name + "_" + (i++)
					next.eSet(nameFeature, name);
					unnamedObjects.add(next)
				}

				// replace whitespace with underscore
				val nameWithoutWhiteSpace = name.replaceAll("\\s", "_")
				next.eSet(nameFeature, nameWithoutWhiteSpace)
			}

			if (next instanceof AttributeRule) {

				// remove empty ruleID 
				if (next.ruleID?.isEmpty) {
					EcoreUtil.remove(next, next.eClass.getEStructuralFeature("ruleID"), next.ruleID)
				} else {

					if (next.ruleID != null) {

						// remove whitespace
						val ruleIdWithoutWhiteSpace = next.ruleID.replaceAll("\\s", "")
						EcoreUtil.replace(next, next.eClass.getEStructuralFeature("ruleID"), next.ruleID,
							ruleIdWithoutWhiteSpace)
					}
				}
			}

			if (next instanceof ConceptTemplate) {

				if (next.name != null) {

					// remove whitespace
					val ruleIdWithoutWhiteSpace = next.name.replaceAll("-", "_")
					EcoreUtil.replace(next, next.eClass.getEStructuralFeature("name"), next.name,
						ruleIdWithoutWhiteSpace)
				}
			}
		}
	}

}
