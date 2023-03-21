import SymbolResolution

public
enum ExtensionBlockSignatureError:Equatable, Error
{
    case conformance(by:ExtensionBlockResolution,
        of:UnifiedScalarResolution,
        to:UnifiedScalarResolution)
    
    case membership(by:ExtensionBlockResolution,
        of:UnifiedScalarResolution,
        in:UnifiedScalarResolution)
}
extension ExtensionBlockSignatureError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .conformance(by: let block, of: let type, to: let conformance):
            return """
            Cannot declare an external conformance (of '\(type)' to '\(conformance)') \
            with different generic constraints than its extension block ('\(block)').
            """
        case .membership(by: let block, of: let member, in: let type):
            return """
            Cannot declare an external membership (of '\(member)' in '\(type)') \
            with different generic constraints than its extension block ('\(block)').
            """
        }
    }
}
