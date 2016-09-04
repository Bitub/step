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

import de.bitub.step.express.Entity
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.Type
import de.bitub.step.util.EXPRESSExtension
import java.util.Collections
import java.util.List
import java.util.Optional
import java.util.function.BiFunction
import java.util.function.BiPredicate
import java.util.function.Function
import java.util.regex.Pattern

/**
 * An analytical package partitioning delegate.
 * 
 * <p>
 * Functional descriptors form up a tree where each path represents a qualified package descriptor chain. 
 * If multiple descriptors match the given concept, path candidates are merged by levels in order of input sequence when appending new
 * descriptors. Later added descriptors will placed as super packages while the earliest added represents the tail.
 * </p>
 */
class XcoreFunctionalPartitioningDelegate implements XcorePartitioningDelegate {
	
	val List<FunctionalDescriptor> functionalDescriptors = newArrayList
	var XcoreInfo info
	
	static class Predicate {
		
		val FunctionalDescriptor dscpParent
		var BiPredicate<XcoreInfo, ExpressConcept> dscpPredicate
		var BiFunction<FunctionalDescriptor, ExpressConcept, XcorePackageDescriptor> dscpFunction
		
		new() {
		
			this.dscpParent = null	
			this.dscpPredicate = [ i,c | true ]
		}
		
		new(FunctionalDescriptor parent) {
		
			this.dscpParent = parent
			this.dscpPredicate = [ i,c | true ]	
		}
		
		def FunctionalDescriptor create() {
			
			new FunctionalDescriptor(
				dscpParent, dscpPredicate, if(null==dscpFunction) [p,c | null] else dscpFunction
			)
		}
		
		def Predicate mapPackageName(String packageName) {
			
			dscpFunction = [ p, c | { new XcoreGenericSubPackageDescriptor(p.parent.apply(c), packageName) }]
			
			this
		}

		def Predicate mapSupertypeLevel(String ... fragments) {
			
			dscpFunction = [ p, c | {
						
						val maxLevel = EXPRESSExtension.getSpecificationLevel(c)
												
						new XcoreGenericSubPackageDescriptor(
							p.parent.apply(c), if(maxLevel>=fragments.length) fragments.get(fragments.length-1) else fragments.get(maxLevel)
						) 						
					}]			
			this
		}
		
		/**
		 * Filters for entities above given level.
		 */
		def Predicate gtSupertypeLevel(int superEntities) {
			
			dscpPredicate =	dscpPredicate.and( [ i, c | EXPRESSExtension.getSpecificationLevel(c) > superEntities ] )
			
			this
		}
				
		/**
		 * Filters for entities less than equal given level.
		 */
		def Predicate lteSupertypeLevel(int superEntities) {
			
			dscpPredicate =	dscpPredicate.and( [ i, c | EXPRESSExtension.getSpecificationLevel(c) <= superEntities ] )
			
			this
		}
		
		def Predicate isNamedLike(String regularExpr) {

			val Pattern pattern = Pattern.compile(regularExpr)
			dscpPredicate = dscpPredicate.and( [ i, c | pattern.matcher(c.name).find ] )
			
			this
		}
		
		def Predicate isDataTypeOf(Class<?> type) {
			
			dscpPredicate = dscpPredicate.and( [ i, c | if(c instanceof Type) type == (c as Type).datatype.class else false] )
			
			this
		}		

		def Predicate isDataKindOf(Class<?> superType) {
			
			dscpPredicate = dscpPredicate.and( [ i, c | if(c instanceof Type) superType.isAssignableFrom((c as Type).datatype.class) else false] )
			
			this
		}

		def Predicate isNonAbstractEntity() {
			
			dscpPredicate = dscpPredicate.and( [ i, c | {
				switch(c) {
					Entity:
						!c.abstract
					default:
						false
				}
			}])
			
			this
		}
		
		def Predicate isAbstractEntity() {
			
			dscpPredicate = dscpPredicate.and( [ i, c | {
				switch(c) {
					Entity:
						c.abstract
					default:
						false
				}
			}])
			
			this
		}
		
