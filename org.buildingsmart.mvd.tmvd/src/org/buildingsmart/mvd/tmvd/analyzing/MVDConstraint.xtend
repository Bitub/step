package org.buildingsmart.mvd.tmvd.analyzing

import java.util.ArrayList
import java.util.List
import java.util.function.Predicate
import org.buildingsmart.ifc4.IFC4
import org.buildingsmart.ifc4.Ifc4Package
import org.buildingsmart.mvd.mvdxml.AttributeRule
import org.buildingsmart.mvd.mvdxml.Concept
import org.buildingsmart.mvd.mvdxml.ConceptRoot
import org.buildingsmart.mvd.mvdxml.ConceptTemplate
import org.buildingsmart.mvd.mvdxml.TemplateRuleType
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.EcoreUtil2

/**
 * Holds the relevant information for constraint checking.
 * 
 * The Concept class holds the actual constraint to check.
 * The ConceptRoot and ConceptTemplate hold additional information.
 * These information are the applicability of objects, the navigation tree and more.
 */
class MVDConstraint {

	protected ConceptRoot conceptRoot
	protected Concept concept
	protected ConceptTemplate conceptTemplate

	protected EClass entityType;

	public Predicate<? super EObject> isApplicable = [true] // TODO compute applicability
	public Predicate<? super EObject> isNotApplicable = isApplicable.negate

	new(ConceptRoot conceptRoot, Concept concept, ConceptTemplate conceptTemplate) {
		this.conceptRoot = conceptRoot
		this.concept = concept
		this.conceptTemplate = conceptTemplate

		this.entityType = Ifc4Package.eINSTANCE.getEClassifier(conceptRoot.applicableRootEntity) as EClass
	}

	new(Concept concept) {
		this(EcoreUtil2::getContainerOfType(concept, ConceptRoot), concept, concept.template.ref)
	}

	def List<AttributeRule> getAttributeRules() {
		return EcoreUtil2::getAllContentsOfType(conceptTemplate.rules, AttributeRule);
	}

	def List<TemplateRuleType> getTemplateRules() {
		return EcoreUtil2::getAllContentsOfType(concept, TemplateRuleType);
	}

	def List<? extends EObject> getAllCheckableEntitiesFrom(IFC4 model) {
		val entityName = this.conceptRoot.applicableRootEntity
		val typeName = getClassFromName(entityName) as Class<? extends EObject>

		if (null == typeName) {
			return new ArrayList
		}

		// all entities of applicable type
		return EcoreUtil2::getAllContentsOfType(model, typeName)
	}

	def private getClassFromName(String name) {
		var eClass = Ifc4Package::eINSTANCE.getEClassifier(name) as EClass;
		if (eClass.isAbstract) {
			return null
		}

		var tmpObject = EcoreUtil.create(eClass)
		return tmpObject.class
	}

}
