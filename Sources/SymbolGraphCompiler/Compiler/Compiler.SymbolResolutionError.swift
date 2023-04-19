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
