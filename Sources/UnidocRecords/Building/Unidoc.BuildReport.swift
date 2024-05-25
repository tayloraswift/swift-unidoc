import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct BuildReport:Equatable, Sendable
    {
        public
        let package:Package

        public
        var failure:BuildFailure?
        public
        var entered:BuildStage?

        public
        var logs:[BuildLog]

        @inlinable public
        init(package:Package,
            failure:BuildFailure? = nil,
            entered:BuildStage? = nil,
            logs:[BuildLog] = [])
        {
            self.package = package
            self.failure = failure
            self.entered = entered
            self.logs = logs
        }
    }
}
extension Unidoc.BuildReport
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package = "P"
        case failure = "F"
        case entered = "E"
        case logs = "L"
    }
}
extension Unidoc.BuildReport:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.package] = self.package
        bson[.failure] = self.failure
        bson[.entered] = self.entered
        bson[.logs] = self.logs.isEmpty ? nil : self.logs
    }
}
extension Unidoc.BuildReport:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            failure: try bson[.failure]?.decode(),
            entered: try bson[.entered]?.decode(),
            logs: try bson[.logs]?.decode() ?? [])
    }
}
