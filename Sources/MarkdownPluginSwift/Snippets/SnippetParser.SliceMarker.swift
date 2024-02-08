import SwiftSyntax

extension SnippetParser
{
    struct SliceMarker
    {
        let statement:Statement
        /// The number of leading spaces before the control comment.
        let indent:Int
        /// The UTF-8 offset of the (first) newline before the control comment, or the beginning
        /// of the file if the control comment is at the beginning of the file.
        let before:AbsolutePosition
        /// The UTF-8 offset of the newline after the control comment, assuming it exists.
        let after:AbsolutePosition
    }
}
