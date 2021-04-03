# Copyright 2021 Kai Pastor <dg0yt@darc.de>

/^Error: /  s/^Error: /##vso[task.logissue type=error]/;

/^Starting package/  s/^Starting /##[group]/;
/^Elapsed time for package\|^Error: Building package .* failed/  {
    h;
    s/.*/##[endgroup]/;
    p;
    g;
};

/^    See logs for more information:/,/^[^ ]/  {
    /^ *See logs/  {
        p;
        s/See logs.*/(Use "Downloads logs" for this Azure Pipelines run.)/;
    };
    /^       */  {
        p;
        s/^ */##vso[task.uploadfile]/;
    };
};

