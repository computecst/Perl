#! /usr/bin/perl
use Fcntl ':mode'; # nos ayuda a obtener datos de los archivos
use strict;
use 5.014;
use warnings;
use Digest::SHA qw(sha256_hex); #hash
use POSIX; #mactime
use File::Copy qw(copy); #copiar archivo
use Term::ANSIColor;

# indicamos el directorio a analizar
my $directory="/home/zeus/Escritorio/ProyectosPerl/test/";
my $file_log = "error.log";
my $report_file = "report.csv";
my $file_analysis = "analysis.csv";
my $cuarentena = "";
# guarda un archivo ubicado en el directorio
my $file;

my %report_user =(
	malicioso => 0,
	posiblemente_malicioso => 0,
	indeterminado => 0
);

# validaciones
my $exp_64 = "(.){20,}==";
my $exp_html = "(iframe)|(src=(.+).js.)";
my $exp_word = "(base64)|(system)|(root)|(toor)|(sudo)|(su)|(init.?[0|1|2|3|4|5|6]+)";
my $exp_dir = "(\/var\/www(\/html|\/public_html)*)|(\/tmp)";


if ($#ARGV != 0 && $#ARGV != 2){
    print "Error en los argumentos. \nPasa como argumento tu directorio.\nOpcional [name_script name_directory -c directory_quarantine]\n";
    exit(0);
}
if (! -e $ARGV[0] || ! -d $ARGV[0] ){
    print "Error: $ARGV[0] no existe o no es un directorio.\n";
    exit(0);
}
if ($#ARGV == 2 && $ARGV[1] ne "-c"){
    print "Error: $ARGV[1] opcion no valida.\n";
    exit(0);
}
if($#ARGV == 2){ say $cuarentena = $ARGV[2]; }
else{ $cuarentena = "_cuarentena"; }


&_install_dependencies();
&_read_directory($directory);
&_report_user();

sub _install_dependencies {
	#my @perl = qw(LWP::Simple XML::LibXML MIME::Lite DBI DateTime Config::Tiny Proc::ProcessTable);
	my @perl = qw(Fcntl Digest::SHA POSIX File::Copy Term::ANSIColor 5.014 strict warnings);

	foreach my $x (@perl){
		eval "use $x";
		if($@){ system("cpan $x"); eval "use $x"; }
	}

}
# presenta un mensaje de error al usuario y lo guarda en un archivo de log
sub _log{
	my $cod_error = shift;
	open FILE, ">>", $file_log;
	say FILE $cod_error . "\t" . localtime() . "\n";
	say $cod_error;
}

sub _analysis{
	my $file_line = shift;
	
	if(-e $file_analysis){ # el archivo analisis ya EXISTE
		open ANALYSIS, ">>", $file_analysis;
		say ANALYSIS $file_line;
	}else{ # el archivo analisis NO existe
		open ANALYSIS, ">>", $file_analysis;
		say ANALYSIS "\t################### ANALYSIS REPORT #######################";
		say ANALYSIS $file_line;
	}
}

sub _remove_permissions{
	my $file_cuarentena = shift;
	return(chmod 0000, $file_cuarentena); # Colocamos los permisos del archivo en 0000
}

sub _copy_files{
    my $file_original = shift;

    my $original = File::Spec->splitpath($file_original);
    # guarda la ubicacion, donde se va a copiar el archivo
    my $copia = $cuarentena."/".$original;
    say "\t\+ Copiando: ", $file_original, " a: ", $copia;

    my $dir_exists = 0;
    if(!-d $cuarentena){ # El directorio NO existe
    	if (!mkdir($cuarentena)){
    		&_log("NO se puede crear el dir $cuarentena, error: $!");
	    	return(-1); # Si no se pudo crear devolvemos un valor negativo
		}else{$dir_exists = 1;}
    } # el directorio EXISTE
    else{ $dir_exists = 1;}

    #validamos que existe el directorio de cuarentena
    if($dir_exists ==1){
    	my $res = copy($file_original, $copia);
	    if($res){ # Si se ha podido copiar los archivos maliciosos
	    	
	    	if(!_remove_permissions($copia)){ # asignamos permisos 000 a los archivos en cuarentena
		    	&_log("NO se han podido cambiar los permisos de los archivos malicisosos, error: $!");
		    	return(1);
			}
			if(!_remove_permissions($file_original)){ # asignamos permisos 000 a los archivos en cuarentena
				#say "siiiiiiiiiiiiiiii";
		    	&_log("NO se han podido cambiar los permisos de los archivos malicisosos, error: $!");
		    	return(1);
			}
	    }else{ # Si no se pudo copiar el archivo
			say "\t\- Error: ","Copiando: ", $file_original, " a: ", $copia;
			return(0);
	    }
    }else{
    	&_log("NO se han copiado los archivos maliciosos");
    }
}

sub _classification{
	my $num_point = shift;
	my $ms = "";
	if($num_point >= 4){ $ms = "malicioso"; $report_user{malicioso}++ }
	elsif($num_point < 4 and $num_point > 1){ $ms = "posiblemente_malicioso"; $report_user{posiblemente_malicioso}++ }
	elsif($num_point == 1){ $ms = "indeterminado"; $report_user{indeterminado}++ }
	elsif($num_point == 0){ $ms = "limpio"; }
	return $ms;
}

sub _report{
	# ruta del archivo sospechoso
	my $my_file = shift;
	my $points_file = shift;

	say "\t".$my_file; # directorio actual

	my $status = _classification($points_file->{points});
	# obtenemos los permisos del archivo
	my $permission = sprintf("%04o", S_IMODE((stat($my_file))[2]));
	#mactime
	my $mtime = (stat $my_file)[9];
	my $mactime = (POSIX::strftime("%d-%m-%Y-%H:%M:%S", localtime($mtime)));
	#tamaño
	my $size = 0;
	# obtenemos el tamaño del archivo
	foreach ($my_file){ $size = -s $_;}
	# hash del archivo
	my $hash = sha256_hex($my_file);
	my $row_file = $my_file."\t" .$mactime."\t" .$permission."\t" .$size."\t" .$hash."\t" .$status;

	if(-e $report_file){ # el archivo de reportes ya EXISTE
		open REPORT, ">>", $report_file;
		say REPORT $row_file;
	}else{ # el archivo reportes de NO existe
		open REPORT, ">", $report_file;
		say REPORT "ubicacion\tmactime\tpermisos\ttamaño\thash\tdeteccion\n\n";
		say REPORT $row_file;
	}

	&_copy_files($my_file);
}

sub _read_directory{
	my $directory = shift;
	my %score;
	my $points = 0;

	say "Directory: " .$directory;

	# accesamos al directorio
	if(opendir DIR, $directory){
		# leemos los archivos que contiene el directorio
		foreach $file(readdir DIR){
			# continua si hay algun archivo
			if($file){
				# ruta del archivo que se esta analizando
				my $path = $directory.$file;
				# el parametro (-f) valida si es un archivo de texto plano
				if(-f $path){
					# validamos los permisos que tiene el archivo
					my $tmp_permission = sprintf("%04o", S_IMODE((stat($path))[2]));
					$tmp_permission =~ /(.)(.)(.)(.)/;
					my ($user,$group,$otros)=($2,$3,$4);
					
					if($group > 5 or $otros > 5){
						$score{'points'}++;
				  		my $ms1 = colored(['red on_bright_yellow'],"$path - archivo con privilegios elevados");
						&_analysis($ms1);
				    	my $ms2 = colored(['bright_red on_black'],"$path \n");
				    	&_analysis($ms2);
					}
					
					if(open FILE, "<", $path){
						#say "leyendo...!!". "\n";
						$score{'file'} = $path;
						$score{'points'} = 0;

						my @my_file = (<FILE>);
						# leemos el archivo
						for(@my_file){
							chomp($_); # omitimos el salto de linea

						  	if(m/$exp_64/){ # busca cadenas codificadas en base64
								$score{'points'}++;
								#say colored(['red on_bright_yellow'],"posiblemente este en base64");
								my $ms1 = colored(['red on_bright_yellow'],"$path - posiblemente este en base64");
								&_analysis($ms1);
						    	#say colored(['bright_red on_black'],$_);
						    	my $ms2 = colored(['bright_red on_black'],"$path - ".$_ . "\n");
						    	&_analysis($ms2);
						  	}
						  	
						  	if(m/$exp_html/){ # busca iframes y analiza urls
						  		$score{'points'}++;
						  		#say colored(['red on_bright_yellow'],"posible problema en el codigo");
								my $ms1 = colored(['red on_bright_yellow'],"$path - posible problema en el codigo");
								&_analysis($ms1);
						    	#say colored(['bright_red on_black'],$_);
						    	my $ms2 = colored(['bright_red on_black'],"$path - ".$_ . "\n");
						    	&_analysis($ms2);
						  	}
						  	if(m/$exp_dir/){ # busca directorios
						  		$score{'points'}++;
						  		#say colored(['red on_bright_yellow'],"posible riesgo a directorio");
								my $ms1 = colored(['red on_bright_yellow'],"$path - posible riesgo a directorio");
								&_analysis($ms1);
						    	#say colored(['bright_red on_black'],$_);
						    	my $ms2 = colored(['bright_red on_black'],"$path - ".$_ . "\n");
						    	&_analysis($ms2)
						  	}
						  	if(m/$exp_word/){ # busca palabras sospechosas
						  		$score{'points'}++;
						  		#say colored(['red on_bright_yellow'],"palabra sospechosa");
								my $ms1 = colored(['red on_bright_yellow'],"$path - palabra sospechosa");
								&_analysis($ms1);
						    	#say colored(['bright_red on_black'],$_);
						    	my $ms2 = colored(['bright_red on_black'],"$path - ".$_ . "\n");
						    	&_analysis($ms2);
						  	}
						  	if(length($_) > 100){ # valida la longitud de la cadena
						  		$score{'points'}++;
						  		#say colored(['red on_bright_yellow'],"cadena muy extensa");
								my $ms1 = colored(['red on_bright_yellow'],"$path - cadena muy extensa");
								&_analysis($ms1);
						    	#say colored(['bright_red on_black'],$_);
						    	my $ms2 = colored(['bright_red on_black'],"$path - ".$_ . "\n");
						    	&_analysis($ms2);
						  	}
						  	else{
						  		#say $_;
						  	}
						}
						if($score{'points'} > 0){
							&_report($path, \%score);
						}
						# cerramos el archivo
						close FILE;
					}
					else{
						&_log("NO se puede leer el archivo $file, error: $!");
					}
				}
				else{
					# archivos que son directorios
					#say "dir: " . $file;
					if(-d $file){ # obtiene el directorio actual(.) y la referencia al directorio padre(..)
					#if($file eq '.' or $file eq '..'){ # hace lo mismo que la linea de arriba
						#say "###### sistema $path ##########\n";
						# archivos que son directorios del sistema (.) y (..)
					}
					else{
						# archivos que son direcotorios y que NO son (.) o (..)
						&_read_directory($path."/");
					}	
				}	
		    }
		}
		# cerramos el direcorio
		closedir DIR;
	}
	else{
		&_log("NO se puede abrir el directorio: $!");
	}
}

sub _report_user{
	print color('bold blue');
	#say "\n\n###################################";
	say "\n\n\tRESULTS:";
	say "\t###################################";
	say "\t# \+ malicioso: \t\t\t" . $report_user{malicioso} . " #";
	say "\t# \+ posiblemente_malicioso: \t" . $report_user{posiblemente_malicioso} . " #";
	say "\t# \+ indeterminado: \t\t" . $report_user{indeterminado} . " #";
	say "\t###################################\n";
}

if ($#ARGV != 0 && $#ARGV != 2){
    print "Error en los argumentos. \nPasa como argumento tu directorio.\nOpcional [name_script name_directory -c directory_quarantine]\n";
    exit(0);
}
if (! -e $ARGV[0] || ! -d $ARGV[0] ){
    print "Error: $ARGV[0] no existe o no es un directorio.\n";
    exit(0);
}
if ($#ARGV == 2 && $ARGV[1] ne "-c"){
    print "Error: $ARGV[1] opcion no valida.\n";
    exit(0);
}
if($#ARGV == 2){ say $cuarentena = $ARGV[2]; exit;}
else{ $cuarentena = "_cuarentena"; exit;}

say "
		#     #                  #####                                    ###
		#  #  #  ######  #####  #     #  #    #  ######  #       #        ###
		#  #  #  #       #    # #        #    #  #       #       #        ###
		#  #  #  #####   #####   #####   ######  #####   #       #         #
		#  #  #  #       #    #       #  #    #  #       #       #
		#  #  #  #       #    # #     #  #    #  #       #       #        ###
		 ## ##   ######  #####   #####   #    #  ######  ######  ######   ###
";
&_install_dependencies();
&_read_directory($directory);
&_report_user();
exit;











__END__

=pod

=head1 Proyecto Final - Perl

=head2 EQUIPO

Zaine Coronado Gozain

Omar Santiago Lopez

Luis Miguel Torres Ortiz

Jose Luis Torres Rodriguez

=head2 DESCRIPCION

El programa lleva a cabo un analisis de los archivos de un directorio para determinar si estos son maliciosos. 
Para esto se considera la longitud de las lineas y las lineas codificadas en base64, tambien se hacen busquedas 
de patrones usados para realizar "defacement". Tambien se consideran los permisos y la ubicacion de los archivos para 
tratar de determinar si se pueden considerar maliciosos. Ademas se realizan busquedas de palabras "sospechosas", 
tales como "sudo", "root", entre otras. El analisis se lleva a cabo de manera recursiva sobre el directorio
recibido.

Los archivos detectados como maliciosos se copian a un directorio de cuarentena, donde se les asignan
permisos 0000, estos permisos tambien se asignan a los archivos originales.

=head2 PARAMETROS

El programa recibe como parametro el nombre del directorio a analizar. Tambien puede recibir la siguiente
opcion:

B<C<-c [directorio para cuarentena]>>

A traves de esta opcion se puede indicar el nombre del directorio que se utilizara para copiar los archivos
detectados como maliciosos. Si no se incluye la opcion se crea un directorio de nombre C<_cuarentena> en el
directorio actual.

=head2 VALORES DEVUELTOS

Genera un archivo "error.log" donde se almacenan los mensajes de error y mensajes generados por el programa,
al tratar de abrir, copiar o modificar permisos de archivos.

Genera un archivo "report.csv" que contiene el resultado del analisis.

Genera un archivo "analisis.csv", que contiene la ruta de los archivos y las lineas que se detectaron como
sospechosas.

=head2 EJECUCION

La siguiente instruccion invoca al programa para analizar el directorio C<datos>, no se incluye la opcion "-c",
por lo que los archivos se colocaran en cuarentena en el subdirectorio C<_cuarentena>:

B<C<./webShell.pl datos>>

La siguiente instruccion invoca al programa para analizar el directorio C<datos>, en este caso los archivos
maliciosos se colocaran en el directorio "malos":

B<C<./webShell.pl datos -c malos>>

=cut




