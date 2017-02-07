#!/usr/bin/perl
use strict;
use warnings;
use 5.014;

if($#ARGV == 0) {
  # definimos rutas y variables
  my $archivo = $ARGV[0];
  my $resultado = 'result.txt';
  my $num_result = 0;
  say "Leyendo archivo :)\n";
  # iniciamos archivos
  open(FH, '>>', $resultado) or die "Error al escribir en '$resultado' $!"; #RESULTADOS
  open PASS, $archivo or die "Error en la lectura de $archivo :( $!"; #LECTURA

  sub search_patron {
    my $linea = shift;
    my $exp = shift;

    if($linea !~ /"\r"/) {
      if($linea =~ /$exp/ ) {
        #say "coincidencia: " . $&;
        print FH $& . "\n"; # escribimos la coincidencia
        $num_result++;
        &search_patron($', $exp); #enviamos el argumento $', que es el resto de la linea, despues de haber encontrado la primer coincidencia
      }
    }
    else{ say "#############################"; }
  }

  # email
  my $exp_email = "([a-z]*|[A-Z]*|[0-9]*|[\_|\.|\-]*)*(\@{1})([a-z]*|[A-Z]*|[0-9]*|[\_|\.|\-]*)*(com|COM|mx|MX|org|ORG)";
  print FH "\n EMAIL: \n\n";
  while(<PASS>){ &search_patron($_, $exp_email); }
  print "email: ".$num_result."\n";
  print FH "-----------------------\n";
  print FH "TOTAL: $num_result . \n\n\n";
  close FH; # cerramos archivo de escritura
  close PASS; # cerramos el archivo

  # IP
  # iniciamos archivos
  open(FH, '>>', $resultado) or die "Error al escribir en '$resultado' $!"; #RESULTADOS
  open PASS, $archivo or die "Error en la lectura de $archivo :( $!"; #LECTURA
  $num_result = 0;
  print FH "\n IP \n\n";
  my $exp_ip = "([0-9]{1,3})(\\.{1})([0-9]{1,3})(\\.{1})([0-9]{1,3})(\\.{1})([0-9]{1,3})";
  while(<PASS>){ &search_patron($_, $exp_ip); }
  print "IP: ".$num_result."\n";
  print FH "-----------------------\n";
  print FH "TOTAL: $num_result . \n\n\n";
  close FH; # cerramos archivo de escritura
  close PASS; # cerramos el archivo

  # Dominio
  # iniciamos archivos
  open(FH, '>>', $resultado) or die "Error al escribir en '$resultado' $!"; #RESULTADOS
  open PASS, $archivo or die "Error en la lectura de $archivo :( $!"; #LECTURA
  $num_result = 0;
  print FH "\n DOMINIO: \n\n";
  my $exp_dominio = "(http?:\/\/[a-zA-Z0-9-]+[a-zA-Z0-9](\.[a-zA-Z]{2,})+)";
  while(<PASS>){ &search_patron($_, $exp_dominio); }
  print "dominio: ".$num_result."\n";
  print FH "-----------------------\n";
  print FH "TOTAL: $num_result . \n\n\n";
  close FH; # cerramos archivo de escritura
  close PASS; # cerramos el archivo

  # URL
  # iniciamos archivos
  open(FH, '>>', $resultado) or die "Error al escribir en '$resultado' $!"; #RESULTADOS
  open PASS, $archivo or die "Error en la lectura de $archivo :( $!"; #LECTURA
  $num_result = 0;
  print FH "\n URL: \n\n";
  my $exp_url = "(http?:\/\/[a-zA-Z0-9-]+[a-zA-Z0-9](\.[a-zA-Z]{2,})+)";
  while(<PASS>){ &search_patron($_, $exp_url); }
  print "url: ".$num_result."\n";
  print FH "-----------------------\n";
  print FH "TOTAL: $num_result . \n\n\n";
  close FH; # cerramos archivo de escritura
  close PASS; # cerramos el archivo


  ##################  buscamos coincidencias ###########################
  die;
  # leemos el archivo
  open PASS, "result.txt" or die "ERROR :( $!";

  sub search_coincidencia {
    my $linea = shift;
    if($linea !~ /"\r"/)
    {
      if($linea =~ "hola\@hotmail.com"){
        say "coincidencia: " . $&;
        #&search_coincidencia($'); #enviamos el argumento $', que es el resto de la linea, despues de haber encontrado la primer coincidencia
      }
    }
    else{ say "#############################"; }
  }

  while(<PASS>){
    #print $_;
    &search_coincidencia($_);
  }
}
else{
  print "\nTienes que pasar un archivo como argumento\n";die;
}

# --------------------------------------------------------------------------------------
=head1 NOMBRE
Tarea2 - Expresiones Regulares

=head1 DESCRIPCION
Este modulo lee un archivo en el cual busca
emails, dominios, IPs y URLs, con ayuda
de expresiones regulartes.

=head1 AUTOR
Omar Santiago Lopez - <https://github.com/santiago-10/Perl>
=cut
