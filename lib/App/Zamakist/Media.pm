package App::Zamakist::Media;
use Moose;
use namespace::autoclean;

has 'filename' => (
    is  => 'ro',
    isa => 'Str'
);

has 'ext' => (
    is  => 'ro',
    isa => 'Str'
);

has 'name' => (
    is => 'rw',
    isa => 'Str',
);

has 'language' => (
    is  => 'rw',
    isa => 'Str',
);

has 'permalink' => (
    is => 'rw',
    isa => 'URI',
    predicate => 'has_permalink',
);

has 'download_link' => (
    is => 'rw',
    isa => 'URI',
    predicate => 'has_download_link',
);

sub _parse_meta {
    my ($self, $text) = @_;

    my $regexps = [ qr/S([0-9]{2})E([0-9]{2})/i, qr/.+?S?([0-9]{2})x([0-9]{2})/i ];
    my ($season, $episode);

    for my $regexp (@{ $regexps }) {
        ($season, $episode) = $text =~ $regexp;
        last if $season && $episode;
    }

    return +{} unless $season && $episode;

    return +{
        season  => $season,
        episode => $episode,
    };
}

sub is_reliable {
    my $self = shift;

    my $meta  = $self->_parse_meta($self->filename);
    return 0 unless scalar keys %$meta;
    my $meta2 = $self->_parse_meta($self->name);
    return 0 unless scalar keys %$meta2;

    $meta->{season} eq $meta2->{season} && $meta->{episode} eq $meta2->{episode};
}

sub filename_with_ext {
    my $self = shift;

    sprintf '%s.%s', $self->filename, $self->ext;
}

sub prepare_to_download {
    my ($self, $process) = @_;

    my $download_link = $process->($self->permalink);
    $self->download_link($download_link);
}

sub download {
    my ($self, $process) = @_;

    $process->($self->download_link, $self->filename.'.smi');   
}

__PACKAGE__->meta->make_immutable;

1;