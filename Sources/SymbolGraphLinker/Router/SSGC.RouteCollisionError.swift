import FNV1
import SourceDiagnostics

extension SSGC
{
    enum RouteCollisionError:Equatable, Error
    {
        case hash(FNV24, [Int32])
        case path(Route, [Int32])
    }
}
extension SSGC.RouteCollisionError:Diagnostic
{
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output:inout DiagnosticOutput<Symbolicator>)
    {
        switch self
        {
        case .hash(let hash, _):
            output[.error] = "hash collision on [\(hash)]"
        case .path(.main(let path), _):
            output[.error] = "path collision on '\(path)'"
        }
    }

    func emit(details output:inout DiagnosticOutput<Symbolicator>)
    {
        switch self
        {
        case .hash(_, let collisions), .path(_, let collisions):
            for colliding:Int32 in collisions
            {
                output[.note] = """
                symbol (\(output.symbolicator[colliding])) \
                does not have a unique URL
                """
            }
        }
    }
}
