extension Compiler
{
    public
    struct SymbolResolutionError:Equatable, Error, Sendable
    {
        public
        let resolution:UnifiedSymbolResolution

        public
        init(invalid resolution:UnifiedSymbolResolution)
        {
            self.resolution = resolution
        }
    }
}
extension Compiler.SymbolResolutionError:CustomStringConvertible
{
    public
    var description:String
    {
        "Invalid symbol resolution '\(self.resolution)'."
    }
}
