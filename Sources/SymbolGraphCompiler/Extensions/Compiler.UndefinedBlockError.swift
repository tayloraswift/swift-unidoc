extension Compiler
{
    public
    struct UndefinedBlockError:Equatable, Error
    {
        public
        let resolution:BlockSymbol

        public
        init(undefined resolution:BlockSymbol)
        {
            self.resolution = resolution
        }
    }
}
extension Compiler.UndefinedBlockError:CustomStringConvertible
{
    public
    var description:String
    {
        "Undefined extension block '\(self.resolution)'."
    }
}
