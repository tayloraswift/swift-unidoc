import MarkdownABI
import Signatures

extension Signature.Abridged
{
    @inlinable public
    init(_ fragments:__shared some Sequence<Signature<Scalar>.Fragment>)
    {
        var utf8:[UInt8] = []
        for fragment:Signature.Fragment in fragments
        {
            utf8 += fragment.spelling.utf8
        }
        self.init(utf8: utf8)
    }

    @_spi(testable) public
    init(_ string:String)
    {
        self.init(utf8: [UInt8].init(string.utf8))
    }

    @usableFromInline
    init(utf8:consuming [UInt8])
    {
        //  There seems to be a bug in SwiftSyntax that causes misalignment of source ranges
        //  when trimming leading trivia from syntax nodes. As a temporary workaround, we
        //  replace all newline characters with space characters before parsing the source.
        for i:Int in utf8.indices
        {
            switch utf8[i]
            {
            case 0x0A:  utf8[i] = 0x20
            case 0x0D:  utf8[i] = 0x20
            default:    continue
            }
        }

        let signature:SignatureSyntax = utf8.withUnsafeBufferPointer { .abridged($0) }
        let bytecode:Markdown.Bytecode = .init
        {
            for span:SignatureSyntax.Span in signature.elements
            {
                switch span
                {
                case .wbr(indent: false):
                    $0[.wbr]

                case .wbr(indent: true):
                    $0[.indent]

                case .text(let range, nil, _):
                    $0 += utf8[range]

                case .text(let range, let color?, let depth):
                    let text:String = .init(decoding: utf8[range], as: Unicode.UTF8.self)
                    switch  (color, text, depth)
                    {
                    case    (.keyword, "subscript", .toplevel?),
                            (.keyword, "deinit", .toplevel?),
                            (.keyword, "init", .toplevel?),
                            (.identifier, _, .toplevel?):
                        $0[.identifier] = text

                    case    (_, _, _):
                        $0 += text
                    }
                }
            }
        }
        self.init(bytecode: bytecode)
    }
}
