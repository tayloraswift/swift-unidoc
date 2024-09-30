import InlineArray
import Symbols
import UCF

extension UCF.ResolutionTable
{
    struct Search
    {
        private
        let predicate:UCF.Selector.Suffix?

        private
        var selected:[Symbol.Decl: Overload]
        private
        var rejected:[Symbol.Decl: Overload]

        init(matching predicate:UCF.Selector.Suffix?)
        {
            self.predicate = predicate
            self.selected = [:]
            self.rejected = [:]
        }
    }
}
extension UCF.ResolutionTable.Search
{
    mutating
    func add(_ candidates:InlineArray<Overload>)
    {
        //  Because of the way `@_exported` paths are represented in the search tree, it is 
        //  possible to encounter the same overload multiple times, due to namespace inference
        if  let predicate:UCF.Selector.Suffix = self.predicate
        {
            for overload:Overload in candidates
            {
                guard predicate ~= overload
                else
                {
                    self.rejected[overload.id] = overload
                    continue
                }

                self.selected[overload.id] = overload
            }
        }
        else
        {
            for overload:Overload in candidates
            {
                self.selected[overload.id] = overload
            }
        }
    }

    func any() -> UCF.Resolution<Overload>?
    {
        guard 
        let overload:Overload = self.selected.values.first
        else
        {
            return nil 
        }

        if  self.selected.count == 1
        {
            return .overload(overload)
        }
        else
        {
            return .choose(among: self.selected, rejected: self.rejected)
        }
    }

    consuming
    func get() -> UCF.Resolution<Overload>
    {
        if  let overload:Overload = self.selected.values.first, self.selected.count == 1
        {
            return .overload(overload)
        }
        else
        {
            return .choose(among: self.selected, rejected: self.rejected)
        }
    }
}
