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

import org.eclipse.emf.ecore.EClass
import de.bitub.step.express.ExpressPackage
import de.bitub.step.express.BuiltInType

class XcoreConstants {

	// Builtin mapping of primitive data types
	
	val static builtinMappings = <EClass, String>newHashMap(
		ExpressPackage.Literals.INTEGER_TYPE -> "int",
		ExpressPackage.Literals.NUMBER_TYPE -> "double",
		ExpressPackage.Literals.LOGICAL_TYPE -> "Boolean",
		ExpressPackage.Literals.BOOLEAN_TYPE -> "boolean",
		ExpressPackage.Literals.BINARY_TYPE -> "Binary",
		ExpressPackage.Literals.REAL_TYPE -> "double",
		ExpressPackage.Literals.STRING_TYPE -> "String"
	);
	
	def static String qualifiedName(BuiltInType c) {
		
		builtinMappings.get(c.eClass)
	}
}