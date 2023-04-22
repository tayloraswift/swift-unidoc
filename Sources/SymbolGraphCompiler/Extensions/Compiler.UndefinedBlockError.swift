extension Compiler
{
    public
    struct UndefinedBlockError:Equatable, Error
    {
        public
        let resolution:Symbol.Block

        public
        init(undefined resolution:Symbol.Block)
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
