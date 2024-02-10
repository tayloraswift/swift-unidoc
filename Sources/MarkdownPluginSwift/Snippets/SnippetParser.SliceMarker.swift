import SwiftSyntax

extension SnippetParser
{
    struct SliceMarker
    {
        let statement:Statement
        /// The number of leading spaces before the slice marker.
        let indent:Int
        /// The UTF-8 offset of the (first) newline before the slice marker, or the beginning
        /// of the file if the control comment is at the beginning of the file.
        let before:AbsolutePosition
        /// The UTF-8 offset of the newline after the slice marker, assuming it exists.
        let after:AbsolutePosition
        /// The line number (1-indexed) of the slice marker.
        let line:Int
    }
}
