import MarkdownABI
import Signatures

extension Signature.Abridged
{
    @inlinable public
    init(_ fragments:__shared some Sequence<Signature<Scalar>.Fragment>, actor:Bool = false)
    {
        var utf8:[UInt8] = []
        for fragment:Signature.Fragment in fragments
        {
            utf8 += fragment.spelling.utf8
        }
        self.init(utf8: utf8, actor: actor)
    }

    @_spi(testable) public
    init(_ string:String)
    {
        self.init(utf8: [UInt8].init(string.utf8))
    }

    @usableFromInline internal
    init(utf8:[UInt8], actor:Bool = false)
    {
        let regions:SignatureSyntax = utf8.withUnsafeBufferPointer(SignatureSyntax.init)
        let bytecode:MarkdownBytecode = .init
        {
            for token:SignatureSyntax.Token? in regions.tokens
            {
                guard let token:SignatureSyntax.Token
                else
                {
                    $0[.wbr]
                    continue
                }

                let text:String = .init(decoding: utf8[token.range], as: Unicode.UTF8.self)

                if  actor,
                    case (.keyword, "class") = (token.color, text)
                {
                    $0 += "actor"
                    continue
                }

                switch  (token.color, text)
                {
                case    (.identifier, _),
                        (.keyword, "init"),
                        (.keyword, "deinit"),
                        (.keyword, "subscript"):
                    $0[.identifier] = text

                case    (.label, _):
                    $0[.label] = text

                case    _:
                    $0 += text
                }
            }
        }
        self.init(bytecode: bytecode)
    }
}
