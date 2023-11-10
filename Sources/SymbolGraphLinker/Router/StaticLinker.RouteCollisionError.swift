import FNV1
import UnidocDiagnostics

extension StaticLinker
{
    enum RouteCollisionError:Equatable, Error
    {
        case hash(FNV24, [Int32])
        case path(Route, [Int32])
    }
}
extension StaticLinker.RouteCollisionError:Diagnostic
{
    typealias Symbolicator = StaticSymbolicator

    static func += (output:inout DiagnosticOutput<StaticSymbolicator>, self:Self)
    {
        switch self
        {
        case .hash(let hash, _):
            output[.warning] = "hash collision on [\(hash)]"
        case .path(.main(let path), _):
            output[.warning] = "path collision on '\(path)'"
        }
    }

    var notes:[StaticLinker.RouteCollision]
    {
        switch self
        {
        case    .hash(_, let collisions),
                .path(_, let collisions):
            collisions.map(StaticLinker.RouteCollision.init(colliding:))
        }
    }
}
