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

package de.bitub.step.xcore

import com.google.inject.Inject
import de.bitub.step.analyzing.EXPRESSInterpreter
import de.bitub.step.analyzing.EXPRESSModelInfo
import de.bitub.step.express.Attribute
import de.bitub.step.express.BuiltInType
import de.bitub.step.express.CollectionType
import de.bitub.step.express.Entity
import de.bitub.step.express.EnumType
import de.bitub.step.express.ExpressConcept
import de.bitub.step.express.GenericType
import de.bitub.step.express.ReferenceType
import de.bitub.step.express.Schema
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import de.bitub.step.util.EXPRESSExtension
import java.util.Date
import java.util.Map
import java.util.Set
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider

/**
 * Generates Xcore specifications from EXPRESS models.
 */
class XcoreGenerator implements IGenerator {
	
	enum Options {
		
		SEPARATE_TYPEPACKAGE, COPYRIGHT_NOTICE, NS_URI, NS_PREFIX, 
		ENABLE_CDO, PACKAGE, SOURCE_FOLDER, FORCE_UNIQUE_DELEGATES	
	}
		
	@Inject static Logger LOGGER
		
	@Inject extension IQualifiedNameProvider	
	@Inject extension EXPRESSExtension	
	
	extension EXPRESSModelInfo modelInfo;
	extension XcoreInfo xcoreInfo;
	
	@Inject EXPRESSInterpreter interpreter;
	@Inject FunctionGenerator functionGenerator;


	static val PREFIX_DELEGATE = "Delegate";		

	// Second stage cache (any additional concept needed beside first stage)
	//
	var secondStageCache = ''''''
	

	/**
	 * Options of generation process.
	 */
	val public Map<Options, Object> options = newHashMap  


	override void doGenerate(Resource resource, IFileSystemAccess fsa) {

		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
		
		LOGGER.info("Generating XCore representation of "+schema.name)

		fsa.generateFile(schema.name+".xcore", schema.compileSchema)
	}
	
	
	
	/**
	 * Compiles Xcore from given EXPRESS resource.
	 */
	def compile(Resource resource) {
				
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;		
		schema.compileSchema
	}
	
	
	def private isOptionTrue(Options o) {
		
		options.containsKey(o) && (options.get(o) as Boolean) == Boolean.TRUE
	}
	
	def private isOption(Options o) {
		
		options.containsKey(o)
	}
	
	def private getOptionText(Options o) {
		
		if(options.containsKey(o)) options.get(o) as String else ""
	}
		
	def private assembleXcoreHeader(Schema s) {
		
		assembleXcoreHeader(
			if(Options.NS_PREFIX.option) Options.NS_PREFIX.optionText else s.name,
			if(Options.NS_URI.option) Options.NS_URI.optionText else s.name,
			if(Options.SOURCE_FOLDER.option) Options.SOURCE_FOLDER.optionText else "src-gen"
		)		
	}
		
	/**
	 * Assembles the header / annotation information on top of the Xcore file.
	 */
	def private assembleXcoreHeader(String nsPrefix, String nsURI, String folder) { 
		'''
		@Ecore(nsPrefix="«nsPrefix»",nsURI="«nsURI»")
		@Import(ecore="http://www.eclipse.org/emf/2002/Ecore")
		@GenModel(
			«IF Options.COPYRIGHT_NOTICE.option»copyrightText="«Options.COPYRIGHT_NOTICE.optionText»",«ENDIF»
			modelDirectory="«folder»"
			adapterFactory="false", 
			updateClasspath="false",
			complianceLevel="8.0",
			optimizedHasChildren="true",
			
			«IF Options.ENABLE_CDO.optionTrue»			 
			rootExtendsInterface="org.eclipse.emf.cdo.CDOObject", 
			rootExtendsclassRef="org.eclipse.emf.internal.cdo.CDOObjectImpl", 
			importerID="org.eclipse.emf.importer.ecore", 
			featureDelegation="Dynamic", 
			providerRootExtendsclassRef="org.eclipse.emf.cdo.edit.CDOItemProviderAdapter"«ENDIF»
		)
		
		annotation "http://www.eclipse.org/OCL/Import" as Import
		annotation "http://www.bitub.de/express/XpressModel" as XpressModel
		annotation "http://www.bitub.de/express/P21" as P21
		
		// THIS FILE IS GENERATED (TIMESTAMP «new Date().toString()»). ANY CHANGE WILL BE LOST.
		'''
	}
	
