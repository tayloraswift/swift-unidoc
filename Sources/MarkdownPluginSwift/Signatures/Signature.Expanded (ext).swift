import MarkdownABI
import Signatures

extension Signature.Expanded
{
    @inlinable public
    init(_ fragments:__shared some Collection<Signature<Scalar>.Fragment>,
        sugarDictionary:Scalar,
        sugarArray:Scalar,
        sugarOptional:Scalar,
        desugarSelf:String? = nil,
        landmarks:inout SignatureLandmarks)
    {
        var utf8:[UInt8] = []
            utf8.reserveCapacity(fragments.reduce(0) { $0 + $1.spelling.utf8.count })

        var linkBoundaries:[Int] = []
        var linkTargets:[Int: Scalar] = [:]
        for fragment:Signature.Fragment in fragments
        {
            let i:Int = utf8.endIndex

            utf8 += fragment.spelling.utf8

            if  let referent:Scalar = fragment.referent
            {
                linkTargets[i] = referent
                linkBoundaries.append(i)
                linkBoundaries.append(utf8.endIndex)
            }
        }

        let sugarMap:SignatureSyntax.SugarMap = linkTargets.reduce(
            into: .init(staticSelf: desugarSelf))
        {
            switch $1.value
            {
            case sugarArray:        $0.arrays.insert($1.key)
            case sugarDictionary:   $0.dictionaries.insert($1.key)
            case sugarOptional:     $0.optionals.insert($1.key)
            default:                break
            }
        }

        self.init(utf8: utf8,
            sugarMap: sugarMap,
            linkBoundaries: linkBoundaries,
            linkTargets: &linkTargets,
            landmarks: &landmarks)

        if !linkTargets.isEmpty
        {
            let source:String = .init(decoding: utf8, as: Unicode.UTF8.self)

            print("ERROR: failed to round-trip swift syntax!")
            for (offset, symbol):(Int, Scalar) in linkTargets
            {
                print("Note: (offset = \(offset) symbol = \(symbol))")
                print("'\(source)'")
                print(" \(String.init(repeating: " ", count: offset))^")
            }

            fatalError()
        }
    }

    @inlinable @_spi(testable) public
    init(_ string:String,
        linkBoundaries:borrowing [Int] = [])
    {
        var ignored:SignatureLandmarks = .init()
        self.init(string, linkBoundaries: linkBoundaries, landmarks: &ignored)
    }

    @inlinable @_spi(testable) public
    init(_ string:String,
        linkBoundaries:borrowing [Int] = [],
        landmarks:inout SignatureLandmarks)
    {
        var empty:[Int: Scalar] = [:]
        self.init(utf8: [UInt8].init(string.utf8),
            linkBoundaries: linkBoundaries,
            linkTargets: &empty,
            landmarks: &landmarks)
    }

    @inlinable
    init(utf8:[UInt8],
        sugarMap:SignatureSyntax.SugarMap = .init(staticSelf: nil),
        linkBoundaries:borrowing [Int],
        linkTargets:inout [Int: Scalar],
        landmarks:inout SignatureLandmarks)
    {
        let signature:SignatureSyntax = utf8.withUnsafeBufferPointer
        {
            .expanded($0, sugaring: sugarMap, landmarks: &landmarks)
        }
        var references:[Scalar: Int] = [:]
        var referents:[Scalar] = []

        let bytecode:Markdown.Bytecode = .init
        {
            for span:SignatureSyntax.Span in signature.split(on: linkBoundaries)
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
                        case "@attached":       landmarks.keywords.attached = true
                        case "@freestanding":   landmarks.keywords.freestanding = true
                        default:                break
                        }
                    }
                    if  case .keyword = color
                    {
                        //  The `actor` and `async` keywords are contextual; there is no
                        //  other way to detect them besides inspecting token text!
                        switch String.init(decoding: utf8[range], as: Unicode.UTF8.self)
                        {
                        case "actor":           landmarks.keywords.actor = true
                        case "class":           landmarks.keywords.class = true
                        case "final":           landmarks.keywords.final = true
                        default:                break
                        }
                    }

                    fallthrough

                case .text(let range, let color?, _):
                    let referent:Scalar? = linkTargets.removeValue(forKey: range.lowerBound)

                    $0[color]
                    {
                        if  let referent:Scalar
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
                        //  This is an ugly, ugly hack to work around the upstream bug in
                        //  lib/SymbolGraphGen described here:
                        //  https://github.com/swiftlang/swift/issues/78343
                        //
                        //  This hack is still **correct** if the declaration shadows the `Self`
                        //  type, because lib/SymbolGraphGen will emit such a token without the
                        //  extraneous backticks.
                        if  case .type = color,
                            case [
                                0x60, // '`'
                                0x53, // 'S'
                                0x65, // 'e'
                                0x6C, // 'l'
                                0x66, // 'f'
                                0x60, // '`'
                            ] = utf8[range]
                        {
                            let i:Int = utf8.index(after: range.lowerBound)
                            let j:Int = utf8.index(before: range.upperBound)

                            $0 += utf8[i ..< j]
                        }
                        else
                        {
                            $0 += utf8[range]
                        }
                    }
                }
            }
        }

        self.init(bytecode: bytecode, scalars: referents)
    }
}
