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
 * Generates Xcore specifications from EXPRESS models.
 */
class XcoreGenerator implements IGenerator {
		
	val static Logger myLog = Logger.getLogger(XcoreGenerator);
	
	// Builtin mapping of primitive data types
	val static builtinMappings =  <EClass, String>newHashMap(
		ExpressPackage.Literals.INTEGER_TYPE -> "int",
		ExpressPackage.Literals.NUMBER_TYPE -> "double",
		ExpressPackage.Literals.LOGICAL_TYPE -> "BooleanObject",
		ExpressPackage.Literals.BOOLEAN_TYPE -> "boolean",
		ExpressPackage.Literals.BINARY_TYPE -> "Binary",
		ExpressPackage.Literals.REAL_TYPE -> "double",
		ExpressPackage.Literals.STRING_TYPE -> "String"
	);
	
	
	@Inject	IQualifiedNameProvider nameProvider; 
	
	// Flattened concept set of selects
	var resolvedSelectsMap = <Type, Set<ExpressConcept>>newHashMap
	// Inverse references
	var inverseReferenceMap = <Attribute, Set<Attribute>>newHashMap
	// Nested aggregation as QN to Xcore class name
	var nestedAggregationQN = <String,String>newHashMap()
	// Nested proxies as Attribute to <Class name of proxy, name of opposite Xcore attribute>
	var nestedProxiesQN = <Attribute, Pair<String, String>>newHashMap
	// Maps the type aliases
	var aliasConceptMap = <Type,ExpressConcept>newHashMap
	
	// Second stage cache (any additional concept needed beside first stage)
	var secondOrderCache = ''''''
	
