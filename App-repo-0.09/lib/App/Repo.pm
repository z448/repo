package App::Repo;
use Data::Dumper;
use Digest::SHA qw< sha1_hex sha256_hex >;
use Digest::MD5 qw< md5_hex >;
use File::Path;
use File::Find;
use File::Copy;

use warnings;
use strict;

=head1 NAME
 
App::Repo - creates Packages list and starts APT repository
 
=cut

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = ( 'digest', 'packages' );
our $VERSION = '0.09';


my @deb_files = ();
my $url_base = 'https://api.metacpan.org/source';
my $stash = "$ENV{HOME}/tmp/.repo";

sub init {
    unless( -d "$ENV{HOME}/tmp/.repo" ){
        mkpath( "$ENV{HOME}/tmp/.repo" );
        print "\nUsing curl to get dependencies\n $ENV{HOME}/tmp/.repo <<<getopts.pl ";
        system("curl -#kL $url_base/ZEFRAM/Perl4-CoreLibs-0.003/lib/getopts.pl > $ENV{HOME}/tmp/.repo/getopts.pl");
        print " $ENV{HOME}/tmp/.repo <<<ar";
        system("curl -#kL $url_base/BDFOY/PerlPowerTools-1.007/bin/ar > $ENV{HOME}/tmp/.repo/ar");
    }
}; init();

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

    mkpath("$stash/tmp");
    if($file =~ /\.deb/){
        my $file_size = -s "$dir/$file";
        copy("$dir/$file", "$stash/tmp");
        system("cd $stash/tmp && perl -I$stash $stash/ar -x $file && tar -xf control.tar.gz");
        open(my $fh,"<","$stash/tmp/control") || die "cant open $stash/tmp/control: $!";
        system("rm -rf $stash/tmp/*");
        while(<$fh>){
            if(/^\n/){ next };
            chomp;
            push @control, $_;
        }
        push @control, 'Size: ' . $file_size;
        push @control, 'Filename: ' . "deb/$file"; 
        push @control, 'MD5sum: ' . $digest->("$dir/$file")->{'md5'};
        push @control, 'SHA1: ' . $digest->("$dir/$file")->{'sha1'};
        push @control, 'SHA256: ' . $digest->("$dir/$file")->{'sha256'};
        push @control, "\n";
        return \@control;
    }
    #} else { warn "no deb file" }
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
