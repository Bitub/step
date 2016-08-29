/* 
 * Copyright (c) 2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft, Sebastian Riemschüssel - initial implementation and initial documentation
 */
package de.bitub.step.xcore

import de.bitub.step.express.ExpressConcept
import java.util.Optional
import org.eclipse.xtext.naming.QualifiedName

class XcoreBasePartitionDelegate implements XcorePartitioningDelegate {

	val XcorePackageDescriptor baseDescriptor
	var XcoreInfo info
	
	new(String declaredName, QualifiedName packageQn, String namespaceUri) {
		
		baseDescriptor = new XcorePackageDescriptor() {
			
			override getNsURI() {
				namespaceUri
			}
			
			override getName() {
				declaredName
			}
			
			override getBasePackage() {
				packageQn
			}
		}
	}

	
	override apply(ExpressConcept t) {
		
		Optional.of(baseDescriptor)
	}
	
	override setSchemeInfo(XcoreInfo info) {
		
		this.info = info
	}
	
}