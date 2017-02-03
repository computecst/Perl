#! perl
use strict;
use warnings;
my @students = ("Arturo", "Jose", "Alan", "Yeudiel", "Virgilio", "Fernando", "Diana",
                "Jorge", "Sergio", "Luis", "Carlos", "Olivia", "Jennifer", "Fernando2",
                "Saine", "Armando", "Omar", "Oscar", "Angel", "Cristian", "Gonzalo", "Ivan");
print("PRAGMA
Un pragma es un modulo (conjunto de instrucciones), que ha sido desarrollado
para un fin en especifico; por ejemplo, el pragma warnings, esta orientado
para el control de advertencias.
");
print "\nStudent: ", $students[ int rand(22) ], "\n";
# --------------------------------------------------------------------------------------
=head1 NOMBRE
Tarea1 - Un modulo de ejemplo

=head1 DESCRIPCION
Este modulo presenta en pantalla
el nombre de un estudiante, de manera
aleatoria.

=head1 AUTOR
Omar Santiago Lopez - <https://github.com/santiago-10/>
=cut
