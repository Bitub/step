package de.bitub.step.xcore

import org.eclipse.xtext.generator.IOutputConfigurationProvider
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration

class XcoreOutputConfigurationProvider implements IOutputConfigurationProvider {
	
	override getOutputConfigurations() {
		
		var defaultOutput = new OutputConfiguration(IFileSystemAccess.DEFAULT_OUTPUT);
	    defaultOutput.setDescription("Output Folder");
	    defaultOutput.setOutputDirectory("./model-gen");
	    defaultOutput.setOverrideExistingResources(true);
	    defaultOutput.setCreateOutputDirectory(true);
	    defaultOutput.setCleanUpDerivedResources(true);
	    defaultOutput.setSetDerivedProperty(true);
	
	    return newHashSet(defaultOutput);
	}
	
}