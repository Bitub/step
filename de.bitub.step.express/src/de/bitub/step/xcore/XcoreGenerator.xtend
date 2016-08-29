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
import de.bitub.step.xcore.XcoreInfo.Delegate
import java.util.Date
import java.util.Map
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName

import static extension de.bitub.step.util.EXPRESSExtension.*
import static extension de.bitub.step.xcore.XcoreConstants.*

/**
 * Generates Xcore specifications from EXPRESS models.
 */
class XcoreGenerator implements IGenerator {
	
	static val Logger LOGGER = Logger.getLogger(XcoreGenerator)
	
	/**
	 * Options of generation process.
	 */
	val public Map<Options, Object> options = newHashMap  
	
	/**
	 * Available options to the generation process.
	 */
	enum Options {
		
		COPYRIGHT_NOTICE, 
		NS_URI, 
		NS_PREFIX, 
		ENABLE_CDO, 
		PACKAGE, 
		SOURCE_FOLDER, 
		FORCE_UNIQUE_DELEGATES,
		UPDATE_CLASSPATH,
		ROOT_CONTAINER_NAME	
	}
		
		
	@Inject extension IQualifiedNameProvider nameProvider	
	
	// The current EXPRESS info aggregation
	var extension EXPRESSModelInfo modelInfo
	// The current xcore info aggregation
	var extension XcoreInfo xcoreInfo
	// The current Xcore package to fill
	var extension XcorePackage activePackage 
	
	@Inject EXPRESSInterpreter interpreter

	// Temporary second stage cache (any additional concept needed beside first stage)
	var secondStageCache = ''''''
	
	// The partitioning delegate
	var XcorePartitioningDelegate partitioningDelegate = new XcoreDefaultPartitionDelegate

	val escapeKeywords = <String>newHashSet("id", "contains", "opposite", "refers", "unique", "unordered")

	// The nsURI to package cache
	val packageCache = <String, XcorePackage>newHashMap		

	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {

		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;
		
		LOGGER.info('''Start generation of schema "«schema.name»".''')
		
		schema.generateSchema
		fsa.generateXcorePackages		
	}
	
	/**
	 * Sets the partitioning delegate. The delegate is basically a mapping of a given STEP ecore class and a qualified name in context. It 
	 * returns a descriptor of an assigned xcore package. Whenever the descriptor is not present, the default package (under the QN of
	 * the current schema) is taken.
	 */
	def void setPartitioningDelegate(XcorePartitioningDelegate delegate) {
		
		this.partitioningDelegate = delegate
		packageCache.clear
		activePackage = null
		secondStageCache = ''''''
	}
	
	
	def getPartitioningDelegate() {
		
		partitioningDelegate
	}
		
	
	def private getXCorePackage(ExpressConcept c) {
		
		var dscp = partitioningDelegate.apply(c)
		var pkg = if(dscp.isPresent) 
				packageCache.get(dscp.get().nsURI) // get by URI 
			else
				packageCache.get("") // get default
			
		if(null==pkg) {
			pkg = createXCorePackage(dscp.get)			
		}
		
		pkg 
	}
	
	
	def private createXCorePackage(XcorePackageDescriptor dscp) {
		
		var XcorePackage pkg
		// Generate new package
		packageCache.put(dscp.nsURI, pkg = new XcorePackage(
			modelInfo,
			activePackage.baseSchema,
			dscp.name, dscp.basePackage, dscp.nsURI
		))		
		
		pkg
	}
	
	
	/**
	 * Gets or creates the proper package cache and resets to the new package. Additionally a qualified name
	 * is provided by call.
	 */
	def private partitionXCorePackage(ExpressConcept c) {
		
		var dscp = partitioningDelegate.apply(c)
		var pkg = if(dscp.isPresent) 
				packageCache.get(dscp.get().nsURI) // get by URI 
			else
				packageCache.get("") // get default
				 
		if(null==pkg) {
						
			// Generate new package
			pkg = createXCorePackage(dscp.get)
		}	
		
		// Append secondary cache
		activePackage.textModel += secondStageCache
		
		// Switch and clean
		secondStageCache = ''''''
		activePackage = pkg
	}
	
		
	def private <T extends DataType> refersImport(T c) {
		
		switch(c) {
			
			BuiltInType: {
				
				if(c.compileBuiltin.length > 0) {
					
					// If implemented, register for import
					activePackage.importRegistry += packageCache.get("").packageQN.append(XcoreConstants.qualifiedBuiltInName(c))
				}										
			}
		}
		
		c		
	}
	
	
	def private CharSequence refersClassImport(Class<?> c) {
		
		val qn = QualifiedName.create(c.name.split("\\."))
		activePackage.importRegistry += qn
		 
		qn.lastSegment
	}
	
	
	def private Delegate refersImportDelegate(Delegate delegate) {
		
		addReferenceOnNonBuiltin(delegate.originAttribute.hostEntity, delegate.qualifiedName)
		delegate
	}
	
	
	def private addReferenceOnNonBuiltin(ExpressConcept c, String className) {
		
		var dscp = partitioningDelegate.apply(c)
		var pkg = if(dscp.isPresent) 
			 	packageCache.get(dscp.get().nsURI) // get by URI 
			else
				packageCache.get("") // get default
				
		if(null==pkg) {
			pkg = createXCorePackage(dscp.get)
		}
				
		if(pkg != activePackage) {
			// Append import request
			activePackage.importRegistry += pkg.packageQN.append(className)
			
			true
						
		} else {
			
			false
		}			
	}

	
	def private <T extends ExpressConcept> refersImport(T c) {
		
		if(!c.builtinAlias || c.aggregation) {
			
			addReferenceOnNonBuiltin(c, c.name.toFirstUpper)
		
		} else {
			
			// If no nested aggregation, check whether a compile statement exists in default package
			val builtIn = (c as Type).refersDatatype as BuiltInType
			val pkg = packageCache.get("")
			
			if(builtIn.implemented && activePackage != pkg) {
				// If implemented and default package is not active
				activePackage.importRegistry += pkg.packageQN.append(XcoreConstants.qualifiedBuiltInName(builtIn))
			}			
		}
		
		c
	}

