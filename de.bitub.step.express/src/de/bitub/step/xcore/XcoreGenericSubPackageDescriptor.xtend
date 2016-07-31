package de.bitub.step.xcore

import org.eclipse.xtext.naming.QualifiedName

class XcoreGenericSubPackageDescriptor implements XcorePackageDescriptor {
	
	val String subNamespace
	
	val QualifiedName packageRoot
	val String packageName
	val String packageUri
	
	
	new(String packageName, String subNamespace, QualifiedName packageRoot, String packageUri) {
		
		this.subNamespace = subNamespace
		this.packageName = packageName
		this.packageRoot = packageRoot	
		this.packageUri = packageUri	
	}	
	
	
	override getNsURI() {
	
		if(subNamespace.trim.length > 0) {
			packageUri +"/"+ subNamespace.toFirstLower
		} else {
			packageUri
		}			
	}
	
	override getName() {
		
		if(subNamespace.trim.length > 0) {
			packageName + subNamespace.toFirstUpper
		} else {
			packageName
		}
	}
	
	override getBasePackage() {
		
		if(subNamespace.trim.length > 0) {
			packageRoot.append(subNamespace.toLowerCase)
		} else {
			packageRoot
		}
	}
	
}