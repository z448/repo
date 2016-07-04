package App::Repo;
use Data::Dumper;
use Digest::SHA qw< sha1_hex sha256_hex >;
use Digest::MD5 qw< md5_hex >;
use File::Path;
use File::Find;
use File::Copy;

use warnings;
use strict;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = ( 'digest', 'packages' );
our $VERSION = '0.01';


my @deb_files = ();
my $stash = '/tmp/.repo';
my $url_base = 'https://api.metacpan.org/source';

my $init = sub {
    unless( -d "$stash/tmp" ){
        mkpath( "$stash/tmp" );
        #chmod( 0755, $tmp_dir);
        print "\nUsing curl to get dependencies\n $stash <<<getopts.pl ";
        system("curl -#kL $url_base/ZEFRAM/Perl4-CoreLibs-0.003/lib/getopts.pl > $stash/getopts.pl");
        print " $stash <<<ar";
        system("curl -#kL $url_base/BDFOY/PerlPowerTools-1.007/bin/ar > $stash/ar");
    }
}; $init->();

my $digest = sub {
    my $file = shift;
    my( $data, %data ) = ();
    open(my $fh,"<:raw :bytes",$file) || die "cant open $file: $!";
    while(<$fh>){
        $data .= $_;
    }

    %data = (
        sha1    =>  sha1_hex($data),
        sha256  =>  sha256_hex($data),
        md5     =>  md5_hex($data),
    );

    return \%data;
};

my $content = sub {
    my( $dir, $file ) = @_;
    my @control = ();
    if($file =~ /\.deb/){
        copy("$dir/$file", "$stash/tmp");
        system("cd $stash/tmp && perl -I $stash $stash/ar -x $file && tar -xf control.tar.gz");
        open(my $fh,"<","$stash/tmp/control") || die "cant open $stash/tmp/control: $!";
        system("rm -rf $stash/tmp/*");
        while(<$fh>){
            if(/^\n/){ next };
            chomp;
            push @control, $_;
        }
        push @control, 'MD5sum: ' . $digest->("$dir/$file")->{'md5'};
        push @control, 'SHA1: ' . $digest->("$dir/$file")->{'sha1'};
        push @control, 'SHA256: ' . $digest->("$dir/$file")->{'sha256'};
        push @control, "\n";
        return \@control;
    } else { die "no deb file" }
};

my $find_deb = sub {
    my $deb_dir = shift;
    my @packages = ();
    find( sub{ 
            if(/\.deb$/){
                push @deb_files, $_;
            }}, $deb_dir );

    for my $deb_file (@deb_files){
        push @packages, $content->($deb_dir, $deb_file);
    }
    return \@packages;
};


sub digest {
    $digest->(shift);
}

sub packages {
    $find_deb->(shift);
}
1;
