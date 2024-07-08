import UnixTime

extension Unidoc.PackageRepo
{
    func chyron(now:UnixAttosecond, ref:String? = nil) -> Unidoc.PackageChyron
    {
        let pushed:UnixMillisecond
        let icon:Unidoc.SourceLink.Icon
        let name:Substring
        let url:String

        switch self.origin
        {
        case .github(let origin):
            pushed = origin.pushed
            icon = .github
            name = "\(origin.owner)/\(origin.name)"
            url = ref.map { "\(origin.https)/tree/\($0)" } ?? origin.https
        }

        return .init(
            source: .init(target: url, icon: icon, file: name),
            social: .init(pushed: pushed, stars: self.stars, now: now))
    }
}
