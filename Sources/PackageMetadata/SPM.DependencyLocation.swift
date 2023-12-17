import Symbols

extension SPM
{
    @frozen public
    enum DependencyLocation:Hashable, Equatable, Sendable
    {
        /// A package in a local git repository.
        case local(root:Symbol.FileBase)
        /// A package in a remote git repository.
        case remote(url:String)
    }
}
extension SPM.DependencyLocation
{
    @inlinable public
    init(location:String)
    {
        self = location.first == "/" ?
            .local(root: .init(location)) :
            .remote(url: location)
    }
}
extension SPM.DependencyLocation
{
    /// Returns the exact name of the repository, which is the last path component without the
    /// extension.
    public
    var name:Substring
    {
        let uri:String
        switch self
        {
        case .local(let root):  uri = root.path
        case .remote(let url):  uri = url
        }

        let start:String.Index = uri.lastIndex(of: "/").map(uri.index(after:)) ??
            uri.startIndex

        return uri[start...].prefix(while: { $0 != "." })
    }
}
