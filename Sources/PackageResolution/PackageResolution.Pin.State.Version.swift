import JSONDecoding
import JSONEncoding
import SemanticVersions

extension PackageResolution.Pin.State
{
    struct Version
    {
        let semantic:SemanticVersion

        private
        init(_ semantic:SemanticVersion)
        {
            self.semantic = semantic
        }
    }
}
extension PackageResolution.Pin.State.Version:LosslessStringConvertible, CustomStringConvertible
{
    init?(_ description:String)
    {
        if let semantic:SemanticVersion = .init(description)
        {
            self.init(semantic)
        }
        else
        {
            return nil
        }
    }
    var description:String
    {
        self.semantic.description
    }
}
extension PackageResolution.Pin.State.Version:JSONStringDecodable, JSONStringEncodable
{
}
