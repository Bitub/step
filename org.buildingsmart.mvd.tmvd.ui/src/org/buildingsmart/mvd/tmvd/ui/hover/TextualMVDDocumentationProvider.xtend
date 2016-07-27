package org.buildingsmart.mvd.tmvd.ui.hover

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider
import org.buildingsmart.mvd.mvdxml.Rules

class TextualMVDDocumentationProvider implements IEObjectDocumentationProvider {

	override getDocumentation(EObject o) {
		return switch (o) {
			Rules: "Rule: " + o.documentation
			default: null
		}
	}

}
