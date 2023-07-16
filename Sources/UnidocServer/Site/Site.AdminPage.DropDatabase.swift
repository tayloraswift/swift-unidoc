import HTML

extension Site.AdminPage
{
    struct DropDatabase
    {
        init()
        {
        }
    }
}
extension Site.AdminPage.DropDatabase:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, _:Self)
    {
        html[.head]
        {
            $0[.meta] { $0.charset = "utf-8" }
            $0[.title] = "Drop Database?"
        }

        html[.body]
        {
            $0[.form]
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
}
