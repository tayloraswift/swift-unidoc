import BSON

extension Unidoc
{
    @frozen public
    struct BuildFailureReport:Equatable, Sendable
    {
        public
        let package:Package
        public
        let failure:BuildFailure

        public
        var logs:BuildLogs

        @inlinable public
        init(package:Package, failure:BuildFailure, logs:BuildLogs)
        {
            self.package = package
            self.failure = failure
            self.logs = logs
        }
    }
}
extension Unidoc.BuildFailureReport
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package = "P"
        case failure = "F"

        case logs_swiftPackageResolve = "R"
        case logs_swiftPackageBuild = "C"
        case logs_ssgcDocsBuild = "D"
    }
}
extension Unidoc.BuildFailureReport:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.package] = self.package
        bson[.failure] = self.failure

        bson[.logs_swiftPackageResolve] = self.logs.swiftPackageResolve
        bson[.logs_swiftPackageBuild] = self.logs.swiftPackageBuild
        bson[.logs_ssgcDocsBuild] = self.logs.ssgcDocsBuild
    }
}
extension Unidoc.BuildFailureReport:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            failure: try bson[.failure].decode(),
            logs: .init(
                swiftPackageResolve: try bson[.logs_swiftPackageResolve]?.decode(),
                swiftPackageBuild: try bson[.logs_swiftPackageBuild]?.decode(),
                ssgcDocsBuild: try bson[.logs_ssgcDocsBuild]?.decode()))
    }
}
