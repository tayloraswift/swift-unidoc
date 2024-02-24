/// A `DiagnosticAlert` is just some text with a prefix. It is useful for simple diagnostics
/// that don’t require symbolication.
@frozen public
struct DiagnosticAlert
{
    @usableFromInline
    let type:DiagnosticPrefix
    @usableFromInline
    let text:String

    @inlinable
    init(type:DiagnosticPrefix, text:String)
    {
        self.type = type
        self.text = text
    }
}
extension DiagnosticAlert
{
    @inlinable public static
    func warning(_ error:some Error) -> Self
    {
        .init(type: .warning, text: "\(error)")
    }

    @inlinable public static
    func error(_ error:some Error) -> Self
    {
        .init(type: .error, text: "\(error)")
    }
}
