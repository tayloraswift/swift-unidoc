extension Compiler
{
    public
    struct UnclaimedBlockError:Equatable, Error
    {
        public
        let block:BlockSymbolResolution

        public
        init(unclaimed block:BlockSymbolResolution)
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
