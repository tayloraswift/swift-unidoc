import JSON

extension Unidoc
{
    @frozen public
    struct BuildStatus
    {
        public
        let request:Unidoc.BuildRequest?
        public
        let stage:Unidoc.BuildStage?
        public
        let failure:Unidoc.BuildFailure?

        @inlinable public
        init(request:Unidoc.BuildRequest?,
            stage:Unidoc.BuildStage?,
            failure:Unidoc.BuildFailure?)
        {
            self.request = request
            self.stage = stage
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
        case series
        case force
        case stage
        case failure
    }
}
extension Unidoc.BuildStatus:JSONObjectEncodable
{
    public
    func encode(to json:inout JSON.ObjectEncoder<CodingKey>)
    {
        switch self.request
        {
        case nil:
            break

        case .latest(let series, force: let force):
            json[.series] = series
            json[.force] = force

        case .id(let id, force: let force):
            json[.version] = id
            json[.force] = force
        }

        json[.stage] = self.stage
        json[.failure] = self.failure
    }
}
extension Unidoc.BuildStatus:JSONObjectDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let request:Unidoc.BuildRequest?
        if  let series:Unidoc.VersionSeries = try json[.series]?.decode()
        {
            request = .latest(series, force: try json[.force].decode())
        }
        else if
            let id:Unidoc.Edition = try json[.version]?.decode()
        {
            request = .id(id, force: try json[.force].decode())
        }
        else
        {
            request = nil
        }

        self.init(request: request,
            stage: try json[.stage]?.decode(),
            failure: try json[.failure]?.decode())
    }
}
