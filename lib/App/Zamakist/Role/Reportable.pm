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

    $self->report();
    $self->report('hash_permalink');
}

sub report {
    my ($self, $has_permalink) = @_;

    my @mediafiles = $self->filter_mediafiles(sub { $has_permalink ? $_->has_permalink : !$_->has_permalink });
    return unless scalar @mediafiles;

    my $i = 0;
    my $table = Text::UnicodeBox::Table->new;

    $table->add_header('ID', 'Filename', 'Scrapped MediaName', 'Language');
    my $unreliable_qty = 0;
    for my $media (sort { $a->filename cmp $b->filename } @mediafiles) {
        my $media_name = $media->name || '-';
        my $language   = $media->language || '-';
        my $colored_media_name = 
            $has_permalink ? colored($media_name, $media->is_reliable ? "bold green" : "bold red") : "-";

        $table->add_row(
            ++$i, 
            $media->filename_with_ext, 
            $colored_media_name,
            $media->language || '-'
        );
        if (($has_permalink && !$media->is_reliable) || !$has_permalink) {
            $table->add_row(
                '-',
                "Maybe you can adjust its subscription file as you access this url\n".
                $self->search_link($media->filename),
            );
        }
        $unreliable_qty++ if $has_permalink && !$media->is_reliable;
    }

    if ($has_permalink) {
        print colored ("Found $i subscriptions", "bold green")."\n";
        print colored ("Maybe $unreliable_qty Subscriptions mismatched.", "bold red")."\n" if $unreliable_qty;
    } else {
        print colored ("Not found $i subscription of media files", "bold red")."\n";
    }

    print $table->render();
}

1;