import CasesByIntegerEncodingMacro

extension ISO
{
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
extension ISO.Country {
    @inlinable public static
    var ad: Self {
        .init(rawValue: 0x6164)
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
    var ag: Self {
        .init(rawValue: 0x6167)
    }
    @inlinable public static
    var ai: Self {
        .init(rawValue: 0x6169)
    }
    @inlinable public static
    var al: Self {
        .init(rawValue: 0x616c)
    }
    @inlinable public static
    var am: Self {
        .init(rawValue: 0x616d)
    }
    @inlinable public static
    var ao: Self {
        .init(rawValue: 0x616f)
    }
    @inlinable public static
    var aq: Self {
        .init(rawValue: 0x6171)
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
    var at: Self {
        .init(rawValue: 0x6174)
    }
    @inlinable public static
    var au: Self {
        .init(rawValue: 0x6175)
    }
    @inlinable public static
    var aw: Self {
        .init(rawValue: 0x6177)
    }
    @inlinable public static
    var ax: Self {
        .init(rawValue: 0x6178)
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
    var bb: Self {
        .init(rawValue: 0x6262)
    }
    @inlinable public static
    var bd: Self {
        .init(rawValue: 0x6264)
    }
    @inlinable public static
    var be: Self {
        .init(rawValue: 0x6265)
    }
    @inlinable public static
    var bf: Self {
        .init(rawValue: 0x6266)
    }
    @inlinable public static
    var bg: Self {
        .init(rawValue: 0x6267)
    }
    @inlinable public static
    var bh: Self {
        .init(rawValue: 0x6268)
    }
    @inlinable public static
    var bi: Self {
        .init(rawValue: 0x6269)
    }
    @inlinable public static
    var bj: Self {
        .init(rawValue: 0x626a)
    }
    @inlinable public static
    var bl: Self {
        .init(rawValue: 0x626c)
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
    var bq: Self {
        .init(rawValue: 0x6271)
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
    var bt: Self {
        .init(rawValue: 0x6274)
    }
    @inlinable public static
    var bv: Self {
        .init(rawValue: 0x6276)
    }
    @inlinable public static
    var bw: Self {
        .init(rawValue: 0x6277)
    }
    @inlinable public static
    var by: Self {
        .init(rawValue: 0x6279)
    }
    @inlinable public static
    var bz: Self {
        .init(rawValue: 0x627a)
    }
    @inlinable public static
    var ca: Self {
        .init(rawValue: 0x6361)
    }
    @inlinable public static
    var cc: Self {
        .init(rawValue: 0x6363)
    }
    @inlinable public static
    var cd: Self {
        .init(rawValue: 0x6364)
    }
    @inlinable public static
    var cf: Self {
        .init(rawValue: 0x6366)
    }
    @inlinable public static
    var cg: Self {
        .init(rawValue: 0x6367)
    }
    @inlinable public static
    var ch: Self {
        .init(rawValue: 0x6368)
    }
    @inlinable public static
    var ci: Self {
        .init(rawValue: 0x6369)
    }
    @inlinable public static
    var ck: Self {
        .init(rawValue: 0x636b)
    }
    @inlinable public static
    var cl: Self {
        .init(rawValue: 0x636c)
    }
    @inlinable public static
    var cm: Self {
        .init(rawValue: 0x636d)
    }
    @inlinable public static
    var cn: Self {
        .init(rawValue: 0x636e)
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
    var cu: Self {
        .init(rawValue: 0x6375)
    }
    @inlinable public static
    var cv: Self {
        .init(rawValue: 0x6376)
    }
    @inlinable public static
    var cw: Self {
        .init(rawValue: 0x6377)
    }
    @inlinable public static
    var cx: Self {
        .init(rawValue: 0x6378)
    }
    @inlinable public static
    var cy: Self {
        .init(rawValue: 0x6379)
    }
    @inlinable public static
    var cz: Self {
        .init(rawValue: 0x637a)
    }
    @inlinable public static
    var de: Self {
        .init(rawValue: 0x6465)
    }
    @inlinable public static
    var dj: Self {
        .init(rawValue: 0x646a)
    }
    @inlinable public static
    var dk: Self {
        .init(rawValue: 0x646b)
    }
    @inlinable public static
    var dm: Self {
        .init(rawValue: 0x646d)
    }
    @inlinable public static
    var `do`: Self {
        .init(rawValue: 0x646f)
    }
    @inlinable public static
    var dz: Self {
        .init(rawValue: 0x647a)
    }
    @inlinable public static
    var ec: Self {
        .init(rawValue: 0x6563)
    }
    @inlinable public static
    var ee: Self {
        .init(rawValue: 0x6565)
    }
    @inlinable public static
    var eg: Self {
        .init(rawValue: 0x6567)
    }
    @inlinable public static
    var eh: Self {
        .init(rawValue: 0x6568)
    }
    @inlinable public static
    var er: Self {
        .init(rawValue: 0x6572)
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
    var fi: Self {
        .init(rawValue: 0x6669)
    }
    @inlinable public static
    var fj: Self {
        .init(rawValue: 0x666a)
    }
    @inlinable public static
    var fk: Self {
        .init(rawValue: 0x666b)
    }
    @inlinable public static
    var fm: Self {
        .init(rawValue: 0x666d)
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
    var ga: Self {
        .init(rawValue: 0x6761)
    }
    @inlinable public static
    var gb: Self {
        .init(rawValue: 0x6762)
    }
    @inlinable public static
    var gd: Self {
        .init(rawValue: 0x6764)
    }
    @inlinable public static
    var ge: Self {
        .init(rawValue: 0x6765)
    }
    @inlinable public static
    var gf: Self {
        .init(rawValue: 0x6766)
    }
    @inlinable public static
    var gg: Self {
        .init(rawValue: 0x6767)
    }
    @inlinable public static
    var gh: Self {
        .init(rawValue: 0x6768)
    }
    @inlinable public static
    var gi: Self {
        .init(rawValue: 0x6769)
    }
    @inlinable public static
    var gl: Self {
        .init(rawValue: 0x676c)
    }
    @inlinable public static
    var gm: Self {
        .init(rawValue: 0x676d)
    }
    @inlinable public static
    var gn: Self {
        .init(rawValue: 0x676e)
    }
    @inlinable public static
    var gp: Self {
        .init(rawValue: 0x6770)
    }
    @inlinable public static
    var gq: Self {
        .init(rawValue: 0x6771)
    }
    @inlinable public static
    var gr: Self {
        .init(rawValue: 0x6772)
    }
    @inlinable public static
    var gs: Self {
        .init(rawValue: 0x6773)
    }
    @inlinable public static
    var gt: Self {
        .init(rawValue: 0x6774)
    }
    @inlinable public static
    var gu: Self {
        .init(rawValue: 0x6775)
    }
    @inlinable public static
    var gw: Self {
        .init(rawValue: 0x6777)
    }
    @inlinable public static
    var gy: Self {
        .init(rawValue: 0x6779)
    }
    @inlinable public static
    var hk: Self {
        .init(rawValue: 0x686b)
    }
    @inlinable public static
    var hm: Self {
        .init(rawValue: 0x686d)
    }
    @inlinable public static
    var hn: Self {
        .init(rawValue: 0x686e)
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
    var id: Self {
        .init(rawValue: 0x6964)
    }
    @inlinable public static
    var ie: Self {
        .init(rawValue: 0x6965)
    }
    @inlinable public static
    var il: Self {
        .init(rawValue: 0x696c)
    }
    @inlinable public static
    var im: Self {
        .init(rawValue: 0x696d)
    }
    @inlinable public static
    var `in`: Self {
        .init(rawValue: 0x696e)
    }
    @inlinable public static
    var io: Self {
        .init(rawValue: 0x696f)
    }
    @inlinable public static
    var iq: Self {
        .init(rawValue: 0x6971)
    }
    @inlinable public static
    var ir: Self {
        .init(rawValue: 0x6972)
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
    var je: Self {
        .init(rawValue: 0x6a65)
    }
    @inlinable public static
    var jm: Self {
        .init(rawValue: 0x6a6d)
    }
    @inlinable public static
    var jo: Self {
        .init(rawValue: 0x6a6f)
    }
    @inlinable public static
    var jp: Self {
        .init(rawValue: 0x6a70)
    }
    @inlinable public static
    var ke: Self {
        .init(rawValue: 0x6b65)
    }
    @inlinable public static
    var kg: Self {
        .init(rawValue: 0x6b67)
    }
    @inlinable public static
    var kh: Self {
        .init(rawValue: 0x6b68)
    }
    @inlinable public static
    var ki: Self {
        .init(rawValue: 0x6b69)
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
    var kp: Self {
        .init(rawValue: 0x6b70)
    }
    @inlinable public static
    var kr: Self {
        .init(rawValue: 0x6b72)
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
    var kz: Self {
        .init(rawValue: 0x6b7a)
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
    var lc: Self {
        .init(rawValue: 0x6c63)
    }
    @inlinable public static
    var li: Self {
        .init(rawValue: 0x6c69)
    }
    @inlinable public static
    var lk: Self {
        .init(rawValue: 0x6c6b)
    }
    @inlinable public static
    var lr: Self {
        .init(rawValue: 0x6c72)
    }
    @inlinable public static
    var ls: Self {
        .init(rawValue: 0x6c73)
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
    var ly: Self {
        .init(rawValue: 0x6c79)
    }
    @inlinable public static
    var ma: Self {
        .init(rawValue: 0x6d61)
    }
    @inlinable public static
    var mc: Self {
        .init(rawValue: 0x6d63)
    }
    @inlinable public static
    var md: Self {
        .init(rawValue: 0x6d64)
    }
    @inlinable public static
    var me: Self {
        .init(rawValue: 0x6d65)
    }
    @inlinable public static
    var mf: Self {
        .init(rawValue: 0x6d66)
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
    var mk: Self {
        .init(rawValue: 0x6d6b)
    }
    @inlinable public static
    var ml: Self {
        .init(rawValue: 0x6d6c)
    }
    @inlinable public static
    var mm: Self {
        .init(rawValue: 0x6d6d)
    }
    @inlinable public static
    var mn: Self {
        .init(rawValue: 0x6d6e)
    }
    @inlinable public static
    var mo: Self {
        .init(rawValue: 0x6d6f)
    }
    @inlinable public static
    var mp: Self {
        .init(rawValue: 0x6d70)
    }
    @inlinable public static
    var mq: Self {
        .init(rawValue: 0x6d71)
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
    var mu: Self {
        .init(rawValue: 0x6d75)
    }
    @inlinable public static
    var mv: Self {
        .init(rawValue: 0x6d76)
    }
    @inlinable public static
    var mw: Self {
        .init(rawValue: 0x6d77)
    }
    @inlinable public static
    var mx: Self {
        .init(rawValue: 0x6d78)
    }
    @inlinable public static
    var my: Self {
        .init(rawValue: 0x6d79)
    }
    @inlinable public static
    var mz: Self {
        .init(rawValue: 0x6d7a)
    }
    @inlinable public static
    var na: Self {
        .init(rawValue: 0x6e61)
    }
    @inlinable public static
    var nc: Self {
        .init(rawValue: 0x6e63)
    }
    @inlinable public static
    var ne: Self {
        .init(rawValue: 0x6e65)
    }
    @inlinable public static
    var nf: Self {
        .init(rawValue: 0x6e66)
    }
    @inlinable public static
    var ng: Self {
        .init(rawValue: 0x6e67)
    }
    @inlinable public static
    var ni: Self {
        .init(rawValue: 0x6e69)
    }
    @inlinable public static
    var nl: Self {
        .init(rawValue: 0x6e6c)
    }
    @inlinable public static
    var no: Self {
        .init(rawValue: 0x6e6f)
    }
    @inlinable public static
    var np: Self {
        .init(rawValue: 0x6e70)
    }
    @inlinable public static
    var nr: Self {
        .init(rawValue: 0x6e72)
    }
    @inlinable public static
    var nu: Self {
        .init(rawValue: 0x6e75)
    }
    @inlinable public static
    var nz: Self {
        .init(rawValue: 0x6e7a)
    }
    @inlinable public static
    var om: Self {
        .init(rawValue: 0x6f6d)
    }
    @inlinable public static
    var pa: Self {
        .init(rawValue: 0x7061)
    }
    @inlinable public static
    var pe: Self {
        .init(rawValue: 0x7065)
    }
    @inlinable public static
    var pf: Self {
        .init(rawValue: 0x7066)
    }
    @inlinable public static
    var pg: Self {
        .init(rawValue: 0x7067)
    }
    @inlinable public static
    var ph: Self {
        .init(rawValue: 0x7068)
    }
    @inlinable public static
    var pk: Self {
        .init(rawValue: 0x706b)
    }
    @inlinable public static
    var pl: Self {
        .init(rawValue: 0x706c)
    }
    @inlinable public static
    var pm: Self {
        .init(rawValue: 0x706d)
    }
    @inlinable public static
    var pn: Self {
        .init(rawValue: 0x706e)
    }
    @inlinable public static
    var pr: Self {
        .init(rawValue: 0x7072)
    }
    @inlinable public static
    var pt: Self {
        .init(rawValue: 0x7074)
    }
    @inlinable public static
    var pw: Self {
        .init(rawValue: 0x7077)
    }
    @inlinable public static
    var py: Self {
        .init(rawValue: 0x7079)
    }
    @inlinable public static
    var qa: Self {
        .init(rawValue: 0x7161)
    }
    @inlinable public static
    var re: Self {
        .init(rawValue: 0x7265)
    }
    @inlinable public static
    var ro: Self {
        .init(rawValue: 0x726f)
    }
    @inlinable public static
    var rs: Self {
        .init(rawValue: 0x7273)
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
    var sb: Self {
        .init(rawValue: 0x7362)
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
    var sh: Self {
        .init(rawValue: 0x7368)
    }
    @inlinable public static
    var si: Self {
        .init(rawValue: 0x7369)
    }
    @inlinable public static
    var sj: Self {
        .init(rawValue: 0x736a)
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
    var sv: Self {
        .init(rawValue: 0x7376)
    }
    @inlinable public static
    var sx: Self {
        .init(rawValue: 0x7378)
    }
    @inlinable public static
    var sy: Self {
        .init(rawValue: 0x7379)
    }
    @inlinable public static
    var sz: Self {
        .init(rawValue: 0x737a)
    }
    @inlinable public static
    var tc: Self {
        .init(rawValue: 0x7463)
    }
    @inlinable public static
    var td: Self {
        .init(rawValue: 0x7464)
    }
    @inlinable public static
    var tf: Self {
        .init(rawValue: 0x7466)
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
    var tj: Self {
        .init(rawValue: 0x746a)
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
    var tm: Self {
        .init(rawValue: 0x746d)
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
    var tt: Self {
        .init(rawValue: 0x7474)
    }
    @inlinable public static
    var tv: Self {
        .init(rawValue: 0x7476)
    }
    @inlinable public static
    var tz: Self {
        .init(rawValue: 0x747a)
    }
    @inlinable public static
    var ua: Self {
        .init(rawValue: 0x7561)
    }
    @inlinable public static
    var ug: Self {
        .init(rawValue: 0x7567)
    }
    @inlinable public static
    var um: Self {
        .init(rawValue: 0x756d)
    }
    @inlinable public static
    var us: Self {
        .init(rawValue: 0x7573)
    }
    @inlinable public static
    var uy: Self {
        .init(rawValue: 0x7579)
    }
    @inlinable public static
    var uz: Self {
        .init(rawValue: 0x757a)
    }
    @inlinable public static
    var va: Self {
        .init(rawValue: 0x7661)
    }
    @inlinable public static
    var vc: Self {
        .init(rawValue: 0x7663)
    }
    @inlinable public static
    var ve: Self {
        .init(rawValue: 0x7665)
    }
    @inlinable public static
    var vg: Self {
        .init(rawValue: 0x7667)
    }
    @inlinable public static
    var vi: Self {
        .init(rawValue: 0x7669)
    }
    @inlinable public static
    var vn: Self {
        .init(rawValue: 0x766e)
    }
    @inlinable public static
    var vu: Self {
        .init(rawValue: 0x7675)
    }
    @inlinable public static
    var wf: Self {
        .init(rawValue: 0x7766)
    }
    @inlinable public static
    var ws: Self {
        .init(rawValue: 0x7773)
    }
    @inlinable public static
    var ye: Self {
        .init(rawValue: 0x7965)
    }
    @inlinable public static
    var yt: Self {
        .init(rawValue: 0x7974)
    }
    @inlinable public static
    var za: Self {
        .init(rawValue: 0x7a61)
    }
    @inlinable public static
    var zm: Self {
        .init(rawValue: 0x7a6d)
    }
    @inlinable public static
    var zw: Self {
        .init(rawValue: 0x7a77)
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
