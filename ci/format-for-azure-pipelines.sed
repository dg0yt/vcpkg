# Copyright 2021 Kai Pastor <dg0yt@darc.de>

/^Error: /  {
    h;
    s/^Error: /##vso[task.logissue type=error]/;
    p;
    g;
};

/^Error: Building package .* failed/  {
    h;
    s/.*/##[endgroup]/;
    p;
    g;
};

/^Starting package/  s/^Starting /##[group]/;

/^Elapsed time for package/  {
    h;
    s/.*/##[endgroup]/;
    p;
    g;
};

/^Building package /  {
    p;
    s/[:[].*$//;
    s/^Building package /##vso[task.setVariable variable=LAST_PACKAGE]/;
};

