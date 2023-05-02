import Declarations
import MarkdownABI
import Symbols

extension Declaration<Symbol.Scalar>.Fragments.Abridged
{
    init(_ fragments:__shared some Sequence<DeclarationFragment>)
    {
        let bytecode:MarkdownBytecode = .init
        {
            for fragment:DeclarationFragment in fragments
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
