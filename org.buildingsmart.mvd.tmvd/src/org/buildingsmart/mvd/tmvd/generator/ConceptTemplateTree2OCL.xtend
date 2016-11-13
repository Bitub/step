package org.buildingsmart.mvd.tmvd.generator

import de.bitub.step.p21.XPressModel
import org.buildingsmart.ifc4.Ifc4Package
import org.buildingsmart.mvd.mvdxml.AttributeRule
import org.buildingsmart.mvd.mvdxml.AttributeRulesType
import org.buildingsmart.mvd.mvdxml.ConceptTemplate
import org.buildingsmart.mvd.mvdxml.EntityRule
import org.buildingsmart.mvd.mvdxml.EntityRulesType
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.MvdXmlPackage
import org.buildingsmart.mvd.mvdxml.RulesType
import org.buildingsmart.mvd.tmvd.analyzing.MVDModelInfo
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil

class ConceptTemplateTree2OCL {

	public val exprMap = <String, String>newHashMap()

	public var MVDModelInfo info = null

	private var ruleId = ""

	new(MVDModelInfo info) {
		this.info = info
	}

	new(MvdXML mvdXML) {
		info = new MVDModelInfo(mvdXML)
	}

	def void relationships() {
		info.ruleIds.forEach[compile('''''')]
	}

	def dispatch CharSequence compile(AttributeRule rule, CharSequence expr) {

		if (!rule.ruleID.nullOrEmpty) {
			ruleId = rule.ruleID
		}

		rule.eContainer.compile('''«rule.name.toFirstLower»«IF rule.isDelegateSelect».get«rule.name»()«ENDIF»«expr»''')
	}

	def dispatch CharSequence compile(AttributeRulesType rules, CharSequence expr) {
		rules.eContainer.compile('''.«expr»''')
	}

	def dispatch CharSequence compile(EntityRule rule, CharSequence expr) {
		var attr = rule.getFirstAncestorOfType(MvdXmlPackage.Literals.ATTRIBUTE_RULE) as AttributeRule

		rule.eContainer.
			compile('''«IF attr.isNonSelectDelegate».«rule.name.toFirstLower»«ELSE»-> selectByType(«rule.name»)«ENDIF»«expr»''')
	}

	def dispatch CharSequence compile(EntityRulesType rules, CharSequence expr) {
		rules.eContainer.compile('''«expr»''')
	}

	def dispatch CharSequence compile(RulesType rules, CharSequence expr) {
		exprMap.put(ruleId, expr.toString) // save current
		rules.eContainer.compile('''«expr»''')
	}

	def dispatch CharSequence compile(ConceptTemplate template, CharSequence expr) {

		if (template.isIsPartial) {

			info.references.filter [
				it.template.ref == template
			].forEach [

				var idPrefix = it.idPrefix

				if (idPrefix.nullOrEmpty) {
					exprMap.put(ruleId, it.eContainer.compile('''.«expr»''').toString)
				} else {
					exprMap.put(idPrefix + ruleId,
						it.eContainer.compile('''«exprMap.getOrDefault(ruleId, '''''')»''').toString)
				}
			]
		}
		'''«expr»'''
	}

	private def getAncestor(EObject rule) {

		var ent = rule.getFirstAncestorOfType(MvdXmlPackage.Literals.ENTITY_RULE)
		if (null == ent) {
			ent = rule.getFirstAncestorOfType(MvdXmlPackage.Literals.CONCEPT_TEMPLATE)
		}
	}

	private def getName(EObject eObject) {

		return switch (eObject) {
			EntityRule: eObject.name
			ConceptTemplate: eObject.applicableEntity
			default: ""
		}
	}

	private def getFirstAncestorOfType(EObject eObject, EClassifier eClassifier) {

		var isAncestorOfType = false
		var root = EcoreUtil.getRootContainer(eObject)
		var EObject ancestor = null
		var parent = eObject.eContainer

		while (!isAncestorOfType) {
			parent = parent.eContainer
			if (eClassifier.isInstance(parent)) {
				ancestor = parent
				isAncestorOfType = true
			}

			if(parent == null) return ancestor
			if(parent == root) return ancestor
		}
		return ancestor
	}

	private def isDelegateSelect(AttributeRule rule) {
		val feature = rule.feature
		XPressModel.isDelegate(feature) && XPressModel.isSelect(feature)
	}

	private def getFeature(AttributeRule attr) {
		val name = attr.ancestor.name
		val entity = Ifc4Package.eINSTANCE.getEClassifier(name) as EClass
		entity?.getEStructuralFeature(attr.name.toFirstLower)
	}

	private def isNonSelectDelegate(AttributeRule attr) {
		var feature = attr.feature
		XPressModel.isDelegate(feature) && !XPressModel.isSelect(feature)
	}
}
