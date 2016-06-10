package org.buildingsmart.mvd.tmvd.analyzing

import java.util.List
import org.buildingsmart.mvd.mvdxml.AttributeRule
import org.buildingsmart.mvd.mvdxml.EntityRule
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.ReferencesType
import org.eclipse.emf.ecore.EObject
import java.util.Map

class MVDModelInfo {

	public val MvdXML mvd;

	var List<EObject> ruleIds;
	var List<EObject> idPrefixes;
	var List<ReferencesType> references;

	var Map<String, Pair<String, String>> simpleIds;

	new(MvdXML mvd) {
		this.mvd = mvd
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
