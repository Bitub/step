package de.bitub.step.generator

import de.bitub.step.express.Function
import de.bitub.step.express.Schema
import de.bitub.step.express.DataType
import de.bitub.step.express.CollectionType
import de.bitub.step.express.BooleanType
import de.bitub.step.express.LogicalType
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.GenericType
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.StringType
import de.bitub.step.express.RealType
import de.bitub.step.express.NumberType
import de.bitub.step.express.IntegerType

class FunctionGenerator {

	def compileFunction(Schema schema) {

		'''
		class Functions {
		
		«FOR f : schema.funtions»«f.compileFunction»«ENDFOR»
		
		}'''
	}

	def compileFunction(Function function) {

		'''
			
				op«function.returnType.compileReturnType» «function.name.toFirstLower»()
		'''
	}

	def compileReturnType(DataType type) {

		switch type {
			CollectionType:
				switch innerType: type.type {
					ReferenceType: ''' «innerType.instance.name.toFirstUpper»[]'''
				}
			ReferenceType: ''' «type.instance.name»''' // TODO (Riemschüssel): handle mapped types
			BooleanType: ''' boolean'''
			LogicalType: ''' Boolean'''
			StringType: ''' String'''
			IntegerType: ''' int'''
			NumberType: ''' int'''
			RealType: ''' double'''
			GenericType: ''''''
			default: ''' void'''
		}
	}
}