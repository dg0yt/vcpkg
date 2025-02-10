#include <girepository.h>

int main()
{
    GError *error = NULL;

    GIRepository *repository = g_irepository_get_default();
    g_irepository_require(repository, "GLib", "2.0", 0, &error);
    if (error)
    {
        g_error("ERROR: %s\n", error->message);
        return 1;
    }

    GIBaseInfo *base_info = g_irepository_find_by_name(repository, "GLib", "random_int_range");
    if (!base_info)
    {
        g_error("ERROR: %s\n", "Could not find GLib.random_int_range");
        return 1;
    }

    GIArgument in_args[2];
    in_args[0].v_int = 2;
    in_args[1].v_int = 3;

    GIArgument retval;
    if (!g_function_info_invoke((GIFunctionInfo *)base_info, (const GIArgument *)&in_args, 2, NULL, 0, &retval, &error))
    {
        g_error("ERROR: %s\n", error->message);
        return 1;
    }

    if (retval.v_int32 != 2)
    {
        g_error("ERROR: Expect: 2, actual: %d\n", retval.v_int32);
        return 1;
    }

    g_base_info_unref(base_info);

    return 0;
}
