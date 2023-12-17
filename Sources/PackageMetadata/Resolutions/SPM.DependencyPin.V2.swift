import JSON

extension SPM.DependencyPin
{
    struct V2
    {
        let value:SPM.DependencyPin

        private
        init(value:SPM.DependencyPin)
        {
            self.value = value
        }
    }
}

extension SPM.DependencyPin.V2:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "identity"
        case location
        case state
        case type = "kind"
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let location:SPM.DependencyLocation
        switch try json[.type].decode(to: SPM.DependencyPinType.self)
        {
        case .localSourceControl:
            location = .local(root: try json[.location].decode())

        case .remoteSourceControl:
            location = .remote(url: try json[.location].decode())
        }

        self.init(value: .init(id: try json[.id].decode(),
            location: location,
            state: try json[.state].decode()))
    }
}
