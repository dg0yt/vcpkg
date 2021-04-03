$|++;
while (<STDIN>) {
    if (/##.group.package (\d+)\/(\d+):/) {
        $_ = ( sprintf "##vso[task.setprogress value=%d]\n", ($1-1)/$2*100 ) . $_;
    }
    print $_;
}
