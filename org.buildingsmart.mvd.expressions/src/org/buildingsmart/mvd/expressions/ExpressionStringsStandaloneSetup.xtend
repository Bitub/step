/*
 * generated by Xtext 2.10.0
 */
package org.buildingsmart.mvd.expressions


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
class ExpressionStringsStandaloneSetup extends ExpressionStringsStandaloneSetupGenerated {

	def static void doSetup() {
		new ExpressionStringsStandaloneSetup().createInjectorAndDoEMFRegistration()
	}
}