		def Predicate hasUnidirectionalRelation() {
			
			dscpPredicate = dscpPredicate.and( [ i, c | {
				
				switch(c) {
					Entity:
						c.attribute.exists[ i.isUnidirectionalRelation(it) ]
					default:
						false
				}
			}])
			
			this			
		}

		def Predicate isTrue(BiPredicate<XcoreInfo, ExpressConcept> predicate) {
			
			dscpPredicate = dscpPredicate.and(predicate)
			
			this
		}				
	}
	
	
	/**
	 * A procedural package descriptor which relies on functional descriptions.
	 */
	static class FunctionalDescriptor {
		
		// A predicate which indicates to apply this descriptor
		val BiPredicate<XcoreInfo, ExpressConcept> predicate
		// A function of parent descriptor & current concept which returns a package descriptor 
		val BiFunction<FunctionalDescriptor, ExpressConcept, XcorePackageDescriptor> function
		// The parent
		var FunctionalDescriptor parent
		
		new(FunctionalDescriptor parent, BiPredicate<XcoreInfo, ExpressConcept> predicate, BiFunction<FunctionalDescriptor, ExpressConcept, XcorePackageDescriptor> packageFunction) {
			
			this.predicate = predicate
			this.function = packageFunction
			this.parent = parent
		}

		new(FunctionalDescriptor parent, BiPredicate<XcoreInfo, ExpressConcept> predicate, String subPackage) {
			
			this.predicate = predicate
			this.function = [p, c| new XcoreGenericSubPackageDescriptor(p.apply(c), subPackage)]
			this.parent = parent
		}
		
		new(XcorePackageDescriptor baseDescriptor) {
			
			this.predicate = [i, c | true]
			this.function = [p, c | baseDescriptor]
			this.parent = null
		}
		
		
		def int getStage() {
			
			if(null==parent) 0 else parent.stage + 1
		}
		
				
		
		def boolean isApplicable(XcoreInfo i, ExpressConcept c) {
			
			predicate.test(i, c)
		}
		
		def XcorePackageDescriptor apply(ExpressConcept c) {
			
			function.apply(this,c)
		}
		
		def Function<ExpressConcept, XcorePackageDescriptor> apply(FunctionalDescriptor other) {
			
			[ c | function.apply(other,c) ]
		}
		
		def FunctionalDescriptor concat(FunctionalDescriptor child) {
			
			new FunctionalDescriptor(this, child.predicate, child.function)
		}
				
	}
	
	
	new(XcorePackageDescriptor baseDescriptor) {
	
		functionalDescriptors += new FunctionalDescriptor(baseDescriptor)
	}
	
	new(FunctionalDescriptor pd) {
		
		functionalDescriptors += pd
	}
	
	def void append(FunctionalDescriptor pd) {
		
		if(!functionalDescriptors.contains(pd)) {
			// Add and sort descending by tree depth
			functionalDescriptors += pd
			Collections.sort(functionalDescriptors, [a, b | b.stage - a.stage]);			
		}
	}
	
	
	override apply(ExpressConcept t) {
				
		val pSet = <FunctionalDescriptor>newHashSet
		val sequence = <FunctionalDescriptor>newArrayList
		var cStage = 0
		
		for( pd : functionalDescriptors.filter[ p | p.isApplicable(info, t)]) {
			// Scan through applicable descriptors
			
			var d = pd
			while( null!=d && !pSet.contains(d)) {

				pSet += d
				
				while(cStage>0 && sequence.get(cStage-1).stage >= d.stage) {
					// Scan backwards to find proper insertion index
					cStage--
				}
			
				// And linearize it 	
				sequence.add(cStage, d)
				d = d.parent
			}
			
			cStage = sequence.length
		}
		
		if(sequence.empty) {
			
			return Optional.empty
		}
		
		var FunctionalDescriptor pHead = sequence.get(0)
		for(var i=1; i<sequence.length; i++) {
			
			pHead = pHead.concat(sequence.get(i))
		}
		
		Optional.ofNullable(pHead.apply(t))
	}
	
	override setSchemeInfo(XcoreInfo info) {
		
		this.info = info
	}
	
	
}