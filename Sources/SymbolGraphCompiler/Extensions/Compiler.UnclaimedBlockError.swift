extension Compiler
{
    public
    struct UnclaimedBlockError:Equatable, Error
    {
        public
        let block:BlockSymbol

        public
        init(unclaimed block:BlockSymbol)
        {
            self.block = block
        }
    }
}
extension Compiler.UnclaimedBlockError:CustomStringConvertible
{
    public
    var description:String
    {
        "Extension block '\(self.block)' is not claimed by any type in its colony."
    }
}
