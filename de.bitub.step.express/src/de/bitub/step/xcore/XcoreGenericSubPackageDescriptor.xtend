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