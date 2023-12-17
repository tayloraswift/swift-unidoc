import JSON
import PackageGraphs
import Symbols

extension SPM.Manifest
{
    @frozen public
    enum Dependency:Equatable, Sendable
    {
        case filesystem(Filesystem)
        case resolvable(Resolvable)
    }
}
extension SPM.Manifest.Dependency:Identifiable
{
    @inlinable public
    var id:Symbol.Package
    {
        switch self
        {
        case .filesystem(let dependency): dependency.id
        case .resolvable(let dependency): dependency.id
        }
    }
}
extension SPM.Manifest.Dependency
{
    @inlinable public
    var requirement:SPM.Manifest.DependencyRequirement?
    {
        if  case .resolvable(let dependency) = self
        {
            dependency.requirement
        }
        else
        {
            nil
        }
    }
}
extension SPM.Manifest.Dependency:JSONObjectDecodable
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
        let json:JSON.FieldDecoder<CodingKey> = try json.single()
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
