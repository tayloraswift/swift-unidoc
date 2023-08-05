import HTML
import URI

extension Site.Admin
{
    struct DropDatabase
    {
        init()
        {
        }
    }
}
extension Site.Admin.DropDatabase:FixedPage
{
    var location:URI { Site.Admin.uri.path / "drop-database" }

    var title:String { "Drop Database?" }

    func emit(main:inout HTML.ContentEncoder)
    {
        main[.form]
        {
            $0.enctype = "multipart/form-data"
            $0.action = "/admin/action/drop-database"
            $0.method = "post"
        }
        content:
        {
            $0[.p] =
            """
            This will drop (and reinitialize) the entire database. Are you sure?
            """

            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = "Drop Database"
            }
        }
    }
}
