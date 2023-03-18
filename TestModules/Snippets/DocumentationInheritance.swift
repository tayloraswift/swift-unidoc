/// A documented protocol.
public
protocol Protocol
{
    /// This comment is from the root protocol.
    var everywhere:Void { get }

    /// This comment is from the root protocol.
    var `protocol`:Void { get }

    var refinement:Void { get }

    var conformer:Void { get }

    var nowhere:Void { get }
}

public
protocol Refinement:Protocol
{
    /// This comment is from the refined protocol.
    var everywhere:Void { get }

    var `protocol`:Void { get }

    /// This comment is from the refined protocol.
    var refinement:Void { get }

    var conformer:Void { get }

    var nowhere:Void { get }
}
public
protocol OtherRefinement:Protocol
{
}
extension OtherRefinement
{
    /// This is a default implementation provided by a refined protocol.
    public
    var everywhere:Void { return }

    public
    var `protocol`:Void { return }

    public
    var nowhere:Void { return }
}

public
struct Conformer:Refinement
{
    /// This comment is from the conforming type.
    public
    var everywhere:Void { return }
    public
    var `protocol`:Void { return }
    public
    var refinement:Void { return }
    /// This comment is from the conforming type.
    public
    var conformer:Void { return }
    public
    var nowhere:Void { return }
}