	def private assembleXcorePackage(Schema s) {
	
		assembleXcorePackage(
			if(Options.PACKAGE.option) Options.PACKAGE.optionText else s.name
		)
	}
	
	/**
	 * Assembles the package information.
	 */
	def private assembleXcorePackage(String name) {

		'''		
		package «name»
				
		'''		
	}
	
	

	
	/**
	 * Check whether the collection types are identically.
	 */
	def static boolean isUniqueCollectionSelect(Iterable<CollectionType> aggregationTypes) {
		
		// Check unique aggregation type
		//
		if(aggregationTypes.map[name].toSet.size > 1) {			
			return false
		}
		
		val nonNullLowerBound = aggregationTypes.findFirst[lowerBound > 0];
		
		// If there any non-null lower bound
		//
		if(null!=nonNullLowerBound && aggregationTypes.filter[lowerBound != nonNullLowerBound.lowerBound ].size > 1) {
			
			// False, if there are multiple lower bounds
			//
			return false;
		}

		val nonNullUpperBound = aggregationTypes.findFirst[upperBound > 0]
		
		// If there any non-null upper bound
		//
		if(null!=nonNullLowerBound && aggregationTypes.filter[upperBound != nonNullUpperBound.upperBound ].size > 1) {
			
			// False if there are multiple upper bounds
			//
			return false;
		}
		
		val nestedCollections = aggregationTypes.filter[it.type instanceof CollectionType];
		
		if(!nestedCollections.empty) {
			
			// If there are nested aggregations
			//
			if(nestedCollections.size < aggregationTypes.size) {
		
				return false			
			} else {
				
				// Check nested aggregation
				//
				return isUniqueCollectionSelect(nestedCollections.map[type as CollectionType])
			}
		}
				
		val typeSet = aggregationTypes.map[it.type.eClass].toSet;
		
		if(typeSet.size>1) {			
			return false
		}
		
		// Check if concept
		//
		if(aggregationTypes.filter[it.type instanceof ExpressConcept].map[(it.type as ExpressConcept).name].toSet.size > 1) {
			return false
		}
		
		return true
	}
	
	/**
	 * Checks whether select is a unique alias select (only semantics changes)
	 */
	def static isUniqueAliasSelect(Set<ExpressConcept> selects) {
		
		// Filter for aggregations
		//
		val aggregationTypes = selects
			.filter[it instanceof Type && (it as Type).datatype instanceof CollectionType]
			.map[(it as Type).datatype as CollectionType];
		
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
			t.refersDatatype.eContainer as ExpressConcept
		}
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
	
		val alias = t.refersDatatype
		 
