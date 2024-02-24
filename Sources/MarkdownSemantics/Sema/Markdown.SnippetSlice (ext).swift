import Sources

extension Markdown.SnippetSlice
{
    func location(in file:Int32) -> SourceLocation<Int32>?
    {
        guard
        let position:SourcePosition = .init(line: self.line, column: 0)
        else
        {
            return nil
        }

        return .init(position: position, file: file)
    }
}
