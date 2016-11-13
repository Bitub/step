package org.buildingsmart.mvd.tmvd.generator

import com.google.inject.Inject
import de.bitub.step.p21.XPressModel
import java.util.function.Consumer
import java.util.function.Predicate
import org.buildingsmart.ifc4.Ifc4Package
import org.buildingsmart.mvd.expressions.transform.ExpressionString2OCL
import org.buildingsmart.mvd.mvdxml.AttributeRule
import org.buildingsmart.mvd.mvdxml.AttributeRulesType
import org.buildingsmart.mvd.mvdxml.Concept
import org.buildingsmart.mvd.mvdxml.ConceptRoot
import org.buildingsmart.mvd.mvdxml.ConceptTemplate
import org.buildingsmart.mvd.mvdxml.EntityRule
import org.buildingsmart.mvd.mvdxml.EntityRulesType
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.MvdXmlPackage
import org.buildingsmart.mvd.mvdxml.RulesType
import org.buildingsmart.mvd.mvdxml.TemplateRuleType
import org.buildingsmart.mvd.mvdxml.TemplateRules
import org.buildingsmart.mvd.tmvd.analyzing.MVDModelInfo
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.ocl.OCL
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.generator.IGeneratorContext

class MVD2OCLGenerator implements IGenerator2 {

	@Inject extension ExpressionString2OCL expr2ocl

	var ConceptTemplateTree2OCL tree2ocl = null
	public MVDModelInfo info = null

	val private ocl = OCL.newInstance(EcoreEnvironmentFactory.INSTANCE);
	val private helper = ocl.createOCLHelper

	def void init(MvdXML mvdXML) {
		info = new MVDModelInfo(mvdXML)
		tree2ocl = new ConceptTemplateTree2OCL(info)
	}

	override afterGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override beforeGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {

		val mvdXML = input.allContents.findFirst[e|e instanceof MvdXML] as MvdXML
		init(mvdXML)
		mvdXML.compile
	}

	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def CharSequence compile(MvdXML mvdXML) {
		throw new UnsupportedOperationException
	}

	def CharSequence compileValidation(ConceptRoot conceptRoot, /* TODO remove later */ Predicate<Concept> predicate) {
		helper.context = Ifc4Package.eINSTANCE.getEClassifier(conceptRoot.applicableRootEntity)
		'''self.«conceptRoot.applicableRootEntity.toFirstLower»''' + conceptRoot.concepts.concept.findFirst [
			predicate.test(it)
		].compileValidation [
			var simpleIdPair = info.findMatchingPairs(it)
		]

	}

	def dispatch CharSequence compileValidation(Concept concept, Consumer<String> fn) {
		val refConceptTemplate = concept.template.ref
		val applicableEntity = refConceptTemplate.applicableEntity

		// TODO Check if supertype of applicable entity.
		// generate let-expr for given id
		tree2ocl.compile(refConceptTemplate, '''''')

		// TODO Connect let-expr with boolean-expr
		'''«concept.templateRules.compileValidation(fn)»'''
//		'''«concept.templateRules.compileValidation[
//			var simpleIdPair = info.findMatchingPairs(it)
//		]»'''
	}

	def firstExpr(Pair<String, String> simpleId, String type) {
		'''let «simpleId.key»«simpleId.value» : Sequence(«type») ='''
	}

	def secExpr(String listName, ConceptTemplate concept, Pair<String, String> simpleId) {
		'''self.«listName».«concept.compileTree(simpleId.key, simpleId.value)» in'''
	}

	def thrExpr(Concept concept) {

		val rootConcept = concept.getFirstAncestorOfType(MvdXmlPackage.Literals.CONCEPT_ROOT)
		val conceptTemplate = concept.template.ref
		val templateRules = concept.templateRules

		'''«concept.compileValidation[]»'''
	}

	def compileTree(ConceptTemplate template, String ruleId, String idPrefix) {

		// get leaf node of template tree by referenced ruleID as starting point for expression building 
		var leaf = info.ruleIds.findFirst [
			var feature = it.eClass.getEStructuralFeature("ruleID")
			var value = it.eGet(feature) as String

			value.equalsIgnoreCase(ruleId)
		]

		// TODO Inlcude value type of expression string for sequence.
		'''let «idPrefix»«ruleId» : Sequence(String) = «leaf.compileTree(idPrefix)»'''
	}

