import UnidocRecords
import UnidocDatabase

extension Page.Docs.Zone
{
    enum Deep
    {
        case decl(Decl)
        case disambiguation(Disambiguation)
    }
}
extension Page.Docs.Zone.Deep
{
    init?(_ output:[DeepQuery.Output])
    {
        if output.count == 1
        {
            self.init(output[0])
        }
        else
        {
            return nil
        }
    }

    private
    init?(_ output:DeepQuery.Output)
    {
        guard output.principal.count == 1
        else
        {
            return nil
        }

        if  let master:Record.Master = output.principal[0].master
        {
            self = .decl(.init(
                extensions: output.principal[0].extensions,
                entourage: output.entourage,
                master: master,
                zone: output.principal[0].zone))
        }
        else
        {
            self = .disambiguation(.init(
                matches: output.principal[0].matches))
        }
    }
}
