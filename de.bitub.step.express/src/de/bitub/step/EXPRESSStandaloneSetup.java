/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */

package de.bitub.step;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class EXPRESSStandaloneSetup extends EXPRESSStandaloneSetupGenerated{

	public static void doSetup() {
		new EXPRESSStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

