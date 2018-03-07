#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $convert = "convert";

my $input = "flp2.png";
my $output = "flp2-p.png";

my $command1 = 'file '.shell_quote($input);
my $info = `$command1`;

print $info."\n";

# flp2.png: PNG image data, 1989 x 825, 8-bit/color RGBA, non-interlaced
if ($info =~ /\s(\d+)\s+x\s+(\d+),/) {
  my $x = $1;
  my $y = $2;
  # list($x, $y, $type2, $attr2) = getimagesize($input);

  # ///percentages as coordinates

  #   $ps= array(0,0,30,100,100,0,90,100);
  my $ps = [0,0,30,100,100,0,90,100];

  my $a = ($x*$ps->[0])/100;
  my $b = ($y*$ps->[1])/100;
  my $c = ($x*$ps->[2])/100;
  my $d = ($y*$ps->[3])/100;
  my $e = ($x*$ps->[4])/100;
  my $f = ($y*$ps->[5])/100;
  my $g = ($x*$ps->[6])/100;
  my $h = ($y*$ps->[7])/100;

  # convert flp2-bt.png -distort Perspective '-300,0 0,0  1125,0 825,0  0,825 0,412.5  825,825 825,412.5' flp2-bt-p.png; xdg-open  flp2-bt-p.png
  my $command2 = "$convert ".shell_quote($input)." -matte -virtual-pixel transparent -distort Perspective '0,0 $a,$b  0,$y $c,$d $x,0 $e,$f $x,$y $g,$h' ".shell_quote($output);
  print $command2."\n";
  system $command2;
  system 'xdg-open '.shell_quote($output).' &';
}
