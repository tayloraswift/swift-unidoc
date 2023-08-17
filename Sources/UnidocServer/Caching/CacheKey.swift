import HTTPServer
import Media
import System

protocol CacheKey:RawRepresentable<String>, Hashable, Sendable
{
    var requirement:CacheReloading? { get }
    var source:[FilePath.Component] { get }
    var type:MediaType { get }
}
