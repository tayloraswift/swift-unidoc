import JSONDecoding
import ModuleGraphs

extension PackageManifest
{
    @frozen public
    enum Dependency:Equatable, Sendable
    {
        case filesystem(Filesystem)
        case resolvable(Resolvable)
    }
}
extension PackageManifest.Dependency:Identifiable
{
    @inlinable public
    var id:PackageIdentifier
    {
        switch self
        {
        case .filesystem(let dependency): return dependency.id
        case .resolvable(let dependency): return dependency.id
        }
    }
}
extension PackageManifest.Dependency:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case filesystem = "fileSystem"
        case resolvable = "sourceControl"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        let json:JSON.ExplicitField<CodingKeys> = try json.single()
        switch json.key
        {
        case .filesystem:
            self = .filesystem(try json.decode(
                as: JSON.SingleElementRepresentation<Filesystem>.self,
                with: \.value))

        case .resolvable:
            self = .resolvable(try json.decode(
                as: JSON.SingleElementRepresentation<Resolvable>.self,
                with: \.value))
        }
    }
}
