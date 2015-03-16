/* 
 * Copyright (c) 2015  Bernold Kraft and others (Berlin, Germany).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *  Bernold Kraft - initial implementation and initial documentation
 */

package de.bitub.step.generator

import de.bitub.step.express.Attribute
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.CollectionType
import de.bitub.step.express.DataType
import de.bitub.step.express.Entity
import de.bitub.step.express.EnumType
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.ExpressPackage
import de.bitub.step.express.GenericType
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import java.util.Set
import javax.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider

/**
 * Generates code from your model files on save. 
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class XcoreGenerator implements IGenerator {
		
	val static Logger myLog = Logger.getLogger(XcoreGenerator);
	
	val static builtinMappings =  <EClass, String>newHashMap(
		ExpressPackage.Literals.INTEGER_TYPE -> "int",
		ExpressPackage.Literals.NUMBER_TYPE -> "double",
		ExpressPackage.Literals.LOGICAL_TYPE -> "BooleanObject",
		ExpressPackage.Literals.BOOLEAN_TYPE -> "boolean",
		ExpressPackage.Literals.BINARY_TYPE -> "Binary",
		ExpressPackage.Literals.REAL_TYPE -> "double",
		ExpressPackage.Literals.STRING_TYPE -> "String"
	);
	
	
	@Inject
	IQualifiedNameProvider nameProvider; 
	
	var resolvedSelectsMap = <Type, Set<ExpressConcept>>newHashMap()
	var inverseReferenceMap = <Attribute, Set<Attribute>>newHashMap()
	var secondOrderCache = ''''''
	
	var projectFolder = "<project folder>";
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
							
							
		myLog.info("Generating XCore representation of "+schema.name)
		fsa.generateFile(schema.name+".xcore", schema.compileSchema)
	}
	
	/**
	 * Sets the project folder for Xcore code generation.
	 */
	def setProjectFolder(String prjFolder) {
		
		projectFolder = prjFolder;
	}
	
	/**
	 * Compiles Xcore from given EXPRESS resource.
	 */
	def compile(Resource resource) {
				
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
		
		schema.preprocess
		schema.compileSchema
	}
		
	/**
	 * Compiles the header / annotation information on top of the Xcore file.
	 */
	def compileHeader(Schema s) 
