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

    static func += (output:inout DiagnosticOutput<SSGC.Symbolicator>, self:Self)
    {
        switch self
        {
        case .hash(let hash, _):
            output[.warning] = "hash collision on [\(hash)]"
        case .path(.main(let path), _):
            output[.warning] = "path collision on '\(path)'"
        }
    }

    var notes:[SSGC.RouteCollision]
    {
        switch self
        {
        case    .hash(_, let collisions),
                .path(_, let collisions):
            collisions.map(SSGC.RouteCollision.init(colliding:))
        }
    }
}
