import MarkdownABI
import Signatures
import Symbols

extension Signature<Symbol.Decl>.Abridged
{
    init(_ fragments:__shared some Sequence<Signature.Fragment>)
    {
        let bytecode:MarkdownBytecode = .init
        {
            for fragment:Signature.Fragment in fragments
            {
                switch  (fragment.color, fragment.spelling)
                {
                case    (.identifier, _),
                        (.keyword, "init"),
                        (.keyword, "deinit"),
                        (.keyword, "subscript"):
                    $0[.identifier] = fragment.spelling

                case    (.label, _):
                    $0[.label] = fragment.spelling

                case    _:
                    $0 += fragment.spelling
                }
            }
        }
        self.init(bytecode: bytecode)
    }
}
