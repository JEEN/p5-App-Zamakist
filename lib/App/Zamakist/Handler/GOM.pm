package App::Zamakist::Handler::GOM;
use Moose;
use namespace::autoclean;
with qw(App::Zamakist::Role::Reportable);
use Web::Query;
use URI;
use LWP::UserAgent;

has 'mediafiles' => (
    traits => [ 'Array' ],
    is => 'rw',
    isa => 'ArrayRef[App::Zamakist::Media]',
    default => sub { [] },
    handles => {
        add_mediafile     => 'push',
        filter_mediafiles => 'grep',
    }
);

has '_ua' => (
    is => 'ro',
    isa => 'LWP::UserAgent',
    default => sub { 
        LWP::UserAgent->new;
    }
);

sub name { 'GOM' }

sub search_link { 
    my $uri = URI->new('http://search.gomtv.com/searchjm.gom');
    $uri->query_form( key => $_[1] );
    $uri;
}

sub find_permalink {
    my ($self, $filename) = @_;

    wq($self->search_link($filename))
        ->find('table#wp_list.smi_list tr td.title div a')
        ->attr('href');
}

sub available_mediafiles {
    [ $_[0]->filter_mediafiles(sub { $_->has_permalink }) ];
}

sub add {
    my ($self, $media, $job) = @_;

    my $permalink = $self->find_permalink($media->filename);
    if ($permalink) {
       $media->permalink(URI->new($permalink));
    }
    $self->add_mediafile($media);
    return 1;
}

sub download_all {
    my $self = shift;

    $self->prepare_to_download();
    for my $media (@{ $self->available_mediafiles() }) {
        $media->download(sub {
            $self->_ua->mirror(@_);
        });
    }
    $self->report_result();
}

sub prepare_to_download {
    my $self = shift;

    for my $media (@{ $self->available_mediafiles() }) {
        $media->prepare_to_download(sub {
            my $permalink = shift;
            return $self->_fetch_download_link($permalink);
        });
    }
}

sub _fetch_download_link {
    my ($self, $permalink) = @_;

    my $res = $self->_ua->get($permalink);
    my ($data) = $res->content =~ /save_down\(('[^\)]+)\)/;
    my ($int_seq,$cap_seq,$file_name) = map { s/^'//; s/'$//; $_ } split ',', $data;
    my $uri = URI->new('http://gom.gomtv.com/jmdb/save.html/'.$file_name);
    $uri->query_form(
        intSeq => $int_seq,
        capSeq => $cap_seq,
    );
    $uri;
}

__PACKAGE__->meta->make_immutable;

1;