		if(alias instanceof BuiltInType) {
			
			// End point is a builtin datatype
			'''@XpressModel(name="«t.name»",kind="mapped",qualifiedName="«t.datatype.qualifiedName»")
			'''
		} else if (alias instanceof ReferenceType) {
			
			val qn = t.fullyQualifiedName
			if(nestedAggregationQN.containsKey(qn.toString)) {
								
				'''@XpressModel(name="«t.name»",kind="nested",classRef="«nestedAggregationQN.get(qn.toString)»[]")
				'''
			} else {

				// End point is a reference to an entity
				'''@XpressModel(name="«t.name»",kind="mapped",classRef="«t.datatype.qualifiedName»")
				'''			
			}
		} else if (alias instanceof GenericType) {
			
			// End point is a generic datatype wrapper
			'''@XpressModel(name="«t.name»",kind="generic",qualifiedName="«alias.qualifiedName»")
			'''
		} else if (alias instanceof SelectType && t.aliasType) {
			
			// End point is a SelectType
			'''@XpressModel(name="«t.name»",kind="mapped",classRef="«alias.qualifiedName»")
			'''
		} else if (t.aliasType) {
			
			// End point has been omitted (model validation error?)
			'''@XpressModel(name="«t.name»",kind="omitted")
			'''
		} else {
			
			// Nothing to annotate
			''''''
		}
	} 


	/**
	 * Transforms a schema into a package definition.
	 */
	def compileSchema(Schema s) {
		
		// process schema for structural information
		//		
		modelInfo = interpreter.process(s);
			 
		'''	
		«s.assembleXcoreHeader»
		
		
		@GenModel(documentation="Generated EXPRESS model of schema «s.name»")
		@XpressModel(name="«s.name»",rootContainerClassRef="«s.name»")		
		«s.assembleXcorePackage» 
		
		import org.eclipse.emf.ecore.EObject
						
		// Additional datatype for binary
		type Binary wraps java.util.BitSet
				
		// Base container of «s.name»
		@GenModel(documentation="Generated container class of «s.name»")
		@XpressModel(kind="new")
		class «s.name» {
					
		«FOR e:s.entity.filter[!abstract]»  contains «e.name.toFirstUpper»[] «e.name.toFirstLower»
		«ENDFOR»
		
		// persisted SELECTS
		
		«FOR t:s.type.filter[datatype instanceof SelectType]»  contains «t.name.toFirstUpper»[] «t.name.toFirstLower»
		«ENDFOR»
		}
		
		// --- TYPE DEFINITIONS ------------------------------
		
		«FOR t:s.type»«t.compileConcept»«ENDFOR»
		
		// --- ENTITY DEFINITIONS ----------------------------
		
		«FOR e:s.entity»«e.compileConcept»«ENDFOR»
			
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
		
		  «FOR a : e.attribute»
		  
		  «IF !a.derivedAttribute»
		  @GenModel(documentation="Attribute definition of «a.name»")
		  «IF !a.declaringInverseAttribute»
		  @P21
		  «ENDIF»
		  «a.compileAttribute»
		  
		  «ENDIF»
		  «ENDFOR»
		}
		'''
	}
	
	/**
	 * Transforms a type into a class / type definition.
	 */
	def dispatch compileConcept(Type t) {
		
		switch(t) {
			
			GenericType: {
				// Wraps String						
				'''
				
				@XpressModel(name="«t.name»",kind="mapped")
				type «t.name.toFirstUpper» wraps String
				'''			
			}
			EnumType: {
				// Compile enum
				'''
				
				@GenModel(documentation="Enumeration of «t.name»")
				@XpressModel(name="«t.name»",kind="generated")
				enum «t.name.toFirstUpper» {
								
					«t.datatype.compileDatatype»
				}
				'''
			}
			SelectType: {
				// Compile select
				'''
				
				@GenModel(documentation="Select of «t.name»")
				@XpressModel(name="«t.name»",kind="generated")
				class «t.name.toFirstUpper» {
				
					«t.datatype.compileDatatype»	
				}
				'''							
			}
			
			default: {
				
			}	
		}		
	}
	
	/**
	 * Transforms a Select into a class specification.
	 */
	def dispatch compileDatatype(SelectType s) {
		
		val conceptSet = s.flattenedConceptSet
		
		''' 
		   «FOR c : conceptSet.filter[it instanceof Entity]»
			«c.compileInlineAnnotation»refers «c.name.toFirstUpper» «c.name.toFirstLower»
		   «ENDFOR»
		   «FOR t : conceptSet.filter[it instanceof Type].map[it as Type]»
			«t.compileInlineAnnotation»«IF t.namedAlias && !t.builtinAlias»refers «ENDIF»«t.datatype.qualifiedName» «t.name.toFirstLower»
		   «ENDFOR»
		'''
	}

	
	def dispatch CharSequence qualifiedName(EnumType t) { 
		
		'''«(t.eContainer as Type).name.toFirstUpper»'''
	
	}
	
	def dispatch CharSequence qualifiedName(SelectType t) {
		
		'''«(t.eContainer as Type).name.toFirstUpper»'''
	}
	
	
	def dispatch CharSequence qualifiedName(ReferenceType r) { 
		//TODO
		val parentAttribute = r.hostingAttribute
		
		val alias = r.refersDatatype
	
		'''«IF alias.builtinAlias
				»«alias.compileDatatype»«
			ELSE
				»«
				IF parentAttribute != null && (parentAttribute.inverseManyToManyRelation || parentAttribute.nonUniqueRelation)
					»«parentAttribute.delegateRef»«
				ELSE
					»«IF alias instanceof ReferenceType
							»«alias.instance.name.toFirstUpper
					»«ELSE
						»«alias.qualifiedName
					»«ENDIF»«
				ENDIF»«
			ENDIF»'''	
	}
	
	def dispatch CharSequence qualifiedName(BuiltInType b) { 
		
		'''«XcoreConstants.qualifiedName(b)»'''
	
	}
	
	def dispatch CharSequence qualifiedName(GenericType g) { 
		
		'''«(g.eContainer as ExpressConcept).name.toFirstUpper»'''
	
	}
	
	def dispatch CharSequence qualifiedName(CollectionType c) {
		
		// If nested but not datatype
		var CharSequence referredType 
		
		if(c.type instanceof CollectionType) {
		
			// Replace by nested collector proxy	
			if(!c.type.builtinAlias) {
			
				referredType = generateCollector_NestedDelegate(c)+'''[]'''
				
			} else {
								
				referredType = generateCollector_NestedWrapper(c.type.qualifiedName+'''[]''')
			}			
		} else {
			
			 referredType = c.type.qualifiedName+'''[]'''
		}

		
		return referredType
	}
	
		
	/**
	 * Generates a nested inner delegate for the delegation of multi-dimensional references.
	 */
	protected def String generateCollector_NestedDelegate(CollectionType c) {

		// Builtin type or entity ?
		val qualifiedName = c.eContainer.fullyQualifiedName
		
		// Generate nested class
		if(nestedAggregationQN.containsKey(qualifiedName.toString)) {
			
			return nestedAggregationQN.get(qualifiedName.toString)
		}
		
		val nestedClassName = qualifiedName.toString.replace('.','_').toFirstUpper
		nestedAggregationQN.put(qualifiedName.toString, nestedClassName)
				
		val qualifiedName = c.type.qualifiedName
		secondStageCache +=
		'''
				
		
		@XpressModel(kind="new")
		class «nestedClassName» {
			
			«IF !c.type.builtinAlias
				»«IF c.type.isNestedAggregation»contains «ELSE»refers «ENDIF»«
			ENDIF
				»«qualifiedName» «c.type.fullyQualifiedName.lastSegment.toLowerCase»
		}
		'''		
		return nestedClassName
	}

	/**
	 * Generates a type wrapper for primitive multi-dimensional arrays
	 */	
	protected def String generateCollector_NestedWrapper(String primitiveTypeRef) {

		if(nestedAggregationQN.containsKey(primitiveTypeRef)) {
			
			return nestedAggregationQN.get(primitiveTypeRef)
		}
		
		val typeWrap = primitiveTypeRef.toFirstUpper.replace('''[]''','''Array''')
				
		secondStageCache +=
		'''
		
		@XpressModel(kind="new")
		type «typeWrap» wraps «primitiveTypeRef»
		'''
		nestedAggregationQN.put(primitiveTypeRef, typeWrap)
		return typeWrap
	}
	
	
	/**
	 * Generates a single delegate class for an inverse relation name.
	 */
	def private String generateDelegate(Attribute declaring, Attribute inverse, String delegateInterface) {
		
		val declaringEntity = declaring.eContainer as ExpressConcept		
		val inverseEntity = declaring.opposite.eContainer as ExpressConcept
		
		// Generate proxy name as "ProxyEntityFromEntityTo"
		val delegateName = PREFIX_DELEGATE + declaringEntity.name.toFirstUpper + inverseEntity.name.toFirstUpper
		val hasInterface = !delegateInterface.trim.empty
		
		secondStageCache +=
		'''
		
		@GenModel(documentation="Inverse delegation helper between «declaringEntity.name» and «inverseEntity.name»")
		@XpressModel(kind="new"«IF hasInterface && inverse.select»,select="«declaringEntity.name»"«ENDIF»)
		class «delegateName» «IF hasInterface»extends «delegateInterface»«ENDIF» {
			«IF !hasInterface»
			// Reference to «inverseEntity.name»
			«inverseEntity.compileInlineAnnotation
			»refers «inverseEntity.refersAlias.name.toFirstUpper» «declaring.name.toFirstLower» opposite «inverse.name.toFirstLower»
			«ENDIF»
			// Containment on declaring side of «declaringEntity.name»
			«declaringEntity.compileInlineAnnotation»container «declaringEntity.refersAlias.name.toFirstUpper» «inverse.name.toFirstLower» opposite «declaring.name.toFirstLower»	
		}
		'''
		return delegateName
	}
	
	
	/**
	 * Compiles a non-unique relationship by adding delegates.
	 */
	def private generateDelegateNonUniqueRelation(Attribute a) {
		
		val declaringInverse = if (a.declaringInverseAttribute) a else a.oppositeAttribute
		val declaringInverseSet = declaringInverse.allOppositeAttributes
				
		val inverseConcept = declaringInverse.opposite.eContainer as ExpressConcept
		val inverseAttribute = declaringInverse.opposite
						
		// Generate proxy interface name as "ProxyEntityToSelect"
		val targetConcept = inverseAttribute.type.refersConcept
		val delegateInterfaceName = PREFIX_DELEGATE + inverseConcept.name.toFirstUpper + targetConcept.name.toFirstUpper

		// Map QN of inverse attribute
		xcoreInfo.addDelegate(inverseAttribute, delegateInterfaceName, null)
		//nestedProxiesQN.put(inverseAttribute, delegateInterfaceName -> inverseConcept.name.toFirstLower )
			
		// Write to second stage cache				
		secondStageCache +=
		
		'''
		
		@XpressModel(kind="new", type="delegate")
		@GenModel(documentation="")
		interface «delegateInterfaceName» {
			
			// Blueprint of inverse relation, implemented by sub classing
			op «IF a.supertypeOppositeDirectedRelation»«a.refersConcept.name.toFirstUpper»«ELSE»EObject«ENDIF» get«inverseAttribute.name.toFirstUpper»()
			// Non-unique counter part, using concept QN as reference name
			«inverseConcept.compileInlineAnnotation»refers «inverseConcept.refersAlias.name.toFirstUpper» «inverseConcept.name.toFirstLower» opposite «inverseAttribute.name.toFirstLower»
		}
		'''

		// Generate proxies for all 
		for(Attribute ia : declaringInverseSet) {
								
			val delegateClass = generateDelegate(ia, inverseAttribute, delegateInterfaceName)
			xcoreInfo.addDelegate(ia, delegateClass, inverseAttribute)
			//nestedProxiesQN.put(ia, proxyClass -> inverseAttribute.name.toFirstLower)				
		}
	}
	
	/**
	 * Generates a simple delegate.
	 */
	def private generateDelegateUniqueRelation(Attribute a) {
		
		val declaringInverse = if (a.declaringInverseAttribute) a else a.oppositeAttribute
		
		// Generate delegate without interface
		val qnClassRef = generateDelegate(declaringInverse, declaringInverse.opposite, "")
		xcoreInfo.addDelegate(declaringInverse, qnClassRef, declaringInverse.opposite)
		//nestedProxiesQN.put(declaringInverse, qnClassRef -> declaringInverse.opposite.name.toFirstLower)
		//nestedProxiesQN.put(declaringInverse.opposite, qnClassRef -> declaringInverse.name.toFirstLower)		
	}
	
	
	/**
	 * Generates a relation delegate and returns class reference.
	 */
	def protected String getCreateDelegateQN(Attribute a) { // TODO
				
		// Get existing QN of delegate
		if(!a.hasDelegate) {
			
			if(a.inverseManyToManyRelation) {
				
				if(a.nonUniqueRelation) {
				
					generateDelegateNonUniqueRelation(a)
					
				} else if(Options.FORCE_UNIQUE_DELEGATES.option) {
					// Create delegates for unique relations only if forced
					generateDelegateUniqueRelation(a)
				}
			}
		}
		
		a.delegateQN
	}
	
		
	def dispatch CharSequence compileDatatype(CollectionType c) {
								
		'''«IF !c.builtinAlias
				»«IF !#["ARRAY","LIST"].contains(c.name)»unordered «ENDIF
				»«IF "SET"==c.name»unique «ENDIF»«
			ENDIF»«c.qualifiedName»'''
	}

	
	def dispatch CharSequence compileDatatype(ReferenceType r) {
						
		'''«r.qualifiedName»'''		
	}

		
	def dispatch CharSequence compileDatatype(BuiltInType t) {
		
		'''«t.qualifiedName»'''		
	}
	
		
	def dispatch CharSequence compileDatatype(EnumType t) {
		
		var nameList = <String>newArrayList
		var i = 0
		
		for(String name : t.literal.map[name]) {
			nameList += name+"="+(i++)
		}		
			
		'''«nameList.join(", ")»'''
	}


	/**
	 * Compiles a single attribute.
	 */
	def compileAttribute(Attribute a) { // TODO
		
		'''«IF !a.type.builtinAlias»«
				IF a.nonUniqueRelation && a.declaringInverseAttribute
					»@XpressModel(type="delegate") contains «
				ELSE
					»«a.type.refersConcept?.compileInlineAnnotation
					»«IF !a.type.isBuiltinAlias
						»«IF a.type.nestedAggregation
							»contains «
						ELSE
							»«IF a.type.isReferable
								»refers «
							ENDIF
						»«ENDIF
					»«ENDIF»«
				ENDIF
			»«ELSE
				»«a.type.refersConcept?.compileInlineAnnotation
			»«ENDIF
			»«IF a.derivedAttribute
				»derived «
			ENDIF
			»«a.type.compileDatatype» «a.name.toFirstLower» «
			IF a.inverseRelation
				»opposite «a.oppositeQN.toFirstLower
			»«ENDIF»'''
	}
	
	

}		
