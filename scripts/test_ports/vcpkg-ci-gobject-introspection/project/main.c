#include <girepository.h>

int main()
{
    GError *error = NULL;

    GIRepository *repository = g_irepository_get_default();
    g_irepository_require(repository, "HarfBuzz", "0.0", 0, &error);
    if (error)
    {
        g_error("ERROR: %s\n", error->message);
        return 1;
    }

    GIBaseInfo *base_info = g_irepository_find_by_name(repository, "HarfBuzz", "color_get_red");
    if (!base_info)
    {
        g_error("ERROR: %s\n", "Could not find HarfBuzz.color_get_red");
        return 1;
    }

    // https://harfbuzz.github.io/harfbuzz-hb-ot-color.html#HB-COLOR:CAPS
    // https://harfbuzz.github.io/harfbuzz-hb-ot-color.html#hb-color-t
    const uint bgra_red = 0x00008000;
    GIArgument in_args[1];
    in_args[0].v_uint32 = bgra_red;  

    GIArgument retval;
    if (!g_function_info_invoke((GIFunctionInfo *)base_info, (const GIArgument *)&in_args, 1, NULL, 0, &retval, &error))
    {
        g_error("ERROR: %s\n", error->message);
        return 1;
    }

    if (retval.v_uint8 != 0x80)
    {
        g_error("ERROR: Expect: 0x80, actual: %0xd\n", retval.v_uint8);
        return 1;
    }

    g_base_info_unref(base_info);

    return 0;
}
