
use warnings;
use strict;
use Test::More tests => 29;

# Check if module loads ok
BEGIN { use_ok('Verilog::VCD', qw(:all)) }

# Check module version number
BEGIN { use_ok('Verilog::VCD', '0.02') }


my $vcd;
my $expected;

# Before a VCD file is parsed, the endtime is undefined
is(get_endtime(), undef, 'undefined endtime');

# If the input file is not a VCD file, then an empty hash ref is returned
$vcd = parse_vcd('t/vcd/plain.txt');
$expected = {};
is_deeply($vcd, $expected, 'not a vcd file');

$vcd = parse_vcd('t/vcd/one-sig.vcd');
is(keys %{ $vcd }, 1, 'one code');
my ($code) = keys %{ $vcd };
is($code, '+', 'code');
is(scalar @{ $vcd->{$code}{nets} }, '1', 'number of nets');
is($vcd->{$code}{nets}[0]{name}, 'sss', 'name');
is($vcd->{$code}{nets}[0]{hier}, 'chip.cpu.alu.toggle', 'hier');
is($vcd->{$code}{nets}[0]{type}, 'reg', 'type');
is($vcd->{$code}{nets}[0]{size}, '1'  , 'size');
my $tv = $vcd->{$code}{tv};
my @ts = map { $_->[0] } @{ $tv };
my @vs = map { $_->[1] } @{ $tv };
my @times_exp = (
    '0',
    '12',
    '24',
    '36',
    '48',
    '60',
    '72',
    '84'
);
$expected = \@times_exp;
is_deeply(\@ts, $expected, 'times');
$expected = [(
    '1',
    '0',
    '1',
    '0',
    '1',
    '0',
    '1',
    '0'
)];
is_deeply(\@vs, $expected, 'values');

is(get_endtime(), '84', 'end time');

# Passed argument is ignored
is(get_endtime('1234'), '84', 'getter, not setter');

is(get_timescale(), '10ps', 'timescale = 10ps');


# Check all valid timescales: s ms us ns ps fs

$vcd = parse_vcd('t/vcd/one-sig.vcd', {timescale => 'fs'});
$tv = $vcd->{$code}{tv};
@ts = map { $_->[0] } @{ $tv };
$expected = [ map {$_ * 10e3} @times_exp ];
is_deeply(\@ts, $expected, 'times fs');

$vcd = parse_vcd('t/vcd/one-sig.vcd', {timescale => 'ps'});
$tv = $vcd->{$code}{tv};
@ts = map { $_->[0] } @{ $tv };
$expected = [ map {$_ * 10} @times_exp ];
is_deeply(\@ts, $expected, 'times ps');

$vcd = parse_vcd('t/vcd/one-sig.vcd', {timescale => 'ns'});
$tv = $vcd->{$code}{tv};
@ts = map { $_->[0] } @{ $tv };
$expected = [ map {$_ * 10e-3} @times_exp ];
is_deeply(\@ts, $expected, 'times ns');

$vcd = parse_vcd('t/vcd/one-sig.vcd', {timescale => 'us'});
$tv = $vcd->{$code}{tv};
@ts = map { $_->[0] } @{ $tv };
$expected = [ map {$_ * 10e-6} @times_exp ];
is_deeply(\@ts, $expected, 'times us');

$vcd = parse_vcd('t/vcd/one-sig.vcd', {timescale => 'ms'});
$tv = $vcd->{$code}{tv};
@ts = map { $_->[0] } @{ $tv };
$expected = [ map {$_ * 10e-9} @times_exp ];
is_deeply(\@ts, $expected, 'times ms');

# Also check that extra foo option is ignored
$vcd = parse_vcd('t/vcd/one-sig.vcd', {timescale => 's', foo => 1});
$tv = $vcd->{$code}{tv};
@ts = map { $_->[0] } @{ $tv };
$expected = [ map {$_ * 10e-12} @times_exp ];
is_deeply(\@ts, $expected, 'times s');


# Check error messages

$@ = '';
eval { my $vcd = parse_vcd('t/vcd/one-sig.vcd', {timescale => 'sec'}) };
like($@, qr/Illegal user-supplied timescale/, 'die if illegal user timescale');

$@ = '';
eval { my @sigs = parse_vcd() };
like($@, qr/parse_vcd requires a filename/, 'die if no filename');

$@ = '';
eval { my @sigs = parse_vcd(undef) };
like($@, qr/parse_vcd requires a filename/, 'die if undef');

$@ = '';
eval { my @sigs = parse_vcd('file-does-not-exist.vcd') };
like($@, qr/Can not open VCD file/, 'die if file does not exist');

$@ = '';
eval { my $vcd = parse_vcd({timescale => 'ns'}, 't/vcd/one-sig.vcd') };
like($@, qr/passed as a hash reference/, 'die if illegal option order');

$@ = '';
eval { my $vcd = parse_vcd('t/vcd/one-sig.vcd', timescale => 'ns') };
like($@, qr/passed as a hash reference/, 'die if option hash');

$@ = '';
eval { my $vcd = parse_vcd('t/vcd/one-sig.vcd', 777) };
like($@, qr/passed as a hash reference/, 'die if option hash');

