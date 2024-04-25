extension SSGC.ArticleCollations
{
    struct Key:Equatable, Hashable
    {
        //  Layout reversed for space efficiency.
        let j:Int?
        let i:Int32

        init(i:Int32, j:Int?)
        {
            self.i = i
            self.j = j
        }
    }
}
