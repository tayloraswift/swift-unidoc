import Unidoc
import SourceDiagnostics

enum DroppedPassagesError:Equatable, Error
{
    case fromExtension(Unidoc.LinkerIndex<Unidoc.Extension>, of:Unidoc.Scalar)
}
extension DroppedPassagesError:Diagnostic
{
    typealias Symbolicator = Unidoc.Symbolicator

    func emit(summary output:inout DiagnosticOutput<Unidoc.Symbolicator>)
    {
        switch self
        {
        case .fromExtension(_, of: let type):
            output[.warning] = """
            dropped documentation due to coalescing multiple extensions of the same type \
            (\(output.symbolicator[type]))
            """
        }
    }
}
