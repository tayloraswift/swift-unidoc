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

        @inlinable public
        init(package:Package, failure:BuildFailure)
        {
            self.package = package
            self.failure = failure
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
    }
}
extension Unidoc.BuildFailureReport:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.package] = self.package
        bson[.failure] = self.failure
    }
}
extension Unidoc.BuildFailureReport:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            failure: try bson[.failure].decode())
    }
}
