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
import java.util.Collections
import java.util.Iterator
import java.util.List
import java.util.Optional
import java.util.Stack
import java.util.function.BiFunction
import java.util.function.Function
import java.util.function.Predicate
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
	
	val List<FunctionalDescriptor> proceduralDescriptors = newArrayList
	var XcoreInfo info
	
	static class Predicates {
		
		def static getTypeLevel(ExpressConcept c) {
						
			switch(c) {
				Type: {
					
					0					
				}
				Entity: {
					
					var mLevel = 0
					var cLevel = 0
					
					val stack = new Stack<Iterator<Entity>>()
					stack.push(c.supertype.iterator)
					
					while(!stack.isEmpty) {
						
						val iterator = stack.peek
						if(iterator.hasNext) {
							
							cLevel++
							mLevel = Math.max(cLevel, mLevel)
														
							val entity = iterator.next
							stack.push(entity.supertype.iterator)
							
						} else {
							
							cLevel--
							stack.pop
						}
					}
					
					mLevel
				}	
			}
		}
		
	}
	
	/**
	 * A procedural package descriptor which relies on functional descriptions.
	 */
	static class FunctionalDescriptor {
		
		// A predicate which indicates to apply this descriptor
		val Predicate<ExpressConcept> predicate
		// A function of parent descriptor & current concept which returns a package descriptor 
		val BiFunction<FunctionalDescriptor, ExpressConcept, XcorePackageDescriptor> function
		// The parent
		var FunctionalDescriptor parent
		
		new(FunctionalDescriptor parent, Predicate<ExpressConcept> predicate, BiFunction<FunctionalDescriptor, ExpressConcept, XcorePackageDescriptor> packageFunction) {
			
			this.predicate = predicate
			this.function = packageFunction
			this.parent = parent
		}

		new(FunctionalDescriptor parent, Predicate<ExpressConcept> predicate, String subPackage) {
			
			this.predicate = predicate
			this.function = [p, c| new XcoreGenericSubPackageDescriptor(p.apply(c), subPackage)]
			this.parent = parent
		}
		
		new(XcorePackageDescriptor baseDescriptor) {
			
			this.predicate = [c | true]
			this.function = [p, c | baseDescriptor]
			this.parent = null
		}
		
		def int getStage() {
			
			if(null==parent) 0 else parent.stage + 1
		}
		
		/**
		 * Filters for entities above given level.
		 */
		def static FunctionalDescriptor isLeastInheritanceLevel(FunctionalDescriptor parent, int superEntities, String packageName) {
			
			new FunctionalDescriptor(parent,
					[ ExpressConcept c | Predicates.getTypeLevel(c) >= superEntities ],
					[ p, c | {
						new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)
					}]
			)										
		}

		/**
		 * A descriptor which will generate a sub package by level between [0..n]. If no fragments are given,
		 * the level itself will be taken as argument to the template (i.e. holding an "%d" expression).
		 */
		def static FunctionalDescriptor isAtInheritanceLevel(FunctionalDescriptor parent, String packageNameTemplate, String ... fragments) {
			
			if(fragments.empty) {
				
				new FunctionalDescriptor(parent,
					[ ExpressConcept c | true ],
					[ p, c | {
						new XcoreGenericSubPackageDescriptor(p.apply(c), String.format(packageNameTemplate, Predicates.getTypeLevel(c)))
					}]
				)							
			} else {
				
				new FunctionalDescriptor(parent,
					[ ExpressConcept c | true ],
					[ p, c | {
						
						val maxLevel = Predicates.getTypeLevel(c)						
						new XcoreGenericSubPackageDescriptor(
							p.parent.apply(c), String.format(packageNameTemplate, if(maxLevel>=fragments.length) fragments.length-1 else maxLevel) 
						)
					}]
				)											
			}
		}
		
		def static FunctionalDescriptor isNamedLike(FunctionalDescriptor parent, String regularExpr, String packageName) {

			val Pattern pattern = Pattern.compile(regularExpr)
			new FunctionalDescriptor(parent,
				[ ExpressConcept c | pattern.matcher(c.name).find ],
				[ p, c | new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)]
			)			
		}
		
		def static FunctionalDescriptor isDataTypeOf(FunctionalDescriptor parent, Class<?> type, String packageName) {
			
			new FunctionalDescriptor(parent,
				[ ExpressConcept c | if(c instanceof Type) type == (c as Type).datatype.class else false],
				[ p, c | new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)]
			)
		}		

		def static FunctionalDescriptor isDataKindOf(Class<?> superType, String packageName) {
			
			isDataKindOf(null, superType, packageName)
		}
		
		def static FunctionalDescriptor isDataKindOf(FunctionalDescriptor parent, Class<?> superType, String packageName) {

			new FunctionalDescriptor(parent,
				[ ExpressConcept c | if(c instanceof Type) superType.isAssignableFrom((c as Type).datatype.class) else false],
				[ p, c | new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)]
			)			
		}
		
		def static FunctionalDescriptor isTrue(FunctionalDescriptor parent, Predicate<ExpressConcept> predicate, String packageName) {

			new FunctionalDescriptor(parent,
				predicate,
				[ p, c | new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)]
			)			
		}
				
		
		def boolean isApplicable(ExpressConcept c) {
			
			predicate.test(c)
		}
		
		def XcorePackageDescriptor apply(ExpressConcept c) {
			
			function.apply(parent,c)
		}
		
		def Function<ExpressConcept, XcorePackageDescriptor> apply(FunctionalDescriptor otherParent) {
			
			[ c | function.apply(otherParent,c) ]
		}
		
		def FunctionalDescriptor concat(FunctionalDescriptor child) {
			
			new FunctionalDescriptor(this, child.predicate, child.function)
		}
				
	}
	
	
	new(XcorePackageDescriptor baseDescriptor) {
	
		proceduralDescriptors += new FunctionalDescriptor(baseDescriptor)
	}
	
	new(FunctionalDescriptor pd) {
		
		proceduralDescriptors += pd
	}
	
	def void append(FunctionalDescriptor pd) {
		
		if(!proceduralDescriptors.contains(pd)) {
			// Add and sort descending by tree depth
			proceduralDescriptors += pd
			Collections.sort(proceduralDescriptors, [a, b | b.stage - a.stage]);			
		}
	}
	
	
	override apply(ExpressConcept t) {
				
		val pSet = <FunctionalDescriptor>newHashSet
		val sequence = <FunctionalDescriptor>newArrayList
		var cStage = 0
		
		for( pd : proceduralDescriptors.filter[ p | p.isApplicable(t)]) {
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