package de.bitub.step.express.tests.xcoregen.ifc

import de.bitub.step.express.EnumType
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import de.bitub.step.xcore.XcoreFunctionalPartitioningDelegate
import de.bitub.step.xcore.XcorePackageDescriptor

import static extension de.bitub.step.util.EXPRESSExtension.*

/**
 * An IFC procedural partitioner with the following rule set
 * <ul>
 * <li>All enums go into "enums"</li>
 * <li>All non-relational selects go into "selects"</li>
 * <li>All abstract entities go into "model"</li>
 * <li>All non-abstract entities go into "impl"</li>
 * <li>All explicit aggregation types go into "aggregation"</li>
 * <li>All entities having an unidirectional (inverse) relation go into "core"</li>
 * <li>All relation entities go into super package "relation"</li>
 * </ul>
 */
class IfcPartitioningDelegate extends XcoreFunctionalPartitioningDelegate {
	
	val FunctionalDescriptor ifcRootDescriptor
		
	new(XcorePackageDescriptor ifcPackageRoot) {
		
		this(new FunctionalDescriptor(ifcPackageRoot))
	}
	
	new(FunctionalDescriptor ifcRootDescriptor) {
		
		super(ifcRootDescriptor)
		this.ifcRootDescriptor = ifcRootDescriptor 
		
		init(ifcRootDescriptor)
	}

	def private init(FunctionalDescriptor ifcRootPackage) {
		
		append(new Predicate(ifcRootPackage).isDataKindOf(typeof(EnumType)).mapPackageName("enums").create)
		append(new Predicate(ifcRootPackage).isDataKindOf(typeof(SelectType)).mapPackageName("selects").create)
		
		//append(new Predicate(ifcRootPackage).abstractEntity.lteSupertypeLevel(3).mapPackageName("high").create)
		//append(new Predicate(ifcRootPackage).abstractEntity.gtSupertypeLevel(3).mapPackageName("model").create)
		append(new Predicate(ifcRootPackage).abstractEntity.mapPackageName("model").create)
				
		append(new Predicate(ifcRootPackage).nonAbstractEntity.mapPackageName("impl").create)
			
		append(new Predicate(ifcRootPackage).isTrue([i, c | 
				if(c instanceof Type) 
					(c as Type).aggregation
				else 
					false
			]).mapPackageName("aggregation").create)

		append(new Predicate(ifcRootPackage).hasUnidirectionalRelation.mapPackageName("core").create)
			
		append(new Predicate(ifcRootPackage).isNamedLike("^IfcRel|Relation").mapPackageName("relation").create)
	}
	
}