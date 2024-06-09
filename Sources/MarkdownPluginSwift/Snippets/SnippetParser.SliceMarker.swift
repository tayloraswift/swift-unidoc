import SwiftSyntax

extension SnippetParser
{
    struct SliceMarker
    {
        let statement:Statement
        /// The number of leading spaces before the slice marker.
        let indent:Int
        /// The line number (0-indexed) of the slice marker.
        let line:Int
        /// The range of the newlines before the slice marker, which may be empty if the control
        /// comment is at the beginning of the file.
        let gap:Range<AbsolutePosition>
        let end:AbsolutePosition
    }
}
