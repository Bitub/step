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
import de.bitub.step.express.GenericType
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import de.bitub.step.generator.util.XcoreUtil
import java.util.Date
import java.util.List
import java.util.Set
import javax.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider

/**
 * Generates Xcore specifications from EXPRESS models.
 */
class XcoreGenerator implements IGenerator {
		
	val static Logger LOGGER = Logger.getLogger(XcoreGenerator);
		
	@Inject	IQualifiedNameProvider nameProvider;
	@Inject ExpressInterpreter interpreter;
	@Inject FunctionGenerator functionGenerator;
	@Inject XcoreUtil util;

	// Second stage cache (any additional concept needed beside first stage)
	//
	var secondStageCache = ''''''
	
	// Current project folder
	//
	var projectFolder = "<project folder>";
		
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
							
		de.bitub.step.generator.XcoreGenerator.LOGGER.info("Generating XCore representation of "+schema.name)
				
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
	def compileHeader(Schema s) '''
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
	 * Refers to itself. No substitution.
	 */
	def dispatch ExpressConcept refersAlias(Entity t) {
		
		t
	}
	
	/**
	 * Resolves alias reference, if there's any.
	 */
	def dispatch ExpressConcept refersAlias(Type t) {
		
		if(util.isBuiltinAlias(t)) {
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
	 * Empty annotation for entities (done before class statement)
	 */	
	def dispatch CharSequence compileInlineAnnotation(Entity t) {
		''''''
	}
	
	/**
	 * Compiles an annotation, if an alias exists other returns an empty statement.
	 */
	def dispatch CharSequence compileInlineAnnotation(Type t) {
	
		val alias = t.refersTransitiveDatatype
		 
		if(alias instanceof BuiltInType) {
			
			// End point is a builtin datatype
			'''@XpressModel(name="«t.name»",kind="mapped",datatypeRef="«t.datatype.referDatatype»")
			'''
		} else if (alias instanceof ReferenceType) {
			
			val qn = nameProvider.getFullyQualifiedName(t)
			if(interpreter.nestedAggregationQN.containsKey(qn.toString)) {
								
				'''@XpressModel(name="«t.name»",kind="nested",classRef="«interpreter.nestedAggregationQN.get(qn.toString)»[]")
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
		} else if (alias instanceof SelectType && interpreter.aliasConceptMap.containsKey(t)) {
			
			// End point is a SelectType
			'''@XpressModel(name="«t.name»",kind="mapped",classRef="«alias.referDatatype»")
			'''
		} else if (interpreter.aliasConceptMap.containsKey(t)) {
			
			// End point has been omitted (model validation error?)
			'''@XpressModel(name="«t.name»",kind="omitted")
			'''
		} else {
			
			// Nothing to annotate
			''''''
		}
	} 
	
	/**
	 * True, if a is part of an inverse relation with many-to-many relation.
	 */
	def isInverseManyToManyRelation(Attribute a) {
		
		a.inverseRelation && util.isOneToManyRelation(a) && util.isOneToManyRelation(a.anyInverseAttribute)
	}
	
	/**
	 * True if a refers to an inverse relation.
	 */
	protected def isInverseRelation(Attribute a) {
		
		interpreter.inverseReferenceMap.containsKey(a) || null!=a.opposite
	}
	
	/** 
	 * Get inverse attribute
	 */
	protected def Attribute getAnyInverseAttribute(Attribute a) {
		
		return 
			if(null!=a.opposite) 
				a.opposite 
			else
				interpreter.inverseReferenceMap.get(a)?.findFirst[it!=null]
	}
	
	def boolean isLeftNonUniqueRelation(Attribute a)
	{
		val knownDeclaring = 
			if(null!=a.opposite) 
				interpreter.inverseReferenceMap.get(a.opposite) 
			else 
				interpreter.inverseReferenceMap.get(a)
				 
		return if(null==knownDeclaring) false else knownDeclaring.size > 1
	}
	
	def Set<Attribute> getInverseAttributeSet(Attribute a) {
		
		if(null!=a.opposite) {
			
			return newHashSet( a.opposite )
		} else {
			
			val inverseSet = interpreter.inverseReferenceMap.get(a)
			if(!inverseSet.empty) {
			
				return inverseSet	
			} else {
				
				return newHashSet
			}
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
			
			if(interpreter.inverseReferenceMap.containsKey(a)) {
				
				interpreter.inverseReferenceMap.get(a)
			}
		}
	}
		
	/**
	 * Pre-processes the scheme before generating any code.
	 *  - Registering and flattening select types with composite entities
	 *  - Simplifying selects with unique builtin type
	 * 
	 * 
	 */
