import Sources

extension SourceReference where Frame:DiagnosticFrame
{
    @inlinable public
    var start:SourceLocation<Frame.File>?
    {
        if  let offset:SourcePosition = self.range?.lowerBound
        {
            self.frame.origin?.translated(by: offset)
        }
        else
        {
            nil
        }
    }
}
