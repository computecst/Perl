#!/usr/bin/perl
use warnings;
use strict;
use HTML::Template;

my $file_write = "result.html";
my $file_read = "passwd";
my $f_template = "templatePasswd.tmpl";

my %hash2;
my $output;

open RESULT, "> $file_write" or die "error al crear el archivo $file_write";
open FILE, "< $file_read" or die "error al leer el archivo $file_read";

my @file = (<FILE>);
my $template = HTML::Template->new(filename => $f_template);

print RESULT &showForm();
close RESULT;

sub showForm{
	my @loop_data=();

	for(@file) {
		my %hash;
		# user: pass: uid: gid: geos: home: shell
		my $exp = "(.*):(.*):(.*):(.*):(.*):(.*):(.*)";
		if(m{$exp}){
			$hash{'user'} = $1;
			$hash{'pass'} = $2;
			$hash{'uid'} = $3;
			$hash{'gid'} = $4;
			$hash{'geos'} = $5;
			$hash{'home'} = $6;
			$hash{'shell'} = $7;
		}

		my $temp  = $hash{'user'};
		$hash2{$temp}=\%hash;
		push(@loop_data,\%hash);
	}

	$template->param(interfaces => \@loop_data);
	$output .= $template->output();
	print $output;
	return $output;
}

# --------------------------------------------------------------------------------------
=head1 NOMBRE
Tarea3 - Template

=head1 DESCRIPCION
Se obtienen los 7 campos del archivo passwd
y se presentan en un template html.

=head1 AUTOR
Omar Santiago Lopez - <https://github.com/santiago-10/Perl>
=cut
