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
 * A
 */
class XcoreAnalyticalPackageDescriptor implements Function<ExpressConcept, Optional<XcorePackageDescriptor>> {
	
	val List<ProceduralDescriptor> proceduralDescriptors = newArrayList
	var isOrdered = false
	
	static class ProceduralDescriptor {
		
		val Predicate<ExpressConcept> predicate
		val BiFunction<ProceduralDescriptor,ExpressConcept, XcorePackageDescriptor> function
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
			
			parent?.stage + 1
		}
		
		def setParent(ProceduralDescriptor pd) {
			
			parent = pd
		}
		
		def concat(ProceduralDescriptor ... pd) {
			
			pd.forEach[ parent = this ]
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
						new XcoreGenericSubPackageDescriptor(p.parent.apply(c), packageName)
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
						new XcoreGenericSubPackageDescriptor(p.parent.apply(c), String.format(packageNameTemplate, c.maxSuperTypeLevel))
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
				[ p, c | new XcoreGenericSubPackageDescriptor(p.parent.apply(c), packageName)]
			)			
		}
		
		def static ProceduralDescriptor isTypeOf(ProceduralDescriptor parent, Class<?> type, String packageName) {
			
			new ProceduralDescriptor(parent,
				[ ExpressConcept c | type == c.class],
				[ p, c | new XcoreGenericSubPackageDescriptor(p.parent.apply(c), packageName)]
			)
		}		

		def static ProceduralDescriptor isKindOf(Class<?> superType, String packageName) {
			
			isKindOf(null, superType, packageName)
		}
		
		def static ProceduralDescriptor isKindOf(ProceduralDescriptor parent, Class<?> superType, String packageName) {

			new ProceduralDescriptor(parent,
				[ ExpressConcept c | superType.isAssignableFrom(c.class)],
				[ p, c | new XcoreGenericSubPackageDescriptor(p.parent.apply(c), packageName)]
			)			
		}		
		
		def boolean isApplicable(ExpressConcept c) {
			
			predicate.test(c)
		}
		
		def XcorePackageDescriptor apply(ExpressConcept c) {
			
			function.apply(this,c)
		}
	}
	
	
	new(XcorePackageDescriptor baseDescriptor) {
	
		proceduralDescriptors += new ProceduralDescriptor(baseDescriptor)
	}
	
	new(ProceduralDescriptor pd) {
		
		proceduralDescriptors += pd
	}
	
	def void append(ProceduralDescriptor pd) {
		
		proceduralDescriptors += pd
		isOrdered = false
	}
	
	def private void doSortByStage() {
		
		if(!isOrdered) {
			// Sort descending by stage
			Collections.sort(proceduralDescriptors, [a, b | b.stage - a.stage]);
			isOrdered = true
		}
	}
	
	override apply(ExpressConcept t) {
		
		doSortByStage
		
		var pd = proceduralDescriptors.findFirst[ p | p.predicate.test(t)]
		Optional.ofNullable(pd?.apply(t))
	}
	
	
}