'''
@Ecore(nsPrefix="«s.name»",nsURI="http://example.org/«s.name»")
@Import(ecore="http://www.eclipse.org/emf/2002/Ecore")
@GenModel(
	modelDirectory="«projectFolder»/src-gen"
	 
// UNCOMMENT THESE LINES TO HAVE ECLIPSE CDO WORKING.

//	rootExtendsInterface="org.eclipse.emf.cdo.CDOObject", 
//	rootExtendsClass="org.eclipse.emf.internal.cdo.CDOObjectImpl", 
//	importerID="org.eclipse.emf.importer.ecore", 
//	featureDelegation="Dynamic", 
//	providerRootExtendsClass="org.eclipse.emf.cdo.edit.CDOItemProviderAdapter"
)	
'''		
	
	/**
	 * Determines the set of express concepts represented by given Select statement.
	 */
	def static Set<ExpressConcept> selectSet(ExpressConcept t) {
		
		val uniqueTypeSet = <ExpressConcept>newHashSet
		
		if(t instanceof Type) {
			if(t.datatype instanceof SelectType) {
				
				// Self evaluation
				var set = (t.datatype as SelectType).select
					.filter[!(it instanceof Type && (it as Type).datatype instanceof SelectType)]
					.toSet;
				
				// Recursion
				(t.datatype as SelectType).select
					.filter[it instanceof Type && (it as Type).datatype instanceof SelectType]
					.forEach[uniqueTypeSet+=selectSet(it)]
				
				uniqueTypeSet += set	
			}
		}
		
		uniqueTypeSet
	}
	
	/**
	 * Check whether there are any entity concepts inside set.
	 */
	def static isEntityCompositeSelect(Set<ExpressConcept> selects) {
	
		selects.exists[it instanceof Entity]	
	}
	
	/**
	 * Check whether the collection types are identically.
	 */
	def static boolean isUniqueCollectionSelect(Iterable<CollectionType> aggregationTypes) {
		
		// Check unique aggregation type
		if(aggregationTypes.map[name].toSet.size > 1) {
			
			return false
		}
		
		val nonNullLowerBound = aggregationTypes.findFirst[lowerBound > 0]
		// If there any non-null lower bound
		if(null!=nonNullLowerBound 
			&& aggregationTypes.filter[lowerBound != nonNullLowerBound.lowerBound ].size > 1
		) {
			// False, if there are multiple lower bounds
			return false;
		}

		val nonNullUpperBound = aggregationTypes.findFirst[upperBound > 0]
		// If there any non-null upper bound
		if(null!=nonNullLowerBound 
			&& aggregationTypes.filter[upperBound != nonNullUpperBound.upperBound ].size > 1
		) {
			// False if there are multiple upper bounds
			return false;
		}
		
		val nestedCollections = aggregationTypes.filter[it.type instanceof CollectionType];
		if(!nestedCollections.empty) {
			// If there are nested aggregations
			if(nestedCollections.size < aggregationTypes.size) {
				
				return false
				
			} else {
				// Check nested aggregation
				return isUniqueCollectionSelect(nestedCollections.map[type as CollectionType])
			}
		}
				
		val typeSet = aggregationTypes.map[it.type.eClass].toSet
		if(typeSet.size>1) {
			
			return false
		}
		
		// Check if concept
		if(aggregationTypes
			.filter[it.type instanceof ExpressConcept]
			.map[(it.type as ExpressConcept).name].toSet.size > 1
		) {
			return false
		}
		
		return true
	}
	
	/**
	 * Checks whether select is a unique alias select (only semantics changes)
	 */
	def static isUniqueAliasSelect(Set<ExpressConcept> selects) {
		
		// Filter for aggregations
		val aggregationTypes = selects.filter[
			it instanceof Type && (it as Type).datatype instanceof CollectionType
		].map[(it as Type).datatype as CollectionType];
		
		var isAggregationSelect = !aggregationTypes.empty
		if(isAggregationSelect) {
			if(!isUniqueCollectionSelect(aggregationTypes)) {
				return false;
			}			
		}
		
		// Test for builtin selects
		val builtinSelects = selects.filter[
			it instanceof Type && (it as Type).datatype instanceof BuiltInType 
		].map[(it as Type).datatype as BuiltInType]
		
		var isBuiltinSelect = !builtinSelects.empty;
		if(isAggregationSelect && isBuiltinSelect) {
			
			return false;
		
		}		
				
		if(builtinSelects.map[eClass].toSet.size > 1) {
			
			// TODO Test number types
		}
		
		// Test for generic selects
		val genericSelects = selects.filter[
			it instanceof Type && (it as Type).datatype instanceof GenericType 
		].map[(it as Type).datatype as GenericType]
		
		var isGenericSelect = !genericSelects.empty
		// TODO
		
	}
	
	/**
	 * True if attribute's type is a one to many relation
	 */
	def isOneToManyRelation(Attribute a) {
		
		if(a.type instanceof CollectionType) {
			
			val t = a.type as CollectionType
			
			return t.upperBound > 1 
				|| t.many 
				|| t.upperRef != null 
				|| t.lowerRef != null
				|| t.refersConcept instanceof Type
		}
		
		false
	}
	
	/**
	 * If type is an alias type (simple type wrapper)
	 */
	def boolean isNamedAlias(ExpressConcept e) {
		
		if(e instanceof Type) {
		
			val t = e as Type			
			!(t.datatype instanceof SelectType || t.datatype instanceof EnumType)				
							
		} else {
		
			false
		}		
	}

	/**
	 * True, if builtin type reference (primitive or aggregation)
	 */
	def boolean isBuiltinAlias(ExpressConcept e) {
		
		if(e instanceof Type) {
		
			(e as Type).datatype.builtinAlias
						
		} else {
		
			false
		}		
	}
	
	
	def boolean isBuiltinAlias(DataType t) {
		
		if(t instanceof CollectionType) {
			
			(t as CollectionType).type.builtinAlias
				
		} else if(t instanceof ReferenceType) {
			
			(t as ReferenceType).instance.builtinAlias
		} else {
						
			t instanceof BuiltInType 				
		}		
	}
	

	/**
	 * Returns the opposite attribute(s) of given attribute or null, if there's no inverse
	 * relation.
	 */
	def Set<Attribute> refersOppositeAttribute(Attribute a) {
		
		if(null!=a.opposite) {
			
		 	newHashSet(a.opposite)
		} else {
			
			if(inverseReferenceMap.containsKey(a)) {
				
				inverseReferenceMap.get(a)
			}
		}
	}
	
	
	/**
	 * Returns the transitively referred concept, if there's any referenced
	 */
	def ExpressConcept refersConcept(DataType dataType) {
		
		if(dataType instanceof ReferenceType) {
			
			(dataType as ReferenceType).instance
				
		} else if(dataType instanceof CollectionType) {
			
			(dataType as CollectionType).type.refersConcept
		} else {
		
		   null
		}
	}


	/**
	 * Returns the parent attribute of a specific data type.
	 */
	def parentAttribute(DataType t) {

		var eAttr = t.eContainer
		while(null!=eAttr && !(eAttr instanceof Attribute)) {
			eAttr = eAttr.eContainer
		}
		eAttr as Attribute
	}

		
	/**
	 * Pre-processes the scheme before generating any code.
	 *  - Registering and flattening select types with composite entities
	 *  - Simplifying selects with unique builtin type
	 * 
	 * 
	 */
	def preprocess(Schema s) {
		
		// Filter for simplified type selects
		myLog.info("Processing selects...")
		for(Type t : s.types.filter[it.datatype instanceof SelectType]) {
			
			val conceptSet = selectSet(t)
			myLog.debug("~> \""+t.name+"\" resolves to "+conceptSet.size+" sub concepts")
		
			resolvedSelectsMap.put(t, conceptSet)
		}
				
		myLog.info("Processing inverse n-m relations ...")
		for(Entity e : s.entities.filter[attribute.exists[opposite!=null]]) {
						
			// Filter for both sided collection types, omit any restriction (cardinalities etc.)
			for(Attribute a : e.attribute.filter[
				opposite!=null && oneToManyRelation && opposite.oneToManyRelation 				
			]) {

				val oppositeEntity = a.opposite.eContainer as ExpressConcept;				
				myLog.debug("~> "+(a.eContainer as Entity).name+"."+a.name+" <--> "+oppositeEntity.name+"."+a.opposite.name)
		
				var inverseAttributeSet = inverseReferenceMap.get(a.opposite)
				if(null==inverseAttributeSet) {
					inverseAttributeSet = newHashSet()
					inverseReferenceMap.put(a.opposite, inverseAttributeSet)
				}
				
				inverseAttributeSet += a
			}
		}
		
		myLog.info("Pre-compilation phase finished.")
	}
		

	// --- GENERATOR CODE ------------------------------------


	/**
	 * Transforms a schema into a package definition.
	 */
	def compileSchema(Schema s) 
