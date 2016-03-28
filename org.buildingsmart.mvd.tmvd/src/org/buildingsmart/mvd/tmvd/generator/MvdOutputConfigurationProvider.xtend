package org.buildingsmart.mvd.tmvd.generator

import org.eclipse.xtext.generator.OutputConfigurationProvider

class MvdOutputConfigurationProvider extends OutputConfigurationProvider {

	public val MVD_GEN = "./mvd-gen"

	override getOutputConfigurations() {
		super.getOutputConfigurations() => [
			head.outputDirectory = MVD_GEN
		]
	}
}
