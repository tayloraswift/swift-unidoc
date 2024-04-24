extension SSGC
{
    struct ArticleCollations
    {
        private
        var table:[Key: ArticleCollation]

        init(table:[Key: ArticleCollation] = [:])
        {
            self.table = table
        }
    }
}
extension SSGC.ArticleCollations
{
    subscript(i:Int32, j:Int? = nil) -> SSGC.ArticleCollation?
    {
        _read   { yield  self.table[.init(i: i, j: j)] }
        _modify { yield &self.table[.init(i: i, j: j)] }
    }

    mutating
    func move(_ i:Int32, _ j:Int? = nil) -> SSGC.ArticleCollation?
    {
        {
            if  let article:SSGC.ArticleCollation = $0
            {
                $0 = nil
                return article
            }
            else
            {
                return nil
            }
        } (&self[i, j])
    }
}
