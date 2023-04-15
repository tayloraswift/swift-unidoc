import TraceableErrors

public
struct SymbolDescriptionError<Resolution>:Error where Resolution:Equatable & Sendable
{
    public
    let underlying:any Error
    public
    let resolution:Resolution

    public
    init(underlying:any Error, in resolution:Resolution)
    {
        self.underlying = underlying
        self.resolution = resolution
    }
}
extension SymbolDescriptionError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.resolution == rhs.resolution && lhs.underlying == rhs.underlying
    }
}
extension SymbolDescriptionError:TraceableError
{
    public
    var notes:[String]
    {
        ["While validating symbol \(self.resolution)"]
    }
}
