import HTTP
import MD5
import ModuleGraphs
import MongoDB
import UnidocAnalysis
import UnidocDatabase
import UnidocPages
import UnidocRecords
import UnidocSelectors
import URI

extension Server.Endpoint
{
    struct SiteMap:Sendable
    {
        let package:PackageIdentifier

        let uri:URI
        let tag:MD5?

        init(package:PackageIdentifier, uri:URI, tag:MD5?)
        {
            self.package = package
            self.uri = uri
            self.tag = tag
        }
    }
}
extension Server.Endpoint.SiteMap:DatabaseOperation, UnrestrictedOperation
{
    func load(from database:Services.Database) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: database.sessions)

        guard   let siteMap:Volume.SiteMap<PackageIdentifier> =
                try await database.unidoc.siteMap(
                    package: self.package,
                    with: session)
        else
        {
            return nil
        }

        let prefix:String = "https://swiftinit.org/\(Site.Docs.root)/\(self.package)"
        var string:String = ""
        var i:Int = siteMap.lines.startIndex

        while let j:Int = siteMap.lines[i...].firstIndex(of: 0x0A)
        {
            defer { i = siteMap.lines.index(after: j) }

            let shoot:Volume.Shoot = .deserialize(from: siteMap.lines[i..<j])
            var uri:URI = [] ; uri.path += shoot.stem ; uri["hash"] = shoot.hash?.description

            string += "\(prefix)\(uri)\n"
        }

        var resource:ServerResource = .init(.one(canonical: nil),
            content: .string(string),
            type: .text(.plain, charset: .utf8))

        resource.optimize(tag: self.tag)

        return .resource(resource)
    }
}
