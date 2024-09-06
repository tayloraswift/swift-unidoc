import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct BuildArtifact:Sendable
    {
        public
        let edition:Edition
        public
        var outcome:Result<Snapshot, BuildFailure>
        public
        var seconds:Int64
        public
        var logs:[BuildLog]

        @inlinable public
        init(edition:Edition,
            outcome:Result<Snapshot, BuildFailure>,
            seconds:Int64 = 0,
            logs:[BuildLog] = [])
        {
            self.edition = edition
            self.seconds = seconds
            self.outcome = outcome
            self.logs = logs
        }
    }
}
extension Unidoc.BuildArtifact
{
    @inlinable public
    var failure:Unidoc.BuildFailure?
    {
        switch self.outcome
        {
        case .success:              nil
        case .failure(let failure): failure
        }
    }
}
extension Unidoc.BuildArtifact
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case edition = "e"
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
        bson[.edition] = self.edition

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
            edition: try bson[.edition].decode(),
            outcome: outcome,
            seconds: try bson[.seconds].decode(),
            logs: try bson[.logs]?.decode() ?? [])
    }
}
