import MarkdownABI
import SwiftIDEUtils
import SwiftParser
import SwiftSyntax

extension MarkdownCodeLanguage.Swift
{
    @frozen public
    struct Highlighter
    {
        @inlinable public
        init()
        {
        }
    }
}

extension SnippetSliceControl
{
    enum Keyword
    {
        case end
        case hide
        case show
        case slice(String)
    }
}
extension SnippetSliceControl.Keyword
{
    private
    init(_ text:Substring)
    {
        switch text
        {
        case "end":     self = .end
        case "hide":    self = .hide
        case "show":    self = .show
        default:        self = .slice(String.init(text))
        }
    }

    init?(lineComment text:borrowing String, skip:Int)
    {
        guard
        let i:String.Index = text.index(text.startIndex,
            offsetBy: skip,
            limitedBy: text.endIndex)
        else
        {
            fatalError("Encountered a line comment with no leading slashes!")
        }

        let text:Substring = (copy text)[i...].drop(while: \.isWhitespace)

        guard
        let j:String.Index = text.firstIndex(of: "."),
        case "snippet" = text[..<j]
        else
        {
            return nil
        }

        let k:String.Index = text.index(after: j)
        if  let space:String.Index = text[k...].firstIndex(where: \.isWhitespace)
        {
            guard text[text.index(after: space)...].allSatisfy(\.isWhitespace)
            else
            {
                return nil
            }

            self.init(text[k ..< space])
        }
        else
        {
            self.init(text[k...])
        }
    }
}
struct SnippetSliceControl
{
    let keyword:Keyword
    /// The number of leading spaces before the control comment.
    let indent:Int
    /// The UTF-8 offset of the (first) newline before the control comment, or the beginning
    /// of the file if the control comment is at the beginning of the file.
    let before:AbsolutePosition
    /// The UTF-8 offset of the newline after the control comment, assuming it exists.
    let after:AbsolutePosition
}

struct SnippetSlice
{
    let id:String
    var ranges:[Range<AbsolutePosition>]

    init(id:String)
    {
        self.id = id
        self.ranges = []
    }
}
extension SnippetParser
{
    struct Slice
    {
        private
        var slice:SnippetSlice
        private
        var start:AbsolutePosition?

        init(id:String, at position:AbsolutePosition)
        {
            self.slice = .init(id: id)
            self.start = position
        }
    }
}
extension SnippetParser.Slice
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
    func end(at position:AbsolutePosition) -> SnippetSlice
    {
        self.hide(at: position)
        return self.slice
    }
}
struct SnippetParser
{
    var complete:[SnippetSlice]
    var current:Slice?

    init(start position:AbsolutePosition)
    {
        self.complete = []
        self.current = .init(id: "", at: position)
    }
}
extension SnippetParser
{
    private mutating
    func handle(control:SnippetSliceControl)
    {
        switch control.keyword
        {
        case .end:
            if  let current:Slice = self.current
            {
                self.current = nil
                self.complete.append(current.end(at: control.before))
            }
            else
            {
                //  TODO: Emit a warning.
            }

        case .hide:
            if  case nil = self.current?.hide(at: control.before)
            {
                //  TODO: Emit a warning.
            }

        case .show:
            if  case nil = self.current?.show(at: control.after)
            {
                //  TODO: Emit a warning.
            }

        case .slice(let id):
            if  let current:Slice = self.current
            {
                self.current = nil
                self.complete.append(current.end(at: control.before))
            }

            self.current = .init(id: id, at: control.after)
        }
    }
}
extension SnippetParser
{
    mutating
    func handle(trivia:Trivia, at position:AbsolutePosition)
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

            if  let keyword:SnippetSliceControl.Keyword = .init(lineComment: line, skip: skip)
            {
                //  We know that line comments always extend to the end of the line.
                //  So the start of the next line is the index after the end of the comment.
                self.handle(control: .init(keyword: keyword,
                    indent: leading.indent,
                    before: leading.position,
                    after: range.upperBound.advanced(by: 1)))
            }
            else
            {
                newline = nil
            }
        }
    }

    consuming
    func finish(at position:AbsolutePosition) -> [SnippetSlice]
    {
        if  let current:Slice = self.current
        {
            self.current = nil
            self.complete.append(current.end(at: position))
        }

        return complete
    }
}

extension MarkdownCodeLanguage.Swift.Highlighter
{
    public
    func _parse(snippet text:consuming String)
    {
        text.withUTF8
        {
            (utf8:UnsafeBufferPointer<UInt8>) in

            let parsed:SourceFileSyntax = Parser.parse(source: utf8)
            var start:AbsolutePosition = parsed.position
            var text:String = ""
            lines:
            for piece:TriviaPiece in parsed.leadingTrivia
            {
                let line:String
                let skip:Int
                switch piece
                {
                case .lineComment(let text):
                    start += piece.sourceLength
                    line = text
                    skip = 2

                case .docLineComment(let text):
                    start += piece.sourceLength
                    line = text
                    skip = 3

                case .newlines(1), .carriageReturnLineFeeds(1):
                    start += piece.sourceLength
                    continue

                case .newlines, .carriageReturnLineFeeds:
                    start += piece.sourceLength
                    break lines

                default:
                    break lines
                }

                guard
                let i:String.Index = line.index(line.startIndex,
                    offsetBy: skip,
                    limitedBy: line.endIndex)
                else
                {
                    fatalError("Encountered a line comment with no leading slashes!")
                }

                text += line[i...].drop(while: \.isWhitespace)
                text.append("\n")
            }

            var parser:SnippetParser = .init(start: start)
            for token:TokenSyntax in parsed.tokens(viewMode: .sourceAccurate)
            {
                parser.handle(trivia: token.leadingTrivia, at: token.position)
                parser.handle(trivia: token.trailingTrivia,
                    at: token.endPositionBeforeTrailingTrivia)
            }

            let slices:[SnippetSlice] = parser.finish(at: parsed.endPosition)

            for slice:SnippetSlice in slices
            {
                print("Snippet '\(slice.id)':")
                print("--------------------")
                for range:Range<AbsolutePosition> in slice.ranges
                {
                    let start:Int = range.lowerBound.utf8Offset
                    if  start >= utf8.endIndex
                    {
                        //  This could happen if the file ends with a control comment and no
                        //  final newline.
                        continue
                    }

                    let end:Int = min(range.upperBound.utf8Offset, utf8.endIndex)
                    if  end <= start
                    {
                        continue
                    }

                    print(String(decoding: utf8[start ..< end], as: Unicode.UTF8.self))
                }
                print("--------------------")
            }
        }
    }
}
extension MarkdownCodeLanguage.Swift.Highlighter:MarkdownCodeHighlighter
{
    public
    func emit(_ text:consuming String, into binary:inout MarkdownBinaryEncoder)
    {
        //  Last I checked, SwiftParser already does this internally in its
        //  ``String``-based parsing API. Since we need to load the original
        //  source text anyway, we might as well use the UTF-8 buffer-based API.
        text.withUTF8
        {
            guard
            let base:UnsafePointer<UInt8> = $0.baseAddress
            else
            {
                return // empty string
            }
            let parsed:SourceFileSyntax = Parser.parse(source: $0)
            for span:SyntaxClassifiedRange in parsed.classifications
            {
                let text:UnsafeBufferPointer<UInt8> = .init(
                    start: base + span.offset,
                    count: span.length)

                if  let context:MarkdownBytecode.Context = .init(classification: span.kind)
                {
                    binary[context] { $0 += text }
                }
                else
                {
                    binary += text
                }
            }
        }
    }
}
