import Symbols
import SourceDiagnostics

struct DroppedExtensionsError:Equatable, Error
{
    let affected:AffectedExtensions
    let count:Int

    init(affected:AffectedExtensions, count:Int)
    {
        self.affected = affected
        self.count = count
    }
}
extension DroppedExtensionsError
{
    static
    func extending(_ namespace:Symbol.Module, count:Int) -> Self
    {
        .init(affected: .namespace(namespace), count: count)
    }

    static
    func extending(_ decl:Symbol.Decl, count:Int) -> Self
    {
        .init(affected: .decl(decl), count: count)
    }
}
extension DroppedExtensionsError:Diagnostic
{
    typealias Symbolicator = Unidoc.Symbolicator

    static
    func += (output:inout DiagnosticOutput<Unidoc.Symbolicator>, self:Self)
    {
        switch self.affected
        {
        case .decl(let decl):
            output[.warning] = """
            dropped \(self.count) extension(s) because the type they extend \
            (\(output.symbolicator.demangle(decl))) could not be loaded
            """

        case .namespace(let namespace):
            output[.warning] = """
            dropped \(self.count) extension(s) because the namespace they extend \
            (\(namespace)) could not be loaded
            """
        }
    }
}
