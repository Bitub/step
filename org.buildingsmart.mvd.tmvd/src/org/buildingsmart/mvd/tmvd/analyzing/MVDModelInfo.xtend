package org.buildingsmart.mvd.tmvd.analyzing

import java.util.List
import org.buildingsmart.mvd.mvdxml.AttributeRule
import org.buildingsmart.mvd.mvdxml.EntityRule
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.ReferencesType
import org.eclipse.emf.ecore.EObject
import java.util.Map
import org.eclipse.xtext.EcoreUtil2
import org.buildingsmart.mvd.mvdxml.Concept
import org.buildingsmart.mvd.mvdxml.ConceptRoot
import org.buildingsmart.mvd.mvdxml.ConceptTemplate

class MVDModelInfo {

	public val MvdXML mvd;

	var List<EObject> ruleIds;
	var List<EObject> idPrefixes;
	var List<ReferencesType> references;

	var Map<String, Pair<String, String>> simpleIds;

	new(MvdXML mvd) {
		this.mvd = mvd
	}
	
	def dispatch getConstraintsFrom(AttributeRule rule){
		rule.constraints.constraint
	}
	
	def dispatch getConstraintsFrom(EntityRule rule){
		rule.constraints.constraint
	}
	
	def getConceptRoots(){
		EcoreUtil2::getAllContentsOfType(mvd.views, ConceptRoot);
	}
	
	def getConecptTemplates(){ // TODO: Also filter subtemplates here ?
		EcoreUtil2::getAllContentsOfType(mvd, ConceptTemplate).filter[
			!it.isIsPartial
		];
	}

	def getMVDConstraints() {
		val allConcepts = EcoreUtil2::getAllContentsOfType(mvd, Concept);

		return allConcepts.map [
			val root = EcoreUtil2::getContainerOfType(it, ConceptRoot)
			val template = it.template.ref
			new MVDConstraint(root, it, template)
		]
	}

	def getRuleIds() {
		if (ruleIds == null) {

			return ruleIds = mvd.eAllContents.filter [
				if (it instanceof AttributeRule) {
					return !it.ruleID.nullOrEmpty
				}
				if (it instanceof EntityRule) {
					return !it.ruleID.nullOrEmpty
				}
				false
			].toList
		}
		ruleIds
	}

	def getIdPrefixes() {
		if (idPrefixes == null) {

			return idPrefixes = mvd.eAllContents.filter [
				if (it instanceof ReferencesType) {
					return !it.idPrefix.nullOrEmpty
				}
				false
			].toList
		}
		idPrefixes
	}

	def getReferences() {
		if (references == null) {
			references = mvd.eAllContents.filter(typeof(ReferencesType)).toList
		}
		references
	}

	def findMatchingPairs(String simpleId) {

		if (simpleIds == null) {
			simpleIds = this.getIdPrefixes.map [

				val reference = it as ReferencesType
				return this.getRuleIds.map [

					return reference.idPrefix -> switch (it) {
						AttributeRule: it.ruleID
						EntityRule: it.ruleID
					}
				]
			].flatten.toMap [
				it.key + it.value
			]
			return simpleIds.get(simpleId)
		}
		simpleIds.get(simpleId)
	}

}
