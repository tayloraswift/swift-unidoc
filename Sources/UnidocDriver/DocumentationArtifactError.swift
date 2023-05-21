import TraceableErrors
import System

public
struct DocumentationArtifactError:Error, Sendable
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
extension DocumentationArtifactError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.path == rhs.path && lhs.underlying == rhs.underlying
    }
}
extension DocumentationArtifactError:TraceableError
{
    public
    var notes:[String]
    {
        ["while processing artifact '\(self.path)'"]
    }
}
