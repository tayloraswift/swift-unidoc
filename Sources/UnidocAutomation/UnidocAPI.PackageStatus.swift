import JSON

extension UnidocAPI
{
    @frozen public
    struct PackageStatus
    {
        public
        let coordinate:Int32
        public
        let repo:String

        public
        var release:Edition
        public
        var prerelease:Edition?

        @inlinable public
        init(coordinate:Int32, repo:String, release:Edition, prerelease:Edition? = nil)
        {
            self.coordinate = coordinate
            self.repo = repo
            self.release = release
            self.prerelease = prerelease
        }
    }
}
extension UnidocAPI.PackageStatus
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
extension UnidocAPI.PackageStatus:JSONObjectEncodable
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
extension UnidocAPI.PackageStatus:JSONObjectDecodable
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
