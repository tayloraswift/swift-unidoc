import UnidocRecords

extension Volume
{
    func groups(latest:Bool) -> Groups<Bool>
    {
        .init(self.groups, latest: latest)
    }
}
