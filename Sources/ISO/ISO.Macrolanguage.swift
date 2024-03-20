import CasesByIntegerEncodingMacro

extension ISO
{
    @GenerateCasesByIntegerEncoding
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
