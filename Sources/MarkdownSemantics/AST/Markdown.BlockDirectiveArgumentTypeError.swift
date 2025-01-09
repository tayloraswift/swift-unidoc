extension Markdown
{
    struct BlockDirectiveArgumentTypeError<Option, Value>:Error
        where Option:BlockDirectiveOption
    {
        let option:Option
        let value:String
    }
}
extension Markdown.BlockDirectiveArgumentTypeError:CustomStringConvertible
{
    var description:String
    {
        """
        could not convert argument '\(self.value)' for option '\(self.option)' to expected \
        type '\(Value.self)'
        """
    }
}
