extension Symbol
{
    @frozen public
    struct Module:LosslessStringConvertible, Equatable, Hashable, Sendable
    {
        public
        let description:String

        @inlinable public
        init(_ description:String)
        {
            self.description = description
        }
    }
}
extension Symbol.Module:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
extension Symbol.Module:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.description < rhs.description
    }
}
extension Symbol.Module
{
    public
    init(mangling name:String)
    {
        //  Stolen from:
        //  https://github.com/apple/swift-tools-support-core/blob/main/Sources/TSCUtility/StringMangling.swift
        var codepoints:String.UnicodeScalarView.Iterator = name.unicodeScalars.makeIterator()
        var mangled:String = ""

        if  let codepoint:Unicode.Scalar = codepoints.next()
        {
            mangled.append(Character.init(Self.mangle(first: codepoint)))

            while let codepoint:Unicode.Scalar = codepoints.next()
            {
                mangled.append(Character.init(Self.mangle(subsequent: codepoint)))
            }
        }

        self.init(mangled)
    }
    private static
    func mangle(first codepoint:Unicode.Scalar) -> Unicode.Scalar
    {
        switch codepoint
        {
        case    "0" ... "9",
                // Annex D.
                "\u{0660}" ... "\u{0669}", "\u{06F0}" ... "\u{06F9}", "\u{0966}" ... "\u{096F}",
                "\u{09E6}" ... "\u{09EF}", "\u{0A66}" ... "\u{0A6F}", "\u{0AE6}" ... "\u{0AEF}",
                "\u{0B66}" ... "\u{0B6F}", "\u{0BE7}" ... "\u{0BEF}", "\u{0C66}" ... "\u{0C6F}",
                "\u{0CE6}" ... "\u{0CEF}", "\u{0D66}" ... "\u{0D6F}", "\u{0E50}" ... "\u{0E59}",
                "\u{0ED0}" ... "\u{0ED9}", "\u{0F20}" ... "\u{0F33}":
            "_"

        case let codepoint:
            self.mangle(subsequent: codepoint)
        }
    }
    private static
    func mangle(subsequent codepoint:Unicode.Scalar) -> Unicode.Scalar
    {
        switch codepoint
        {
        case    "A" ... "Z",
                "a" ... "z",
                "0" ... "9",
                "_",
                // Latin (1)
                "\u{00AA}" ... "\u{00AA}",
                // Special characters (1)
                "\u{00B5}" ... "\u{00B5}", "\u{00B7}" ... "\u{00B7}",
                // Latin (2)
                "\u{00BA}" ... "\u{00BA}", "\u{00C0}" ... "\u{00D6}", "\u{00D8}" ... "\u{00F6}",
                "\u{00F8}" ... "\u{01F5}", "\u{01FA}" ... "\u{0217}", "\u{0250}" ... "\u{02A8}",
                // Special characters (2)
                "\u{02B0}" ... "\u{02B8}", "\u{02BB}" ... "\u{02BB}", "\u{02BD}" ... "\u{02C1}",
                "\u{02D0}" ... "\u{02D1}", "\u{02E0}" ... "\u{02E4}", "\u{037A}" ... "\u{037A}",
                // Greek (1)
                "\u{0386}" ... "\u{0386}", "\u{0388}" ... "\u{038A}", "\u{038C}" ... "\u{038C}",
                "\u{038E}" ... "\u{03A1}", "\u{03A3}" ... "\u{03CE}", "\u{03D0}" ... "\u{03D6}",
                "\u{03DA}" ... "\u{03DA}", "\u{03DC}" ... "\u{03DC}", "\u{03DE}" ... "\u{03DE}",
                "\u{03E0}" ... "\u{03E0}", "\u{03E2}" ... "\u{03F3}",
                // Cyrillic
                "\u{0401}" ... "\u{040C}", "\u{040E}" ... "\u{044F}", "\u{0451}" ... "\u{045C}",
                "\u{045E}" ... "\u{0481}", "\u{0490}" ... "\u{04C4}", "\u{04C7}" ... "\u{04C8}",
                "\u{04CB}" ... "\u{04CC}", "\u{04D0}" ... "\u{04EB}", "\u{04EE}" ... "\u{04F5}",
                "\u{04F8}" ... "\u{04F9}",
                // Armenian (1)
                "\u{0531}" ... "\u{0556}",
                // Special characters (3)
                "\u{0559}" ... "\u{0559}",
                // Armenian (2)
                "\u{0561}" ... "\u{0587}",
                // Hebrew
                "\u{05B0}" ... "\u{05B9}", "\u{05BB}" ... "\u{05BD}", "\u{05BF}" ... "\u{05BF}",
                "\u{05C1}" ... "\u{05C2}", "\u{05D0}" ... "\u{05EA}", "\u{05F0}" ... "\u{05F2}",
                // Arabic (1)
                "\u{0621}" ... "\u{063A}", "\u{0640}" ... "\u{0652}",
                // Digits (1)
                "\u{0660}" ... "\u{0669}",
                // Arabic (2)
                "\u{0670}" ... "\u{06B7}", "\u{06BA}" ... "\u{06BE}", "\u{06C0}" ... "\u{06CE}",
                "\u{06D0}" ... "\u{06DC}", "\u{06E5}" ... "\u{06E8}", "\u{06EA}" ... "\u{06ED}",
                // Digits (2)
                "\u{06F0}" ... "\u{06F9}",
                // Devanagari and Special character 0x093D.
                "\u{0901}" ... "\u{0903}", "\u{0905}" ... "\u{0939}", "\u{093D}" ... "\u{094D}",
                "\u{0950}" ... "\u{0952}", "\u{0958}" ... "\u{0963}",
                // Digits (3)
                "\u{0966}" ... "\u{096F}",
                // Bengali (1)
                "\u{0981}" ... "\u{0983}", "\u{0985}" ... "\u{098C}", "\u{098F}" ... "\u{0990}",
                "\u{0993}" ... "\u{09A8}", "\u{09AA}" ... "\u{09B0}", "\u{09B2}" ... "\u{09B2}",
                "\u{09B6}" ... "\u{09B9}", "\u{09BE}" ... "\u{09C4}", "\u{09C7}" ... "\u{09C8}",
                "\u{09CB}" ... "\u{09CD}", "\u{09DC}" ... "\u{09DD}", "\u{09DF}" ... "\u{09E3}",
                // Digits (4)
                "\u{09E6}" ... "\u{09EF}",
                // Bengali (2)
                "\u{09F0}" ... "\u{09F1}",
                // Gurmukhi (1)
                "\u{0A02}" ... "\u{0A02}", "\u{0A05}" ... "\u{0A0A}", "\u{0A0F}" ... "\u{0A10}",
                "\u{0A13}" ... "\u{0A28}", "\u{0A2A}" ... "\u{0A30}", "\u{0A32}" ... "\u{0A33}",
                "\u{0A35}" ... "\u{0A36}", "\u{0A38}" ... "\u{0A39}", "\u{0A3E}" ... "\u{0A42}",
                "\u{0A47}" ... "\u{0A48}", "\u{0A4B}" ... "\u{0A4D}", "\u{0A59}" ... "\u{0A5C}",
                "\u{0A5E}" ... "\u{0A5E}",
                // Digits (5)
                "\u{0A66}" ... "\u{0A6F}",
                // Gurmukhi (2)
                "\u{0A74}" ... "\u{0A74}",
                // Gujarti
                "\u{0A81}" ... "\u{0A83}", "\u{0A85}" ... "\u{0A8B}", "\u{0A8D}" ... "\u{0A8D}",
                "\u{0A8F}" ... "\u{0A91}", "\u{0A93}" ... "\u{0AA8}", "\u{0AAA}" ... "\u{0AB0}",
                "\u{0AB2}" ... "\u{0AB3}", "\u{0AB5}" ... "\u{0AB9}", "\u{0ABD}" ... "\u{0AC5}",
                "\u{0AC7}" ... "\u{0AC9}", "\u{0ACB}" ... "\u{0ACD}", "\u{0AD0}" ... "\u{0AD0}",
                "\u{0AE0}" ... "\u{0AE0}",
                // Digits (6)
                "\u{0AE6}" ... "\u{0AEF}",
                // Oriya and Special character 0x0B3D
                "\u{0B01}" ... "\u{0B03}", "\u{0B05}" ... "\u{0B0C}", "\u{0B0F}" ... "\u{0B10}",
                "\u{0B13}" ... "\u{0B28}", "\u{0B2A}" ... "\u{0B30}", "\u{0B32}" ... "\u{0B33}",
                "\u{0B36}" ... "\u{0B39}", "\u{0B3D}" ... "\u{0B43}", "\u{0B47}" ... "\u{0B48}",
                "\u{0B4B}" ... "\u{0B4D}", "\u{0B5C}" ... "\u{0B5D}", "\u{0B5F}" ... "\u{0B61}",
                // Digits (7)
                "\u{0B66}" ... "\u{0B6F}",
                // Tamil
                "\u{0B82}" ... "\u{0B83}", "\u{0B85}" ... "\u{0B8A}", "\u{0B8E}" ... "\u{0B90}",
                "\u{0B92}" ... "\u{0B95}", "\u{0B99}" ... "\u{0B9A}", "\u{0B9C}" ... "\u{0B9C}",
                "\u{0B9E}" ... "\u{0B9F}", "\u{0BA3}" ... "\u{0BA4}", "\u{0BA8}" ... "\u{0BAA}",
                "\u{0BAE}" ... "\u{0BB5}", "\u{0BB7}" ... "\u{0BB9}", "\u{0BBE}" ... "\u{0BC2}",
                "\u{0BC6}" ... "\u{0BC8}", "\u{0BCA}" ... "\u{0BCD}",
                // Digits (8)
                "\u{0BE7}" ... "\u{0BEF}",
                // Telugu
                "\u{0C01}" ... "\u{0C03}", "\u{0C05}" ... "\u{0C0C}", "\u{0C0E}" ... "\u{0C10}",
                "\u{0C12}" ... "\u{0C28}", "\u{0C2A}" ... "\u{0C33}", "\u{0C35}" ... "\u{0C39}",
                "\u{0C3E}" ... "\u{0C44}", "\u{0C46}" ... "\u{0C48}", "\u{0C4A}" ... "\u{0C4D}",
                "\u{0C60}" ... "\u{0C61}",
                // Digits (9)
                "\u{0C66}" ... "\u{0C6F}",
                // Kannada
                "\u{0C82}" ... "\u{0C83}", "\u{0C85}" ... "\u{0C8C}", "\u{0C8E}" ... "\u{0C90}",
                "\u{0C92}" ... "\u{0CA8}", "\u{0CAA}" ... "\u{0CB3}", "\u{0CB5}" ... "\u{0CB9}",
                "\u{0CBE}" ... "\u{0CC4}", "\u{0CC6}" ... "\u{0CC8}", "\u{0CCA}" ... "\u{0CCD}",
                "\u{0CDE}" ... "\u{0CDE}", "\u{0CE0}" ... "\u{0CE1}",
                // Digits (10)
                "\u{0CE6}" ... "\u{0CEF}",
                // Malayam
                "\u{0D02}" ... "\u{0D03}", "\u{0D05}" ... "\u{0D0C}", "\u{0D0E}" ... "\u{0D10}",
                "\u{0D12}" ... "\u{0D28}", "\u{0D2A}" ... "\u{0D39}", "\u{0D3E}" ... "\u{0D43}",
                "\u{0D46}" ... "\u{0D48}", "\u{0D4A}" ... "\u{0D4D}", "\u{0D60}" ... "\u{0D61}",
                // Digits (11)
                "\u{0D66}" ... "\u{0D6F}",
                // Thai...including Digits "\u{0E50}" ... "\u{0E59}" }
                "\u{0E01}" ... "\u{0E3A}", "\u{0E40}" ... "\u{0E5B}",
                // Lao (1)
                "\u{0E81}" ... "\u{0E82}", "\u{0E84}" ... "\u{0E84}", "\u{0E87}" ... "\u{0E88}",
                "\u{0E8A}" ... "\u{0E8A}", "\u{0E8D}" ... "\u{0E8D}", "\u{0E94}" ... "\u{0E97}",
                "\u{0E99}" ... "\u{0E9F}", "\u{0EA1}" ... "\u{0EA3}", "\u{0EA5}" ... "\u{0EA5}",
                "\u{0EA7}" ... "\u{0EA7}", "\u{0EAA}" ... "\u{0EAB}", "\u{0EAD}" ... "\u{0EAE}",
                "\u{0EB0}" ... "\u{0EB9}", "\u{0EBB}" ... "\u{0EBD}", "\u{0EC0}" ... "\u{0EC4}",
                "\u{0EC6}" ... "\u{0EC6}", "\u{0EC8}" ... "\u{0ECD}",
                // Digits (12)
                "\u{0ED0}" ... "\u{0ED9}",
                // Lao (2)
                "\u{0EDC}" ... "\u{0EDD}",
                // Tibetan (1)
                "\u{0F00}" ... "\u{0F00}", "\u{0F18}" ... "\u{0F19}",
                // Digits (13)
                "\u{0F20}" ... "\u{0F33}",
                // Tibetan (2)
                "\u{0F35}" ... "\u{0F35}", "\u{0F37}" ... "\u{0F37}", "\u{0F39}" ... "\u{0F39}",
                "\u{0F3E}" ... "\u{0F47}", "\u{0F49}" ... "\u{0F69}", "\u{0F71}" ... "\u{0F84}",
                "\u{0F86}" ... "\u{0F8B}", "\u{0F90}" ... "\u{0F95}", "\u{0F97}" ... "\u{0F97}",
                "\u{0F99}" ... "\u{0FAD}", "\u{0FB1}" ... "\u{0FB7}", "\u{0FB9}" ... "\u{0FB9}",
                // Georgian
                "\u{10A0}" ... "\u{10C5}", "\u{10D0}" ... "\u{10F6}",
                // Latin (3)
                "\u{1E00}" ... "\u{1E9B}", "\u{1EA0}" ... "\u{1EF9}",
                // Greek (2)
                "\u{1F00}" ... "\u{1F15}", "\u{1F18}" ... "\u{1F1D}", "\u{1F20}" ... "\u{1F45}",
                "\u{1F48}" ... "\u{1F4D}", "\u{1F50}" ... "\u{1F57}", "\u{1F59}" ... "\u{1F59}",
                "\u{1F5B}" ... "\u{1F5B}", "\u{1F5D}" ... "\u{1F5D}", "\u{1F5F}" ... "\u{1F7D}",
                "\u{1F80}" ... "\u{1FB4}", "\u{1FB6}" ... "\u{1FBC}",
                // Special characters (4)
                "\u{1FBE}" ... "\u{1FBE}",
                // Greek (3)
                "\u{1FC2}" ... "\u{1FC4}", "\u{1FC6}" ... "\u{1FCC}", "\u{1FD0}" ... "\u{1FD3}",
                "\u{1FD6}" ... "\u{1FDB}", "\u{1FE0}" ... "\u{1FEC}", "\u{1FF2}" ... "\u{1FF4}",
                "\u{1FF6}" ... "\u{1FFC}",
                // Special characters (5)
                "\u{203F}" ... "\u{2040}",
                // Latin (4)
                "\u{207F}" ... "\u{207F}",
                // Special characters (6)
                "\u{2102}" ... "\u{2102}", "\u{2107}" ... "\u{2107}", "\u{210A}" ... "\u{2113}",
                "\u{2115}" ... "\u{2115}", "\u{2118}" ... "\u{211D}", "\u{2124}" ... "\u{2124}",
                "\u{2126}" ... "\u{2126}", "\u{2128}" ... "\u{2128}", "\u{212A}" ... "\u{2131}",
                "\u{2133}" ... "\u{2138}", "\u{2160}" ... "\u{2182}", "\u{3005}" ... "\u{3007}",
                "\u{3021}" ... "\u{3029}",
                // Hiragana
                "\u{3041}" ... "\u{3093}", "\u{309B}" ... "\u{309C}",
                // Katakana
                "\u{30A1}" ... "\u{30F6}", "\u{30FB}" ... "\u{30FC}",
                // Bopmofo [sic]
                "\u{3105}" ... "\u{312C}",
                // CJK Unified Ideographs
                "\u{4E00}" ... "\u{9FA5}",
                // Hangul,
                "\u{AC00}" ... "\u{D7A3}":
            codepoint
        default:
            "_"
        }
    }
}