	// Current project folder
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
		schema.compileSchema
	}
		
	/**
	 * Compiles the header / annotation information on top of the Xcore file.
	 */
	def compileHeader(Schema s) { 
		'''
		@Ecore(nsPrefix="«s.name»",nsURI="http://example.org/«s.name»")
		@Import(ecore="http://www.eclipse.org/emf/2002/Ecore")
		@GenModel(
			modelDirectory="«projectFolder»/src-gen"
			 
		// UNCOMMENT THESE LINES TO HAVE ECLIPSE CDO WORKING.
		
		//	rootExtendsInterface="org.eclipse.emf.cdo.CDOObject", 
		//	rootExtendsclassRef="org.eclipse.emf.internal.cdo.CDOObjectImpl", 
		//	importerID="org.eclipse.emf.importer.ecore", 
		//	featureDelegation="Dynamic", 
		//	providerRootExtendsclassRef="org.eclipse.emf.cdo.edit.CDOItemProviderAdapter"
		)	
		'''		
	}
	
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
	 * Refers to itself. No substitution.
	 */
	def dispatch ExpressConcept refersAlias(Entity t) {
		
		t
	}
	
	/**
	 * Resolves alias reference, if there's any.
	 */
	def dispatch ExpressConcept refersAlias(Type t) {
		
		if(t.builtinAlias) {
			// If builtin alias -> no concept at all
			null
		} else {
			// otherwise resolve transitive and return concept container
			t.refersTransitiveDatatype.eContainer as ExpressConcept
		}
	}
	
	
	/**
	 * Returns the transitive associated datatype.
	 */
	def DataType refersTransitiveDatatype(DataType t) {
		
		if(t  instanceof ReferenceType) {
			
			if( (t as ReferenceType).instance instanceof Type) {
				
				((t as ReferenceType).instance as Type).refersTransitiveDatatype
			} else {
				
				t
			} 
		} else if(t instanceof CollectionType) {
			
			(t as CollectionType).type.refersTransitiveDatatype
		} else {
			
			t
		}
	}
	
	def DataType refersTransitiveDatatype(Type t) {
		
		t.datatype.refersTransitiveDatatype
	}

	/**
	 * Compiles an annotation, if an alias exists other returns an empty statement.
	 */	
	def dispatch CharSequence compileInlineAnnotation(Entity t) {
		
		// Empty annotation for entities (done before class statement)
		''''''
	}
	
	/**
	 * Compiles an annotation, if an alias exists other returns an empty statement.
	 */
	def dispatch CharSequence compileInlineAnnotation(Type t) {
	
		// If no alias exists, no annotation
		if(!aliasConceptMap.containsKey(t)) {
		
			return ''''''	
		}
		
		val alias = t.refersTransitiveDatatype
		 
		if(alias instanceof BuiltInType) {
			
			// End point is a builtin datatype
			'''@XpressModel(name="«t.name»",kind="mapped",datatypeRef="«t.datatype.referDatatype»")
			'''
		} else if (alias instanceof ReferenceType) {
			
			val qn = nameProvider.getFullyQualifiedName(t)
			if(nestedAggregationQN.containsKey(qn.toString)) {
								
				'''@XpressModel(name="«t.name»",kind="nested",classRef="«nestedAggregationQN.get(qn.toString)»[]")
				'''
			} else {

				// End point is a reference to an entity
				'''@XpressModel(name="«t.name»",kind="mapped",classRef="«t.datatype.referDatatype»")
				'''			
			}
		} else if (alias instanceof GenericType) {
			
			// End point is a generic datatype wrapper
			'''@XpressModel(name="«t.name»",kind="generic",datatypeRef="«alias.referDatatype»")
			'''
		} else if (alias instanceof SelectType && aliasConceptMap.containsKey(t)) {
			
			// End point is a SelectType
			'''@XpressModel(name="«t.name»",kind="mapped",classRef="«alias.referDatatype»")
			'''
		} else if (aliasConceptMap.containsKey(t)) {
			
			// End point has been omitted (model validation error?)
			'''@XpressModel(name="«t.name»",kind="omitted")
			'''
		} else {
			
			// Nothing to annotate
			''''''
		}
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
				|| t.refersConcept instanceof Type // implies Select type
		}
		
		false
	}
	
	/**
	 * True, if a is part of an inverse relation with many-to-many relation.
	 */
	def isInverseManyToManyRelation(Attribute a) {
		
		a.inverseRelation && a.oneToManyRelation && a.anyInverseAttribute.oneToManyRelation
	}
	
	/**
	 * True if a refers to an inverse relation.
	 */
	def isInverseRelation(Attribute a) {
		
		inverseReferenceMap.containsKey(a) || null!=a.opposite
	}
	
	/** Get inverse attribute */
	def Attribute getAnyInverseAttribute(Attribute a) {
		
		if(null!=a.opposite) {
			
			return a.opposite
		} else {
			
			val inverseSet = inverseReferenceMap.get(a)
			if(!inverseSet.empty) {
			
				return inverseSet.findFirst[it!=null]	
			} else {
				
				return null
			}
		}
	}
	
	def boolean isLeftNonUniqueRelation(Attribute a)
	{
		if(null!=a.opposite) {
			
			return inverseReferenceMap.get(a.opposite).size > 1
		} else {
			
			val knownDeclaring = inverseReferenceMap.get(a)
			return knownDeclaring.size > 1
		}
	}
	
	def Set<Attribute> getInverseAttributeSet(Attribute a) {
		
		if(null!=a.opposite) {
			
			return newHashSet( a.opposite )
		} else {
			
			val inverseSet = inverseReferenceMap.get(a)
			if(!inverseSet.empty) {
			
				return inverseSet	
			} else {
				
				return newHashSet
			}
		}
	}
	
	
	/**
	 * True, if attribute declares the inverse relation
	 */
	def isDeclaringInverseAttribute(Attribute a) {
		
		null!=a.opposite
	}
	
	/**
	 * True, if derived.
	 */
	def isDerivedAttribute(Attribute a) {
		
		null!=a.expression
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
	protected def preprocess(Schema s) {
		
		// Filter for simplified type selects
		myLog.info("Processing select types ...")
		for(Type t : s.types.filter[it.datatype instanceof SelectType]) {
			
			val conceptSet = selectSet(t)
			myLog.debug("~> Type definition of \""+t.name+"\" resolved to "+conceptSet.size+" sub concept(s).")
		
			resolvedSelectsMap.put(t, conceptSet)
		}
				
		myLog.info("Finished. Found "+resolvedSelectsMap.size+" select(s) in schema.")
		myLog.info("Processing inverse relations ...")
		
		for(Entity e : s.entities.filter[attribute.exists[opposite!=null]]) {
						
			// Filter for both sided collection types, omit any restriction (cardinalities etc.)
			for(Attribute a : e.attribute.filter[opposite!=null]) {

				val oppositeEntity = a.opposite.eContainer as ExpressConcept;				
				myLog.debug("~> "+(a.eContainer as Entity).name+"."+a.name+" <--> "+oppositeEntity.name+"."+a.opposite.name)
		
				// Add opposite versus declaring attribute
				var inverseAttributeSet = inverseReferenceMap.get(a.opposite)
				if(null==inverseAttributeSet) {
					inverseAttributeSet = newHashSet
					inverseReferenceMap.put(a.opposite, inverseAttributeSet)
				}
				
				inverseAttributeSet += a				
			}
		}
		
		myLog.info("Finished. Found "+inverseReferenceMap.size+" relation(s) with "+ 
			inverseReferenceMap.values.filter[size > 1].size+" non-unique left hand side (select on right hand).")
	}
		

	// --- GENERATOR CODE ------------------------------------


	/**
	 * Transforms a schema into a package definition.
	 */
	def compileSchema(Schema s) {
	
		s.preprocess
		 
'''	
«compileHeader(s)»

// THIS FILE IS GENERATED. ANY CHANGE WILL BE LOST.

@GenModel(documentation="Generated EXPRESS model of schema «s.name»")
@XpressModel(name="«s.name»",rootContainerClassRef="«s.name»")		
package «s.name.toLowerCase» 

import org.eclipse.emf.ecore.xml.^type.BooleanObject

annotation "http://www.eclipse.org/OCL/Import" as Import
annotation "http://www.bitub.de/express/XpressModel" as XpressModel
		
// Additional datatype for binary
type Binary wraps java.util.BitSet
		
// Base container of «s.name»
@GenModel(documentation="Generated container class of «s.name»")
@XpressModel(kind="new")
class «s.name» {

«FOR e:s.entities.filter[!abstract]»  contains «e.name.toFirstUpper»[] «e.name.toFirstLower»
«ENDFOR»

}

// --- TYPE DEFINITIONS ------------------------------

«FOR t:s.types»«t.compileConcept»«ENDFOR»

// --- ENTITY DEFINITIONS ----------------------------

«FOR e:s.entities»«e.compileConcept»«ENDFOR»
	
// --- ADDITIONALLY GENERATED ------------------------

«secondOrderCache»
	
// --- END OF «s.name» ---
'''		
	}
	
	
	/**
	 * Transforms an entity into a class definition. 
	 */	
	def dispatch compileConcept(Entity e) {
		
		'''
		
		@GenModel(documentation="Class definition of «e.name»")
		@XpressModel(name="«e.name»",kind="generated")
		«IF e.abstract»abstract «ENDIF»class «e.name.toFirstUpper» «IF !e.supertype.empty»extends «e.supertype.map[name].join(', ')» «ENDIF»{
		
		  «FOR a : e.attribute»
		  @GenModel(documentation="Attribute definition of «a.name»")
		  «a.compileAttribute»
		  
		  «ENDFOR»
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
			
			@XpressModel(name="«t.name»",kind="mapped")
			type «t.name.toFirstUpper» wraps String
			'''

		} else if(t.datatype instanceof EnumType) {
			// Compile enum
			'''
			
			@GenModel(documentation="Enumeration of «t.name»")
			@XpressModel(name="«t.name»",kind="generated")
			enum «t.name.toFirstUpper» {
							
				«t.datatype.compileDatatype»
			}
			'''
		} else if(t.datatype instanceof SelectType) {
			
			// Compile select
			'''
			
			@GenModel(documentation="Select of «t.name»")
			@XpressModel(name="«t.name»",kind="generated")
			class «t.name.toFirstUpper» {
			
				«t.datatype.compileDatatype»	
			}
			'''			
		} else if(t.datatype instanceof BuiltInType) {
	
			'''
			
			// Type «t.name» is a built-in primitive type (using «builtinMappings.get(t.datatype.eClass)»)
			'''			
						
		} else if(t.datatype instanceof ReferenceType) {

			aliasConceptMap.put(t, t.datatype.refersConcept)			
			'''
			
			// Type «t.name» not generated. It is an alias of «(t.datatype as ReferenceType).instance.name»
			'''			
			
		} else if(t.datatype instanceof CollectionType) {

			aliasConceptMap.put(t, t)			
			'''
			
			// Type «t.name» not generated. It is a named aggregation (using «t.datatype.referDatatype»)
			'''			
		} else {
			
			aliasConceptMap.put(t, null)
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
			@GenModel(documentation="Gets the current set member.")  
			op String ^get()
			@GenModel(documentation="Sets the value and member")
			op void ^set(String member, String value) {
			}
			
		   «FOR c : conceptSet.filter[it instanceof Entity]»
			«c.compileInlineAnnotation»refers «c.name.toFirstUpper» «c.name.toFirstLower»
		   «ENDFOR»
		   «FOR t : conceptSet.filter[it instanceof Type].map[it as Type]»
			«t.compileInlineAnnotation»«IF t.namedAlias && !t.builtinAlias»refers «ENDIF»«t.datatype.referDatatype» «t.name.toFirstLower»
		   «ENDFOR»
		'''
	}


	
	//// ---- REFERENCE DISPATCH
	
	def dispatch CharSequence referDatatype(EnumType t) { 
		
		'''«(t.eContainer as Type).name.toFirstUpper»'''
	
	}
	
	def dispatch CharSequence referDatatype(ReferenceType r) { 
		
		val parentAttribute = r?.parentAttribute
		val alias = r.refersTransitiveDatatype
	
		'''«IF alias.builtinAlias
				»«alias.compileDatatype»«
			ELSE
				»«
				IF parentAttribute?.inverseManyToManyRelation
					»«parentAttribute.proxyRef»«
				ELSE
					»«IF alias instanceof ReferenceType
						»«alias.instance.name.toFirstUpper
					»«ELSE
						»«alias.referDatatype
					»«ENDIF»«
				ENDIF»«
			ENDIF»'''	
	}
	
	def dispatch CharSequence referDatatype(BuiltInType b) { 
		
		'''«de.bitub.step.generator.XcoreGenerator.builtinMappings.get(b.eClass)»'''
	
	}
	
	def dispatch CharSequence referDatatype(GenericType g) { 
		
		'''«(g.eContainer as ExpressConcept).name.toFirstUpper»'''
	
	}
	
	def dispatch CharSequence referDatatype(CollectionType c) {
		
		// If nested but not datatype
		var CharSequence referredType 
		
		if(c.type instanceof CollectionType) {
		
			// Replace by nested collector proxy	
			if(!c.type.builtinAlias) {
			
				referredType = generateCollector_NestedInnerProxy(c)+'''[]'''
				
			} else {
								
				referredType = generateCollector_ReferencedPrimitive(c.type.referDatatype+'''[]''')
			}			
		} else {
			
			 referredType = c.type.referDatatype+'''[]'''
		}

		return referredType
	}
	
	def dispatch boolean isNestedAggregation(DataType c) {
		
		false
	}
	
	def dispatch boolean isNestedAggregation(ReferenceType c) {
		
		(c.instance instanceof Type) && (c.instance as Type).datatype.nestedAggregation
	}
	
	def dispatch boolean isNestedAggregation(CollectionType c) {
		
		c.type instanceof CollectionType && (c.type as CollectionType).type instanceof CollectionType
	}
		
	/**
	 * Generates a nested inner proxy for the delegation of multi-dimensional references.
	 */
	protected def String generateCollector_NestedInnerProxy(CollectionType c) {

		// Builtin type or entity ?
		val qualifiedName = nameProvider.getFullyQualifiedName(c.eContainer)		
		
		// Generate nested class
		if(nestedAggregationQN.containsKey(qualifiedName.toString)) {
			return nestedAggregationQN.get(qualifiedName.toString)
		}
		
		val nestedClassName = qualifiedName.toString.replace('.','_').toFirstUpper
		nestedAggregationQN.put(qualifiedName.toString, nestedClassName)
				
		val referDatatype = c.type.referDatatype
		secondOrderCache +=
		'''
				
		
		@XpressModel(kind="new")
		class «nestedClassName» {
			
			«IF !c.type.isBuiltinAlias
				»«IF c.isNestedAggregation»contains «ELSE»refers «ENDIF»«
			ENDIF
				»«referDatatype» «nameProvider.getFullyQualifiedName(c.type).lastSegment.toLowerCase»
		}
		'''		
		return nestedClassName
	}

	/**
	 * Generates a type wrapper for primitive multi-dimensional arrays
	 */	
	protected def String generateCollector_ReferencedPrimitive(String primitiveTypeRef) {

		if(nestedAggregationQN.containsKey(primitiveTypeRef)) {
			
			return nestedAggregationQN.get(primitiveTypeRef)
		}
		
		val typeWrap = primitiveTypeRef.toFirstUpper.replace('''[]''','''Array''')
				
		secondOrderCache +=
		'''
		
		@XpressModel(kind="new")
		type «typeWrap» wraps «primitiveTypeRef»
		'''
		nestedAggregationQN.put(primitiveTypeRef, typeWrap)
		return typeWrap
	}
	
	/**
	 * Generates a single proxy class for an inverse relation name.
	 */
	protected def String generateProxy(Attribute declaring, Attribute inverse, String proxyInterface) {
		
		val declaringEntity = declaring.eContainer as ExpressConcept
		val inverseEntity = declaring.opposite.eContainer as ExpressConcept
		// Generate proxy name as "ProxyEntityFromEntityTo"
		val proxyName = "Proxy"+declaringEntity.name.toFirstUpper+inverseEntity.name.toFirstUpper
		val hasProxyInterface = !proxyInterface.trim.empty
		
		secondOrderCache +=
		'''
		
		@GenModel(documentation="Inverse proxy helper between «declaringEntity.name» and «inverseEntity.name»")
		@XpressModel(kind="new")
		class «proxyName» «IF hasProxyInterface»extends «proxyInterface»«ENDIF» {
		
			«IF !hasProxyInterface»// Reference to «inverseEntity.name»
			«inverseEntity.compileInlineAnnotation
			»refers «inverseEntity.refersAlias.name.toFirstUpper» «declaring.name.toFirstLower» opposite «inverse.name.toFirstLower»
			«ENDIF»
			// Containment on declaring side of «declaringEntity.name»
			«declaringEntity.compileInlineAnnotation»container «declaringEntity.refersAlias.name.toFirstUpper» «inverse.name.toFirstLower» opposite «declaring.name.toFirstLower»	
		}
		'''
		return proxyName
	}
	
	/**
	 * Generate a proxy and returns class reference.
	 */
	def String getProxyRef(Attribute a) {
		
		// Determine declaring inverse
		
		val declaringInverse = if (a.declaringInverseAttribute) a else a.anyInverseAttribute
		val declaringInverseSet = inverseReferenceMap.get(declaringInverse.opposite)
		
		// Get mapping if existing
		if(nestedProxiesQN.containsKey(a)) {
			return nestedProxiesQN.get(a).key
		}
			
		// Generate if not
		var qnClassRef = ""					
		if(declaringInverse.leftNonUniqueRelation) {
			
			// Non-unique relation (SELECT on right hand side

			val inverseConcept = declaringInverse.opposite.eContainer as ExpressConcept
			val inverseAttribute = declaringInverse.opposite
			val selectType = (inverseAttribute.type.refersTransitiveDatatype as SelectType).eContainer as Type
			
			// Generate proxy interface name as "ProxyEntityToSelect"
			val proxyInterfaceName = "Proxy" + inverseConcept.name.toFirstUpper + selectType.name.toFirstUpper

			// Map QN of inverse attribute
			nestedProxiesQN.put(inverseAttribute, proxyInterfaceName -> inverseConcept.name.toFirstLower )
			
			// Write to second stage cache				
			secondOrderCache +=
			
			'''
			
			@XpressModel(kind="new")
			interface «proxyInterfaceName» {
				
				// Blueprint of inverse relation, implemented by subclassing
				op EObject get«inverseAttribute.name.toFirstUpper»()
				// Non-unique counter part, using concept QN as reference name
				«inverseConcept.compileInlineAnnotation»refers «inverseConcept.refersAlias.name.toFirstUpper» «inverseConcept.name.toFirstLower» opposite «inverseAttribute.name.toFirstLower»
			}
			'''

			// Generate proxies for all 
			for(Attribute ia : declaringInverseSet) {
									
				val proxyClass = generateProxy(ia, inverseAttribute, proxyInterfaceName)
				nestedProxiesQN.put(ia, proxyClass -> inverseAttribute.name.toFirstLower)				
			}
			
			qnClassRef = getProxyRef(a)
			
		} else {
			
			// Unique relation
			qnClassRef = generateProxy(declaringInverse, declaringInverse.opposite, "")
			nestedProxiesQN.put(declaringInverse, qnClassRef -> declaringInverse.opposite.name.toFirstLower)
			nestedProxiesQN.put(declaringInverse.opposite, qnClassRef -> declaringInverse.name.toFirstLower)
		}
		
		return qnClassRef
	}
	
	/**
	 * Returns the local QN of opposite attribute, if there's any.
	 */
	def String getOppositeRef(Attribute a) {
		
		if(a.inverseRelation) {
			if(a.isInverseManyToManyRelation) {
				
				return nestedProxiesQN.get(a).value
				
			} else  {
				
				return a.anyInverseAttribute.name				
			}
		}
	}
	

	// --- COMPILATION RULES --------------------------
		
	def dispatch CharSequence compileDatatype(CollectionType c) {
								
		'''«IF !c.isBuiltinAlias
				»«IF !#["ARRAY","LIST"].contains(c.name)»unordered «ENDIF
				»«IF "SET"==c.name»unique «ENDIF»«
			ENDIF»«c.referDatatype»'''

	}
	
	def dispatch CharSequence compileDatatype(ReferenceType r) {
						
		'''«IF r.instance instanceof Type
				»«IF (r.instance as Type).isNamedAlias
					»«(r.instance as Type).datatype.referDatatype
				»«ENDIF
			»«ELSE
				»«r.instance.name.toFirstUpper»«ENDIF»'''		
	}
		
	def dispatch CharSequence compileDatatype(BuiltInType builtin) {
		
		'''«de.bitub.step.generator.XcoreGenerator.builtinMappings.get(builtin.eClass)»'''
		
	}
	
		
	def dispatch CharSequence compileDatatype(EnumType t) {
		
		var nameList = <String>newArrayList
		var i = 0
		
		for(String name : t.literals.map[name]) {
			nameList += name+"="+(i++)
		}		
			
		'''«nameList.join(", ")»'''
	}

	// --- COMPILATION OF ATTRIBUTES	
		
	/**
	 * Compiles a single attribute.
	 */
	def compileAttribute(Attribute a) {
		
		'''«IF !a.type.builtinAlias»«
				IF a.inverseManyToManyRelation
					»@XpressModel(kind="proxy") contains «
				ELSE
					»«a.type.refersConcept.compileInlineAnnotation
					»«IF !a.type.builtinAlias»«IF a.type.nestedAggregation»contains «ELSE»refers «ENDIF»«ENDIF»«
				ENDIF
				»«IF a.derivedAttribute»derived «ENDIF
			»«ELSE
				»«a.type.refersConcept.compileInlineAnnotation
			»«ENDIF
			»«a.type.compileDatatype» «a.name.toFirstLower» «
			IF a.inverseRelation»opposite «a.oppositeRef.toFirstLower»«ENDIF»'''
	}
	

			

}		