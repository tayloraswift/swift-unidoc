import JSONDecoding
import ModuleGraphs
import PackageGraphs

extension PackageNode.Dependency:JSONObjectDecodable
{
    public
    enum CodingKey:String
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
