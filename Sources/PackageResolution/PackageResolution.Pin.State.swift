import JSONDecoding
import PackageMetadata
import SemanticVersions

extension PackageResolution.Pin
{
    struct State
    {
        let reference:GitReference
        let revision:GitRevision

        private
        init(reference:GitReference, revision:GitRevision)
        {
            self.reference = reference
            self.revision = revision
        }
    }
}
extension PackageResolution.Pin.State:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case branch
        case revision
        case version
    }
    init(json:JSON.ObjectDecoder<CodingKeys>) throws 
    {
        let reference:GitReference
        if  let version:SemanticVersion = try json[.version]?.decode(
                as: JSON.StringRepresentation<SemanticVersion>.self,
                with: \.value)
        {
            reference = .version(version)
        }
        else 
        {
            reference = .branch(try json[.branch].decode())
        }
        self.init(reference: reference, revision: try json[.revision].decode())
    }
}
