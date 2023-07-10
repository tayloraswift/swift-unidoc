import HTML
import HTMLRendering

extension Page.Admin
{
    struct DropDatabase
    {
        init()
        {
        }
    }
}
extension Page.Admin.DropDatabase
{
    var html:HTML
    {
        .document
        {
            $0[.html, { $0[.lang] = "en" }]
            {
                $0[.head]
                {
                    $0[.meta] { $0[.charset] = "utf-8" }
                    $0[.title] = "Drop Database?"
                }

                $0[.body]
                {
                    $0[.form]
                    {
                        $0[.enctype] = "multipart/form-data"
                        $0[.action] = "/admin/action/drop-database"
                        $0[.method] = "post"
                    }
                    content:
                    {
                        $0[.p] =
                        """
                        This will drop (and reinitialize) the entire database. Are you sure?
                        """

                        $0[.p]
                        {
                            $0[.button] { $0[.type] = "submit" } = "Drop Database"
                        }
                    }
                }
            }
        }
    }
}
