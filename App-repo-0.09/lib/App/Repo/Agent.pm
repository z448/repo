package App::Repo::Agent;

use 5.010;
use Mojo::UserAgent;
use Data::Dumper;
use Digest::SHA qw< sha1_hex sha256_hex >;
use Digest::MD5 qw< md5_hex >;
use Term::ANSIColor;
use JSON::PP;
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
our @EXPORT_OK = qw< get_repos_url get_packages >;
our $VERSION = '0.01';

$ENV{MOJO_NO_TLS} = 0;
$ENV{MOJO_MAX_REDIRECTS} = 15;
my $base_path = "$ENV{HOME}/.repo/stash";

my $ua = Mojo::UserAgent->new;
$ua->transactor->name('Telesphoreo APT-HTTP/1.0.592');

sub get_repos_url {
    my $url = 'https://raw.githubusercontent.com/jonluca/MasterRepo/master/MasterRepo.list';
    my @repo_url = ();
    my $tx = $ua->get("$url");
    if (my $res = $tx->success) {
        open(my $fh,'<',\$res->body);
        while(<$fh>){
            s/(.*deb\ )(.*?)(\ .*)/$2/;
            push @repo_url, $2;
        }
        close $fh;
        return \@repo_url;
    }
}

sub get_packages {
    my $repo_url = shift; 
    $repo_url =~ s/\/$//;
    my @packages_list = qw( Packages Packages.bz2 Packages.gz );

    mkpath($base_path);
    for(@packages_list){
        #my $packages_tmp_file = "$base_path/$_";
        #say "packages_tmp_file: $packages_tmp_file" if $ENV{REPO_DEBUG};
        #say "trying $repo_url/$_" if $ENV{REPO_DEBUG};;

        my $tx = $ua->get("$repo_url/$_");
        #say "$repo_url/$_";
        if (my $res = $tx->success) { 
            return parse_control($res->body, "$_");
            last;
        } 
    }
}

sub parse_control {
    my( $stream, $file_type ) = @_;
    my( @packages, %packages, $i ) = ();
    open(my $fh,"> :raw :bytes", "$base_path/$file_type");
    print $fh $stream;
    close $fh;

    if( $file_type =~ /\.gz/){
        #say "gz exist";
        system("mv $base_path/Packages.gz $base_path/Packages");
    } 
    if( $file_type =~ /\.bz2/ ){
        #say "bz2 exist";
        system("bzcat $base_path/Packages.bz2 > $base_path/Packages");
    }

    if( -f "$base_path/Packages"){
        open(my $fh, '<', "$base_path/Packages") || die "cant open $base_path/Packages: $!";
        while(<$fh>){ 
            if( /\:/){ 
                s/(.*?)(\:\ ?)(.*)/$1$2$3/;
                my($key, $value) = ($1, $3); chomp $value; $key = lc $key;
                $packages{$key} = $value;
            } else { 
                #$packages{url} = "$repo_url/$packages{Filename}";
                #$packages{number} = $i++;
                #$packages{repository} = $repo_url;
                #$packages{t} = $repo_url;
                push @packages, { %packages };
            }
        }
    }
    return \@packages;
}

#print Dumper(get_packages("$ARGV[0]"));

__DATA__

sub printer {
    my @p = @{get_packages(shift)};
    my %lenght = ();
    for(@p){
        my $number_align = 3 - length $_->{number};
        my $random_offset = rand(int(15));
        print " "x($random_offset) . "$_->{name}" . colored(['yellow'],'__') . colored(['black on_yellow'],"$_->{number}") . colored(['black on_yellow']," "x($number_align)) . "\n";
    }
}

printer("$ARGV[0]");

__DATA__
sub read_json {
    open(my $fh,"<", "$base_path/packages.json") || die "cant open: $base_path/packages.json: $!";
    my $json = <$fh>;
    my $p = decode_json $json;
}

sub write_json {
    my @p = @{get_packages(shift)};
    my $json = encode_json \@p;
    open(my $fh,">", "$base_path/packages.json") || die "cant open: $base_path/packages.json: $!";
    print $fh $json;
}

#my @url = grep { $_->{Name} } @{get_packages("$ARGV[0]")};
#for(@url){
#    say $_->{url};
#}





#for(@p){ say $_->{Name} };

__DATA__
my $res = $furl->get('http://repo.biteyourapple.net/#download.php?package=repo.biteyourapple.net.phixretroios9');
open( my $fh,">", 'debian.deb' ) || die "cant write to debian.deb: $!";
print $fh $res->content;
close $fh;

die;

# print Dumper($furl->env_proxy());
 


#my $res = $furl->get('http://repo.biteyourapple.net/download.php?package=repo.biteyourapple.net.quada');
#my $res = $furl->get('http://repo.biteyourapple.net/download.php?package=repo.biteyourapple.net.voguewallpapers');
die $res->status_line unless $res->is_success;

 
__DATA__


10.0.0.32 - - [03/Aug/2016:13:59:39 +0200] "GET http://repo.biteyourapple.net/download.php?package=repo.biteyourapple.net.voguewallpapers HTTP/1.1" 302 0 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11;



my $res = $furl->post(
    'http://example.com/', # URL
    [...],                 # headers
    [ foo => 'bar' ],      # form data (HashRef/FileHandle are also okay)
);
 
# Accept-Encoding is supported but optional
$furl = Furl->new(
    headers => [ 'Accept-Encoding' => 'gzip' ],
);
my $body = $furl->get('http://example.com/some/compressed');
