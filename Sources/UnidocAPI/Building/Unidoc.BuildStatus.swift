import JSON

extension Unidoc
{
    @frozen public
    struct BuildStatus
    {
        public
        let request:Unidoc.BuildRequest?
        public
        let force:Bool
        public
        let stage:Unidoc.BuildStage?
        public
        let failure:Unidoc.BuildFailure?

        init(request:Unidoc.BuildRequest?,
            force:Bool,
            stage:Unidoc.BuildStage?,
            failure:Unidoc.BuildFailure?)
        {
            self.request = request
            self.force = force
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
