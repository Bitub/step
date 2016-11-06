package de.bitub.step.xcore;

import java.util.Optional;
import java.util.function.Function;

import de.bitub.step.express.ExpressConcept;

public interface XcorePartitioningDelegate extends Function<ExpressConcept, Optional<XcorePackageDescriptor>> {
  
  void setSchemeInfo(XcoreInfo info);

}
