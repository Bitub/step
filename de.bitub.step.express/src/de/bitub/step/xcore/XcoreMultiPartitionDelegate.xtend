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
import java.util.function.BiFunction
import org.eclipse.xtext.naming.QualifiedName

/**
 * 
 */
class XcoreMultiPartitionDelegate implements BiFunction<ExpressConcept, QualifiedName, Optional<XcorePackageDescriptor>> {
		
	val QualifiedName packageRoot
	val String packageName
	val String packageUri
		
	val defaultPackage = new XcorePackageDescriptor() {
				
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
		
	var Map<Object, XcorePackageDescriptor> descriptorMap 
	
	new(String packageName, QualifiedName packageRoot, String packageUri) {
		
		this.packageName = packageName
		this.packageRoot = packageRoot	
		this.packageUri = packageUri
		
		applyTypeMaping("enums", "selects", "")
	}
	
	def applyTypeMaping(String enumsPackage, String selectsPackage, String entityPackage) {
		
		descriptorMap = <Object, XcorePackageDescriptor>newHashMap(
		
			ExpressPackage.Literals.ENUM_TYPE
			 -> new XcoreGenericSubPackageDescriptor(packageName, enumsPackage, packageRoot, packageUri),
		
			ExpressPackage.Literals.SELECT_TYPE
			-> new XcoreGenericSubPackageDescriptor(packageName, selectsPackage, packageRoot, packageUri),

			ExpressPackage.Literals.ENTITY
			-> new XcoreGenericSubPackageDescriptor(packageName, entityPackage, packageRoot, packageUri)		
		)			
	}
	
	override apply(ExpressConcept t, QualifiedName u) {
		
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
		
}