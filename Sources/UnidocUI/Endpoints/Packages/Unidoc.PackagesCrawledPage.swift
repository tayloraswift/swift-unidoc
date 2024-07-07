import BSON
import HTTP
import HTML
import ISO
import UnidocRender
import UnidocDB
import UnidocQueries
import UnixCalendar
import UnixTime
import URI

extension Unidoc
{
    struct PackagesCrawledPage
    {
        private
        let dates:[Timestamp.Date: Date]
        private
        let year:Timestamp.Year

        private
        init(dates:[Timestamp.Date: Date], year:Timestamp.Year)
        {
            self.dates = dates
            self.year = year
        }
    }
}
extension Unidoc.PackagesCrawledPage
{
    init(dates:[Unidoc.PackagesCrawledQuery.Date], in year:Timestamp.Year)
    {
        let dates:[Timestamp.Date: Date] = dates.reduce(into: [:])
        {
            let id:UnixAttosecond = .init($1.window.id)
            if  let timestamp:Timestamp = id.timestamp
            {
                $0[timestamp.date] = .init(
                    crawled: $1.window.crawled.map(UnixAttosecond.init(_:)),
                    repos: $1.repos)
            }
        }

        self.init(dates: dates, year: year)
    }
}
extension Unidoc.PackagesCrawledPage:Unidoc.RenderablePage
{
    var title:String { "Packages · \(self.year)" }
}
extension Unidoc.PackagesCrawledPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.PackagesCrawledEndpoint[self.year] }
}
extension Unidoc.PackagesCrawledPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.nav, { $0.class = "calendar" }]
            {
                $0[.a]
                {
                    $0.href = "\(Unidoc.PackagesCrawledEndpoint[self.year.predecessor])"
                } = "◀"

                $0[.h1] = "\(self.year)"

                $0[.a]
                {
                    $0.href = "\(Unidoc.PackagesCrawledEndpoint[self.year.successor])"
                } = "▶"
            }
        }

        main[.section, { $0.class = "details" }]
        {
            $0[.ol, { $0.class = "calendar" }]
            {
                let (start, leap):(Timestamp.Weekday, Bool) = self.year.vibe

                var padding:Int = Timestamp.Weekday.sunday.distance(to: start)

                for month:Timestamp.Month in Timestamp.Month.allCases
                {
                    for _:Int in 0 ..< padding
                    {
                        $0[.li]
                    }

                    padding = 7

                    for day:Int32 in month.days(leap: leap)
                    {
                        $0[.li, { $0.class = day == 1 ? "first" : "" }]
                        {
                            let id:Timestamp.Date = .init(year: year, month: month, day: day)
                            let label:DateLabel
                            switch (format.locale.country, format.locale.language)
                            {
                            case    (.as?, _),
                                    (.ca?, .en),
                                    (.fm?, _),
                                    (.gu?, _),
                                    (.ke?, .sw),
                                    (.mh?, _),
                                    (.mp?, _),
                                    (.pa?, _),
                                    (.ph?, _),
                                    (.pr?, _),
                                    (.to?, .ee),
                                    (.us?, _),
                                    (.um?, _),
                                    (.vi?, _):
                                label = .md(month, day)

                            default:
                                label = .dm(day, month)
                            }

                            guard
                            let date:Date = self.dates[id]
                            else
                            {
                                $0[.div] { $0[.p] = label }
                                return
                            }

                            if  case nil = date.crawled
                            {
                                $0[.div]
                                {
                                    $0[.p] = label
                                    $0[.p] = "\(date.repos)"
                                }
                            }
                            else
                            {
                                $0[.a]
                                {
                                    $0.href = "\(Unidoc.PackagesCreatedEndpoint[id])"
                                    $0.title = """
                                    \(date.repos) Swift \
                                    \(date.repos == 1 ? "repository" : "repositories") \
                                    were created on GitHub on \(id.long(.init(language: .en))).
                                    """
                                }
                                    content:
                                {
                                    $0[.p] = label
                                    $0[.p] { $0.class = "crawled" } = "\(date.repos)"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
