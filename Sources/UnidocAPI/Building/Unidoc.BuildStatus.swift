import JSON

extension Unidoc
{
    @frozen public
    struct BuildStatus
    {
        public
        let request:Unidoc.BuildRequest<Void>?
        public
        let stage:Unidoc.BuildStage?
        public
        let failure:Unidoc.BuildFailure?

        @inlinable public
        init(request:Unidoc.BuildRequest<Void>?,
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
        if  let request:Unidoc.BuildRequest<Void> = self.request
        {
            switch request.version
            {
            case .latest(let series, of: ()):
                json[.series] = series

            case .id(let id):
                json[.version] = id
            }

            json[.force] = request.rebuild
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
        let request:Unidoc.BuildRequest<Void>?
        if  let series:Unidoc.VersionSeries = try json[.series]?.decode()
        {
            request = .init(version: .latest(series), rebuild: try json[.force].decode())
        }
        else if
            let id:Unidoc.Edition = try json[.version]?.decode()
        {
            request = .init(version: .id(id), rebuild: try json[.force].decode())
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
