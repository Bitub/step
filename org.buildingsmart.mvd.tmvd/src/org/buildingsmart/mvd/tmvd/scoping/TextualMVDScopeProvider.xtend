/*
 * generated by Xtext
 */
package org.buildingsmart.mvd.tmvd.scoping

import org.buildingsmart.mvd.mvdxml.ApplicabilityType
import org.buildingsmart.mvd.mvdxml.Concept
import org.buildingsmart.mvd.mvdxml.ConceptTemplate
import org.buildingsmart.mvd.mvdxml.ReferencesType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 *
 */
class TextualMVDScopeProvider extends AbstractDeclarativeScopeProvider {

	def scope_GenericReference_ref(ApplicabilityType context, EReference reference) {
		getConceptTemplateScopes(context);
	}

	def scope_GenericReference_ref(ReferencesType context, EReference reference) {
		getConceptTemplateScopes(context);
	}

	def scope_GenericReference_ref(Concept context, EReference reference) {
		getConceptTemplateScopes(context);
	}

	def getConceptTemplateScopes(EObject context) {
		val candidates = getCandidates(context, ConceptTemplate)
		return Scopes::scopeFor(candidates)
	}

	/**
	 * Collect a list of candidates by going through the model
	 */
	def getCandidates(EObject context, Class<? extends EObject> type) {
		val rootElement = EcoreUtil2.getRootContainer(context)
		return EcoreUtil2.getAllContentsOfType(rootElement, type)
	}
}
