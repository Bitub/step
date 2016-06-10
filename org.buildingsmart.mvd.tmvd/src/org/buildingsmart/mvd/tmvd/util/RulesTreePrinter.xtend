package org.buildingsmart.mvd.tmvd.util

import org.buildingsmart.mvd.mvdxml.RulesType
import org.buildingsmart.mvd.mvdxml.AttributeRulesType
import org.buildingsmart.mvd.mvdxml.AttributeRule
import org.buildingsmart.mvd.mvdxml.EntityRulesType
import org.buildingsmart.mvd.mvdxml.EntityRule

class RulesTreePrinter {

	def dispatch CharSequence tree(RulesType rules) {
		rules.attributeRule.map [
			'''  - «tree»'''
		].join('\n')
	}

	def dispatch CharSequence tree(AttributeRulesType rules) {
		rules.attributeRule.map [
			'''  - «tree»'''
		].join('\n')
	}

	def dispatch CharSequence tree(AttributeRule rule) {
		if (rule.entityRules != null) {
			return '''
				«rule.name»
				«tree(rule.entityRules)»
			'''
		}
		'''«rule.name»'''
	}

	def dispatch CharSequence tree(EntityRulesType rules) {
		rules.entityRule.map [
			'''  - «tree»'''
		].join('\n')
	}

	def dispatch CharSequence tree(EntityRule rule) {
		if (rule.attributeRules != null) {
			return '''
				«rule.name»
				«print(rule.attributeRules)»
			'''
		}
		if (rule.references != null) {
			return '''
				«rule.name»
				«tree(rule.references.template.ref.rules)»
			'''
		}
		'''«rule.name»'''
	}
}
