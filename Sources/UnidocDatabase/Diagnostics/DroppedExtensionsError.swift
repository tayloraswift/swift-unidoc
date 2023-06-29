import Symbols
import UnidocDiagnostics

struct DroppedExtensionsError:Equatable, Error
{
    let extendee:Symbol.Decl
    let count:Int

    init(extendee:Symbol.Decl, count:Int)
    {
        self.extendee = extendee
        self.count = count
    }
}
extension DroppedExtensionsError:DynamicLinkerError
{
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
