#!/bin/bash

#tiempoMedio [ día [ mes [ año ] ] [ -v ] | -h | --help ]

#exit 1 -> demasiados parámetros
#exit 2 -> fecha no válida

bdd="/home/usuario/Documentos/networklog.txt" #aqui cambiamos el path de nuestro archivo de registros

function uso() {
	echo "Uso: tiempoMedio [ día [ mes [ año ] ] [ -v ] | -h | --help ]"
}

function calcular_media() {
	fecha=$1 #tomamos la fecha que nos envían desde main()
	suma=$(grep "^$fecha" $bdd | cut -d " " -f 7 | tr "\n" "+" | rev | cut -c 2- | rev | bc) #con esa fecha buscamos en la bdd y sumamos los tiempos medios
	num_lineas=$(grep "^$fecha" $bdd | wc -l) #calculamos el numero de registros para esa fecha
	if [ "$num_lineas" -gt 0 ]; then #hemos encontrado mas de un registro
		media=$(echo "scale=2; $suma / $num_lineas" | bc) #calculamos la media con esos registros
		fechadis=$(echo "$fecha" | tr ' ' '-') #esto es opcional, es solo para que en display la fecha salga con guiones y no espacios
		if echo "$media" | grep -E -q "^."; then #solucionamos los casos en los que no nos aparecen los ceros a la izquierda. opcional también.
			echo "GATEWAY: (192.168.47.254)"      
			echo "FECHA: $fechadis"
			echo "TIEMPO MEDIO: 0$media ms"
		else
			echo "GATEWAY: (192.168.47.254)"      
			echo "FECHA: $fechadis"
			echo "TIEMPO MEDIO: $media ms"
		fi
	else
		echo "No hay registros para la fecha: $fecha" #si no hay registros, mostramos este mensaje
	fi
}

function main() {

	#mas de 4 parametros

	if [ "$#" -gt 4 ]; then
		echo "Error: Demasiados parámetros."; uso; exit 1 #hemos metido mas de 4 parametros posibles, lo que viola la sintaxis
	fi

	#mostrar ayuda si cualquiera de los parametros es -h o --help

	for par in "$@"; do
		if [ "$par" == "-h" -o "$par" == "--help" ]; then  #si algunos de los parametros es un -h o --help, mostramos la ayuda
			uso; return #el uso de return o exit en este caso es equivalente
		fi
	done
	
	#opcional: ver que de qué días existen registros

	for par in "$@"; do
		if [ "$par" == "-r" ]; then  
			cat "$bdd" | cut -d ' ' -f 1-3 | uniq ; return
		fi
	done

	#caso 0 parametros

	if [ "$#" -eq 0 ]; then
		fecha=$(date '+%Y %m %d') #le enviamos la fecha actual a la funcion calcular_media()
		calcular_media "$fecha"
	fi

	#caso 1 parametro

	if [ "$#" -eq 1 ]; then
		if [ "$1" == "-v" ]; then #si el unico parametro es -v, se hace el verboso de la fecha actual
			fecha=$(date '+%Y %m %d')
			echo "$(grep "^$fecha" $bdd)"
			echo "------------------------------------------------------"
			calcular_media "$fecha"
		else
			actual="$(date '+%Y-%m')" #si no es -v, se toma el parametro como el dia que queremos usar + el mes y año actuales
			#comprobamos que el parametro solo incluye numeros y que ademas conforma una fecha valida con el mes y año actuales usando date -d
			if echo "$1" | grep -qE '^[0-9]+$' && date -d "$actual-$1" &>/dev/null; then  
				fecha="$(date -d "$actual-$1" '+%Y %m %d')"
				calcular_media "$fecha"
			else
				echo "Error: Fecha No Válida."; uso; exit 2 #si contiene caracteres no numericos o no forma una fecha valida damos este error
			fi
		fi
	fi

	#caso 2 parametros

	if [ "$#" -eq 2 ]; then
		if [ "$2" == "-v" ]; then #si el segundo parametro es -v, hacemos verboso del dia elegido + mes y año actuales
			actual="$(date '+%Y-%m')"
			if echo "$1" | grep -qE '^[0-9]+$' && date -d "$actual-$1" &>/dev/null; then  #volvemos a comprobar que sea una fecha valida
				fecha="$(date -d "$actual-$1" '+%Y %m %d')"
				echo "$(grep "^$fecha" $bdd)"
				echo "------------------------------------------------------"
				calcular_media "$fecha"
			else
				echo "Error: Fecha No Válida."; uso; exit 2
			fi
		else
			actual="$(date '+%Y')" #tomamos los dos parametros como dia + mes y tomamos el año actual
			#comprobamos los parametros solon incluye numeros y que ademas conforman usando date -d
			if echo "$1$2" | grep -qE '^[0-9]+$' && date -d "$actual-$2-$1" &>/dev/null; then
				fecha="$(date -d "$actual-$2-$1" '+%Y %m %d')"
				calcular_media "$fecha"
			else
				echo "Error: Fecha No Válida."; uso; exit 2
			fi
		fi
	fi

	#caso 3 parametros

	if [ "$#" -eq 3 ]; then
		if [ "$3" == "-v" ]; then
			actual="$(date '+%Y')"
			if echo "$1$2" | grep -qE '^[0-9]+$' && date -d "$actual-$2-$1" &>/dev/null; then
				fecha="$(date -d "$actual-$2-$1" '+%Y %m %d')"
				echo "$(grep "^$fecha" $bdd)"
				echo "------------------------------------------------------"
				calcular_media "$fecha"
			else
				echo "Error: Fecha No Válida."; uso; exit 2
			fi
		else
			if echo "$1$2$3" | grep -qE '^[0-9]+$' && date -d "$3-$2-$1" &>/dev/null; then
				fecha="$(date -d "$3-$2-$1" '+%Y %m %d')"
				calcular_media "$fecha"
			else
				echo "Error: Fecha No Válida."; uso; exit 2
			fi
		fi
	fi

	#caso 4 parametros

	if [ "$#" -eq 4 ]; then
		if [ "$4" != "-v" ]; then
			echo "Error: Demasiados parámetros."; uso; exit 1
		fi
		if echo "$1$2$3" | grep -qE '^[0-9]+$' && date -d "$3-$2-$1" &>/dev/null; then

			fecha="$(date -d "$3-$2-$1" '+%Y %m %d')"
			echo "$(grep "^$fecha" $bdd)"
			echo "------------------------------------------------------"
			calcular_media "$fecha"
		else
			echo "Error: Fecha No Válida."; uso; exit 2
		fi
	fi
}

main $@
