use inc::Module::Install;
name 'App-Zamakist';
all_from 'lib/App/Zamakist.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
