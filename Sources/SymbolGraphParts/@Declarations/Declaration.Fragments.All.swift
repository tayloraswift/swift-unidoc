import Declarations
import MarkdownABI
import Symbols

extension Declaration<Symbol.Scalar>.Fragments.All
{
    init(_ fragments:__shared some Sequence<DeclarationFragment>)
    {
        var references:[Symbol: UInt32] = [:]
        var referents:[Symbol] = []
        let bytecode:MarkdownBytecode = .init
        {
            for fragment:DeclarationFragment in fragments
            {
                if let highlight:MarkdownBytecode.Context = fragment.color.highlight
                {
                    $0[highlight]
                    {
                        if  let referent:Symbol = fragment.referent
                        {
                            $0[.href] =
                            {
                                if  let reference:UInt32 = $0
                                {
                                    return reference
                                }
                                else
                                {
                                    let next:UInt32 = .init(referents.endIndex)
                                    referents.append(referent)
                                    $0 = next
                                    return next
                                }
                            } (&references[referent])
                        }
                    } = fragment.spelling
                }
                else
                {
                    $0.write(text: fragment.spelling)
                }
            }
        }

        self.init(bytecode: bytecode, links: referents)
    }
}
