import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct BuildArtifact:Sendable
    {
        public
        let package:Package
        public
        var outcome:Result<Snapshot, BuildFailure>
        public
        var seconds:Int64
        public
        var logs:[BuildLog]

        @inlinable public
        init(package:Package,
            outcome:Result<Snapshot, BuildFailure>,
            seconds:Int64 = 0,
            logs:[BuildLog] = [])
        {
            self.package = package
            self.seconds = seconds
            self.outcome = outcome
            self.logs = logs
        }
    }
}
extension Unidoc.BuildArtifact
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package = "P"
        case payload = "S"
        case failure = "F"
        case seconds = "D"
        case logs = "L"
    }
}
extension Unidoc.BuildArtifact:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.package] = self.package

        switch self.outcome
        {
        case .success(let snapshot):    bson[.payload] = snapshot
        case .failure(let failure):     bson[.failure] = failure
        }

        bson[.seconds] = self.seconds
        bson[.logs] = self.logs.isEmpty ? nil : self.logs
    }
}
extension Unidoc.BuildArtifact:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let outcome:Result<Unidoc.Snapshot, Unidoc.BuildFailure>

        if  let snapshot:Unidoc.Snapshot = try bson[.payload]?.decode()
        {
            outcome = .success(snapshot)
        }
        else
        {
            outcome = .failure(try bson[.failure].decode())
        }

        self.init(
            package: try bson[.package].decode(),
            outcome: outcome,
            seconds: try bson[.seconds].decode(),
            logs: try bson[.logs]?.decode() ?? [])
    }
}
