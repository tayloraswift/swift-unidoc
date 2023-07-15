import MarkdownABI
import Signatures
import Symbols

extension Signature<Symbol.Decl>.Expanded
{
    init(_ fragments:__shared some Sequence<Signature.Fragment>)
    {
        var references:[Scalar: UInt32] = [:]
        var referents:[Scalar] = []
        let bytecode:MarkdownBytecode = .init
        {
            for fragment:Signature.Fragment in fragments
            {
                if let highlight:MarkdownBytecode.Context = fragment.color.highlight
                {
                    $0[highlight]
                    {
                        if  let referent:Scalar = fragment.referent
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
                    $0 += fragment.spelling
                }
            }
        }

        self.init(bytecode: bytecode, scalars: referents)
    }
}
