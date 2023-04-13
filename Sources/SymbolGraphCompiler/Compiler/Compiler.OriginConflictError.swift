extension Compiler
{
    public
    struct OriginConflictError:Error, Equatable, Sendable
    {
        public
        let other:ScalarSymbolResolution

        public
        init(existing other:ScalarSymbolResolution)
        {
            self.other = other
        }
    }
}
