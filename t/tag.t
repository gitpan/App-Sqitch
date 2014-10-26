#!/usr/bin/perl -w

use strict;
use warnings;
use v5.10.1;
use utf8;
use Test::More tests => 17;
#use Test::More 'no_plan';
use Test::NoWarnings;
use App::Sqitch;
use App::Sqitch::Plan;
use Test::MockModule;
use Digest::SHA1;
use URI;

my $CLASS;

BEGIN {
    $CLASS = 'App::Sqitch::Plan::Tag';
    require_ok $CLASS or die;
    delete $ENV{PGDATABASE};
    delete $ENV{PGUSER};
    delete $ENV{USER};
    $ENV{SQITCH_CONFIG} = 'nonexistent.conf';
}

can_ok $CLASS, qw(
    name
    lspace
    rspace
    comment
    plan
);

my $sqitch = App::Sqitch->new(
    uri => URI->new('https://github.com/theory/sqitch/'),
);
my $plan   = App::Sqitch::Plan->new(sqitch => $sqitch);
my $change = App::Sqitch::Plan::Change->new( plan => $plan, name => 'roles' );

isa_ok my $tag = $CLASS->new(
    name  => 'foo',
    plan  => $plan,
    change  => $change,
), $CLASS;
isa_ok $tag, 'App::Sqitch::Plan::Line';
my $mock_plan = Test::MockModule->new('App::Sqitch::Plan');
$mock_plan->mock(index_of => 0); # no other changes

is $tag->format_name, '@foo', 'Name should format as "@foo"';
is $tag->as_string, '@foo', 'Should as_string to "@foo"';
is $tag->info, join("\n",
    'project ' . $sqitch->uri->canonical,
    'tag @foo',
    'change ' . $change->id,
), 'Tag info should be correct';

ok $tag = $CLASS->new(
    name    => 'howdy',
    plan    => $plan,
    change    => $change,
    lspace  => '  ',
    rspace  => "\t",
    comment => ' blah blah blah',
), 'Create tag with more stuff';

is $tag->as_string, "  \@howdy\t# blah blah blah",
    'It should as_string correctly';

$mock_plan->mock(index_of => 1);
$mock_plan->mock(change_at => $change);
is $tag->change, $change, 'Change should be correct';

# Make sure it gets the change even if there is a tag in between.
my @prevs = ($tag, $change);
$mock_plan->mock(index_of => 8);
$mock_plan->mock(change_at => sub { shift @prevs });
is $tag->change, $change, 'Change should be for previous change';

is $tag->info, join("\n",
    'project ' . $sqitch->uri->canonical,
    'tag @howdy',
    'change ' . $change->id,
), 'Tag info should include the change';

is $tag->id, do {
    my $content = $tag->info;
    Digest::SHA1->new->add(
        'tag ' . length($content) . "\0" . $content
    )->hexdigest;
},'Tag ID should be correct';

##############################################################################
# Test ID for a tag with a UTF-8 name.
ok $tag = $CLASS->new(
    name => '阱阪阬',
    plan => $plan,
    change  => $change,
), 'Create tag with UTF-8 name';
is $tag->info, join("\n",
    'project ' . $sqitch->uri->canonical,
    'tag '     . '@阱阪阬',
    'change '    . $change->id,
), 'The name should be decoded text';

is $tag->id, do {
    my $content = Encode::encode_utf8 $tag->info;
    Digest::SHA1->new->add(
        'tag ' . length($content) . "\0" . $content
    )->hexdigest;
},'Tag ID should be hahsed from encoded UTF-8';
