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

import de.bitub.step.express.Attribute
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.Entity
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import de.bitub.step.util.EXPRESSExtension
import java.util.Set
import javax.inject.Inject
import org.apache.log4j.Logger
import de.bitub.step.analyzing.EXPRESSModelInfo.ReducedSelect
import org.eclipse.xtext.naming.IQualifiedNameProvider

class EXPRESSInterpreter {

	@Inject extension EXPRESSExtension modelExtension
	
	@Inject extension IQualifiedNameProvider nameProvider

	val static Logger LOGGER = Logger.getLogger(EXPRESSInterpreter);
	
	/**
	 * Computes the non-relational selects
	 */
	def processSelectReferences(EXPRESSModelInfo info, Schema schema) {
		
		LOGGER.info('''«schema.name»: Processing select reference check.''')
		
		for(Entity e : schema.entity) {
			
			e.attribute
				.filter[type.refersDatatype instanceof SelectType && !info.isInverseRelation(it)]
				.forEach[info.reducedSelectsMap.put(type.refersDatatype.eContainer as Type, newArrayList)]
		}
		
		LOGGER.info('''«schema.name»: Processing select map-reduction.''')
		
		for(Type t : info.reducedSelectsMap.keySet) {
			
			for(ExpressConcept c : (t.datatype as SelectType).flattenSelect) {
				
				switch(c) {
					
					Entity: {
					
						info.reducedSelectsMap.get(t) += new ReducedSelect(c)	
					}					
					Type: {
						
						(c as Type).builtinAlias
					}						
				}	
			}
		}
	} 
	
	/**
	 * Computes flattened select type references as finite closure of referenced concepts. 
	 */
	def processSelectResolution(EXPRESSModelInfo info, Schema schema) {

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
	def processRelations(EXPRESSModelInfo info, Schema schema) {
		
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
	 * Computes all alias mappings.
	 */
	def processAliasTypes(EXPRESSModelInfo info, Schema schema) {
		
		LOGGER.info('''Processing alias mapping of «schema.name».''')
		
		for(Type t : schema.type) {
			
			switch(t.datatype) {
				
				BuiltInType:
					LOGGER.debug(
						'''Type "«t.name»" maps onto "«t.datatype.eClass.name»".'''
					)
				
				ReferenceType: {
					// Map type by references concept
					var transitiveConcept = t.datatype.refersConcept
					info.aliasConceptMap.put(t, transitiveConcept)
					LOGGER.info(
						'''Mapping type "«t.name»" onto "«transitiveConcept.name»".'''
					)					
				}
				default: {				
				}
			}
		}		
	}
		

	/**
	 * Start processing schema for collecting and analyzing the given schema.
	 * The XcoreGenerator make makes model transformation based on this data. 
	 */
	def EXPRESSModelInfo process(Schema schema) {

		var info = new EXPRESSModelInfo(schema,nameProvider)
		
		// Flatten selects
		processSelectResolution(info, schema)
		
		// Register invers relations
		processRelations(info, schema)
		
		// Register alias types
		processAliasTypes(info, schema)
		
		info
	}



	/**
	 * Determines the flat set of EXPRESS concepts represented by given Select statement.
	 */
	def static Set<ExpressConcept> flattenSelect(SelectType selectType) {

		val uniqueTypeSet = <ExpressConcept>newHashSet


		// Self evaluation
		var set = selectType.select.filter [
			!(it instanceof Type && (it as Type).datatype instanceof SelectType)
		].toSet;

		// Recursion (filter all SELECTs)
		selectType.select.filter [
			it instanceof Type && (it as Type).datatype instanceof SelectType
		].forEach[uniqueTypeSet += flattenSelect((it as Type).datatype as SelectType)]

		uniqueTypeSet += set
		
		return uniqueTypeSet
	}
}