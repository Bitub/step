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

class XcoreGenericSubPackageDescriptor implements XcorePackageDescriptor {
	
	val String packageName
	
	val XcorePackageDescriptor base;	
	
	new(XcorePackageDescriptor baseDescriptor, String packageName) {
		
		this.packageName = packageName
		this.base = baseDescriptor	
	}	
	
	
	override getNsURI() {
	
		if(packageName.trim.length > 0) {
			base.nsURI +"/"+ packageName.toFirstLower
		} else {
			base.nsURI
		}			
	}
	
	override getName() {
		
		if(packageName.trim.length > 0) {
			base.name + packageName.toFirstUpper
		} else {
			base.name
		}
	}
	
	override getBasePackage() {
		
		if(packageName.trim.length > 0) {
			base.basePackage.append(packageName.toLowerCase)
		} else {
			base.basePackage
		}
	}
	
}