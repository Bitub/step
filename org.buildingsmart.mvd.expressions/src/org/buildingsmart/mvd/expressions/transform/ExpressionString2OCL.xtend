package org.buildingsmart.mvd.expressions.transform

import com.google.inject.Inject
import org.buildingsmart.mvd.expressions.expressionStrings.And
import org.buildingsmart.mvd.expressions.expressionStrings.BooleanTerm
import org.buildingsmart.mvd.expressions.expressionStrings.Or
import org.buildingsmart.mvd.expressions.util.IOUtil
import org.buildingsmart.mvd.expressions.expressionStrings.Value
import org.eclipse.xtext.xtext.generator.parser.antlr.splitting.simpleExpressions.BooleanLiteral
import org.buildingsmart.mvd.expressions.expressionStrings.StringLiteral
import org.buildingsmart.mvd.expressions.expressionStrings.RealLiteral

class ExpressionString2OCL {

	@Inject extension IOUtil io

	def transformToOCL(String parameters) {
		io.parse(parameters).compile
	}

	def dispatch compile(And and) {
		'''«and.left.compile» and «and.right.compile»'''
	}

	def dispatch compile(Or or) {
		'''«or.left.compile» or «or.right.compile»'''
	}

	def dispatch compile(BooleanTerm term) {

		val id = term.param.name
		val metric = term.param.metric

		switch (metric) {
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
				'''«id»«term.op»''' + term.value.compile
			}
		}

	}

	def dispatch compile(Value value) {

		return switch (value) {
			BooleanLiteral: '''«value.isValue»'''
			StringLiteral:
				"'" + value.value + "'"
			RealLiteral: '''«value.value»'''
		}
	}
}
