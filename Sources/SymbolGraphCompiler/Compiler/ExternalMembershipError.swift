import SymbolResolution

public
struct ExternalMembershipError:Equatable, Error
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
extension ExternalMembershipError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        Cannot declare an external membership (of '\(self.member)' to '\(self.type)') \
        without an associated extension block record.
        """
    }
}
