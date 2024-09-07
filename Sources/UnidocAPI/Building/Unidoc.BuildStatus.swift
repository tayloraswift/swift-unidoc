import JSON

extension Unidoc
{
    @frozen public
    struct BuildStatus
    {
        public
        let request:Edition
        public
        let pending:BuildStage?
        public
        let failure:BuildFailure?

        @inlinable public
        init(request:Edition,
            pending:Unidoc.BuildStage?,
            failure:BuildFailure?)
        {
            self.request = request
            self.pending = pending
            self.failure = failure
        }
    }
}
extension Unidoc.BuildStatus
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case version
        case stage
        case failure
    }
}
extension Unidoc.BuildStatus:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        json[.version] = request
        json[.stage] = self.pending
        json[.failure] = self.failure
    }
}
extension Unidoc.BuildStatus:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(request: try json[.version].decode(),
            pending: try json[.stage]?.decode(),
            failure: try json[.failure]?.decode())
    }
}
