import HTTP

extension ServerProfile
{
    @frozen public
    struct ByLanguage
    {
        public
        var ar:Int
        public
        var bn:Int
        public
        var de:Int
        public
        var en:Int
        public
        var es:Int
        public
        var fr:Int
        public
        var hi:Int
        public
        var it:Int
        public
        var ja:Int
        public
        var ko:Int
        public
        var pt:Int
        public
        var ru:Int
        public
        var vi:Int
        public
        var zh:Int
        public
        var other:Int

        @inlinable public
        init(
            ar:Int = 0,
            bn:Int = 0,
            de:Int = 0,
            en:Int = 0,
            es:Int = 0,
            fr:Int = 0,
            hi:Int = 0,
            it:Int = 0,
            ja:Int = 0,
            ko:Int = 0,
            pt:Int = 0,
            ru:Int = 0,
            vi:Int = 0,
            zh:Int = 0,
            other:Int = 0
        )
        {
            self.ar = ar
            self.bn = bn
            self.de = de
            self.en = en
            self.es = es
            self.fr = fr
            self.hi = hi
            self.it = it
            self.ja = ja
            self.ko = ko
            self.pt = pt
            self.ru = ru
            self.vi = vi
            self.zh = zh
            self.other = other
        }
    }
}
extension ServerProfile.ByLanguage:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(ar: 0)
    }
}
extension ServerProfile.ByLanguage
{
    @inlinable public
    subscript(language:HTTP.AcceptLanguage) -> Int
    {
        _read
        {
            yield  self[keyPath: language.field]
        }
        _modify
        {
            yield  &self[keyPath: language.field]
        }
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
                self.vi,
                "Vietnamese",
                "vi"
            ),
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
                self.it,
                "Italian",
                "it"
            ),
            (
                self.de,
                "German",
                "de"
            ),
            (
                self.fr,
                "French",
                "fr"
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
