import System
import TraceableErrors

struct ArtifactError:Error, Sendable
{
    public
    let underlying:any Error
    public
    let path:FilePath

    public
    init(underlying:any Error, path:FilePath)
    {
        self.underlying = underlying
        self.path = path
    }
}
extension ArtifactError:Equatable
{
    static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.path == rhs.path && lhs.underlying == rhs.underlying
    }
}
extension ArtifactError:TraceableError
{
    var notes:[String]
    {
        ["while processing artifact '\(self.path)'"]
    }
}
