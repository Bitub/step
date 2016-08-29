package de.bitub.step.express.tests.xcoregen.ifc

import de.bitub.step.express.Entity
import de.bitub.step.express.EnumType
import de.bitub.step.express.SelectType
import de.bitub.step.express.Type
import de.bitub.step.xcore.XcoreFunctionalPartitioningDelegate
import de.bitub.step.xcore.XcorePackageDescriptor

import static extension de.bitub.step.util.EXPRESSExtension.*

/**
 * An IFC procedural partitioner with the following rule set
 * <ul>
 * <li>All enums go into "enum"</li>
 * <li>All non-relational selects go into "select"</li>
 * <li>All abstract entities up to level 3 go into "core"</li>
 * <li>All abstract entities above level 3 go into "model"</li>
 * <li>All non-abstract entities go into "impl"</li>
 * <li>All relation entities go into super package "relation"</li>
 * <li>All explicite aggregation types go into "aggregation"</li>
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
		
		append(FunctionalDescriptor.isDataKindOf(ifcRootPackage, typeof(EnumType), "enum"))
		append(FunctionalDescriptor.isDataKindOf(ifcRootPackage, typeof(SelectType), "select"))
		
		append(FunctionalDescriptor.isTrue(ifcRootPackage, [c | 
				if(c instanceof Entity) 
					(c as Entity).abstract 
						&& Predicates.getTypeLevel(c) <= 3
				else 
					false
			], "core"))
		append(FunctionalDescriptor.isTrue(ifcRootPackage, [c | 
				if(c instanceof Entity) 
					(c as Entity).abstract 
						&& Predicates.getTypeLevel(c) > 3
				else false	], "model"))
				
		append(FunctionalDescriptor.isTrue(ifcRootPackage, [c | 
				if(c instanceof Entity) 
					!(c as Entity).abstract && (c as Entity).attribute.exists[declaringInverseAttribute]
				else 
					false
			], "impl"))
		append(FunctionalDescriptor.isTrue(ifcRootPackage, [c | 
				if(c instanceof Type) 
					(c as Type).aggregation
				else 
					false
			], "aggregation"))

		append(FunctionalDescriptor.isTrue(ifcRootPackage, [c | 
				if(c instanceof Entity) 
					(c as Entity).attribute.exists[declaringInverseAttribute]
				else 
					false
			], "tight"))
			
		append(FunctionalDescriptor.isNamedLike(ifcRootDescriptor,"^IfcRel|Relation", "relation"))
	}
	
}