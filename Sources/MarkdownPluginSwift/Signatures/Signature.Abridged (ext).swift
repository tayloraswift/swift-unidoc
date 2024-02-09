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

    @usableFromInline internal
    init(utf8:[UInt8])
    {
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
