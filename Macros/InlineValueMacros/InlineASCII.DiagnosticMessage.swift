import SwiftDiagnostics

extension InlineASCII
{
    struct DiagnosticMessage
    {
        let severity:DiagnosticSeverity
        let message:String

        init(severity:DiagnosticSeverity, message:String)
        {
            self.severity = severity
            self.message = message
        }
    }
}
extension InlineASCII.DiagnosticMessage:DiagnosticMessage
{
    var diagnosticID:MessageID
    {
        .init(domain: "\(Self.self)", id: "\(self.severity)")
    }
}
