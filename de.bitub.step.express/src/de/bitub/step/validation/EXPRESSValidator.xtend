/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 *  Sebastian Riemschüssel - simple entity name checks 
 */
package de.bitub.step.validation

import org.eclipse.xtext.validation.Check
import de.bitub.step.express.Entity
import de.bitub.step.express.ExpressPackage

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class EXPRESSValidator extends AbstractEXPRESSValidator {

	public static val INVALID_NAME = 'invalidName'

	@Check
	def checkEntityStartsWithCapital(Entity entity) {

		if (!Character.isUpperCase(entity.name.charAt(0))) {
			warning('Name should start with a capital', ExpressPackage.Literals.EXPRESS_CONCEPT__NAME, INVALID_NAME)
		}
	}
}
