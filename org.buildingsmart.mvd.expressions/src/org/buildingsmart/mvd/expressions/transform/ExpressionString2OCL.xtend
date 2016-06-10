package org.buildingsmart.mvd.expressions.transform

import com.google.inject.Inject
import org.buildingsmart.mvd.expressions.expressionStrings.And
import org.buildingsmart.mvd.expressions.expressionStrings.BooleanTerm
import org.buildingsmart.mvd.expressions.expressionStrings.Or
import org.buildingsmart.mvd.expressions.util.IOUtil
import org.buildingsmart.mvd.expressions.expressionStrings.Value
import org.buildingsmart.mvd.expressions.expressionStrings.StringLiteral
import org.buildingsmart.mvd.expressions.expressionStrings.RealLiteral
import java.util.function.Function
import org.buildingsmart.mvd.expressions.expressionStrings.LogicalLiteral
import java.util.function.Consumer

class ExpressionString2OCL {

	@Inject extension IOUtil io

	def transformToOCL(String parameters, Consumer<String> fn) {
		io.parse(parameters).compile(fn)
	}

	def parse(String parameters) {
		io.parse(parameters)
	}

	def dispatch CharSequence compile(And and, Consumer<String> fn) {
		'''«and.left.compile(fn)» and «and.right.compile(fn)»'''
	}

	def dispatch CharSequence compile(Or or, Function<String, CharSequence> fn) {
		'''«or.left.compile(fn)» or «or.right.compile(fn)»'''
	}

	def dispatch CharSequence compile(BooleanTerm term, Consumer<String> fn) {

		val id = term.param.name
		val metric = term.param.metric

		// inform caller about occurence of id
		fn.accept(id)

		return '''«id» -> forAll(i | i''' + switch (metric) {
			case EXISTS: {
				'''«id».oclIsUndefined()'''
			}
			case SIZE: {
			}
			case TYPE: {
			}
			case UNIQUE: {
			}
			case VALUE: {
				'''«term.op»«term.value.compile»'''
			}
		} + ''')'''

	}

	def CharSequence compile(Value value) {

		return switch (value) {
			LogicalLiteral: '''«value.isValue»'''
			StringLiteral:
				"'" + value.value + "'"
			RealLiteral: '''«value.value»'''
		}
	}
}
