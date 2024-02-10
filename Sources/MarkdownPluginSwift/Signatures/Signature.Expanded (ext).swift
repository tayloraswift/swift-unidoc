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
            fatalError("""
                syntax didn’t round-trip, failed to match symbols: \(symbols), \
                source: '\(String.init(decoding: utf8, as: Unicode.UTF8.self))'
                """)
        }
    }

    @inlinable @_spi(testable) public
    init(_ string:String)
    {
        var ignored:InterestingKeywords = .init()
        self.init(string, keywords: &ignored)
    }

    @inlinable @_spi(testable) public
    init(_ string:String, keywords:inout InterestingKeywords)
    {
        var empty:[Int: Scalar] = [:]
        self.init(utf8: [UInt8].init(string.utf8), keywords: &keywords, symbols: &empty)
    }

    @inlinable internal
    init(utf8:[UInt8], keywords:inout InterestingKeywords, symbols:inout [Int: Scalar])
    {
        let signature:SignatureSyntax = utf8.withUnsafeBufferPointer { .expanded($0) }
        var references:[Scalar: Int] = [:]
        var referents:[Scalar] = []

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

                case .text(let range, let color?, .toplevel?):
                    if  case .attribute = color
                    {
                        switch String.init(decoding: utf8[range], as: Unicode.UTF8.self)
                        {
                        case "@attached":       keywords.attached = true
                        case "@freestanding":   keywords.freestanding = true
                        default:                break
                        }
                    }
                    if  case .keyword = color
                    {
                        //  The `actor` and `async` keywords are contextual; there is no
                        //  other way to detect them besides inspecting token text!
                        switch String.init(decoding: utf8[range], as: Unicode.UTF8.self)
                        {
                        case "actor":           keywords.actor = true
                        case "class":           keywords.class = true
                        default:                break
                        }
                    }

                    fallthrough

                case .text(let range, let color?, _):

                    $0[color]
                    {
                        let offset:Int
                        if  case .attribute = color,
                            case 0x40 = utf8[range.lowerBound] // '@'
                        {
                            offset = range.lowerBound + 1
                        }
                        else
                        {
                            offset = range.lowerBound
                        }

                        if  let referent:Scalar = symbols.removeValue(forKey: offset)
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
                    }
                    content:
                    {
                        $0 += utf8[range]
                    }
                }
            }
        }

        self.init(bytecode: bytecode, scalars: referents)
    }
}
