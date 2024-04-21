import CasesByIntegerEncodingMacro

extension ISO
{
    @GenerateCasesByIntegerEncoding
    @frozen public
    struct Country:Equatable, Hashable, Sendable
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
            case ad
            case ae
            case af
            case ag
            case ai
            case al
            case am
            case ao
            case aq
            case ar
            case `as`
            case at
            case au
            case aw
            case ax
            case az
            case ba
            case bb
            case bd
            case be
            case bf
            case bg
            case bh
            case bi
            case bj
            case bl
            case bm
            case bn
            case bo
            case bq
            case br
            case bs
            case bt
            case bv
            case bw
            case by
            case bz
            case ca
            case cc
            case cd
            case cf
            case cg
            case ch
            case ci
            case ck
            case cl
            case cm
            case cn
            case co
            case cr
            case cu
            case cv
            case cw
            case cx
            case cy
            case cz
            case de
            case dj
            case dk
            case dm
            case `do`
            case dz
            case ec
            case ee
            case eg
            case eh
            case er
            case es
            case et
            case fi
            case fj
            case fk
            case fm
            case fo
            case fr
            case ga
            case gb
            case gd
            case ge
            case gf
            case gg
            case gh
            case gi
            case gl
            case gm
            case gn
            case gp
            case gq
            case gr
            case gs
            case gt
            case gu
            case gw
            case gy
            case hk
            case hm
            case hn
            case hr
            case ht
            case hu
            case id
            case ie
            case il
            case im
            case `in`
            case io
            case iq
            case ir
            case `is`
            case it
            case je
            case jm
            case jo
            case jp
            case ke
            case kg
            case kh
            case ki
            case km
            case kn
            case kp
            case kr
            case kw
            case ky
            case kz
            case la
            case lb
            case lc
            case li
            case lk
            case lr
            case ls
            case lt
            case lu
            case lv
            case ly
            case ma
            case mc
            case md
            case me
            case mf
            case mg
            case mh
            case mk
            case ml
            case mm
            case mn
            case mo
            case mp
            case mq
            case mr
            case ms
            case mt
            case mu
            case mv
            case mw
            case mx
            case my
            case mz
            case na
            case nc
            case ne
            case nf
            case ng
            case ni
            case nl
            case no
            case np
            case nr
            case nu
            case nz
            case om
            case pa
            case pe
            case pf
            case pg
            case ph
            case pk
            case pl
            case pm
            case pn
            case pr
            case pt
            case pw
            case py
            case qa
            case re
            case ro
            case rs
            case ru
            case rw
            case sa
            case sb
            case sc
            case sd
            case se
            case sg
            case sh
            case si
            case sj
            case sk
            case sl
            case sm
            case sn
            case so
            case sr
            case ss
            case st
            case sv
            case sx
            case sy
            case sz
            case tc
            case td
            case tf
            case tg
            case th
            case tj
            case tk
            case tl
            case tm
            case tn
            case to
            case tr
            case tt
            case tv
            case tz
            case ua
            case ug
            case um
            case us
            case uy
            case uz
            case va
            case vc
            case ve
            case vg
            case vi
            case vn
            case vu
            case wf
            case ws
            case ye
            case yt
            case za
            case zm
            case zw
        }
    }
}
extension ISO.Country:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension ISO.Country:RawRepresentableByIntegerEncoding
{
}
extension ISO.Country:CustomStringConvertible
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
extension ISO.Country:LosslessStringConvertible
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