'''	
«compileHeader(s)»

// THIS FILE IS GENERATED. ANY CHANGE WILL BE LOST.

@GenModel(documentation="Generated EXPRESS model of schema «s.name»")
@XpressModel(name="«s.name»")		
package «s.name.toLowerCase» 

import org.eclipse.emf.ecore.xml.^type.BooleanObject

annotation "http://www.eclipse.org/OCL/Import" as Import
annotation "http://www.bitub.de/express/XpressModel" as XpressModel
		
// Additional datatype for binary
type Binary wraps java.util.BitSet
		
// Base container of «s.name»
@GenModel(documentation="Generated container class of «s.name»")
@XpressModel(entity="new",type="container")
class «s.name» {

«FOR e:s.entities.filter[!abstract]»  contains «e.name.toFirstUpper»[] «e.name.toFirstLower»
«ENDFOR»

}

// --- TYPE DEFINITIONS ------------------------------

«FOR t:s.types»«t.compileConcept»«ENDFOR»

// --- ENTITY DEFINITIONS ----------------------------

«FOR e:s.entities»«e.compileConcept»«ENDFOR»
	
// --- END OF «s.name» ---
'''		
	
	/**
	 * Transforms an entity into a class definition. 
	 */	
	def dispatch compileConcept(Entity e) {
		
'''

@GenModel(documentation="Entity of «e.name»")
«IF e.abstract»abstract «ENDIF»class «e.name.toFirstUpper» «IF !e.supertype.empty»extends «e.supertype.map[name].join(', ')» «ENDIF»{

}
'''
	}
	
	/**
	 * Transforms a type into a class / type definition.
	 */
	def dispatch compileConcept(Type t) {
		
		if(t.datatype instanceof GenericType) {
			// Wraps String			
'''

type «t.name.toFirstUpper» wraps String
'''

		} else if(t.datatype instanceof EnumType) {
			// Compile enum
'''

@GenModel(documentation="Enumeration of «t.name»")
enum «t.name.toFirstUpper» {
				
	«t.datatype.compileDatatype»
}
'''
		} else if(t.datatype instanceof SelectType) {
			
			// Compile select
'''

@GenModel(documentation="Select of «t.name»")
class «t.name.toFirstUpper» {

	«t.datatype.compileDatatype»	
}
'''			
		} else if(t.datatype instanceof BuiltInType) {
			
'''

// Type «t.name» is a built-in primitive type (using «de.bitub.step.generator.XcoreGenerator.builtinMappings.get(t.datatype.eClass)»)
'''			
						
		} else if(t.datatype instanceof ReferenceType) {
			
'''

// Type «t.name» not generated. It is an alias of «(t.datatype as ReferenceType).instance.name»
'''			
			
		} else if(t.datatype instanceof CollectionType) {
			
'''

// Type «t.name» not generated. It is a named aggregation (using «t.datatype.compileDatatype»)
'''			
		} else {
			
'''

// WARNING: UNKNOWN TYPE «t.name» IS NOT MAPPED. DATATYPE PARSED AS «t.datatype.eClass.name»
'''			
		}
	}
	
	/**
	 * Transforms a Select into a class specification.
	 */
	def dispatch compileDatatype(SelectType s) {
		
		val conceptSet = resolvedSelectsMap.get(s.eContainer)
		
'''   
   «FOR c : conceptSet.filter[it instanceof Entity]»
   refers «c.name.toFirstUpper» «c.name.toFirstLower»
   «ENDFOR»
   «FOR t : conceptSet.filter[it instanceof Type].map[it as Type]»
   «IF t.namedAlias && !t.builtinAlias»refers «ENDIF»«t.datatype.referDatatype» «t.name.toFirstLower»
   «ENDFOR»
'''
	}


	
	//// ---- REFERENCE DISPATCH
	
	def dispatch referDatatype(EnumType t) {
		
'''«(t.eContainer as Type).name.toFirstUpper»'''

	}

	
	def dispatch referDatatype(ReferenceType r) {
		
'''«IF r.instance instanceof Type 
		&& (r.instance as Type).isNamedAlias»«(r.instance as Type).datatype.compileDatatype»«ELSE»«r.instance.name.toFirstUpper»«ENDIF»'''
		
	}

	
	def dispatch referDatatype(BuiltInType b) {
		
'''«de.bitub.step.generator.XcoreGenerator.builtinMappings.get(b.eClass)»'''

	}	

	
	def dispatch referDatatype(GenericType g) {
		
'''«(g.eContainer as ExpressConcept).name.toFirstUpper»'''

	}

	
	def dispatch referDatatype(CollectionType c) {
		
		c.compileDatatype
	}
	
		
	def generateNestedCollector(String containerName, CollectionType nestedCol) {
		
		// Generate nested class
		secondOrderCache +=
'''
class «containerName.toFirstUpper» {
	
	
}
'''

	}
		
	def dispatch compileDatatype(CollectionType c) {
		
		// If nested but not datatype
		if(c.type instanceof CollectionType && !c.type.refersConcept.builtinAlias) {
			
			// Builtin type or entity ?
			val qualifiedName = nameProvider.getFullyQualifiedName(c.eContainer)
			
		}
		
'''«IF !#["ARRAY","LIST"].contains(c.name)»unordered «ENDIF»«IF "SET"==c.name»unique «ENDIF»«c.type.referDatatype»[]'''

	}
	
	def dispatch compileDatatype(ReferenceType r) {
						
'''«IF r.instance instanceof Type 
		&& (r.instance as Type).isNamedAlias»«(r.instance as Type).datatype.compileDatatype»«ELSE»«r.instance.name.toFirstUpper»«ENDIF»'''
		
	}
		
	def dispatch compileDatatype(BuiltInType builtin) {
		
'''«de.bitub.step.generator.XcoreGenerator.builtinMappings.get(builtin.eClass)»'''

	}
		
	def dispatch compileDatatype(EnumType t) {
		
'''«t.literal.map[name].join(", ")»'''

	}	
	
		
	/**
	 * Compiles a single attribute.
	 */
	def compileAttribute(Attribute a) {

//		'''«IF null!=a.opposite && inverseReferenceMap.containsKey(a.opposite)
//				»contains «
//			ELSEIF a.type instanceof ReferenceType || a.type instanceof CollectionType
//				»refers «
//			ENDIF»«
//			IF null!=a.expression
//				»derived «
//			ENDIF»«
//			 
//			a.type.compileDatatype» «a.name.toFirstLower» «
//			
//			IF null!=a.opposite && !inverseReferenceMap.containsKey(a.opposite)
//				»opposite «a.opposite.name.toFirstLower»«ENDIF»'''		
	}
	

		

}		