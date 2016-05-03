/* 
 * Copyright (c) 2015,2016  Bernold Kraft and others (Berlin, Germany).
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
import java.util.Date
import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider

import static extension de.bitub.step.util.EXPRESSExtension.*
import static extension de.bitub.step.xcore.XcoreConstants.*

/**
 * Generates Xcore specifications from EXPRESS models.
 */
class XcoreGenerator implements IGenerator {
	
	enum Options {
		
		SEPARATE_TYPEPACKAGE, 
		COPYRIGHT_NOTICE, 
		NS_URI, 
		NS_PREFIX, 
		ENABLE_CDO, 
		PACKAGE, 
		SOURCE_FOLDER, 
		FORCE_UNIQUE_DELEGATES,
		UPDATE_CLASSPATH	
	}
		
	static Logger LOGGER = Logger.getLogger(XcoreGenerator)
		
		
	@Inject extension IQualifiedNameProvider nameProvider	
	
	extension EXPRESSModelInfo modelInfo
	extension XcoreInfo xcoreInfo
	
	@Inject EXPRESSInterpreter interpreter
	@Inject FunctionGenerator functionGenerator


	static val PREFIX_DELEGATE = "Delegate"		

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
	
	
	def getInfo() {
		
		xcoreInfo
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
	
	def isOption(Options o) {
		
		options.containsKey(o)
	}
	
	def private getOptionText(Options o) {
		
		if(options.containsKey(o)) options.get(o).toString as String else ""
	}
		
	def private assembleXcoreHeader(Schema s) {
				
		val uri = s.eResource.URI
		var genFolder = "src-gen"
		switch(uri) {
			case uri.scheme == "platform": {
				
				genFolder = uri.segment(1) + "/" + genFolder
			}
			default : {
				
				// Nothing here
			}
		}
		assembleXcoreHeader(
			if(Options.NS_PREFIX.option) Options.NS_PREFIX.optionText else s.name,
			if(Options.NS_URI.option) Options.NS_URI.optionText else s.name,
			if(Options.SOURCE_FOLDER.option) Options.SOURCE_FOLDER.optionText else genFolder
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
			«IF Options.PACKAGE.option»basePackage="«Options.PACKAGE.optionText»",«ENDIF»
			«IF Options.COPYRIGHT_NOTICE.option»copyrightText="«Options.COPYRIGHT_NOTICE.optionText»",«ENDIF»
			modelDirectory="«folder»",
			adapterFactory="false",
			forceOverwrite="true",
			updateClasspath="«IF Options.UPDATE_CLASSPATH.option»true«ELSE»false«ENDIF»",
			complianceLevel="8.0",
			optimizedHasChildren="true"«IF Options.ENABLE_CDO.optionTrue»,
									 
			rootExtendsInterface="org.eclipse.emf.cdo.CDOObject", 
			rootExtendsclassRef="org.eclipse.emf.internal.cdo.CDOObjectImpl", 
			importerID="org.eclipse.emf.importer.ecore", 
			featureDelegation="Dynamic", 
			providerRootExtendsclassRef="org.eclipse.emf.cdo.edit.CDOItemProviderAdapter"«ENDIF»
		)
				
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
		package «name.toLowerCase»

		import org.eclipse.emf.ecore.EObject
						
		annotation "http://www.eclipse.org/OCL/Import" as Import
		annotation "http://www.bitub.de/express/XpressModel" as XpressModel
		annotation "http://www.bitub.de/express/P21" as P21
				
		'''		
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
	
	
	def dispatch CharSequence compileAnnotation(DataType t) {
		
		if(t instanceof ReferenceType) {	
			
			val concept = (t as ReferenceType).instance
			if(concept instanceof Type) {
				
				if((concept as Type).datatype.hasDelegate) {
					
					return '''@XpressModel(pattern="nested") '''
				
				}
			}	
		}
			
		if(t instanceof CollectionType) {
			
			if((t as CollectionType).hasDelegate) {
				
				return '''@XpressModel(pattern="nested") '''				
			}
		}
	}
	
	
	def dispatch CharSequence compileAnnotation(Entity e) {
		
		'''@XpressModel(name="«e.name»",kind="generated") '''
	}
	
	def dispatch CharSequence compileAnnotation(Attribute a) {
		
		var annotations = newArrayList
		if(a.hasDelegate || (a.type.hasDelegate)) {
			annotations += '''pattern="delegate"''' 
		}
		if(a.select) {
			annotations += '''select="«(a.refersDatatype.eContainer as Type).name.toFirstUpper»"'''
		}
			
		'''«IF !annotations.empty»@XpressModel(«annotations.join(',')») «
			ENDIF»«IF !a.declaringInverseAttribute»@P21 «ENDIF»'''
	}
	
	def dispatch CharSequence compileAnnotation(Type t) {
	
		val alias = t.refersDatatype
		
		switch(alias) {
			
			BuiltInType: {
				
				'''@XpressModel(name="«t.name»", kind="mapped", qualifiedName="«t.datatype.qualifiedName»")
				'''
			}
			ReferenceType: {
			
				'''@XpressModel(name="«t.name»", kind="mapped" «IF t.datatype.hasDelegate», pattern="nested"«ENDIF»)
				'''
			}
			GenericType: {
				
				'''@XpressModel(name="«t.name»", kind="mapped", qualifiedName="«alias.qualifiedName»")
				'''
			}
			
			default:
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
		xcoreInfo = new XcoreInfo(modelInfo)
			 
		'''	
		«s.assembleXcoreHeader»
		
		
		@GenModel(documentation="Generated EXPRESS model of schema «s.name»")
		@XpressModel(name="«s.name»",rootContainerClassRef="«s.name»")		
		«s.assembleXcorePackage» 
		
		«ExpressPackage.Literals.BINARY_TYPE.compileBuiltin»
		
		«ExpressPackage.Literals.LOGICAL_TYPE.compileBuiltin»
				
		// Base container of «s.name»
		@GenModel(documentation="Generated container class of «s.name»")
		@XpressModel(kind="new", pattern="container")
		class «s.name.toFirstUpper» {
					
		«FOR e:s.entity.filter[!abstract]»  contains «e.name.toFirstUpper»[] «e.name.toFirstLower»
		«ENDFOR»
				
		}
		
		// --- ENUMERATIONS ----------------------------------
		
		«FOR t:s.type.filter[datatype instanceof EnumType]»«t.compileConcept»«ENDFOR»
		
		// --- TYPED NESTED COLLECTIONS ----------------------
		
		«FOR t:s.type.filter[aggregation]»«t.compileConcept»«ENDFOR»
		
		// --- REFERENCED SELECTS ----------------------------
		
		«FOR t:modelInfo.reducedSelectsMap.keySet»«t.compileConcept»«ENDFOR»
		
		// --- ENTITY DEFINITIONS ----------------------------
		
		«FOR e:s.entity»«e.compileConcept»«ENDFOR»
			
		// --- ADDITIONALLY GENERATED ------------------------
		
		«//functionGenerator.compileFunction(s)
		»
		
		«secondStageCache»
			
		// --- END OF «s.name» ---
		'''		
	}
	
	
	/**
	 * Transforms an entity into a class definition. 
	 */	
	def dispatch compileConcept(Entity e) {
		
		// TODO Enable derived attributes
		'''
		
		@GenModel(documentation="Class definition of «e.name»")
		«e.compileAnnotation»
		«IF e.abstract»abstract «ENDIF»class «e.name.toFirstUpper» «IF !e.supertype.empty»extends «e.supertype.map[name].join(', ')» «ENDIF»{
		
		  «FOR a : e.attribute
		  	»«IF !a.derivedAttribute»
		  	@GenModel(documentation="Attribute definition of «a.name»")
		  	«a.compileAttribute»
		  	
		  	«ENDIF
		  »«ENDFOR»
		}
		'''
	}
	
	/**
	 * Transforms a type into a class / type definition.
	 */
	def dispatch compileConcept(Type t) {
		
		switch(t.datatype) {
			
			GenericType: {
				// Wraps String						
				'''
				
				@XpressModel(name="«t.name»",kind="mapped")
				type «t.name.toFirstUpper» wraps String
				'''			
			}
			EnumType: {
				// Compile enum
				t.datatype.compileDatatype
			}
			SelectType: {
				
				// Compile select
				t.datatype.compileDatatype	
			}
			
			CollectionType: {
				
				// If entity reference
				val compiled = t.datatype.compileDatatype // Has to be done first
				'''
				
				@GenModel(documentation="Type wrapper for «t.name»")
				@XpressModel(name="«t.name»", kind="generated")
				class «t.name» {
				
					«t.datatype.compileAnnotation
					»«IF t.datatype.hasDelegate || (t.datatype.referable && t.refersConcept.referencedSelect)»contains «ELSEIF t.datatype.referable»refers «ENDIF
					»«compiled» a«(t.datatype as CollectionType).fullyQualifiedName.lastSegment.toLowerCase.toFirstUpper»	
				}
				'''					
			}			
			
			default: {
				
				'''// FIXME «t.name»
				'''				
			}	
		}		
	}
	
	/**
	 * Transforms a Select into a class specification.
	 */
	def dispatch compileDatatype(SelectType s) {
		
		var t = s.eContainer as Type
		var rList = modelInfo.reducedSelectsMap.get(t)
		var flattenSelect = modelInfo.resolvedSelectsMap.get(t)
		
		var i = 0
		
		val qualifiedNameMap = <ExpressConcept, Pair<Integer, String>>newHashMap
		for(ExpressConcept c : flattenSelect) {
			
			switch(c) {
				
				Type:
					if(c.builtinAlias && !c.aggregation) {						
						qualifiedNameMap.put(c, ( i -> c.refersDatatype.qualifiedName.toString))						
					} else {						
						qualifiedNameMap.put(c, (i -> c.name.toFirstUpper))
					}
					
				Entity:
					qualifiedNameMap.put(c, (i -> c.name.toFirstUpper))
			}
			
			i++ 
		}
		
		'''
		
		@GenModel(documentation="<ul>«qualifiedNameMap
			.entrySet
			.sortBy[key.name]
			.join("\n		",[e|'''<li>{@link «e.key.name.toUpperCase»} as {@link «
				IF e.key.builtinAlias && !e.key.aggregation
					»«(e.key.refersDatatype as BuiltInType).qualifiedBuiltInObjectName
				»«ELSE
					»«e.value.value»«ENDIF»}</li>'''])»</ul>")
		@XpressModel(kind="new")
		enum Enum«t.name.toFirstUpper» {
			«qualifiedNameMap.entrySet
			.sortBy[key.name]
			.join(",\n",[e | '''«e.key.name.toUpperCase» = «e.value.key»'''])»
		}
		
		@GenModel(documentation="Select class of «t.name»")
		@XpressModel(name="«t.name»",kind="generated")
		class «t.name.toFirstUpper» {
			
			Enum«t.name.toFirstUpper» «t.name.toFirstLower»
			
			// Principal select value
			
		«FOR c : rList.map[concept].sortBy[name]
		»	«IF c.hasDelegate || c.aggregation»contains «ELSEIF c.referable»refers «ENDIF
			»«qualifiedNameMap.get(c).value» «qualifiedNameMap.get(c).value.toFirstLower
			»«IF c.builtinAlias && !(c as Type).datatype.aggregation»Value«ENDIF»
		«ENDFOR»
			
			// Operations
			
			op void setValue(Enum«t.name.toFirstUpper» s, Object v) {
				
				switch(s) {
		«FOR r:rList.sortBy[concept.name]
		»			«r.mappedConcepts.sortBy[name].map[name.toUpperCase].join(",\n			",[n|'''case «n»'''])»:
						«qualifiedNameMap.get(r.concept).value.toFirstLower
						»«IF r.concept.builtinAlias && !(r.concept as Type).datatype.aggregation»Value«ENDIF» = v as «IF r.concept.builtinAlias
							»«IF r.concept.aggregation»«(r.concept as Type).name
							»«ELSE
							»«(r.concept.refersDatatype as BuiltInType).qualifiedBuiltInObjectName»«ENDIF
						»«ELSE»«r.concept.name.toFirstUpper»«ENDIF»
		«ENDFOR»
					default:
						throw new IllegalArgumentException
				}
			}
			
			op Object getValue() {
				switch(«t.name.toFirstLower») {
		«FOR r:rList.sortBy[concept.name]
		»			«r.mappedConcepts.sortBy[name].map[name.toUpperCase].join(",\n			",[n|'''case «n»'''])»:
						«qualifiedNameMap.get(r.concept).value.toFirstLower
						»«IF r.concept.builtinAlias && !(r.concept as Type).datatype.aggregation»Value«ENDIF»
		«ENDFOR»
					default:
						throw new IllegalArgumentException
				}
			}
		}
		'''
	}

	
	def dispatch CharSequence qualifiedName(EnumType t) { 
		
		'''«(t.eContainer as Type).name.toFirstUpper»'''
	
	}
	
	def dispatch CharSequence qualifiedName(SelectType t) {
		
		'''«(t.eContainer as Type).name.toFirstUpper»'''
	}
	
	/**
	 * Returns the qualified name of a reference. In general
	 * <ul>
	 * <li>simple references (unique)</li>
	 * <li>unique inverse relations</li>
	 * </ul> 
	 */
	def dispatch CharSequence qualifiedName(ReferenceType r) { 

		val attribute = r.hostAttribute	
		
		if(null!=attribute){
			
			// Hosted in relationship definition
			'''«IF !r.builtinAlias»
					«IF attribute.nonUniqueRelation || Options.FORCE_UNIQUE_DELEGATES.option
						»«attribute.createDelegateQN
					»«ELSE
						»«r.instance.name.toFirstUpper
					»«ENDIF
				»«ELSE
					»«IF r.instance.aggregation
						»«(r.instance as Type).datatype.qualifiedName 
					»«ELSE
						»«(r.instance as Type).refersDatatype.qualifiedName
					»«ENDIF
				»«ENDIF»'''				
		} else {
			
			// Hosted reference in type definition
			switch(r.instance) {
				Entity:
					'''«r.instance.name.toFirstUpper»'''
				Type:
					'''«(r.instance as Type).datatype.qualifiedName»'''
			}
		}
	}
	
	def dispatch CharSequence qualifiedName(BuiltInType b) { 
		
		'''«b.qualifiedBuiltInName»'''
	
	}
	
	def dispatch CharSequence qualifiedName(GenericType g) { 
		
		'''«(g.eContainer as ExpressConcept).name.toFirstUpper»'''
	
	}
	
	
	def dispatch CharSequence qualifiedName(CollectionType c) {
		
		// Generate nested class
		if(c.hasDelegate) {
			
			return c.delegateQN+'''[]'''
		}
		
		var CharSequence referredType
		 			 
//		if(c.typeAggregation) {
//		
//			referredType = generateTypeAggregationWrapper(c)
//							
//		} else 
		if(c.nestedAggregation){
			
			referredType = generateDelegateNestedCollector(c)+'''[]'''
			
		} else {
			
			referredType = c.type.qualifiedName+'''[]'''
		}
		
		referredType
	}
	
	
//	def private String generateTypeAggregationWrapper(CollectionType c) {
//		
//		var typeWrapperName = c.createNestedDelegate
//		
//		secondStageCache +=
//			'''
//			
//			@XpressModel(kind="«IF c.eContainer instanceof Type»generated«ELSE»new«ENDIF»", pattern="nested")
//			type «typeWrapperName» wraps «c.qualifiedReference.segments.join»
//			'''			
//		
//		typeWrapperName
//	}

		
	def private String generateDelegateNestedCollector(CollectionType c) {
		
		val nestedCollectorName = c.createNestedDelegate
		val compiled = c.type.compileDatatype // Has to be done first
		secondStageCache +=
			'''
					
			
			@XpressModel(kind="«IF c.eContainer instanceof Type»generated«ELSE»new«ENDIF»", pattern="nested")
			class «nestedCollectorName» {
				
				«c.type.compileAnnotation
					»«IF c.type.nestedAggregation»contains «ELSE»«IF !c.builtinAlias»«IF !c.uniqueReference»@Ecore(^unique="false") «ENDIF»refers «ELSE»«ENDIF»«ENDIF
					»«compiled» a«c.type.fullyQualifiedName.lastSegment.toLowerCase.toFirstUpper»
			}
			'''			
								
		nestedCollectorName
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
		@XpressModel(kind="new", pattern="delegate"«IF hasInterface && inverse.select»,select="«declaringEntity.name»"«ENDIF»)
		class «delegateName» «IF hasInterface»extends «delegateInterface»«ENDIF» {
			«IF !hasInterface»
			// Reference to «inverseEntity.name»
			«inverseEntity.compileAnnotation
			»refers «inverseEntity.refersAlias.name.toFirstUpper» «declaring.name.toFirstLower» opposite «inverse.name.toFirstLower»
			«ENDIF»
			// Containment on declaring side of «declaringEntity.name»
			container «declaringEntity.refersAlias.name.toFirstUpper» «inverse.name.toFirstLower» opposite «declaring.name.toFirstLower»	
		}
		'''
		return delegateName
	}
	
	
	/**
	 * Compiles a non-unique relationship by adding delegates.
	 */
	def private generateDelegateNonUniqueRelation(Attribute a) {
		
		val declaringInverse = if (a.declaringInverseAttribute) a else a.oppositeAttribute		
				
		val inverseConcept = declaringInverse.opposite.eContainer as ExpressConcept
		val inverseAttribute = declaringInverse.opposite
		val declaringInverseSet = inverseAttribute.allOppositeAttributes
						
		// Generate proxy interface name as "ProxyEntityToSelect"
		val targetConcept = inverseAttribute.type.refersConcept
		val delegateInterfaceName = PREFIX_DELEGATE + inverseConcept.name.toFirstUpper + targetConcept.name.toFirstUpper

		// Map QN of inverse attribute
		xcoreInfo.createDelegate(inverseAttribute, delegateInterfaceName, null)

		// Write to second stage cache				
		secondStageCache +=
		
		'''
		
		@XpressModel(kind="new", pattern="delegate")
		@GenModel(documentation="Delegation select of «targetConcept.name»")
		interface «delegateInterfaceName» {						
			«IF inverseAttribute.supertypeOppositeDirectedRelation»
				// Inverse super type
				op «targetConcept.name.toFirstUpper» get«inverseAttribute.name.toFirstUpper»()«
			ELSE»
				// Inverse select branch
				op EObject get«inverseAttribute.name.toFirstUpper»()«
			ENDIF»
			// Non-unique counter part, using concept QN as reference name
			refers «inverseConcept.refersAlias.name.toFirstUpper» «inverseConcept.name.toFirstLower» opposite «inverseAttribute.name.toFirstLower»
		}
		'''

		// Generate proxies for all 
		for(Attribute ia : declaringInverseSet) {
								
			val delegateClass = generateDelegate(ia, inverseAttribute, delegateInterfaceName)
			xcoreInfo.createDelegate(ia, delegateClass, inverseAttribute)
		}
	}
	
	/**
	 * Generates a simple delegate.
	 */
	def private generateDelegateUniqueRelation(Attribute a) {
		
		val declaringInverse = if (a.declaringInverseAttribute) a else a.oppositeAttribute
		
		// Generate delegate without interface
		val qnClassRef = generateDelegate(declaringInverse, declaringInverse.opposite, "")
		xcoreInfo.createDelegate(declaringInverse, qnClassRef, declaringInverse.opposite)
	}
	
	
	/**
	 * Generates a relation delegate and returns class reference.
	 */
	def protected String getCreateDelegateQN(Attribute a) { 
				
		// Get existing QN of delegate
		if(!a.hasDelegate) {
			
			if(a.nonUniqueRelation) {
			
				generateDelegateNonUniqueRelation(a)
				
			} else if(a.isInverseManyToManyRelation && Options.FORCE_UNIQUE_DELEGATES.option) {
				// Create delegates for unique relations only if forced
				generateDelegateUniqueRelation(a)
			}
		}
		
		a.delegateQN
	}
	
		
	def dispatch CharSequence compileDatatype(CollectionType c) {
								
		'''«IF !c.builtinAlias
				»«IF !#["ARRAY","LIST"].contains(c.name)
					»unordered «
				ENDIF
				»«IF "SET"==c.name
					»unique «
				ENDIF»«
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
			
		val type = (t.eContainer as Type)
		'''
		
		@GenModel(documentation="Enumeration of «type.name»")
		@XpressModel(name="«type.name»",kind="generated")
		enum «type.name.toFirstUpper» {

			«nameList.join(",\n")»
		}
		'''
	}

	// Whether to use containment or not
	def isContainementReference(Attribute a) {
		
		if(a.hasDelegate)
			a.declaringInverseAttribute 
		else
			a.type.hasDelegate || a.refersConcept.isReferencedSelect			
	}
	
	// Whether to use an EClass reference
	def isReferable(Attribute a) {
		
		a.type.referable || a.type.hasDelegate
	}

	def compileAttribute(Attribute a) { 
		
		val compiled = a.type.compileDatatype
		'''«a.compileAnnotation
			»«IF a.referable
				»«IF a.containementReference»contains «
				ELSE
					»«IF !a.type.uniqueReference && !a.inverseRelation»@Ecore(^unique="false") «ENDIF»refers «
				ENDIF
			»«ENDIF
			»«IF a.derivedAttribute»derived «ENDIF
			»«compiled» «a.name.toFirstLower
			»«IF a.inverseRelation» opposite «a.oppositeQN.toFirstLower»«ENDIF»'''
	}
	
	
}		
