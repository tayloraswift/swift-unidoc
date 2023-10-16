extension ServerProfile
{
    @frozen public
    struct ByLanguage
    {
        public
        var zh:Int
        public
        var ko:Int
        public
        var ja:Int
        public
        var es:Int
        public
        var pt:Int
        public
        var de:Int
        public
        var en:Int
        public
        var ar:Int
        public
        var hi:Int
        public
        var bn:Int
        public
        var ru:Int
        public
        var other:Int
        public
        var none:Int

        @inlinable public
        init(
            zh:Int = 0,
            ko:Int = 0,
            ja:Int = 0,
            es:Int = 0,
            pt:Int = 0,
            de:Int = 0,
            en:Int = 0,
            ar:Int = 0,
            hi:Int = 0,
            bn:Int = 0,
            ru:Int = 0,
            other:Int = 0,
            none:Int = 0)
        {
            self.zh = zh
            self.ko = ko
            self.ja = ja
            self.es = es
            self.pt = pt
            self.de = de
            self.en = en
            self.ar = ar
            self.hi = hi
            self.bn = bn
            self.ru = ru
            self.other = other
            self.none = none
        }
    }
}
extension ServerProfile.ByLanguage:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(zh: 0)
    }
}
extension ServerProfile.ByLanguage
{
    func chart(stratum:String) -> Pie<Stat>
    {
        var chart:Pie<Stat> = []

        for (value, name, style):(Int, String, String) in
        [
            (
                self.zh,
                "Chinese",
                "zh"
            ),
            (
                self.ko,
                "Korean",
                "ko"
            ),
            (
                self.ja,
                "Japanese",
                "ja"
            ),
            (
                self.es,
                "Spanish",
                "es"
            ),
            (
                self.pt,
                "Portuguese",
                "pt"
            ),
            (
                self.de,
                "German",
                "de"
            ),
            (
                self.en,
                "English",
                "en"
            ),
            (
                self.ar,
                "Arabic",
                "ar"
            ),
            (
                self.hi,
                "Hindi",
                "hi"
            ),
            (
                self.bn,
                "Bengali",
                "bn"
            ),
            (
                self.ru,
                "Russian",
                "ru"
            ),
            (
                self.other,
                "Other",
                "other"
            ),
            (
                self.none,
                "None",
                "none"
            ),
        ]
        {
            if  value > 0
            {
                chart.append(.init(name,
                    stratum: stratum,
                    value: value,
                    class: "language \(style)"))
            }
        }

        return chart
    }
}
