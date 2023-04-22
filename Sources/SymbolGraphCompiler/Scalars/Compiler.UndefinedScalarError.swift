extension Compiler
{
    public
    struct UndefinedScalarError:Equatable, Error
    {
        public
        let resolution:Symbol.Scalar

        public
        init(undefined resolution:Symbol.Scalar)
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
