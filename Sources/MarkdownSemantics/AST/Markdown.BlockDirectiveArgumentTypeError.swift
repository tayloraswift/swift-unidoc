extension Markdown
{
    struct BlockDirectiveArgumentTypeError<Option, Value>:Error
        where Option:BlockDirectiveOption
    {
        let option:Option
    }
}
