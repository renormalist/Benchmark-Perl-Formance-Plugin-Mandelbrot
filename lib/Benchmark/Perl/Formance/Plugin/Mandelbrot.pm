# -*- mode: cperl -*-
use 5.008;
use strict;
use warnings;

package Benchmark::Perl::Formance::Plugin::Mandelbrot;
# ABSTRACT: Benchmark::Perl::Formance plugin - more modern mandelbrot

our @default_subtests = qw( withmce );

sub perlstone
{
        my ($options) = @_;

        no strict "refs"; ## no critic

        my %results  = ();
        my $verbose  = $options->{verbose};
        my $subtests = $options->{subtests};
        my @subtests = scalar(@{$subtests||[]}) ? @{$subtests||[]} : @default_subtests;

        for my $subtest (@subtests)
        {
                print STDERR "#  - $subtest...\n" if $options->{verbose} > 2;
                eval "use ".__PACKAGE__."::$subtest"; ## no critic
                if ($@) {
                        print STDERR "# Skip PerlStone plugin '$subtest'" if $verbose;
                        print STDERR ":$@"                                if $verbose >= 2;
                        print STDERR "\n"                                 if $verbose;
                }
                else {
                        eval {
                                my $main = __PACKAGE__."::$subtest"."::main";
                                $results{$subtest} = $main->($options);
                        };
                        if ($@) {
                                $results{$subtest} = { failed => $@ };
                        }
                }
        }
        return \%results;
}

sub main
{
        my ($options) = @_;

        my $results = perlstone($options);

        return $results;
}

1; # End of Benchmark::Perl::Formance::Plugin::PerlStone2015

__END__

=pod

=head1 SYNOPSIS

=head2 Run benchmarks via perlformance frontend

 $ benchmark-perlformance -vv --plugin PerlStone2015

=head2 Start raw without any tooling

 $ perl -MData::Dumper -MBenchmark::Perl::Formance::Plugin::PerlStone2015 -e 'print Dumper(Benchmark::Perl::Formance::Plugin::PerlStone2015::main())'
 $ perl -MData::Dumper -MBenchmark::Perl::Formance::Plugin::PerlStone2015 -e 'print Dumper(Benchmark::Perl::Formance::Plugin::PerlStone2015::main({verbose => 3, fastmode => 1})->{perlstone}{subresults})'
 $ perl -MData::Dumper -MBenchmark::Perl::Formance::Plugin::PerlStone2015 -e 'print Dumper(Benchmark::Perl::Formance::Plugin::PerlStone2015::main({subtests => [qw(01overview regex)]})->{perlstone})'

=head2 AVAILABLE SUB BENCHMARKS

 mandelbrot

=head1 METHODS

=head2 main

Main entry point to start the benchmarks.

=head2 perlstone

The primary benchmarking function which in turn starts the sub
benchmarks.

=cut
