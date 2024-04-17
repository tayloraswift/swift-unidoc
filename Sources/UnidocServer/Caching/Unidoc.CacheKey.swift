import Media
import System

extension Unidoc
{
    public
    protocol CacheKey:RawRepresentable<String>, Hashable, Sendable
    {
        var reloadable:Bool { get }
        var source:[FilePath.Component] { get }
        var type:MediaType { get }
    }
}
