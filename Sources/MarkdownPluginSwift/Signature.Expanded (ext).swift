

import MarkdownABI
import Signatures

extension Signature.Expanded
{
    @inlinable public
    init(_ fragments:__shared some Collection<Signature<Scalar>.Fragment>,
        keywords:inout InterestingKeywords)
    {
        var utf8:[UInt8] = []
            utf8.reserveCapacity(fragments.reduce(0) { $0 + $1.spelling.utf8.count })

        var symbols:[Int: Scalar] = [:]
        for fragment:Signature.Fragment in fragments
        {
            let i:Int = utf8.endIndex
            utf8 += fragment.spelling.utf8

            if  let referent:Scalar = fragment.referent
            {
                symbols[i] = referent
            }
        }

        self.init(utf8: utf8, keywords: &keywords, symbols: &symbols)

        if !symbols.isEmpty
        {
            fatalError("syntax didn’t round-trip, failed to match symbols: \(symbols)")
        }
    }

    @inlinable @_spi(testable) public
    init(_ string:String)
    {
        var keywords:InterestingKeywords = .init()
        var empty:[Int: Scalar] = [:]
        self.init(utf8: [UInt8].init(string.utf8), keywords: &keywords, symbols: &empty)
    }

    @inlinable internal
    init(utf8:[UInt8], keywords:inout InterestingKeywords, symbols:inout [Int: Scalar])
    {
        let regions:SignatureSyntax = utf8.withUnsafeBufferPointer(SignatureSyntax.init)
        var references:[Scalar: Int] = [:]
        var referents:[Scalar] = []

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

                guard let color:MarkdownBytecode.Context = token.color
                else
                {
                    $0 += text
                    continue
                }

                if  case .keyword = color
                {
                    switch text
                    {
                    case "actor":   keywords.actor = true
                    case "class":   keywords.class = true
                    default:        break
                    }
                }

                $0[color]
                {
                    if  let referent:Scalar = symbols.removeValue(forKey: token.start)
                    {
                        $0[.href] =
                        {
                            if  let reference:Int = $0
                            {
                                return reference
                            }
                            else
                            {
                                let next:Int = referents.endIndex
                                referents.append(referent)
                                $0 = next
                                return next
                            }
                        } (&references[referent])
                    }
                } = text
            }
        }

        self.init(bytecode: bytecode, scalars: referents)
    }
}
