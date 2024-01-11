import Atomics
import HTML
import HTTPServer
import IP
import URI

extension Swiftinit.PolicyPlugin
{
    struct StatusPage:Sendable
    {
        let updated:ContinuousClock.Instant
        let list:IP.Policylist

        init(updated:ContinuousClock.Instant, list:IP.Policylist)
        {
            self.updated = updated
            self.list = list
        }
    }
}
extension Swiftinit.PolicyPlugin.StatusPage:Swiftinit.RenderablePage, Swiftinit.DynamicPage
{
    var title:String { "Policy plugin" }
}
extension Swiftinit.PolicyPlugin.StatusPage:Swiftinit.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.h1] = "Policy plugin"

        let now:ContinuousClock.Instant = .now

        main[.p] = "Updated: \(self.updated.duration(to: now)) ago"
    }
}
