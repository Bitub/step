/* 
 * Copyright (c) 2015,2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */
 
package de.bitub.step.express.tests.xcoregen

import de.bitub.step.EXPRESSInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EXPRESSInjectorProvider))
class XcoreIfc4GenTest extends AbstractXcoreGeneratorTest {
	    
    @Test
    def void testRunIfc4Conversion() {
    	
    	val ifc4stream = class.classLoader.getResourceAsStream("de/bitub/step/express/tests/xcoregen/IFC4.exp")
    	val ifc4Schema = readModel(ifc4stream)
    	
//    	val Resource resource = resourceSet.getResource(
//		    	URI.createURI("platform:/resource/de.bitub.step.express.tests/src/de/bitub/step/express/tests/xcoregen/IFC4.exp"), true);

		generateXCore(ifc4Schema)    	
    } 
}