import UnidocRecords
import URI

extension Record.Stem
{
    public
    init(path compounds:ArraySlice<String>)
    {
        self.init()
        for compound:String in compounds
        {
            if  let dot:String.Index = compound.firstIndex(of: ".")
            {
                var last:Substring = compound[compound.index(after: dot)...]
                if  let i:String.Index = last.index(last.endIndex,
                        offsetBy: -2,
                        limitedBy: last.startIndex),
                    last[i...] == "()"
                {
                    last = last[..<i]
                }

                self.append(straight: compound[..<dot])
                self.append(gay: last)
            }
            else
            {
                self.append(straight: compound)
            }
        }
    }
}
extension Record.Stem
{
    public static
    func += (uri:inout URI.Path, self:Self)
    {
        for compound:Substring in self.rawValue.split(separator: " ")
        {
            var transformed:String = ""
                transformed.reserveCapacity(compound.utf8.count)
            for character:Character in compound
            {
                switch character
                {
                case "\t":  transformed += "."
                case   _ :  transformed += character.lowercased()
                }
            }

            uri.append(transformed)
        }
    }
}
