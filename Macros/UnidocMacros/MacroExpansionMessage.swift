import SwiftDiagnostics
import SwiftSyntaxMacros

struct MacroExpansionMessage
{
    let severity:DiagnosticSeverity
    let message:String

    init(severity:DiagnosticSeverity, message:String)
    {
        self.severity = severity
        self.message = message
    }
}
extension MacroExpansionMessage:DiagnosticMessage
{
    var diagnosticID:MessageID
    {
        .init(domain: "\(Self.self)", id: "\(self.severity)")
    }
}
