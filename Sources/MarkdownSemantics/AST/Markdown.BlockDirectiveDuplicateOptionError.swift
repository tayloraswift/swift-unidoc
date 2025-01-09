extension Markdown
{
    struct BlockDirectiveDuplicateOptionError<Option>:Error where Option:BlockDirectiveOption
    {
        let option:Option
    }
}
