import Sources

extension SourceLocation<Int>
{
    func translated(through sources:[MarkdownSource]) -> SourceLocation<Int32>?
    {
        sources[self.file].location?.translated(by: self.position)
    }
}