//	protected def preprocess(Schema s) {
//		
//		// Filter for simplified type selects
//		myLog.info("Processing select types ...")
//		for(Type t : s.types.filter[it.datatype instanceof SelectType]) {
//			
//			val conceptSet = selectSet(t)
//			myLog.debug("~> Type definition of \""+t.name+"\" resolved to "+conceptSet.size+" sub concept(s).")
//		
//			interpreter.resolvedSelectsMap.put(t, conceptSet)
//		}
//				
//		myLog.info("Finished. Found "+interpreter.resolvedSelectsMap.size+" select(s) in schema.")
//		myLog.info("Processing inverse relations ...")
//		
//		for(Entity e : s.entities.filter[attribute.exists[opposite!=null]]) {
//						
//			// Filter for both sided collection types, omit any restriction (cardinalities etc.)
//			for(Attribute a : e.attribute.filter[opposite!=null]) {
//
//				val oppositeEntity = a.opposite.eContainer as ExpressConcept;				
//				myLog.debug("~> "+(a.eContainer as Entity).name+"."+a.name+" <--> "+oppositeEntity.name+"."+a.opposite.name)
//						
//				// Inverse super-type references 
//				val refConcept = util.refersConcept(a.opposite.type)
//				if( refConcept instanceof Entity && !refConcept.equals(e) ) {
//					
//					// TODO Inheritance checking
//					var aList = interpreter.inverseSupertypeMap.get(e)
//					if(null==aList) {
//						aList = newArrayList
//						interpreter.inverseSupertypeMap.put(refConcept as Entity, aList)
//					}
//					aList += a
//				}
//				
//				// Add opposite versus declaring attribute
//				var inverseAttributeSet = interpreter.inverseReferenceMap.get(a.opposite)
//				if(null==inverseAttributeSet) {
//					inverseAttributeSet = newHashSet
//					interpreter.inverseReferenceMap.put(a.opposite, inverseAttributeSet)
//				}
//				
//				inverseAttributeSet += a				
//			}
//		}
//		
//		myLog.info("Finished. Found "+interpreter.inverseReferenceMap.size+" relation(s) with "+ 
//			interpreter.inverseReferenceMap.values.filter[size > 1].size+" non-unique left hand side (select on right hand).")
//	}
		

	// --- GENERATOR CODE ------------------------------------


	/**
	 * Transforms a schema into a package definition.
	 */
	def compileSchema(Schema s) {
		
		// process schema for structural information
		//
//		s.preprocess
		interpreter.process(s);
			 
		'''	
		«compileHeader(s)»
		
		// THIS FILE IS GENERATED (TIMESTAMP «new Date().toString()»). ANY CHANGE WILL BE LOST.
		
		@GenModel(documentation="Generated EXPRESS model of schema «s.name»")
		@XpressModel(name="«s.name»",rootContainerClassRef="«s.name»")		
		package «s.name.toLowerCase» 
		
		import org.eclipse.emf.ecore.EObject
		
		annotation "http://www.eclipse.org/OCL/Import" as Import
		annotation "http://www.bitub.de/express/XpressModel" as XpressModel
		annotation "http://www.bitub.de/express/P21" as P21
				
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
		
		«functionGenerator.compileFunction(s)»
		
		«secondStageCache»
			
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
		
		  «IF interpreter.inverseSupertypeMap.containsKey(e)
		  »«FOR a : interpreter.inverseSupertypeMap.get(e)
			  »// FIXME op «a.type.compileDatatype» get«a.name.toFirstUpper»()«
			ENDFOR»«
		  ENDIF»
		  «FOR a : e.attribute»
		  
		  «IF !util.isDerivedAttribute(a)»
		  @GenModel(documentation="Attribute definition of «a.name»")
		  «IF !util.isDeclaringInverseAttribute(a)»
		  @P21
		  «ENDIF»
		  «a.compileAttribute()»
		  
		  «ENDIF»
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
			
			// Type «t.name» is a built-in primitive type (using «TypeMappingConstants.builtinMappings.get(t.datatype.eClass)»)
			'''			
						
		} else if(t.datatype instanceof ReferenceType) {

			interpreter.aliasConceptMap.put(t, util.refersConcept(t.datatype))			
			'''
			
			// Type «t.name» not generated. It is an alias of «(t.datatype as ReferenceType).instance.name»
			'''			
			
		} else if(t.datatype instanceof CollectionType) {

			interpreter.aliasConceptMap.put(t, t)			
			'''
			
			// Type «t.name» not generated. It is a named aggregation (using «t.datatype.referDatatype»)
			'''			
		} else {
			
			interpreter.aliasConceptMap.put(t, null)
			'''
			
			// WARNING: UNKNOWN TYPE «t.name» IS NOT MAPPED. DATATYPE PARSED AS «t.datatype.eClass.name»
			'''			
		}
	}
	
	/**
	 * Transforms a Select into a class specification.
	 */
	def dispatch compileDatatype(SelectType s) {
		
		val conceptSet = interpreter.resolvedSelectsMap.get(s.eContainer)
		
		''' 
		   «FOR c : conceptSet.filter[it instanceof Entity]»
			«c.compileInlineAnnotation»refers «c.name.toFirstUpper» «c.name.toFirstLower»
		   «ENDFOR»
		   «FOR t : conceptSet.filter[it instanceof Type].map[it as Type]»
			«t.compileInlineAnnotation»«IF util.isNamedAlias(t) && !util.isBuiltinAlias(t)»refers «ENDIF»«t.datatype.referDatatype» «t.name.toFirstLower»
		   «ENDFOR»
		'''
	}


	
	//// ---- REFERENCE DISPATCH
	
	def dispatch CharSequence referDatatype(EnumType t) { 
		
		'''«(t.eContainer as Type).name.toFirstUpper»'''
	
	}
	
	def dispatch CharSequence referDatatype(SelectType t) {
		
		'''«(t.eContainer as Type).name.toFirstUpper»'''
	}
	
	def dispatch CharSequence referDatatype(ReferenceType r) { 
		//TODO
		val parentAttribute = util.parentAttribute(r)
//		val inverseAttributes = parentAttribute?.inverseAttributeSet		
		val alias = r.refersTransitiveDatatype
//		inverseSupertypeMap.get(alias.refersConcept)?.filter[inverseAttributes.contains(it)]
//		val isInverseSupertype = inverseSupertypeMap?.get(alias.refersConcept).exists[inverseAttributes.contains(it)]
	
		'''«IF util.isBuiltinAlias(alias)
				»«alias.compileDatatype»«
			ELSE
				»«
				IF parentAttribute?.inverseManyToManyRelation || parentAttribute?.leftNonUniqueRelation
					»«parentAttribute.proxyRef»«
				ELSE
					»«IF alias instanceof ReferenceType
//						»«IF isInverseSupertype 
//							»«(inverseAttribute.eContainer as Entity).name.toFirstUpper
//						»«ELSE
							»«alias.instance.name.toFirstUpper
//						»«ENDIF
					»«ELSE
						»«alias.referDatatype
					»«ENDIF»«
				ENDIF»«
			ENDIF»'''	
	}
	
	def dispatch CharSequence referDatatype(BuiltInType b) { 
		
		'''«TypeMappingConstants.builtinMappings.get(b.eClass)»'''
	
	}
	
	def dispatch CharSequence referDatatype(GenericType g) { 
		
		'''«(g.eContainer as ExpressConcept).name.toFirstUpper»'''
	
	}
	
	def dispatch CharSequence referDatatype(CollectionType c) {
		
		// If nested but not datatype
		var CharSequence referredType 
		
		if(c.type instanceof CollectionType) {
		
			// Replace by nested collector proxy	
			if(!util.isBuiltinAlias(c.type)) {
			
				referredType = generateCollector_NestedInnerProxy(c)+'''[]'''
				
			} else {
								
				referredType = generateCollector_ReferencedPrimitive(c.type.referDatatype+'''[]''')
			}			
		} else {
			
			 referredType = c.type.referDatatype+'''[]'''
		}

		return referredType
	}
	
	/**
	 * Whether the current data type is translated to a nested aggregation.
	 */	
	def dispatch boolean isNestedAggregation(DataType c) {
		
		false
	}

	/**
	 * Whether the current reference type is translated to a nested aggregation.
	 */	
	def dispatch boolean isNestedAggregation(ReferenceType c) {
		
		(c.instance instanceof Type) && (c.instance as Type).datatype.nestedAggregation
	}
	
	/**
	 * Whether the current collection type is translated to a nested aggregation.
	 */
	def dispatch boolean isNestedAggregation(CollectionType c) {
		
		c.type instanceof CollectionType 
	}
		
	/**
	 * Generates a nested inner proxy for the delegation of multi-dimensional references.
	 */
	protected def String generateCollector_NestedInnerProxy(CollectionType c) {

		// Builtin type or entity ?
		val qualifiedName = nameProvider.getFullyQualifiedName(c.eContainer)		
		
		// Generate nested class
		if(interpreter.nestedAggregationQN.containsKey(qualifiedName.toString)) {
			return interpreter.nestedAggregationQN.get(qualifiedName.toString)
		}
		
		val nestedClassName = qualifiedName.toString.replace('.','_').toFirstUpper
		interpreter.nestedAggregationQN.put(qualifiedName.toString, nestedClassName)
				
		val referDatatype = c.type.referDatatype
		secondStageCache +=
		'''
				
		
		@XpressModel(kind="new")
		class «nestedClassName» {
			
			«IF !util.isBuiltinAlias(c.type)
				»«IF c.type.isNestedAggregation»contains «ELSE»refers «ENDIF»«
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

		if(interpreter.nestedAggregationQN.containsKey(primitiveTypeRef)) {
			
			return interpreter.nestedAggregationQN.get(primitiveTypeRef)
		}
		
		val typeWrap = primitiveTypeRef.toFirstUpper.replace('''[]''','''Array''')
				
		secondStageCache +=
		'''
		
		@XpressModel(kind="new")
		type «typeWrap» wraps «primitiveTypeRef»
		'''
		interpreter.nestedAggregationQN.put(primitiveTypeRef, typeWrap)
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
		
		secondStageCache +=
		'''
		
		@GenModel(documentation="Inverse proxy helper between «declaringEntity.name» and «inverseEntity.name»")
		@XpressModel(kind="new"«IF hasProxyInterface»,select="«declaringEntity.name»"«ENDIF»)
		class «proxyName» «IF hasProxyInterface»extends «proxyInterface»«ENDIF» {
		
		«IF !hasProxyInterface
		»	// Reference to «inverseEntity.name»
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
	protected def String getProxyRef(Attribute a) {
		
		// Determine declaring inverse
		
		val declaringInverse = if (util.isDeclaringInverseAttribute(a)) a else a.anyInverseAttribute
		val declaringInverseSet = interpreter.inverseReferenceMap.get(declaringInverse.opposite)
		
		// Get mapping if existing
		if(interpreter.nestedProxiesQN.containsKey(a)) {
			return interpreter.nestedProxiesQN.get(a).key
		}
			
		// Generate if not
		var qnClassRef = ""					
		if(declaringInverse.leftNonUniqueRelation) {
			
			// Non-unique relation (SELECT on right hand side

			val inverseConcept = declaringInverse.opposite.eContainer as ExpressConcept
			val inverseAttribute = declaringInverse.opposite
						
			// Generate proxy interface name as "ProxyEntityToSelect"
			val selectType = util.refersConcept(inverseAttribute.type)
			val proxyInterfaceName = "Proxy" + inverseConcept.name.toFirstUpper + selectType.name.toFirstUpper

			// Map QN of inverse attribute
			interpreter.nestedProxiesQN.put(inverseAttribute, proxyInterfaceName -> inverseConcept.name.toFirstLower )
			
			// Write to second stage cache				
			secondStageCache +=
			
			'''
			
			@XpressModel(kind="new")
			interface «proxyInterfaceName» {
				
				// Blueprint of inverse relation, implemented by sub classing
				op EObject get«inverseAttribute.name.toFirstUpper»()
				// Non-unique counter part, using concept QN as reference name
				«inverseConcept.compileInlineAnnotation»refers «inverseConcept.refersAlias.name.toFirstUpper» «inverseConcept.name.toFirstLower» opposite «inverseAttribute.name.toFirstLower»
			}
			'''

			// Generate proxies for all 
			for(Attribute ia : declaringInverseSet) {
									
				val proxyClass = generateProxy(ia, inverseAttribute, proxyInterfaceName)
				interpreter.nestedProxiesQN.put(ia, proxyClass -> inverseAttribute.name.toFirstLower)				
			}
			
			qnClassRef = getProxyRef(a)
			
		} else {
			
			// Unique relation
			qnClassRef = generateProxy(declaringInverse, declaringInverse.opposite, "")
			interpreter.nestedProxiesQN.put(declaringInverse, qnClassRef -> declaringInverse.opposite.name.toFirstLower)
			interpreter.nestedProxiesQN.put(declaringInverse.opposite, qnClassRef -> declaringInverse.name.toFirstLower)
		}
		
		return qnClassRef
	}
	
	/**
	 * Returns the local QN of opposite attribute, if there's any.
	 */
	def String getOppositeRef(Attribute a) {
		
		if(a.inverseRelation) {
			if(a.inverseManyToManyRelation || a.leftNonUniqueRelation) {
				
				return interpreter.nestedProxiesQN.get(a).value
				
			} else  {
				
				return a.anyInverseAttribute.name				
			}
		}
	}
	

	// --- COMPILATION RULES --------------------------
		
	def dispatch CharSequence compileDatatype(CollectionType c) {
								
		'''«IF !util.isBuiltinAlias(c)
				»«IF !#["ARRAY","LIST"].contains(c.name)»unordered «ENDIF
				»«IF "SET"==c.name»unique «ENDIF»«
			ENDIF»«c.referDatatype»'''
	}
	
	def dispatch CharSequence compileDatatype(ReferenceType r) {
						
		'''«r.referDatatype»'''		
	}
		
	def dispatch CharSequence compileDatatype(BuiltInType builtin) {
		
		'''«TypeMappingConstants.builtinMappings.get(builtin.eClass)»'''		
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
		
		'''«IF !util.isBuiltinAlias(a.type)»«
				IF a.inverseManyToManyRelation || a.leftNonUniqueRelation
					»@XpressModel(kind="proxy") contains «
				ELSE
					»«util.refersConcept(a.type)?.compileInlineAnnotation
					»«IF !util.isBuiltinAlias(a.type)
						»«IF a.type.nestedAggregation
							»contains «
						ELSE
							»«IF util.isReferable(a.type)
								»refers «
							ENDIF
						»«ENDIF
					»«ENDIF»«
				ENDIF
			»«ELSE
				»«util.refersConcept(a.type)?.compileInlineAnnotation
			»«ENDIF
			»«IF util.isDerivedAttribute(a)
				»derived «
			ENDIF
			»«a.type.compileDatatype» «a.name.toFirstLower» «
			IF a.inverseRelation
				»opposite «a.oppositeRef.toFirstLower
			»«ENDIF»'''
	}
	

	def isInverseOppositeAttributeContainerAbstract(Attribute a){
				
		val cont = a.eContainer as Entity;
		if(cont.isAbstract){
			System.out.println("ATTR" + a.eContainer);			
		}
		return cont.isAbstract;
	}
	
	// --- COMPILATION OF FUNCTIONS
	

}		