	def dispatch CharSequence compileTree(AttributeRulesType rules, String idPrefix) {
		'''«IF rules.eContainer != null»«rules.eContainer.compileTree(idPrefix)».«ENDIF»'''
	}

	def dispatch CharSequence compileTree(AttributeRule rule, String idPrefix) {

		var ent = rule.getFirstAncestorOfType(MvdXmlPackage.Literals.ENTITY_RULE)
		if (null == ent) {
			ent = rule.getFirstAncestorOfType(MvdXmlPackage.Literals.CONCEPT_TEMPLATE)
		}

		// get upper entity name
		var name = switch (ent) {
			EntityRule: ent.name
			ConceptTemplate: ent.applicableEntity
			default: ""
		}

		// handle simple delegate occurance 
		var entity = Ifc4Package.eINSTANCE.getEClassifier(name) as EClass
		var feature = entity.getEStructuralFeature(rule.name.toFirstLower)
		if (XPressModel.isDelegate(feature) && XPressModel.isSelect(feature)) {
			return '''«rule?.eContainer.compileTree(idPrefix)»«rule.name.toFirstLower».get«rule.name»()'''
		}

		println(name)
		'''«rule?.eContainer.compileTree(idPrefix)»«rule.name.toFirstLower»'''
	}

	def getFirstAncestorOfType(EObject eObject, EClassifier eClassifier) {

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

	def dispatch CharSequence compileTree(EntityRule rule, String idPrefix) {

		// get information from upper tree structure
		var attr = rule.getFirstAncestorOfType(MvdXmlPackage.Literals.ATTRIBUTE_RULE) as AttributeRule
		var ent = attr.getFirstAncestorOfType(MvdXmlPackage.Literals.ENTITY_RULE)
		if (null == ent) {
			ent = attr.getFirstAncestorOfType(MvdXmlPackage.Literals.CONCEPT_TEMPLATE)
		}

		// get upper entity name
		var name = switch (ent) {
			EntityRule: ent.name
			ConceptTemplate: ent.applicableEntity
			default: ""
		}

		// handle simple delegate occurance 
		var entity = Ifc4Package.eINSTANCE.getEClassifier(name) as EClass
		var feature = entity.getEStructuralFeature(attr.name.toFirstLower)
		if (XPressModel.isDelegate(feature) && !XPressModel.isSelect(feature)) {
			return '''«rule?.eContainer.compileTree(idPrefix)».«rule.name.toFirstLower»'''
		}

		'''«rule?.eContainer.compileTree(idPrefix)» -> selectByType(«rule.name»)'''
	}

	def dispatch CharSequence compileTree(EntityRulesType rules, String idPrefix) {
		'''«rules?.eContainer.compileTree(idPrefix)»'''
	}

	/**
	 * Arrived at the root of a subtree (partial template) or at tree root (conept template with applicable entity)
	 * 
	 * Search for references of subtree in upper tree structure.
	 */
	def dispatch CharSequence compileTree(RulesType rulesType, String idPrefix) {
		val template = rulesType.eContainer as ConceptTemplate

		var refs = info.references.filter [
			it.template.ref == template
		]

		if (refs.size == 1) {
			return '''«refs.get(0).eContainer.compileTree(idPrefix)»«IF template.isIsPartial».«ENDIF»'''
		}

		if (refs.size > 1) {
			var ref = refs.findFirst [
				it.idPrefix.equals(idPrefix)
			]
			return '''«ref.eContainer.compileTree(idPrefix)»«IF template.isIsPartial».«ENDIF»'''
		}

		''''''
	}

	def dispatch CharSequence compileValidation(TemplateRules rules, Consumer<String> fn) {

		var subTrees = rules.templateRules
		var leafs = rules.templateRule

		leafs.map[it.compileValidation(fn)].join
	}

	def dispatch CharSequence compileValidation(TemplateRuleType rule, Consumer<String> fn) {
		expr2ocl.transformToOCL(rule.parameters, fn)
	}

}
