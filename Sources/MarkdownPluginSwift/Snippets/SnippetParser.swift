import SwiftSyntax

struct SnippetParser
{
    private
    let sourcemap:SourceLocationConverter

    private
    var captionText:String
    private
    var captionLine:Bool

    private
    var complete:[SliceBounds]

    /// The start of the current subslice. This is nil if the current slice is hidden or
    /// terminated.
    private
    var subslice:AbsolutePosition?
    private
    var current:SliceBounds
    private
    var currentLine:(indent:Int, gap:Range<AbsolutePosition>)?

    init(sourcemap:SourceLocationConverter, start:AbsolutePosition)
    {
        self.sourcemap = sourcemap

        self.captionText = ""
        self.captionLine = true
        self.complete = []
        self.subslice = start
        self.current = .init(id: "", marker: nil)
        self.currentLine = (indent: 0, gap: start ..< start)
    }
}
extension SnippetParser
{
    mutating
    func visit(token:TokenSyntax)
    {
        self.visit(trivia: token.leadingTrivia, at: token.position)
        self.captionLine = false
        self.currentLine = nil
        self.visit(trivia: token.trailingTrivia, at: token.endPositionBeforeTrailingTrivia)
    }

    private mutating
    func visit(trivia:Trivia, at position:AbsolutePosition)
    {
        var start:AbsolutePosition = position
        for piece:TriviaPiece in trivia
        {
            let range:Range<AbsolutePosition> = start ..< start + piece.sourceLength

            defer
            {
                start = range.upperBound
            }

            let token:String
            let skip:Int

            switch piece
            {
            case .newlines(let count), .carriageReturnLineFeeds(let count):
                self.currentLine = (indent: 0, gap: range)
                self.captionLine = self.captionLine && count == 1
                continue

            case .spaces(let count), .tabs(let count):
                //  We only care about leading spaces.
                self.currentLine?.indent += count
                continue

            case .lineComment(let content):
                token = content
                skip = 2

            case .docLineComment(let content):
                token = content
                skip = 3

            default:
                self.captionLine = false
                self.currentLine = nil
                continue
            }

            guard
            let currentLine:(indent:Int, gap:Range<AbsolutePosition>) = self.currentLine
            else
            {
                //  We only care about line comments at the beginning of a line.
                continue
            }

            self.currentLine = nil

            guard
            let i:String.Index = token.index(token.startIndex,
                offsetBy: skip,
                limitedBy: token.endIndex)
            else
            {
                fatalError("Encountered a line comment with no leading slashes!")
            }

            let trimmedLine:Substring = token[i...].drop(while: \.isWhitespace)

            if  let statement:SliceMarker.Statement = .init(trimmedLine: trimmedLine)
            {
                let grid:SourceLocation = self.sourcemap.location(
                    for: range.lowerBound)

                self.push(marker: .init(statement: statement,
                    indent: currentLine.indent,
                    line: grid.line - 1,
                    gap: currentLine.gap,
                    end: range.upperBound))

                self.captionLine = false
            }
            else if self.captionLine
            {
                self.captionText += trimmedLine
                self.captionText.append("\n")

                self.subslice = range.upperBound
            }
        }
    }

    mutating
    func push(marker:SliceMarker)
    {
        switch marker.statement
        {
        case .hide, .end:
            if  let subslice:AbsolutePosition = self.subslice
            {
                self.current.ranges.append(subslice ..< marker.gap.lowerBound)
                self.subslice = nil
            }

        case .show:
            if  case nil = self.current.marker
            {
                self.current.marker = (line: marker.line, indent: marker.indent)
                self.subslice = marker.end
            }
            else if case nil = self.subslice
            {
                self.subslice = marker.end
            }

        case .slice(let id):
            if  let subslice:AbsolutePosition = self.subslice
            {
                self.current.ranges.append(subslice ..< marker.gap.lowerBound)
            }

            defer
            {
                self.subslice = marker.end
                self.current = .init(id: id, marker: (line: marker.line, indent: marker.indent))
            }

            self.complete.append(self.current)
        }
    }
}
extension SnippetParser
{
    consuming
    func finish(at position:AbsolutePosition, in utf8:[UInt8]) -> (String, [Slice])
    {
        let (caption, bounds):(String, [SnippetParser.SliceBounds]) = self.finish(at: position)
        return (caption, bounds.compactMap { $0.viewbox(in: utf8) })
    }

    private consuming
    func finish(at position:AbsolutePosition) -> (String, [SliceBounds])
    {
        if  let subslice:AbsolutePosition = self.subslice
        {
            self.current.ranges.append(subslice ..< position)
        }

        self.complete.append(self.current)
        return (self.captionText, self.complete)
    }
}
