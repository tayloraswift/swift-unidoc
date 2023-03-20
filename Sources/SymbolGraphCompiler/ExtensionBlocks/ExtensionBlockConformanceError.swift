import SymbolResolution

public
struct ExtensionBlockConformanceError:Equatable, Error
{
    public
    let conformance:UnifiedScalarResolution
    public
    let type:UnifiedScalarResolution
    public
    let usr:UnifiedSymbolResolution

    public
    init(conformance:UnifiedScalarResolution,
        type:UnifiedScalarResolution,
        usr:UnifiedSymbolResolution)
    {
        self.conformance = conformance
        self.type = type
        self.usr = usr
    }
}
extension ExtensionBlockConformanceError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        Cannot declare an external conformance (of '\(self.type)' to '\(self.conformance)') \
        with different generic constraints than its extension block ('\(self.usr)').
        """
    }
}
