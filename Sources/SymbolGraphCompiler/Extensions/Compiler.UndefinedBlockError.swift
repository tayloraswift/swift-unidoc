extension Compiler
{
    public
    struct UndefinedBlockError:Equatable, Error
    {
        public
        let resolution:BlockSymbolResolution

        public
        init(undefined resolution:BlockSymbolResolution)
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
