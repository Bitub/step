/* 
 * Copyright (c) 2015,2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft, Sebastian Riemschüssel - initial implementation and initial documentation
 */
package de.bitub.step.xcore

import de.bitub.step.express.BinaryType
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.ExpressPackage
import de.bitub.step.express.LogicalType
import org.eclipse.emf.ecore.EClass

class XcoreConstants {

	// Builtin mapping of primitive data types
	
	val static builtinMappings = <EClass, String>newHashMap(
		ExpressPackage.Literals.INTEGER_TYPE -> "int",
		ExpressPackage.Literals.NUMBER_TYPE -> "double",
		ExpressPackage.Literals.LOGICAL_TYPE -> "Logical",
		ExpressPackage.Literals.BOOLEAN_TYPE -> "boolean",
		ExpressPackage.Literals.BINARY_TYPE -> "Binary",
		ExpressPackage.Literals.REAL_TYPE -> "double",
		ExpressPackage.Literals.STRING_TYPE -> "String"
	);

	val static builtinObjectMappings = <EClass, String>newHashMap(
		ExpressPackage.Literals.INTEGER_TYPE -> "Integer",
		ExpressPackage.Literals.NUMBER_TYPE -> "Double",
		ExpressPackage.Literals.LOGICAL_TYPE -> "Logical",
		ExpressPackage.Literals.BOOLEAN_TYPE -> "Boolean",
		ExpressPackage.Literals.BINARY_TYPE -> "Binary",
		ExpressPackage.Literals.REAL_TYPE -> "Double",
		ExpressPackage.Literals.STRING_TYPE -> "String"
	);
	
	def static String qualifiedBuiltInName(BuiltInType c) {
		
		builtinMappings.get(c.eClass)
	}
	
	def static String qualifiedBuiltInObjectName(BuiltInType c) {
		
		builtinObjectMappings.get(c.eClass)
	}
	
	def static CharSequence compileBuiltin(BuiltInType c) {
		
		
		switch(c) {
			
			LogicalType : 
				'''
				
				enum Logical {
					
					TRUE = 0, FALSE = 1, UNKNOWN = 2 
				}
				'''
			BinaryType:
				'''
				
				type Binary wraps java.util.BitSet
				'''
				
			default:
				''''''
		}
	}
	
}