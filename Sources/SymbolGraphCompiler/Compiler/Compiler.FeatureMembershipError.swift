extension Compiler
{
    public
    struct FeatureMembershipError:Equatable, Error, Sendable
    {
        public
        let resolution:ScalarSymbolResolution

        public
        init(invalid resolution:ScalarSymbolResolution)
        {
            self.resolution = resolution
        }
    }
}
