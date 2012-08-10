package App::Zamakist;
use Moose;
use namespace::autoclean;
with qw(MooseX::Getopt);
use App::Zamakist::Handler::GOM;
use App::Zamakist::Media;
use MooseX::Types::Path::Class;
use Term::ReadLine::Zoid;

our $VERSION = '0.01';

BEGIN {
    binmode STDOUT, ':utf8';
};

has 'dir' => (
    traits   => [ 'Getopt' ],
    is       => 'ro',
    isa      => 'Path::Class::Dir',
    cmd_aliases => 'd',
    coerce   => 1,
);

has 'file' => (
    traits   => [ 'Getopt' ],
    is       => 'ro',
    isa      => 'Path::Class::File',
    cmd_aliases => 'f',
    coerce   => 1,
);

has 'skip_retry' => (
    is       => 'ro',
    isa      => 'Bool',
    default  => 0,
);

has 'lang' => (
    is     => 'ro',
    isa    => 'Str',
    default => 1,
);

has 'term' => (
    is => 'ro',
    isa => 'Term::ReadLine::Zoid',
    metaclass  => 'NoGetopt',
    lazy_build => 1,
);

has 'handler' => (
    is  => 'rw',
    metaclass => 'NoGetopt',
    default => sub {
        App::Zamakist::Handler::GOM->new;
    }
);

sub _build_term {
    Term::ReadLine::Zoid->new("Zamakist-shell");
}

sub BUILD {
    my $self = shift;

    return 1;
}

sub _parse_file_basename {
    my ($self, $file) = @_;

    return unless -f $file;
    my ($filename, $ext) = $file->basename =~ /^(.+)\.(.+)$/;
    return unless $ext =~ /^(?:mkv|avi|mp4|mpe?g)$/;
    return ($filename, $ext);
}

sub add_mediafile {
    my ($self, $file) = @_;

    my ($filename, $ext) = $self->_parse_file_basename($file);
    return unless $filename;
    $self->handler->add(
        App::Zamakist::Media->new({
            filename => $filename,
            ext      => $ext,
        })
    );
    return 1;
}

sub run {
    my $self = shift;

    if ($self->dir && -d $self->dir) {
        while(my $elm = $self->dir->next) {
            $self->add_mediafile($elm);            
        }
    } 
    elsif ($self->file && -f $self->file) {
        $self->add_mediafile($self->file);
    }

    $self->handler->report_all();

    unless ($self->skip_retry) {
        my @unfetched_mediafiles = $self->handler->filter_mediafiles(sub { !$_->has_permalink });
        for my $mediafile (@unfetched_mediafiles) {
            # Notice If got it
        }
    }

    while(defined (my $input = $self->term->readline("Continue to download? [y/n] "))) {
        $input =~ s/[\r\n]//g;
        exit if $input eq 'n';
        last if $input eq 'y'; 
    }

    $self->handler->download_all();
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

App::Zamakist -

=head1 SYNOPSIS

  use App::Zamakist;

=head1 DESCRIPTION

App::Zamakist is

=head1 AUTHOR

Jeen Lee E<lt>aiatejin@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
