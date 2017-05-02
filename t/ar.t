use Test::Simple tests => 1;

my $ar_gnu = 0;

open my $pipe,'-|',"ar --version";
while(<$pipe>){
    $ar_gnu = 1 if $_ =~ /GNU/;
}

ok( $ar_gnu == 1, "GNU ar version not installed" );
