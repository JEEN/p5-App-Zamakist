use strict;
use Test::More tests => 7;

BEGIN { use_ok 'App::Zamakist' }

my $app = App::Zamakist->new({
    file => 't/test_file/The.Mentalist.S04E01.HDTV.XviD-ASAP.[VTV].Scarlet.Ribbons.avi',
});
ok(ref $app->file eq 'Path::Class::File');

my ($filename, $ext) = $app->_parse_file_basename($app->file);
is($filename, 'The.Mentalist.S04E01.HDTV.XviD-ASAP.[VTV].Scarlet.Ribbons');
is($ext, 'avi');

is($app->add_mediafile($app->file), 1);

my $media = $app->handler->mediafiles->[0];

ok($media->filename eq 'The.Mentalist.S04E01.HDTV.XviD-ASAP.[VTV].Scarlet.Ribbons');
ok($media->ext      eq 'avi');

diag $app->handler->search_link($media->filename);

my ($link, $title) = $app->handler->find_permalink($media->filename);
diag $link;
diag $title;

done_testing();