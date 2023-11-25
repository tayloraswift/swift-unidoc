import JSON

extension PackageManifest.DependencyPin
{
    struct V1
    {
        let value:PackageManifest.DependencyPin

        private
        init(value:PackageManifest.DependencyPin)
        {
            self.value = value
        }
    }
}

extension PackageManifest.DependencyPin.V1:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        //  this field is completely useless!
        //  case id = "package"

        case location = "repositoryURL"
        case state
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let location:PackageManifest.DependencyLocation = .init(
            location: try json[.location].decode())

        self.init(value: .init(id: .init(location.name),
            location: location,
            state: try json[.state].decode()))
    }
}
