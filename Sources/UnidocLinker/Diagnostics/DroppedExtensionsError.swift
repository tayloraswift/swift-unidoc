import Symbols
import UnidocDiagnostics

@frozen public
struct DroppedExtensionsError:Equatable, Error
{
    public
    let extendee:Symbol.Decl
    public
    let count:Int

    @inlinable public
    init(extendee:Symbol.Decl, count:Int)
    {
        self.extendee = extendee
        self.count = count
    }
}
extension DroppedExtensionsError:DynamicLinkerError
{
    public
    func symbolicated(with symbolicator:DynamicSymbolicator) -> [Diagnostic]
    {
        [
            .init(.warning, context: .init(),
                message: """
                dropped \(self.count) extension(s) because its extendee \
                (\(symbolicator.signature(of: self.extendee))) could not be loaded
                """)
        ]
    }
}
