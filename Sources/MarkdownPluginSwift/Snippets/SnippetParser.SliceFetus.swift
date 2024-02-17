import SwiftSyntax

extension SnippetParser
{
    /// A `SliceFetus` is the precursor to a ``SliceBounds``.
    struct SliceFetus
    {
        private
        var slice:SliceBounds
        private
        var start:AbsolutePosition?

        private
        init(id:String, position:AbsolutePosition, marker:(line:Int, indent:Int))
        {
            self.slice = .init(id: id, marker: marker)
            self.start = position
        }
    }
}
extension SnippetParser.SliceFetus
{
    static
    func anonymous(start position:AbsolutePosition) -> Self
    {
        .init(id: "", position: position, marker: (1, 0))
    }

    static
    func named(id:String, marker:SnippetParser.SliceMarker) -> Self
    {
        .init(id: id,
            position: marker.after,
            marker: (line: marker.line, indent: marker.indent))
    }
}
extension SnippetParser.SliceFetus
{
    mutating
    func show(with marker:SnippetParser.SliceMarker)
    {
        //  This is only effective for the anonymous slice.
        if  self.slice.ranges.isEmpty
        {
            self.slice.marker = (line: marker.line, indent: marker.indent)
        }
        if  case nil = self.start
        {
            self.start = marker.after
        }
        else
        {
            //  TODO: Emit a warning.
        }
    }

    mutating
    func hide(at position:AbsolutePosition)
    {
        guard
        let start:AbsolutePosition = self.start
        else
        {
            //  TODO: Emit a warning.
            return
        }
        defer
        {
            self.start = nil
        }
        //  Two ways this check can fail:
        //
        //  1.  Something resembling a control comment appears in the snippet abstract.
        //  2.  A snippet slice is hidden instantly after it is shown.
        if  start < position
        {
            self.slice.ranges.append(start ..< position)
        }
    }

    consuming
    func end(at position:AbsolutePosition) -> SnippetParser.SliceBounds
    {
        self.hide(at: position)
        return self.slice
    }
}
