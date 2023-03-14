import JSONDecoding

extension PackageResolution.Pin
{
    struct State
    {
        let requirement:PackageRequirement
        let revision:String

        private
        init(requirement:PackageRequirement, revision:String)
        {
            self.requirement = requirement
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
        let requirement:PackageRequirement
        if  let version:Version = try json[.version]?.decode()
        {
            requirement = .version(version.semantic)
        }
        else 
        {
            requirement = .branch(try json[.branch].decode())
        }
        self.init(requirement: requirement, revision: try json[.revision].decode())
    }
}
