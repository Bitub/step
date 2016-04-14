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
package de.bitub.step.analyzing

import de.bitub.step.analyzing.EXPRESSModelInfo.ReducedSelect
import de.bitub.step.express.Attribute
import de.bitub.step.express.Entity
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import javax.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName

import static extension de.bitub.step.util.EXPRESSExtension.*

class EXPRESSInterpreter {

	@Inject extension IQualifiedNameProvider nameProvider

	val static Logger LOGGER = Logger.getLogger(EXPRESSInterpreter);
	
	def protected processSelectReduction(EXPRESSModelInfo info, Schema schema) {
		
		LOGGER.info('''«schema.name»: Processing select reference check.''')
		
		for(Entity e : schema.entity) {
			
			e.attribute
				.filter[type.refersDatatype instanceof SelectType && !info.isInverseRelation(it)]
				.forEach[info.reducedSelectsMap.put(type.refersDatatype.eContainer as Type, newArrayList)]
		}
		
		LOGGER.info('''«schema.name»: Processing select map-reduction.''')
		
		for(Type t : info.reducedSelectsMap.keySet) {

			var reducedMap = <QualifiedName, ReducedSelect>newHashMap			
			for(ExpressConcept c : (t.datatype as SelectType).flattenSelect) {
								
				switch(c) {
				
					Entity: {
					
						var qn = info.getQualifiedReference(c)
						var ReducedSelect reducedConcept = reducedMap.get(qn)						
						if(null==reducedConcept) {
							// Create a new 
							reducedConcept = new ReducedSelect(c)
							reducedMap.put(qn, reducedConcept)
							info.reducedSelectsMap.get(t) += reducedConcept
						} else {
							// Add to existing (should not happen)
							LOGGER.debug(''' Detected duplicate concept «c.name» with QN «qn» in select «t.name».''')
						}	
						
						reducedConcept.mappedConcepts += c
					}					
					Type: {
						
						// If no aggregated builtin use type otherwise builtin
						
						var qn = info.getQualifiedReference(if(c.builtinAlias && !c.aggregation) c.datatype else c)						
						var reducedConcept = reducedMap.get(qn)
						if(null==reducedConcept) {
								
							reducedConcept = new ReducedSelect(c)		
							reducedMap.put(qn, reducedConcept)
							info.reducedSelectsMap.get(t) += reducedConcept						
						} 
						
						reducedConcept.mappedConcepts += c					
					}						
				}	
			}
		}
	} 
	
	/**
	 * Computes flattened select type references as finite closure of referenced concepts. 
	 */
	def protected processSelectResolution(EXPRESSModelInfo info, Schema schema) {

		LOGGER.info('''«schema.name»: Processing select resolution.''')

		// Filter for simplified type selects
		//
		for (Type t : schema.type.filter[it.datatype instanceof SelectType]) {

			val conceptSet = flattenSelect(t.datatype as SelectType)
			info.resolvedSelectsMap.put(t, conceptSet)
		}
	}
	
	/**
	 * Computes all inverse relations into schema info.
	 */
	def protected processRelations(EXPRESSModelInfo info, Schema schema) {
		
		LOGGER.info('''«schema.name»: Processing inverse relationship mapping.''')
		
		for (Entity entity : schema.entity.filter[attribute.exists[opposite != null]]) {
			
			for (Attribute attribute : entity.attribute.filter[opposite != null]) {
				
				// Add opposite versus declaring attribute
				//
				var inverseAttributeSet = info.inverseReferenceMap.get(attribute.opposite)
				if (null == inverseAttributeSet) {
										
					info.inverseReferenceMap.put(attribute.opposite, inverseAttributeSet = newHashSet)
				}

				inverseAttributeSet += attribute				
			}
		}
	}
	
		

	/**
	 * Start processing schema for collecting and analyzing the given schema.
	 * The XcoreGenerator make makes model transformation based on this data. 
	 */
	def EXPRESSModelInfo process(Schema schema) {

		var info = new EXPRESSModelInfo(schema,nameProvider)

		// Register invers relations
		processRelations(info, schema)
		
		// Flatten selects
		processSelectResolution(info, schema)
		
		// Will map reduce selects of non-inverse relationsships
		processSelectReduction(info, schema)
		
				
		info
	}




}