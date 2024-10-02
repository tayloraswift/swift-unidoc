import SemanticVersions
import Symbols
import UnidocRecords

extension Unidoc.BuildTemplate
{
    /// This is a separate type to work around yet another compiler bug!!!
    enum Parameter
    {
        static var toolchain:String { "toolchain" }
        static var platform:String { "platform" }
    }

    public
    init?(parameters:borrowing [String: String])
    {
        var toolchain:PatchVersion?
        var platform:Symbol.Triple?

        if  let value:String = parameters[Parameter.toolchain]
        {
            if  let value:PatchVersion = .init(value)
            {
                toolchain = value
            }
            else if !value.isEmpty
            {
                return nil
            }
        }

        if  let value:String = parameters[Parameter.platform]
        {
            if  let value:Symbol.Triple = .init(value)
            {
                platform = value
            }
            else if !value.isEmpty
            {
                return nil
            }
        }

        self.init(toolchain: toolchain, platform: platform)
    }
}
