import JSON

extension PackageManifest.DependencyPin
{
    struct V2
    {
        let value:PackageManifest.DependencyPin

        private
        init(value:PackageManifest.DependencyPin)
        {
            self.value = value
        }
    }
}

extension PackageManifest.DependencyPin.V2:JSONObjectDecodable
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
        let location:PackageManifest.DependencyLocation
        switch try json[.type].decode(to: PackageManifest.DependencyPinType.self)
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
