import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension MacroExpansionContext
{
    subscript(severity:DiagnosticSeverity, node:some SyntaxProtocol) -> String?
    {
        get
        {
            nil
        }
        set(value)
        {
            guard
            let value:String
            else
            {
                return
            }

            self.diagnose(.init(node: node, message: MacroExpansionMessage.init(
                severity: severity,
                message: value)))
        }
    }
}