	/**
	 * Checks given concept whether it is a cross-reference to another package.
	 */	
	def private <T extends Iterable<? extends ExpressConcept>> refersImports(T concepts) {
		
		for(ExpressConcept c : concepts) {
			c.refersImport
		}
		concepts
	}
	
	def getInfo() {
		
		xcoreInfo
	}
	
	
	/**
	 * Compiles a complete set of partial textual Xcore models from resource with a Scheme root object.
	 */
	def Map<String, CharSequence> compile(Resource resource) {
				
		val schema = resource.allContents.findFirst[e | e instanceof Schema] as Schema;		
		
		schema.compile
	}
	

	/**
	 * Compiles a complete set of partial textual Xcore models from a Scheme root object.
	 */	
	def Map<String, CharSequence> compile(Schema schema) {

		schema.generateSchema
		var modelMap = <String, CharSequence>newHashMap
		for(XcorePackage p : packageCache.values) {
			
			modelMap.put(p.packageQN.toString, p.compileXcorePackage)
		}
		
		modelMap		
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
	
	def private getSourceFolder(Schema s){
		
		val uri = s.eResource.URI
		var String genFolder 
		switch(uri) {
			case uri.scheme == "platform": {
				
				genFolder = uri.segment(1) + "/" + genFolder
			}
			default : {
				
				genFolder = "src-gen"
			}
		}
		
		genFolder
	}
	
	
	
	def private compileXcoreHeader(XcorePackage p) {
		
		compileXcoreHeader(
			p.packageName,
			p.packageNsURI,
			if(Options.SOURCE_FOLDER.option) Options.SOURCE_FOLDER.optionText else p.baseSchema.sourceFolder
		)
	}
	
		
	/**
	 * Assembles the header / annotation information on top of the Xcore file.
	 */
	def private compileXcoreHeader(String nsPrefix, String nsURI, String folder) { 
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
	
	
	/**
	 * Assembles the package textual model.
	 */
	def private compileXcorePackage(XcorePackage p) {

		if(activePackage == p) {
			
			activePackage.textModel += secondStageCache
			secondStageCache = ''''''
		}

		'''		
		«p.compileXcoreHeader»
		
		@GenModel(documentation="Generated EXPRESS model of schema «p.packageName»")
		@XpressModel(name="«p.baseSchema.name»",rootContainerClassRef="«xcoreInfo.rootContainerClass»")				
		package «p.packageQN»

		«FOR qn:p.importRegistry.sortBy[lastSegment]
		»import «qn»
		«ENDFOR»
						
		annotation "http://www.eclipse.org/OCL/Import" as Import
		annotation "http://www.bitub.de/express/XpressModel" as XpressModel
		annotation "http://www.bitub.de/express/P21" as P21

		«p.textModel»
		'''		
	}
	
	/**
	 * Escape key words of Xcore language by preceding "^".
	 */
	def private String escapeKeyword(String v) {
		
		if(escapeKeywords.contains(v)) "^"+v else v
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
		
		switch(t) {
			
			ReferenceType: {
				
				val concept = t.instance
				if(concept instanceof Type) {
					
					if((concept as Type).datatype.hasNestedCollector) {
						
						'''@XpressModel(pattern="nested") '''					
					}
				}					
			}
			
			CollectionType: {

				if(t.hasNestedCollector) {
					
					'''@XpressModel(pattern="nested") '''				
				}
				
			}
		}
	}
	
	
	def dispatch CharSequence compileAnnotation(Entity e) {
		
		'''@XpressModel(name="«e.name»",kind="generated") '''
	}
	
	def dispatch CharSequence compileAnnotation(Attribute a) {
		
		var annotations = newArrayList
		if(a.optional) {
			annotations += '''optional="true"'''			
		}
		if(a.hasDelegate) {
			annotations += '''pattern="delegate"''' 
		} else if(a.type.hasNestedCollector) {
			annotations += '''pattern="nested"'''
		}
		if(a.select) {
			annotations += '''select="«(a.refersDatatype.eContainer as Type).name.toFirstUpper»"'''
		}
			
		'''«IF !annotations.empty»@XpressModel(«annotations.join(',')») «
			ENDIF»«IF a.inverseRelation && !a.declaringInverseAttribute»@P21 «ENDIF»'''
	}
	
	def dispatch CharSequence compileAnnotation(Type t) {
	
		val alias = t.refersDatatype
		
		switch(alias) {
			
			BuiltInType: {
				
				'''@XpressModel(name="«t.name»", kind="mapped", qualifiedName="«t.datatype.qualifiedName»")
				'''
			}
			ReferenceType: {
			
				'''@XpressModel(name="«t.name»", kind="mapped" «IF t.hasNestedCollector», pattern="nested"«ENDIF»)
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

	def private createDefaultPackage(Schema s) {
		
		new XcorePackage(
			modelInfo,
			s,
			if(Options.NS_PREFIX.option) Options.NS_PREFIX.optionText else s.name, // prefix
			if(Options.PACKAGE.option) QualifiedName.create(Options.PACKAGE.optionText) else QualifiedName.create(s.name.toLowerCase), // package name
			if(Options.NS_URI.option) Options.NS_URI.optionText else s.name // URI
		)
	}
		
	def private CharSequence compileBuiltins(EClass ... types) {
		
		var String text = ''''''
		for(EClass c : types) {
			
			text += XcoreConstants.compileBuiltin(c)			
		}
		
		text
	}

	
	def private void generateXcorePackages(IFileSystemAccess fsa) {
		
		for(XcorePackage p : packageCache.values) {
			
			val fileName = p.packageName + ".xcore"
			LOGGER.info('''Generating model of "«p.packageName»" into file «fileName».''')
					
			fsa.generateFile(fileName, p.compileXcorePackage)
		}
	}

	
	/**
	 * Transforms a schema into a package definition.
	 */
	def private void generateSchema(Schema s) {

		// process schema for structural information
		//		
		modelInfo = interpreter.process(s);		
		
		// Create default package
		activePackage =  s.createDefaultPackage
		packageCache.put(activePackage.packageNsURI, activePackage)
		packageCache.put("", activePackage) // Fall back insurance 
		
		val rootContainerClass = if(Options.ROOT_CONTAINER_NAME.option) 
			Options.ROOT_CONTAINER_NAME.optionText else s.name.toFirstUpper
			
		xcoreInfo = new XcoreInfo(modelInfo, activePackage.packageQN.append(rootContainerClass))
		partitioningDelegate.schemeInfo = xcoreInfo	
		
		activePackage.textModel = '''	

		// Default root package		
		«compileBuiltins(
			ExpressPackage.Literals.BINARY_TYPE, 
			ExpressPackage.Literals.LOGICAL_TYPE
		)»
				
				
		// Base container of «s.name»
		@GenModel(documentation="Generated container class of «s.name»")
		@XpressModel(kind="new", pattern="container")
		class «s.name.toFirstUpper» {
					
		«FOR e:s.entity.filter[!abstract]»  contains «e.refersImport.name.toFirstUpper»[] «e.name.toFirstLower»
		«ENDFOR»
				
		}
		'''
		
		// Compile enums		
		s.type.filter[datatype instanceof EnumType].forEach[compileConcept]
		
		// Nested collections
		s.type.filter[aggregation].forEach[compileConcept]
		
		// Referenced selects
		modelInfo.reducedSelectsMap.keySet.forEach[compileConcept]
		
		// Finally entity definitions
		s.entity.forEach[compileConcept]					
	}
	
	
	/**
	 * Transforms an entity into a class definition. 
	 */	
	def dispatch void compileConcept(Entity e) {
				
		// Partition package
		var pckg = e.partitionXCorePackage
		
		// Compile Xcore model
		pckg.textModel += '''
		
		@GenModel(documentation="Class definition of «e.name»")
		«e.compileAnnotation»
		«IF e.abstract»abstract «ENDIF»class «e.name.toFirstUpper» «IF !e.supertype.refersImports.empty»extends «e.supertype.map[it.name].join(', ')» «ENDIF»{
		
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
	def dispatch void compileConcept(Type t) {
		
		var pckg = t.partitionXCorePackage
		val innerType = t.datatype
		
		switch(innerType) {
			
			GenericType: {
				// Wraps String						
				pckg.textModel += '''
				
				@XpressModel(name="«t.name»",kind="mapped")
				type «t.name.toFirstUpper» wraps String
				'''			
			}
			EnumType: {
				// Compile enum
				pckg.textModel += innerType.compileDatatype
			}
			SelectType: {
				
				// Compile select
				pckg.textModel += innerType.compileDatatype	
			}
			
			CollectionType: {
				
				// If entity reference
				val compiled = innerType.compileDatatype // Has to be done first
				pckg.textModel += '''
				
				@GenModel(documentation="Type wrapper for «t.name»")
				@XpressModel(name="«t.name»", kind="generated")
				class «t.name» {
				
					«innerType.compileAnnotation
					»«IF activePackage.hasNestedCollector(innerType) || (innerType.referable && t.refersConcept.referencedSelect)»contains «ELSEIF innerType.referable»refers «ENDIF
					»«compiled» a«innerType.fullyQualifiedName.lastSegment.toLowerCase.toFirstUpper»	
				}
				'''					
			}			
			
			default: {
				
				pckg.textModel += '''// FIXME «t.name»
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
		»	«IF c.refersImport.hasNestedCollector || c.aggregation»contains «ELSEIF c.referable»refers «ENDIF
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
							»«IF r.concept.aggregation»«(r.concept as Type).refersImport.name
							»«ELSE
							»«(r.concept.refersDatatype as BuiltInType).qualifiedBuiltInObjectName»«ENDIF
						»«ELSE»«r.concept.name.toFirstUpper»«ENDIF»
		«ENDFOR»
					default:
						throw new IllegalArgumentException
				}
				
				«t.name.toFirstLower» = s
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
		
		'''«(t.eContainer as Type).refersImport.name.toFirstUpper»''' 
	
	}
	
	def dispatch CharSequence qualifiedName(SelectType t) {
		
		'''«(t.eContainer as Type).refersImport.name.toFirstUpper»''' 
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
			'''«IF !r.refersDatatype.builtinAlias» 
					«IF attribute.inverseManyToManyRelation || attribute.nonUniqueRelation 
						»«attribute.refersRelationDelegateQN
					»«ELSE
						»«IF attribute.inverseRelation // Use declaring inverse entity (avoid super type)
							»«attribute.oppositeAttribute.hostEntity.refersImport.name
						»«ELSE
							»«r.instance.refersImport.name.toFirstUpper
						»«ENDIF
					»«ENDIF
				»«ELSE
					»«IF r.instance.aggregation
						»«(r.instance as Type).refersImport.datatype.qualifiedName
					»«ELSE
						»«(r.instance as Type).refersImport.refersDatatype.qualifiedName
					»«ENDIF
				»«ENDIF»'''				
		} else {
			
			// Hosted reference in type definition
			switch(r.instance) {
				Entity:
					'''«r.instance.refersImport.name.toFirstUpper»'''
				Type:
					'''«(r.instance as Type).refersImport.datatype.qualifiedName»''' 
			}
		}
	}
	
	def dispatch CharSequence qualifiedName(BuiltInType b) { 
		
		'''«b.refersImport.qualifiedBuiltInName»''' 
	
	}
	
	def dispatch CharSequence qualifiedName(GenericType g) { 
		
		'''«(g.eContainer as Type).refersImport.name.toFirstUpper»'''
	
	}
	
	
	def dispatch CharSequence qualifiedName(CollectionType c) {
		
		// Generate nested class
		if(c.nestedAggregation) {
								
			var String nestedCollectorClass
			if(!activePackage.hasNestedCollector(c)) {
			
				nestedCollectorClass = activePackage.createNestedCollector(c)	
				secondStageCache += generateDelegateNestedCollector(c)				
			} else {
				
				nestedCollectorClass = activePackage.getNestedCollector(c)
			}
			
			nestedCollectorClass + '''[]'''
			
		} else {
			
			c.type.qualifiedName + '''[]'''
		}
	}
	
	
	/**
	 * Generates a nested collector type.
	 */	
	def private CharSequence generateDelegateNestedCollector(CollectionType c) {
				
		val compiled = c.type.compileDatatype // Has to be done first
		
		'''
				
		
		@XpressModel(kind="«IF c.eContainer instanceof Type»generated«ELSE»new«ENDIF»", pattern="nested")
		class «activePackage.getNestedCollector(c)» {
			
			«c.type.compileAnnotation
				»«IF c.type.nestedAggregation»contains «ELSE»«IF !c.type.builtinAlias»«IF !c.uniqueReference»@Ecore(^unique="false") «ENDIF»refers «ELSE»«ENDIF»«ENDIF
				»«compiled» a«c.type.fullyQualifiedName.lastSegment.toLowerCase.toFirstUpper»
		}
		'''			
	}

	
	/**
	 * Generates a single delegate class for an inverse relation name.
	 */
	def private CharSequence generateRelationDelegate(Delegate typeDelegate, Delegate interfaceDelegate) {
		
		val declaringEntity = typeDelegate.originAttribute.hostEntity	
		val inverseEntity = typeDelegate.targetAttribute.hostEntity
				
		// Register import of select delegate
		val pckg = inverseEntity.XCorePackage
		if(activePackage != pckg) {
		
			if(null!=interfaceDelegate) {	
				activePackage.importRegistry += pckg.packageQN.append(interfaceDelegate.qualifiedName)				
			}
			activePackage.importRegistry += pckg.packageQN.append(inverseEntity.name.toFirstUpper)
		}
		
		'''
		
		@GenModel(documentation="Inverse delegation helper between «declaringEntity.name» and «inverseEntity.name»")
		@XpressModel(kind="new", pattern="delegate"«IF null!=interfaceDelegate && typeDelegate.targetAttribute.select»,select="«declaringEntity.name»"«ENDIF»)
		class «typeDelegate.qualifiedName» «IF null!=interfaceDelegate»extends «interfaceDelegate.qualifiedName»«ENDIF» {
			«IF null==interfaceDelegate»
			// Reference to «inverseEntity.name»
			«inverseEntity.compileAnnotation
			»refers «inverseEntity.refersAlias.name.toFirstUpper» «typeDelegate.originAttribute.name.toFirstLower» opposite «typeDelegate.targetAttribute.name.toFirstLower»
			«ENDIF»
			// Containment on declaring side of «declaringEntity.name»
			container «declaringEntity.refersAlias.name.toFirstUpper» «typeDelegate.targetAttribute.name.toFirstLower» opposite «typeDelegate.originAttribute.name.toFirstLower»	
		}
		'''
	}
	
	
	/**
	 * Compiles a non-unique relationship by adding delegates.
	 */
	def private CharSequence generateRelationDelegateSelect(Delegate relationDelegate) {
		
		val inverseConcept = relationDelegate.originAttribute.hostEntity
		val inverseAttribute = relationDelegate.originAttribute
						
		val targetConcept = inverseAttribute.type.refersConcept
		
		'''
		
		@XpressModel(kind="new", pattern="delegate")
		@GenModel(documentation="Delegation select of «inverseConcept.name»")
		interface «relationDelegate.qualifiedName» {						
			«IF inverseAttribute.supertypeOppositeDirectedRelation»
				// Inverse super type
				op «targetConcept.refersImport.name.toFirstUpper» get«inverseAttribute.name.toFirstUpper»()«
			ELSE»
				// Inverse select branch
				op «typeof(EObject).refersClassImport» get«inverseAttribute.name.toFirstUpper»()«
			ENDIF»
			// Non-unique counter part, using concept QN as reference name
			refers «inverseConcept.refersAlias.name.toFirstUpper» «inverseConcept.name.toFirstLower» opposite «inverseAttribute.name.toFirstLower»
		}
		'''
	}
	
	def boolean hasDelegate(Attribute a) {
		
		if(a.hasRelationDelegate) {
			// Anyway, has been decided before
			true
			
		} else {
						
			if(Options.FORCE_UNIQUE_DELEGATES.option && a.isInverseManyToManyRelation) {
				// Force even unique n-m relations to have a delegate	
				a.createRelationDelegate
				
			} else if(a.nonUniqueRelation) {
				// Otherwise, only if non-unique inverse relation
				a.createRelationDelegate
				
			} else {
				// Otherwise, no delegate is needed
				false
			}
		}
	}
	
		
	/**
	 * Generates a relation delegate and returns class reference.
	 */
	def private String refersRelationDelegateQN(Attribute a) { 
								
		// Test whether a delegate exists (if N-to-M or inverse select)		
		if(a.hasDelegate) {
				
			val delegateSet = a.relationDelegates // Real instance delegates		
			val delegateSelect = if(a.declaringInverseAttribute) 
					a.opposite.relationDelegates.findFirst[targetAttribute==null] // Opposite
				else
					delegateSet.findFirst[targetAttribute==null] // Select interface
					
			// Generate only if active package matches the origin attribute entity
			for(Delegate delegate : delegateSet.filter[
				a == originAttribute && activePackage == originAttribute.hostEntity.XCorePackage
			]) {
				// If got select, enforce special handling
				if(delegate == delegateSelect) {
					
					secondStageCache += generateRelationDelegateSelect(delegate)
				} else {
					
					secondStageCache += generateRelationDelegate(delegate, delegateSelect)						
				}
			}
							
			// Delegation reference
			val delegate = a.relationDelegate			
			delegate.refersImportDelegate.qualifiedName
											
		} else {
			
			// Direct reference 
			a.oppositeAttribute.hostEntity.refersImport.name.toFirstUpper
		}
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
	def isContainmentReference(Attribute a) {
		
		if(a.hasDelegate) {
			
			a.declaringInverseAttribute 
		} else {
			
			activePackage.hasNestedCollector(a.type) || a.refersConcept.isReferencedSelect
		}			
	}
	
	// Whether to use an EClass reference
	def isReferable(Attribute a) {
		
		a.type.referable || a.hasDelegate || activePackage.hasNestedCollector(a.type)
	}

	def private compileAttribute(Attribute a) { 
		
		val compiled = a.type.compileDatatype
		'''«a.compileAnnotation
			»«IF a.referable
				»«IF a.containmentReference»contains «
				ELSE
					»«IF !a.type.uniqueReference && !a.inverseRelation»@Ecore(^unique="false") «ENDIF»refers «
				ENDIF
			»«ENDIF
			»«IF a.derivedAttribute»derived «ENDIF
			»«compiled» «a.name.toFirstLower.escapeKeyword
			»«IF a.inverseRelation» opposite «a.oppositeQN.toFirstLower.escapeKeyword»«ENDIF»'''
	}
	
	
}		
