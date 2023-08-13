import UnidocAnalysis

extension Records
{
    func groups(latest:Bool) -> Groups<Bool>
    {
        .init(self.groups, latest: latest)
    }
}
