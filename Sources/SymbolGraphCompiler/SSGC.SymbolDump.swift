import LexicalPaths
import SymbolGraphParts
import Symbols

extension SSGC
{
    @frozen public
    struct SymbolDump
    {
        let language:Phylum.Language
        let parts:[Part]

        private
        init(language:Phylum.Language, parts:[Part])
        {
            self.language = language
            self.parts = parts
        }
    }
}
extension SSGC.SymbolDump
{
    public
    init(language:Phylum.Language,
        parts:__owned [SymbolGraphPart],
        base:__shared Symbol.FileBase?) throws
    {
        var parts:[SymbolGraphPart] = consume parts
        for i in parts.indices
        {
            try
            {
                for j:Int in $0.vertices.indices
                {
                    let culture:Symbol.Module = $0.culture
                    try
                    {
                        //  Deport foreign doccomments.
                        if  let doccomment:SymbolGraphPart.Vertex.Doccomment = $0.doccomment,
                                doccomment.culture != culture
                        {
                            $0.doccomment = nil
                        }
                        //  Trim file path prefixes.
                        guard
                        let base:Symbol.FileBase = base
                        else
                        {
                            $0.location = nil
                            return
                        }

                        try $0.location?.file.rebase(against: base)

                    } (&$0.vertices[j])
                }
            } (&parts[i])
        }

        self.init(language: language, parts: parts.map(Part.init(from:)))
    }
}
