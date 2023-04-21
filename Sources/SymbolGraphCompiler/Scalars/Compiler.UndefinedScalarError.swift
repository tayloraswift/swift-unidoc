extension Compiler
{
    public
    struct UndefinedScalarError:Equatable, Error
    {
        public
        let resolution:ScalarSymbolResolution

        public
        init(undefined resolution:ScalarSymbolResolution)
        {
            self.resolution = resolution
        }
    }
}
extension Compiler.UndefinedScalarError:CustomStringConvertible
{
    public
    var description:String
    {
        "Undefined (or external) scalar '\(self.resolution)'."
    }
}
