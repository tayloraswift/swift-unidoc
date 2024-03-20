extension Markdown
{
    public
    protocol CodeHighlighter
    {
        func emit(_ text:consuming String, into binary:inout Markdown.BinaryEncoder)
    }
}
