/* 
 * Copyright (c) 2016  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */
 
package de.bitub.step.xcore

import de.bitub.step.express.ExpressConcept
import java.util.List
import java.util.Optional
import java.util.function.Function
import java.util.function.Predicate

class XcoreAnalyticalPackageDescriptor implements Function<ExpressConcept, Optional<XcorePackageDescriptor>> {
	
	static class ProceduralDescriptor {
		
		val Predicate<ExpressConcept> predicate
		val Function<ExpressConcept, XcorePackageDescriptor> function
		val ProceduralDescriptor parent
		
		new(ProceduralDescriptor parent, Predicate<ExpressConcept> predicate, Function<ExpressConcept, XcorePackageDescriptor> packageFunction) {
			
			this.predicate = predicate
			this.function = packageFunction
			this.parent = parent
		}

		new(ProceduralDescriptor parent, Predicate<ExpressConcept> predicate, String subPackage) {
			
			this.predicate = predicate
			this.function = [c| new XcoreGenericSubPackageDescriptor(parent.apply(c), subPackage)]
			this.parent = parent
		}
		
		new(XcorePackageDescriptor baseDescriptor) {
			
			this.predicate = [c | true]
			this.function = [c | baseDescriptor]
			this.parent = null
		}
		
		def static ProceduralDescriptor createInheritanceLevelAt(int superEntities, String packageTemplate) {
			
			
		}
		
		def static ProceduralDescriptor createNamePatternFor(String regularExpr, String packageName) {
			
		}
		
		def static ProceduralDescriptor createTypeOf(Class<?> superType, String packageName) {
			
		}		
		
		def boolean isApplicable(ExpressConcept c) {
			
			predicate.test(c)
		}
		
		def XcorePackageDescriptor apply(ExpressConcept c) {
			
			if(predicate.test(c)) {
				
				function.apply(c)
			} else {

				null				
			}
		}
	}
	
	val List<ProceduralDescriptor> proceduralDescriptors = newArrayList
	
	new(XcorePackageDescriptor baseDescriptor) {
		
		proceduralDescriptors += new ProceduralDescriptor(baseDescriptor)
	}
	
	new(ProceduralDescriptor pd) {
		
		proceduralDescriptors += pd
	}
	
	override apply(ExpressConcept t) {
		
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	
}