import SymbolResolution

public
struct ExternalMemberError:Equatable, Error
{
    public
    let member:UnifiedScalarResolution
    public
    let type:UnifiedScalarResolution

    public
    init(member:UnifiedScalarResolution,
        type:UnifiedScalarResolution)
    {
        self.member = member
        self.type = type
    }
}
extension ExternalMemberError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        Cannot declare an external membership (of '\(self.member)' to '\(self.type)').
        """
    }
}
