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
    public
    var owner:Symbol.PackageScope?
    {
        switch self
        {
        case .local:
            return nil

        case .remote(let url):
            guard
            let j:String.Index = url.lastIndex(of: "/"),
            let i:String.Index = url[..<j].lastIndex(of: "/"),
            url[..<i] == "https://github.com"
            else
            {
                return nil
            }

            let start:String.Index = url.index(after: i)
            return .init(url[start ..< j])
        }
    }

    /// Returns the exact name of the repository, which is the last path component without the
    /// `.git` extension.
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

        if  let end:String.Index = uri.lastIndex(of: "."),
            uri[end...] == ".git"
        {
            return uri[start ..< end]
        }
        else
        {
            return uri[start...]
        }
    }
}
