
use warnings;
use strict;
use Test::More tests => 10;

# Check if module loads ok
BEGIN { use_ok('Verilog::VCD', qw(parse_vcd)) }

my $vcd;
my $expected;

$vcd = parse_vcd('t/vcd/cr-lf.vcd');
is(keys %{ $vcd }, 1, 'one code');
my ($code) = keys %{ $vcd };
is($code, '!', 'code');
is(scalar @{ $vcd->{$code}{nets} }, '1', 'number of nets');
is($vcd->{$code}{nets}[0]{name}, 'clk', 'name');
is($vcd->{$code}{nets}[0]{hier}, 'main', 'hier');
is($vcd->{$code}{nets}[0]{type}, 'reg', 'type');
is($vcd->{$code}{nets}[0]{size}, '1'  , 'size');
my $tv = $vcd->{$code}{tv};
my @ts = map { $_->[0] } @{ $tv };
my @vs = map { $_->[1] } @{ $tv };
my @times_exp = (
    '0',
    '10',
    '15',
    '20',
    '25',
    '30',
    '35',
    '40',
    '45',
    '50',
    '55',
    '60'
);
$expected = \@times_exp;
is_deeply(\@ts, $expected, 'times');
$expected = [(
    '0',
    '1',
    '0',
    '1',
    '0',
    '1',
    '0',
    '1',
    '0',
    '1',
    '0',
    '1'
)];
is_deeply(\@vs, $expected, 'values');

