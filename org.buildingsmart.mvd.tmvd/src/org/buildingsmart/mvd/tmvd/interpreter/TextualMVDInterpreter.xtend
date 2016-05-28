package org.buildingsmart.mvd.tmvd.interpreter

import org.buildingsmart.mvd.mvdxml.ConceptRoot
import org.buildingsmart.mvd.mvdxml.MvdXML
import org.buildingsmart.mvd.mvdxml.OperatorType
import org.buildingsmart.mvd.mvdxml.TemplateRuleType
import org.buildingsmart.mvd.mvdxml.TemplateRules
import org.eclipse.ocl.expressions.ExpressionsFactory

class TextualMVDInterpreter {

	def dispatch interpret(ConceptRoot conceptRoot) {

		// get all instances of applicable root entity for checking
		var rootEntityType = conceptRoot.applicableRootEntity

		// filter instances further by applying applicability constraints
		var applicability = conceptRoot.applicability

	}

	def setupOCLExpression(MvdXML mvd) {
		val expr = ExpressionsFactory.eINSTANCE.createIteratorExp
	}

	def filterApplicableInstances() {
	}

	def dispatch interpret(TemplateRules rules) {

		var op = rules.operator

		switch (op) {
			case OperatorType.AND: {
				rules.templateRule.forEach[it.interpret]
			}
			case OperatorType.OR: {
			}
			case OperatorType.NOT: {
			}
			default: {
			}
		}
	}

	def dispatch interpret(TemplateRuleType rule) {

		var expression = rule.parameters
	}

}
