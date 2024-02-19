import Symbols

extension SSGC
{
    public
    struct UnclaimedBlockError:Equatable, Error
    {
        public
        let block:Symbol.Block

        public
        init(unclaimed block:Symbol.Block)
        {
            self.block = block
        }
    }
}
extension SSGC.UnclaimedBlockError:CustomStringConvertible
{
    public
    var description:String
    {
        "Extension block '\(self.block)' is not claimed by any type in its colony."
    }
}
