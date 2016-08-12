/*
 * generated by Xtext 2.10.0
 */
package org.buildingsmart.mvd.expressions.validation

import org.buildingsmart.mvd.expressions.expressionStrings.BooleanTerm
import org.buildingsmart.mvd.expressions.expressionStrings.ExpressionStringsPackage
import org.eclipse.xtext.validation.Check
import org.buildingsmart.mvd.expressions.expressionStrings.StringLiteral

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class ExpressionStringsValidator extends AbstractExpressionStringsValidator {

	public static val INVALID_METRIC_VALUE_PAIR = 'invalidMetricValuePair'

	@Check
	def checkMetricWorksWithCorrectType(BooleanTerm term) {

		val metric = term.param.metric
		val value = term.value
		switch (metric) {
			case VALUE: {
			}
			case EXISTS: {
			}
			case SIZE: {
			}
			case TYPE: {
				if (value instanceof StringLiteral) {
					warning('Used Metric do not match type of value.',
						ExpressionStringsPackage.Literals.BOOLEAN_TERM__VALUE, INVALID_METRIC_VALUE_PAIR)
				}
			}
			case UNIQUE: {
			}
		}
	}

}