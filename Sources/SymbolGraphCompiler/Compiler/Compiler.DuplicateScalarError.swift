extension Compiler
{
    public
    struct DuplicateScalarError:Equatable, Error
    {
        public
        let resolution:ScalarSymbolResolution

        public
        init(duplicated resolution:ScalarSymbolResolution)
        {
            self.resolution = resolution
        }
    }
}
