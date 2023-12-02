import JSON
import PackageGraphs
import Symbols

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
    var id:Symbol.Package
    {
        switch self
        {
        case .filesystem(let dependency): return dependency.id
        case .resolvable(let dependency): return dependency.id
        }
    }
}
extension PackageManifest.Dependency
{
    @inlinable public
    var requirement:PackageManifest.DependencyRequirement?
    {
        if  case .resolvable(let dependency) = self
        {
            return dependency.requirement
        }
        else
        {
            return nil
        }
    }
}
extension PackageManifest.Dependency:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case filesystem = "fileSystem"
        case resolvable = "sourceControl"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let json:JSON.ExplicitField<CodingKey> = try json.single()
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