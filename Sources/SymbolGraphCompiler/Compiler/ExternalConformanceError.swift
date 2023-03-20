import SymbolResolution

public
struct ExternalConformanceError:Equatable, Error
{
    public
    let conformance:UnifiedScalarResolution
    public
    let type:UnifiedScalarResolution

    public
    init(conformance:UnifiedScalarResolution,
        type:UnifiedScalarResolution)
    {
        self.conformance = conformance
        self.type = type
    }
}
extension ExternalConformanceError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        Cannot declare an external conformance (of '\(self.type)' to '\(self.conformance)') \
        without an associated extension block record.
        """
    }
}
