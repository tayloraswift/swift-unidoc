import InlineArray
import UCF

extension UCF.ResolutionTable
{
    struct Search
    {
        private
        let predicate:UCF.Selector.Suffix?

        private
        var selected:InlineArray<Overload>
        private
        var rejected:[Overload]

        init(matching predicate:UCF.Selector.Suffix?)
        {
            self.predicate = predicate
            self.selected = []
            self.rejected = []
        }
    }
}
extension UCF.ResolutionTable.Search
{
    mutating
    func add(_ candidates:InlineArray<Overload>)
    {
        if  let predicate:UCF.Selector.Suffix = self.predicate
        {
            for overload:Overload in candidates
            {
                predicate ~= overload ?
                self.selected.append(overload) :
                self.rejected.append(overload)
            }
        }
        else
        {
            for overload:Overload in candidates
            {
                self.selected.append(overload)
            }
        }
    }

    func any() -> UCF.Resolution<Overload>?
    {
        switch self.selected
        {
        case .one(let overload):
            .overload(overload)

        case .some(let overloads):
            overloads.isEmpty ? nil : .ambiguous(overloads, rejected: self.rejected)
        }
    }

    consuming
    func get() -> UCF.Resolution<Overload>
    {
        switch self.selected
        {
        case .one(let overload):    .overload(overload)
        case .some(let overloads):  .ambiguous(overloads, rejected: self.rejected)
        }
    }
}
