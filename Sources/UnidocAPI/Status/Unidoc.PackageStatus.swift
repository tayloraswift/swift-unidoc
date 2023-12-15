import JSON
import Unidoc

extension Unidoc
{
    @frozen public
    struct PackageStatus
    {
        public
        let coordinate:Package
        public
        let repo:String

        public
        var release:Edition
        public
        var prerelease:Edition?

        @inlinable public
        init(coordinate:Package, repo:String, release:Edition, prerelease:Edition? = nil)
        {
            self.coordinate = coordinate
            self.repo = repo
            self.release = release
            self.prerelease = prerelease
        }
    }
}
extension Unidoc.PackageStatus
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case coordinate
        case repo
        case release
        case prerelease
    }
}
extension Unidoc.PackageStatus:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.coordinate] = self.coordinate
        json[.repo] = self.repo
        json[.release] = self.release
        json[.prerelease] = self.prerelease
    }
}
extension Unidoc.PackageStatus:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(coordinate: try json[.coordinate].decode(),
            repo: try json[.repo].decode(),
            release: try json[.release].decode(),
            prerelease: try json[.prerelease]?.decode())
    }
}
