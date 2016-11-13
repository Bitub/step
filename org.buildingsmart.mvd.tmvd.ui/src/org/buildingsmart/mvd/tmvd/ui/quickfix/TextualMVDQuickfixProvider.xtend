package org.buildingsmart.mvd.tmvd.ui.quickfix

import java.util.UUID
import org.buildingsmart.mvd.mvdxml.TemplatesType
import org.buildingsmart.mvd.tmvd.validation.TextualMVDValidator
import org.eclipse.xtext.diagnostics.Diagnostic
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.validation.Issue

/**
 * Custom quickfixes.
 *
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#quick-fixes
 */
class TextualMVDQuickfixProvider extends DefaultQuickfixProvider {

	@Fix(TextualMVDValidator::INVALID_NAME)
	def capitalizeConceptTemplateNameFirstLetter(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Capitalize name', 'Capitalize the name.', 'upcase.png') [ context |
			val xtextDocument = context.xtextDocument
			val firstLetter = xtextDocument.get(issue.offset, 1)
			xtextDocument.replace(issue.offset, 1, firstLetter.toUpperCase)
		]
	}

	@Fix(TextualMVDValidator::NO_UUID)
	def createNewConceptTemplateUuid(Issue issue, IssueResolutionAcceptor acceptor) {

		acceptor.accept(issue, 'Create new UUID', 'Create new UUID.', null) [ element, context |
			context.xtextDocument.replace(issue.offset, 0, UUID.randomUUID.toString)
		]
	}

	@Fix(Diagnostic::SYNTAX_DIAGNOSTIC)
	def createMissingUuid(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Create missing UUID', 'Create missing UUID.', null) [ element, context |
			switch (element) {
				TemplatesType:
					context.xtextDocument.replace(issue.offset, 0,
						String.format("@UUID(%s)", UUID.randomUUID.toString))
			}
		]
	}
}
