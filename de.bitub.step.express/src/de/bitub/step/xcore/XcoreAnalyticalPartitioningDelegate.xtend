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
import java.util.Iterator
import java.util.List
import java.util.Optional
import java.util.Stack
import java.util.function.BiFunction
import java.util.function.Function
import java.util.function.Predicate
import java.util.regex.Pattern
import java.util.Collections

/**
 * An analytical & procedural package partitioning delegate.
 * 
 * <p>
 * Procedural descriptors form up a tree where each path represents a qualified package descriptor chain. 
 * If multiple descriptors match the given concept, path candidates are merged by levels in order of input sequence when appending new
 * descriptors. Later added descriptors will placed as super packages while the earliest added represents the tail.
 * </p>
 */
class XcoreAnalyticalPartitioningDelegate implements Function<ExpressConcept, Optional<XcorePackageDescriptor>> {
	
	val List<ProceduralDescriptor> proceduralDescriptors = newArrayList
	
	/**
	 * A procedural package descriptor which relies on functional descriptions.
	 */
	static class ProceduralDescriptor {
		
		// A predicate which indicates to apply this descriptor
		val Predicate<ExpressConcept> predicate
		// A function of parent descriptor & current concept which returns a package descriptor 
		val BiFunction<ProceduralDescriptor,ExpressConcept, XcorePackageDescriptor> function
		// The parent
		var ProceduralDescriptor parent
		
		new(ProceduralDescriptor parent, Predicate<ExpressConcept> predicate, BiFunction<ProceduralDescriptor, ExpressConcept, XcorePackageDescriptor> packageFunction) {
			
			this.predicate = predicate
			this.function = packageFunction
			this.parent = parent
		}

		new(ProceduralDescriptor parent, Predicate<ExpressConcept> predicate, String subPackage) {
			
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
		
				
		def static private getMaxSuperTypeLevel(ExpressConcept c) {
						
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
		
		/**
		 * Filters for entities above given level.
		 */
		def static ProceduralDescriptor isLeastInheritanceLevel(ProceduralDescriptor parent, int superEntities, String packageName) {
			
			new ProceduralDescriptor(parent,
					[ ExpressConcept c | c.maxSuperTypeLevel>=superEntities ],
					[ p, c | {
						new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)
					}]
			)										
		}

		/**
		 * A descriptor which will generate a sub package by level between [0..n]. If no fragments are given,
		 * the level itself will be taken as argument to the template (i.e. holding an "%d" expression).
		 */
		def static ProceduralDescriptor isAtInheritanceLevel(ProceduralDescriptor parent, String packageNameTemplate, String ... fragments) {
			
			if(fragments.empty) {
				
				new ProceduralDescriptor(parent,
					[ ExpressConcept c | true ],
					[ p, c | {
						new XcoreGenericSubPackageDescriptor(p.apply(c), String.format(packageNameTemplate, c.maxSuperTypeLevel))
					}]
				)							
			} else {
				
				new ProceduralDescriptor(parent,
					[ ExpressConcept c | true ],
					[ p, c | {
						
						val maxLevel = c.maxSuperTypeLevel						
						new XcoreGenericSubPackageDescriptor(
							p.parent.apply(c), String.format(packageNameTemplate, if(maxLevel>=fragments.length) fragments.length-1 else maxLevel) 
						)
					}]
				)											
			}
		}
		
		def static ProceduralDescriptor isNamedLike(ProceduralDescriptor parent, String regularExpr, String packageName) {

			val Pattern pattern = Pattern.compile(regularExpr)
			new ProceduralDescriptor(parent,
				[ ExpressConcept c | pattern.matcher(c.name).find ],
				[ p, c | new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)]
			)			
		}
		
		def static ProceduralDescriptor isDataTypeOf(ProceduralDescriptor parent, Class<?> type, String packageName) {
			
			new ProceduralDescriptor(parent,
				[ ExpressConcept c | if(c instanceof Type) type == (c as Type).datatype.class else false],
				[ p, c | new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)]
			)
		}		

		def static ProceduralDescriptor isDataKindOf(Class<?> superType, String packageName) {
			
			isDataKindOf(null, superType, packageName)
		}
		
		def static ProceduralDescriptor isDataKindOf(ProceduralDescriptor parent, Class<?> superType, String packageName) {

			new ProceduralDescriptor(parent,
				[ ExpressConcept c | if(c instanceof Type) superType.isAssignableFrom((c as Type).datatype.class) else false],
				[ p, c | new XcoreGenericSubPackageDescriptor(p.apply(c), packageName)]
			)			
		}
		
		def static ProceduralDescriptor isTrue(ProceduralDescriptor parent, Predicate<ExpressConcept> predicate, String packageName) {

			new ProceduralDescriptor(parent,
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
		
		def Function<ExpressConcept, XcorePackageDescriptor> apply(ProceduralDescriptor otherParent) {
			
			[ c | function.apply(otherParent,c) ]
		}
		
		def ProceduralDescriptor concat(ProceduralDescriptor child) {
			
			new ProceduralDescriptor(this, child.predicate, child.function)
		}
				
	}
	
	
	new(XcorePackageDescriptor baseDescriptor) {
	
		proceduralDescriptors += new ProceduralDescriptor(baseDescriptor)
	}
	
	new(ProceduralDescriptor pd) {
		
		proceduralDescriptors += pd
	}
	
	def void append(ProceduralDescriptor pd) {
		
		if(!proceduralDescriptors.contains(pd)) {
			// Add and sort descending by tree depth
			proceduralDescriptors += pd
			Collections.sort(proceduralDescriptors, [a, b | b.stage - a.stage]);			
		}
	}
	
	
	override apply(ExpressConcept t) {
				
		val pSet = <ProceduralDescriptor>newHashSet
		val sequence = <ProceduralDescriptor>newArrayList
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
		
		var ProceduralDescriptor pHead = sequence.get(0)
		for(var i=1; i<sequence.length; i++) {
			
			pHead = pHead.concat(sequence.get(i))
		}
		
		Optional.ofNullable(pHead.apply(t))
	}
	
	
}