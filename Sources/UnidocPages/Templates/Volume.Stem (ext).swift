import UnidocRecords
import URI

extension Unidoc.Stem
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
