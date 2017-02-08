my $i = 0; 
my %resultado = ();
my $cmd;
my %HoF = (
    salir   =>  sub { exit },
    suma    =>  \&suma,
    resta   =>  \&resta,
    multi   =>  \&multi,
    div    =>  \&divi,
    mod		=>  sub {my $a = shift; my $b = shift; print($a%$b,"\n");},
    help    =>	sub { print("La calculadora tiene las sig. operaciones: \n1)suma \n2)resta \n3)mult \n4)div \n5)modulo\n6)salir\n"); }
);

while(1){
	my $op;
	print "operacion: ";
	chomp($op = <STDIN>);
	$cmd = $op;
   	if($HoF{lc $cmd}){ #lc obtiene convierte en parametro recibido
   		if($op == "salir"){exit;}
   		print "num1: ";
		chomp($n1 = <STDIN>);
		print "num2: ";
		chomp($n2 = <STDIN>);
    	$HoF{lc $cmd}->($n1,$n2);
    	for my $operacion(sort keys %resultado){
			print $operacion, " --> ", $resultado{$operacion};
			print "\n";
		}
   	}else {
    	# warn --> termina el programa, es similar a die, este envia un codigo 0 de advertencia
    	warn "Unknown command: `$cmd'; Try `help' next time\n";
   	}
}

sub suma{
	my $a=shift;
   	my $b=shift;
   	$i++;
   	$resultado{"op $i"} = $a+$b;
}
sub resta{
   my $a=shift;
   my $b=shift;
   $i++; $resultado{"op $i"} = $a-$b;
}
sub multi{
   my $a=shift;
   my $b=shift;
   $i++; $resultado{"op $i"} = $a*$b;
}
sub divi{
   my $a=shift;
   my $b=shift;
   $i++; $resultado{"op $i"} = $a/$b;
}

# --------------------------------------------------------------------------------------
=head1 NOMBRE
Practica3 - Calculadora 2

=head1 DESCRIPCION
Operaciones basicas usando hash

=head1 AUTOR
Omar Santiago Lopez - <https://github.com/santiago-10/Perl>
=cut


