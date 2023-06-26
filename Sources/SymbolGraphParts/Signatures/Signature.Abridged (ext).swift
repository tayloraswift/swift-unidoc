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
                if  fragment.nominal
                {
                    $0[.identifier] = fragment.spelling
                }
                else
                {
                    $0.write(text: fragment.spelling)
                }
            }
        }
        self.init(bytecode: bytecode)
    }
}
