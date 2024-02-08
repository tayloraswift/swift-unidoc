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

        init(id:String, at position:AbsolutePosition, indent:Int = 0)
        {
            self.slice = .init(id: id, indent: indent)
            self.start = position
        }
    }
}
extension SnippetParser.SliceFetus
{
    mutating
    func show(at position:AbsolutePosition)
    {
        if  case nil = self.start
        {
            self.start = position
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
        //  Two ways this check can fail:
        //
        //  1.  Something resembling a control comment appears in the snippet abstract.
        //  2.  A snippet slice is hidden instantly after it is shown.
        if  start < position
        {
            self.slice.ranges.append(start ..< position)
            self.start = nil
        }
    }

    consuming
    func end(at position:AbsolutePosition) -> SnippetParser.SliceBounds
    {
        self.hide(at: position)
        return self.slice
    }
}
