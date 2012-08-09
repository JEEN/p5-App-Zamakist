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