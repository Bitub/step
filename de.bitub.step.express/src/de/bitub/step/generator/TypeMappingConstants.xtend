package de.bitub.step.generator

import org.eclipse.emf.ecore.EClass
import de.bitub.step.express.ExpressPackage

interface TypeMappingConstants {

	// Builtin mapping of primitive data types
	val public static builtinMappings = <EClass, String>newHashMap(
		ExpressPackage.Literals.INTEGER_TYPE -> "int",
		ExpressPackage.Literals.NUMBER_TYPE -> "double",
		ExpressPackage.Literals.LOGICAL_TYPE -> "Boolean",
		ExpressPackage.Literals.BOOLEAN_TYPE -> "boolean",
		ExpressPackage.Literals.BINARY_TYPE -> "Binary",
		ExpressPackage.Literals.REAL_TYPE -> "double",
		ExpressPackage.Literals.STRING_TYPE -> "String"
	);
}