import UnidocRecords

extension Record.Shoot
{
    func description(_ indent:String = "    ") -> String
    {
        let indent:String = .init(repeating: indent, count: max(0, self.stem.depth - 1))
        return "\(indent)\(self.stem.last)"
    }
}
