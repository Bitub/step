package org.buildingsmart.mvd.tmvd.ui.hover

import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider
import org.eclipse.emf.ecore.EObject
import org.buildingsmart.mvd.mvdxml.Rules

class TextualMVDHoverProvider extends DefaultEObjectHoverProvider {

	override protected getFirstLine(EObject o) {

		return switch (o) {
			Rules: "Rules: " + o.templateRules
			default: super.getFirstLine(o)
		}
	}

}
