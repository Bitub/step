package org.buildingsmart.mvd.expressions.tests

import com.google.inject.Inject
import org.buildingsmart.mvd.expressions.expressionStrings.Expression
import org.buildingsmart.mvd.expressions.transform.ExpressionString2OCL
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(ExpressionStringsInjectorProvider)
class ExpressionString2OCLTest {

	@Inject
	extension ParseHelper<Expression>

	@Inject
	extension ExpressionString2OCL

	@Test
	def void parseExpression() {
		var oclExpr = '''
			O_PsetName [Value] = 'Pset_WallCommon' AND  O_PName [Value] = 'Thermal Transmittance' AND O_PSingleValue [Exists] = true
		'''.parse.
			compile

		var expected = "O_PsetName='Pset_WallCommon' and O_PName='Thermal Transmittance' and O_PSingleValue.oclIsUndefined()"
		var actual = oclExpr.toString
		assertEquals(expected, actual)
	}

	@Test
	def void parseSingleBooleanTermExpr() {
		var oclExpr = '''
			O_PsetName [Value] = 'Pset_WallCommon'
		'''.parse.compile

		var expected = "O_PsetName='Pset_WallCommon'"
		var actual = oclExpr.toString
		assertEquals(expected, actual)
	}

	@Test
	def void parseAndExpr() {
		var oclExpr = '''
			O_PName [Value] = 'Thermal Transmittance' AND O_PSingleValue [Exists] = true
		'''.parse.compile

		var expected = "O_PName='Thermal Transmittance' and O_PSingleValue.oclIsUndefined()"
		var actual = oclExpr.toString
		assertEquals(expected, actual)
	}
}
