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

import de.bitub.step.express.Entity
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.ExpressPackage
import de.bitub.step.express.Type
import java.util.Map
import java.util.Optional
import java.util.function.Function
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.naming.QualifiedName

/**
 * A multi partitioning delegate which uses a map of class versus package descriptors.
 */
class XcoreMultiPartitionDelegate implements XcorePartitioningDelegate {
		
	val XcorePackageDescriptor defaultPackage		
	val public Map<EClass, XcorePackageDescriptor> descriptorMap 
	
	var extension XcoreInfo info
	
	new(String packageName, QualifiedName packageRoot, String packageUri) {
		
		this.defaultPackage = new XcorePackageDescriptor() {
				
			override getNsURI() {
				packageUri
			}
			
			override getName() {
				packageName
			}
			
			override getBasePackage() {
				packageRoot
			}		
		}	
			
		descriptorMap = newHashMap( 
			(ExpressPackage.Literals.ENUM_TYPE -> new XcoreGenericSubPackageDescriptor(defaultPackage, "enums")),
			(ExpressPackage.Literals.SELECT_TYPE -> new XcoreGenericSubPackageDescriptor(defaultPackage, "selects") ),
			(ExpressPackage.Literals.ENTITY -> defaultPackage ) 
		)
	}
	
	
	
	override apply(ExpressConcept t) {
		
		switch(t) {
			
			Type: {
				
				val dscp = descriptorMap.get(t.datatype.eClass)
				if(null==dscp) {
					
					Optional.of(defaultPackage)	
				} else {
					
					Optional.of(dscp)
				}
			}
			Entity:
			
				Optional.of(descriptorMap.get(ExpressPackage.Literals.ENTITY))
							
			default:
		
				Optional.of(defaultPackage)		
		} 
		
	}
	
	override setSchemeInfo(XcoreInfo info) {
		
		this.info = info
	}
		
}