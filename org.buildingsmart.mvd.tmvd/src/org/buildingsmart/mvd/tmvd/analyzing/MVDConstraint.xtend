package org.buildingsmart.mvd.tmvd.analyzing

import java.util.List
import org.buildingsmart.mvd.mvdxml.AttributeRule
import org.buildingsmart.mvd.mvdxml.Concept
import org.buildingsmart.mvd.mvdxml.ConceptRoot
import org.buildingsmart.mvd.mvdxml.ConceptTemplate
import org.buildingsmart.mvd.mvdxml.TemplateRuleType
import org.eclipse.xtext.EcoreUtil2

class MVDConstraint {

	protected ConceptRoot conceptRoot;
	protected Concept concept;
	protected ConceptTemplate conceptTemplate;

	new(ConceptRoot conceptRoot, Concept concept, ConceptTemplate conceptTemplate) {
		this.conceptRoot = conceptRoot
		this.concept = concept
		this.conceptTemplate = conceptTemplate
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

}
