package org.buildingsmart.mvd.tmvd.ui.errormessages

import org.eclipse.xtext.parser.antlr.SyntaxErrorMessageProvider
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider.IValueConverterErrorContext
import java.io.NotSerializableException
import org.buildingsmart.mvd.tmvd.validation.TextualMVDValidator

class TextualMvdSyntaxErrorMessageProvider extends SyntaxErrorMessageProvider {

	override getSyntaxErrorMessage(IValueConverterErrorContext context) {

		if (context.valueConverterException.cause instanceof NotSerializableException) {
			new SyntaxErrorMessage(context.getDefaultMessage(), TextualMVDValidator::NO_UUID);
		}
		return super.getSyntaxErrorMessage(context)
	}
}
