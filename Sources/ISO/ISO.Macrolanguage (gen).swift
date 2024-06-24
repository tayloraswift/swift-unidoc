import CasesByIntegerEncodingMacro

extension ISO
{
    @frozen public
    struct Macrolanguage:Equatable, Hashable, Sendable
    {
        public
        var rawValue:UInt16

        @inlinable public
        init(rawValue:UInt16)
        {
            self.rawValue = rawValue
        }

        private
        enum AvailableCases
        {
            case aa
            case ab
            case ae
            case af
            case ak
            case am
            case an
            case ar
            case `as`
            case av
            case ay
            case az
            case ba
            case be
            case bg
            case bi
            case bm
            case bn
            case bo
            case br
            case bs
            case ca
            case ce
            case ch
            case co
            case cr
            case cs
            case cu
            case cv
            case cy
            case da
            case de
            case dv
            case dz
            case ee
            case el
            case en
            case eo
            case es
            case et
            case eu
            case fa
            case ff
            case fi
            case fj
            case fo
            case fr
            case fy
            case ga
            case gd
            case gl
            case gn
            case gu
            case gv
            case ha
            case he
            case hi
            case ho
            case hr
            case ht
            case hu
            case hy
            case hz
            case ia
            case id
            case ie
            case ig
            case ii
            case ik
            case io
            case `is`
            case it
            case iu
            case ja
            case jv
            case ka
            case kg
            case ki
            case kj
            case kk
            case kl
            case km
            case kn
            case ko
            case kr
            case ks
            case ku
            case kv
            case kw
            case ky
            case la
            case lb
            case lg
            case li
            case ln
            case lo
            case lt
            case lu
            case lv
            case mg
            case mh
            case mi
            case mk
            case ml
            case mn
            case mr
            case ms
            case mt
            case my
            case na
            case nb
            case nd
            case ne
            case ng
            case nl
            case nn
            case no
            case nr
            case nv
            case ny
            case oc
            case oj
            case om
            case or
            case os
            case pa
            case pi
            case pl
            case ps
            case pt
            case qu
            case rm
            case rn
            case ro
            case ru
            case rw
            case sa
            case sc
            case sd
            case se
            case sg
            case si
            case sk
            case sl
            case sm
            case sn
            case so
            case sq
            case sr
            case ss
            case st
            case su
            case sv
            case sw
            case ta
            case te
            case tg
            case th
            case ti
            case tk
            case tl
            case tn
            case to
            case tr
            case ts
            case tt
            case tw
            case ty
            case ug
            case uk
            case ur
            case uz
            case ve
            case vi
            case vo
            case wa
            case wo
            case xh
            case yi
            case yo
            case za
            case zh
            case zu
        }
    }
}
extension ISO.Macrolanguage {
    @inlinable public static
    var aa: Self {
        .init(rawValue: 0x6161)
    }
    @inlinable public static
    var ab: Self {
        .init(rawValue: 0x6162)
    }
    @inlinable public static
    var ae: Self {
        .init(rawValue: 0x6165)
    }
    @inlinable public static
    var af: Self {
        .init(rawValue: 0x6166)
    }
    @inlinable public static
    var ak: Self {
        .init(rawValue: 0x616b)
    }
    @inlinable public static
    var am: Self {
        .init(rawValue: 0x616d)
    }
    @inlinable public static
    var an: Self {
        .init(rawValue: 0x616e)
    }
    @inlinable public static
    var ar: Self {
        .init(rawValue: 0x6172)
    }
    @inlinable public static
    var `as`: Self {
        .init(rawValue: 0x6173)
    }
    @inlinable public static
    var av: Self {
        .init(rawValue: 0x6176)
    }
    @inlinable public static
    var ay: Self {
        .init(rawValue: 0x6179)
    }
    @inlinable public static
    var az: Self {
        .init(rawValue: 0x617a)
    }
    @inlinable public static
    var ba: Self {
        .init(rawValue: 0x6261)
    }
    @inlinable public static
    var be: Self {
        .init(rawValue: 0x6265)
    }
    @inlinable public static
    var bg: Self {
        .init(rawValue: 0x6267)
    }
    @inlinable public static
    var bi: Self {
        .init(rawValue: 0x6269)
    }
    @inlinable public static
    var bm: Self {
        .init(rawValue: 0x626d)
    }
    @inlinable public static
    var bn: Self {
        .init(rawValue: 0x626e)
    }
    @inlinable public static
    var bo: Self {
        .init(rawValue: 0x626f)
    }
    @inlinable public static
    var br: Self {
        .init(rawValue: 0x6272)
    }
    @inlinable public static
    var bs: Self {
        .init(rawValue: 0x6273)
    }
    @inlinable public static
    var ca: Self {
        .init(rawValue: 0x6361)
    }
    @inlinable public static
    var ce: Self {
        .init(rawValue: 0x6365)
    }
    @inlinable public static
    var ch: Self {
        .init(rawValue: 0x6368)
    }
    @inlinable public static
    var co: Self {
        .init(rawValue: 0x636f)
    }
    @inlinable public static
    var cr: Self {
        .init(rawValue: 0x6372)
    }
    @inlinable public static
    var cs: Self {
        .init(rawValue: 0x6373)
    }
    @inlinable public static
    var cu: Self {
        .init(rawValue: 0x6375)
    }
    @inlinable public static
    var cv: Self {
        .init(rawValue: 0x6376)
    }
    @inlinable public static
    var cy: Self {
        .init(rawValue: 0x6379)
    }
    @inlinable public static
    var da: Self {
        .init(rawValue: 0x6461)
    }
    @inlinable public static
    var de: Self {
        .init(rawValue: 0x6465)
    }
    @inlinable public static
    var dv: Self {
        .init(rawValue: 0x6476)
    }
    @inlinable public static
    var dz: Self {
        .init(rawValue: 0x647a)
    }
    @inlinable public static
    var ee: Self {
        .init(rawValue: 0x6565)
    }
    @inlinable public static
    var el: Self {
        .init(rawValue: 0x656c)
    }
    @inlinable public static
    var en: Self {
        .init(rawValue: 0x656e)
    }
    @inlinable public static
    var eo: Self {
        .init(rawValue: 0x656f)
    }
    @inlinable public static
    var es: Self {
        .init(rawValue: 0x6573)
    }
    @inlinable public static
    var et: Self {
        .init(rawValue: 0x6574)
    }
    @inlinable public static
    var eu: Self {
        .init(rawValue: 0x6575)
    }
    @inlinable public static
    var fa: Self {
        .init(rawValue: 0x6661)
    }
    @inlinable public static
    var ff: Self {
        .init(rawValue: 0x6666)
    }
    @inlinable public static
    var fi: Self {
        .init(rawValue: 0x6669)
    }
    @inlinable public static
    var fj: Self {
        .init(rawValue: 0x666a)
    }
    @inlinable public static
    var fo: Self {
        .init(rawValue: 0x666f)
    }
    @inlinable public static
    var fr: Self {
        .init(rawValue: 0x6672)
    }
    @inlinable public static
    var fy: Self {
        .init(rawValue: 0x6679)
    }
    @inlinable public static
    var ga: Self {
        .init(rawValue: 0x6761)
    }
    @inlinable public static
    var gd: Self {
        .init(rawValue: 0x6764)
    }
    @inlinable public static
    var gl: Self {
        .init(rawValue: 0x676c)
    }
    @inlinable public static
    var gn: Self {
        .init(rawValue: 0x676e)
    }
    @inlinable public static
    var gu: Self {
        .init(rawValue: 0x6775)
    }
    @inlinable public static
    var gv: Self {
        .init(rawValue: 0x6776)
    }
    @inlinable public static
    var ha: Self {
        .init(rawValue: 0x6861)
    }
    @inlinable public static
    var he: Self {
        .init(rawValue: 0x6865)
    }
    @inlinable public static
    var hi: Self {
        .init(rawValue: 0x6869)
    }
    @inlinable public static
    var ho: Self {
        .init(rawValue: 0x686f)
    }
    @inlinable public static
    var hr: Self {
        .init(rawValue: 0x6872)
    }
    @inlinable public static
    var ht: Self {
        .init(rawValue: 0x6874)
    }
    @inlinable public static
    var hu: Self {
        .init(rawValue: 0x6875)
    }
    @inlinable public static
    var hy: Self {
        .init(rawValue: 0x6879)
    }
    @inlinable public static
    var hz: Self {
        .init(rawValue: 0x687a)
    }
    @inlinable public static
    var ia: Self {
        .init(rawValue: 0x6961)
    }
    @inlinable public static
    var id: Self {
        .init(rawValue: 0x6964)
    }
    @inlinable public static
    var ie: Self {
        .init(rawValue: 0x6965)
    }
    @inlinable public static
    var ig: Self {
        .init(rawValue: 0x6967)
    }
    @inlinable public static
    var ii: Self {
        .init(rawValue: 0x6969)
    }
    @inlinable public static
    var ik: Self {
        .init(rawValue: 0x696b)
    }
    @inlinable public static
    var io: Self {
        .init(rawValue: 0x696f)
    }
    @inlinable public static
    var `is`: Self {
        .init(rawValue: 0x6973)
    }
    @inlinable public static
    var it: Self {
        .init(rawValue: 0x6974)
    }
    @inlinable public static
    var iu: Self {
        .init(rawValue: 0x6975)
    }
    @inlinable public static
    var ja: Self {
        .init(rawValue: 0x6a61)
    }
    @inlinable public static
    var jv: Self {
        .init(rawValue: 0x6a76)
    }
    @inlinable public static
    var ka: Self {
        .init(rawValue: 0x6b61)
    }
    @inlinable public static
    var kg: Self {
        .init(rawValue: 0x6b67)
    }
    @inlinable public static
    var ki: Self {
        .init(rawValue: 0x6b69)
    }
    @inlinable public static
    var kj: Self {
        .init(rawValue: 0x6b6a)
    }
    @inlinable public static
    var kk: Self {
        .init(rawValue: 0x6b6b)
    }
    @inlinable public static
    var kl: Self {
        .init(rawValue: 0x6b6c)
    }
    @inlinable public static
    var km: Self {
        .init(rawValue: 0x6b6d)
    }
    @inlinable public static
    var kn: Self {
        .init(rawValue: 0x6b6e)
    }
    @inlinable public static
    var ko: Self {
        .init(rawValue: 0x6b6f)
    }
    @inlinable public static
    var kr: Self {
        .init(rawValue: 0x6b72)
    }
    @inlinable public static
    var ks: Self {
        .init(rawValue: 0x6b73)
    }
    @inlinable public static
    var ku: Self {
        .init(rawValue: 0x6b75)
    }
    @inlinable public static
    var kv: Self {
        .init(rawValue: 0x6b76)
    }
    @inlinable public static
    var kw: Self {
        .init(rawValue: 0x6b77)
    }
    @inlinable public static
    var ky: Self {
        .init(rawValue: 0x6b79)
    }
    @inlinable public static
    var la: Self {
        .init(rawValue: 0x6c61)
    }
    @inlinable public static
    var lb: Self {
        .init(rawValue: 0x6c62)
    }
    @inlinable public static
    var lg: Self {
        .init(rawValue: 0x6c67)
    }
    @inlinable public static
    var li: Self {
        .init(rawValue: 0x6c69)
    }
    @inlinable public static
    var ln: Self {
        .init(rawValue: 0x6c6e)
    }
    @inlinable public static
    var lo: Self {
        .init(rawValue: 0x6c6f)
    }
    @inlinable public static
    var lt: Self {
        .init(rawValue: 0x6c74)
    }
    @inlinable public static
    var lu: Self {
        .init(rawValue: 0x6c75)
    }
    @inlinable public static
    var lv: Self {
        .init(rawValue: 0x6c76)
    }
    @inlinable public static
    var mg: Self {
        .init(rawValue: 0x6d67)
    }
    @inlinable public static
    var mh: Self {
        .init(rawValue: 0x6d68)
    }
    @inlinable public static
    var mi: Self {
        .init(rawValue: 0x6d69)
    }
    @inlinable public static
    var mk: Self {
        .init(rawValue: 0x6d6b)
    }
    @inlinable public static
    var ml: Self {
        .init(rawValue: 0x6d6c)
    }
    @inlinable public static
    var mn: Self {
        .init(rawValue: 0x6d6e)
    }
    @inlinable public static
    var mr: Self {
        .init(rawValue: 0x6d72)
    }
    @inlinable public static
    var ms: Self {
        .init(rawValue: 0x6d73)
    }
    @inlinable public static
    var mt: Self {
        .init(rawValue: 0x6d74)
    }
    @inlinable public static
    var my: Self {
        .init(rawValue: 0x6d79)
    }
    @inlinable public static
    var na: Self {
        .init(rawValue: 0x6e61)
    }
    @inlinable public static
    var nb: Self {
        .init(rawValue: 0x6e62)
    }
    @inlinable public static
    var nd: Self {
        .init(rawValue: 0x6e64)
    }
    @inlinable public static
    var ne: Self {
        .init(rawValue: 0x6e65)
    }
    @inlinable public static
    var ng: Self {
        .init(rawValue: 0x6e67)
    }
    @inlinable public static
    var nl: Self {
        .init(rawValue: 0x6e6c)
    }
    @inlinable public static
    var nn: Self {
        .init(rawValue: 0x6e6e)
    }
    @inlinable public static
    var no: Self {
        .init(rawValue: 0x6e6f)
    }
    @inlinable public static
    var nr: Self {
        .init(rawValue: 0x6e72)
    }
    @inlinable public static
    var nv: Self {
        .init(rawValue: 0x6e76)
    }
    @inlinable public static
    var ny: Self {
        .init(rawValue: 0x6e79)
    }
    @inlinable public static
    var oc: Self {
        .init(rawValue: 0x6f63)
    }
    @inlinable public static
    var oj: Self {
        .init(rawValue: 0x6f6a)
    }
    @inlinable public static
    var om: Self {
        .init(rawValue: 0x6f6d)
    }
    @inlinable public static
    var or: Self {
        .init(rawValue: 0x6f72)
    }
    @inlinable public static
    var os: Self {
        .init(rawValue: 0x6f73)
    }
    @inlinable public static
    var pa: Self {
        .init(rawValue: 0x7061)
    }
    @inlinable public static
    var pi: Self {
        .init(rawValue: 0x7069)
    }
    @inlinable public static
    var pl: Self {
        .init(rawValue: 0x706c)
    }
    @inlinable public static
    var ps: Self {
        .init(rawValue: 0x7073)
    }
    @inlinable public static
    var pt: Self {
        .init(rawValue: 0x7074)
    }
    @inlinable public static
    var qu: Self {
        .init(rawValue: 0x7175)
    }
    @inlinable public static
    var rm: Self {
        .init(rawValue: 0x726d)
    }
    @inlinable public static
    var rn: Self {
        .init(rawValue: 0x726e)
    }
    @inlinable public static
    var ro: Self {
        .init(rawValue: 0x726f)
    }
    @inlinable public static
    var ru: Self {
        .init(rawValue: 0x7275)
    }
    @inlinable public static
    var rw: Self {
        .init(rawValue: 0x7277)
    }
    @inlinable public static
    var sa: Self {
        .init(rawValue: 0x7361)
    }
    @inlinable public static
    var sc: Self {
        .init(rawValue: 0x7363)
    }
    @inlinable public static
    var sd: Self {
        .init(rawValue: 0x7364)
    }
    @inlinable public static
    var se: Self {
        .init(rawValue: 0x7365)
    }
    @inlinable public static
    var sg: Self {
        .init(rawValue: 0x7367)
    }
    @inlinable public static
    var si: Self {
        .init(rawValue: 0x7369)
    }
    @inlinable public static
    var sk: Self {
        .init(rawValue: 0x736b)
    }
    @inlinable public static
    var sl: Self {
        .init(rawValue: 0x736c)
    }
    @inlinable public static
    var sm: Self {
        .init(rawValue: 0x736d)
    }
    @inlinable public static
    var sn: Self {
        .init(rawValue: 0x736e)
    }
    @inlinable public static
    var so: Self {
        .init(rawValue: 0x736f)
    }
    @inlinable public static
    var sq: Self {
        .init(rawValue: 0x7371)
    }
    @inlinable public static
    var sr: Self {
        .init(rawValue: 0x7372)
    }
    @inlinable public static
    var ss: Self {
        .init(rawValue: 0x7373)
    }
    @inlinable public static
    var st: Self {
        .init(rawValue: 0x7374)
    }
    @inlinable public static
    var su: Self {
        .init(rawValue: 0x7375)
    }
    @inlinable public static
    var sv: Self {
        .init(rawValue: 0x7376)
    }
    @inlinable public static
    var sw: Self {
        .init(rawValue: 0x7377)
    }
    @inlinable public static
    var ta: Self {
        .init(rawValue: 0x7461)
    }
    @inlinable public static
    var te: Self {
        .init(rawValue: 0x7465)
    }
    @inlinable public static
    var tg: Self {
        .init(rawValue: 0x7467)
    }
    @inlinable public static
    var th: Self {
        .init(rawValue: 0x7468)
    }
    @inlinable public static
    var ti: Self {
        .init(rawValue: 0x7469)
    }
    @inlinable public static
    var tk: Self {
        .init(rawValue: 0x746b)
    }
    @inlinable public static
    var tl: Self {
        .init(rawValue: 0x746c)
    }
    @inlinable public static
    var tn: Self {
        .init(rawValue: 0x746e)
    }
    @inlinable public static
    var to: Self {
        .init(rawValue: 0x746f)
    }
    @inlinable public static
    var tr: Self {
        .init(rawValue: 0x7472)
    }
    @inlinable public static
    var ts: Self {
        .init(rawValue: 0x7473)
    }
    @inlinable public static
    var tt: Self {
        .init(rawValue: 0x7474)
    }
    @inlinable public static
    var tw: Self {
        .init(rawValue: 0x7477)
    }
    @inlinable public static
    var ty: Self {
        .init(rawValue: 0x7479)
    }
    @inlinable public static
    var ug: Self {
        .init(rawValue: 0x7567)
    }
    @inlinable public static
    var uk: Self {
        .init(rawValue: 0x756b)
    }
    @inlinable public static
    var ur: Self {
        .init(rawValue: 0x7572)
    }
    @inlinable public static
    var uz: Self {
        .init(rawValue: 0x757a)
    }
    @inlinable public static
    var ve: Self {
        .init(rawValue: 0x7665)
    }
    @inlinable public static
    var vi: Self {
        .init(rawValue: 0x7669)
    }
    @inlinable public static
    var vo: Self {
        .init(rawValue: 0x766f)
    }
    @inlinable public static
    var wa: Self {
        .init(rawValue: 0x7761)
    }
    @inlinable public static
    var wo: Self {
        .init(rawValue: 0x776f)
    }
    @inlinable public static
    var xh: Self {
        .init(rawValue: 0x7868)
    }
    @inlinable public static
    var yi: Self {
        .init(rawValue: 0x7969)
    }
    @inlinable public static
    var yo: Self {
        .init(rawValue: 0x796f)
    }
    @inlinable public static
    var za: Self {
        .init(rawValue: 0x7a61)
    }
    @inlinable public static
    var zh: Self {
        .init(rawValue: 0x7a68)
    }
    @inlinable public static
    var zu: Self {
        .init(rawValue: 0x7a75)
    }
}
extension ISO.Macrolanguage:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension ISO.Macrolanguage:RawRepresentableByIntegerEncoding
{
}
extension ISO.Macrolanguage:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        withUnsafeBytes(of: self.rawValue.bigEndian)
        {
            .init(decoding: $0, as: Unicode.ASCII.self)
        }
    }
}
extension ISO.Macrolanguage:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        guard description.utf8.count == 2
        else
        {
            return nil
        }

        self.init(rawValue: 0)

        for byte:UInt8 in description.utf8
        {
            self.rawValue <<= 8
            self.rawValue |= .init(byte)
        }
    }
}
