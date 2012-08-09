use inc::Module::Install;
name 'App-Zamakist';
all_from 'lib/App/Zamakist.pm';

requires 'MooseX::Types::Path::Class';
requires 'MooseX::Getopt';
requires 'Web::Query';
requires 'Text::UnicodeBox::Table';
requires 'Term::ReadLine::Zoid';
tests 't/*.t';

test_requires 'Test::More';
auto_include;
WriteAll;
