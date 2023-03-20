import SymbolResolution

public
struct ExtensionBlockMemberError:Equatable, Error
{
    public
    let member:UnifiedScalarResolution
    public
    let type:UnifiedScalarResolution
    public
    let usr:UnifiedSymbolResolution

    public
    init(member:UnifiedScalarResolution,
        type:UnifiedScalarResolution,
        usr:UnifiedSymbolResolution)
    {
        self.member = member
        self.type = type
        self.usr = usr
    }
}
extension ExtensionBlockMemberError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        Cannot declare an external membership (of '\(self.member)' to '\(self.type)') \
        in an extension block ('\(self.usr)').
        """
    }
}
