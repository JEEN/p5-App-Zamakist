package App::Zamakist::Role::Reportable;
use Moose::Role;
use Text::UnicodeBox::Table;
use Term::ANSIColor;

sub report_result {
    my ($self) = @_;

    my $count = scalar @{ $self->available_mediafiles() };
    print colored("Downloaded $count subscriptions", "bold blue")."\n" if $count;
}

sub report_all {
    my $self = shift;

    $self->report('hash_permalink');
    $self->report();
}

sub report {
    my ($self, $has_permalink) = @_;

    my @mediafiles = $self->filter_mediafiles(sub { $has_permalink ? $_->has_permalink : !$_->has_permalink });
    return unless scalar @mediafiles;
    my $i = 0;
    my $table = Text::UnicodeBox::Table->new;
    $table->add_header('id', 'filename');
    for my $media (sort { $a->filename cmp $b->filename } @mediafiles) {
        $table->add_row(++$i, $media->filename_with_ext);
    }
    print colored ("Found $i subscriptions", "bold green")."\n";
    print $table->render();
}

1;