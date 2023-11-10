import Unidoc
import UnidocDiagnostics

@frozen public
enum DroppedPassagesError:Equatable, Error
{
    case fromExtension(Unidoc.Scalar, of:Unidoc.Scalar)
}
extension DroppedPassagesError:Diagnostic
{
    public
    typealias Symbolicator = DynamicSymbolicator

    @inlinable public static
    func += (output:inout DiagnosticOutput<DynamicSymbolicator>, self:Self)
    {
        switch self
        {
        case .fromExtension(_, of: let type):
            output[.warning] = """
            dropped documentation due to coalescing multiple extensions of the same type \
            (\(output.symbolicator.signature(of: type)))
            """
        }
    }
}
