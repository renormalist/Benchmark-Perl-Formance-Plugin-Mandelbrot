package Benchmark::Perl::Formance::Plugin::Mandelbrot::withmce;
# ABSTRACT: benchmark - Generate Mandelbrot set portable bitmap file - using MCE

# http://www.perlmonks.org/?node_id=1129370

# http://benchmarksgame.alioth.debian.org/u64q/performance.php?test=mandelbrot
# based on Perl code contributed by Mykola Zubach
# parallelization via MCE by Mario Roy

use strict;
use warnings;

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';

use MCE::Flow;

use constant MAXITER =>  50;
use constant LIMIT   =>  4.0;
use constant XMIN    => -1.5;
use constant YMIN    => -1.0;
use constant WHITE   => "\000";
use constant BLACK   => "\001";

my ( $w, $h, $m, $invN );

sub draw_line {
   my ( $mce, $y, $chunk_id ) = @_;
   my ( $Cr, $Zr, $Zi, $Tr, $Ti );
   my $Ci = $y * $invN + YMIN;
   my $line;

   LOOP: for my $x (0 .. $w - 1) {
      $Cr = $x * $invN + XMIN;
      $Zr = $Zi = $Tr = $Ti = 0.0;

      for (1 .. MAXITER) {
         $Zi = $Zi * 2 * $Zr + $Ci;
         $Zr = $Tr - $Ti + $Cr;
         $Ti = $Zi * $Zi;
         $Tr = $Zr * $Zr;
         if ($Tr + $Ti > LIMIT) {
            $line .= WHITE;
            next LOOP;
         }
      }

      $line .= BLACK;
   }

   MCE->gather( $chunk_id, pack('B*', $line) );
}

## MAIN()

sub run
{
    $w = $h = shift;
    $m = int( $h / 2 );
    $invN = 2 / $w;

    # Compute upper-half only, gather lines

    my %picture = mce_flow_s { chunk_size => 1 }, \&draw_line, 0, $m;

    # Output PBM image header
    # Output upper half
    # Remove first and last lines
    # Output bottom half in reverse

    binmode STDOUT;
}

sub main
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 400 : 2_000;
        my $count  = $options->{fastmode} ? 1   : 5;

        my $result;
        my $t = timeit $count, sub { $result = run($goal) };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

1;
