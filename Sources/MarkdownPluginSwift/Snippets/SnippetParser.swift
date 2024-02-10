import SwiftSyntax

struct SnippetParser
{
    private
    let sourcemap:SourceLocationConverter

    var complete:[SliceBounds]
    var current:SliceFetus?

    init(sourcemap:SourceLocationConverter, start position:AbsolutePosition)
    {
        self.sourcemap = sourcemap

        self.complete = []
        self.current = .init(id: "", position: position)
    }
}
extension SnippetParser
{
    mutating
    func visit(token:TokenSyntax)
    {
        self.visit(trivia: token.leadingTrivia, at: token.position)
        self.visit(trivia: token.trailingTrivia, at: token.endPositionBeforeTrailingTrivia)
    }

    private mutating
    func visit(trivia:Trivia, at position:AbsolutePosition)
    {
        var newline:(position:AbsolutePosition, indent:Int)? = nil
        var current:AbsolutePosition = position
        for piece:TriviaPiece in trivia
        {
            let range:Range<AbsolutePosition> = current ..< current + piece.sourceLength

            defer
            {
                current = range.upperBound
            }

            let line:String
            let skip:Int

            switch piece
            {
            case .newlines, .carriageReturnLineFeeds:
                newline = (position: range.lowerBound, indent: 0)
                continue

            case .spaces(let count):
                //  We only care about leading spaces.
                if  let indent:Int = newline?.indent
                {
                    newline?.indent = indent + count
                }
                continue

            case .lineComment(let text):
                line = text
                skip = 2

            case .docLineComment(let text):
                line = text
                skip = 3

            default:
                newline = nil
                continue
            }

            guard
            let leading:(position:AbsolutePosition, indent:Int) = newline
            else
            {
                //  We only care about line comments at the beginning of a line.
                continue
            }

            if  let statement:SliceMarker.Statement = .init(lineComment: line, skip: skip)
            {
                let location:SourceLocation = self.sourcemap.location(for: current)
                //  We know that line comments always extend to the end of the line.
                //  Therefore, `range.upperBound` “always” points to a newline, and the start of
                //  the next line is one after the index after the end of the comment.
                //
                //  This math of course is invalid if the source file is missing a final
                //  newline. So code that uses these indices **must** clamp them to the bounds
                //  of the source text.
                self.push(marker: .init(statement: statement,
                    indent: leading.indent,
                    before: leading.position,
                    after: range.upperBound.advanced(by: 1),
                    line: location.line))
            }
            else
            {
                newline = nil
            }
        }
    }

    private mutating
    func push(marker:SliceMarker)
    {
        switch marker.statement
        {
        case .end:
            if  let current:SliceFetus = self.current
            {
                self.current = nil
                self.complete.append(current.end(at: marker.before))
            }
            else
            {
                //  TODO: Emit a warning.
            }

        case .hide:
            if  case nil = self.current?.hide(at: marker.before)
            {
                //  TODO: Emit a warning.
            }

        case .show:
            if  case nil = self.current?.show(at: marker.after)
            {
                //  TODO: Emit a warning.
            }

        case .slice(let id):
            appending:
            if  let current:SliceFetus = self.current
            {
                self.current = nil
                let slice:SliceBounds = current.end(at: marker.before)

                if  slice.id == "",
                    slice.ranges.isEmpty
                {
                    //  We don't want to emit an empty snippet.
                    break appending
                }

                self.complete.append(slice)
            }

            self.current = .init(id: id,
                position: marker.after,
                marker: (line: marker.line, indent: marker.indent))
        }
    }
}
extension SnippetParser
{
    consuming
    func finish(at position:AbsolutePosition, in utf8:[UInt8]) -> [Slice]
    {
        let bounds:[SnippetParser.SliceBounds] = self.finish(at: position)
        return bounds.map { $0.viewbox(in: utf8) }
    }

    private consuming
    func finish(at position:AbsolutePosition) -> [SliceBounds]
    {
        if  let current:SliceFetus = self.current
        {
            self.current = nil
            self.complete.append(current.end(at: position))
        }

        return complete
    }
}
