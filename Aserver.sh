#!/usr/bin/env bash
# -*- ENCODING: UTF-8 -*-
#modificado y creado 0x4171341
#basado en linuxpostinstall & Script personales 
#para automatizar la instalacion y gestion de procesos en server!
# Licence: gpl-3
clear

function solo_root(){
[ $( id -u ) != 0 ] && zenity --error --text="¡El SCRIPT debe ser ejecutado como ROOT!" && exit 1
}
solo_root
DIR_INI=$(echo $PWD)
FEC_INI=$(date +"%d-%b-%y")
FEC_RESP=$(date "+%d-%m-%y_%H-%M-%S")
NOM_HOST=$(cat /etc/hostname)
IP_ETH0_HOST=$(ifconfig eth0 | grep inet | grep -v inet6 | cut -d ":" -f 2 | cut -d " " -f 1)
NAME_ROOT=root
HOME_ROOT=/root
USER1000_HOST=$(cat /etc/passwd | grep 1000 | cut -d: -f1)
Webmin=$(cat/etc/webmin)

check_priv()
{
    if [ $EUID -ne 0 ] ; then
        err "Para continuar debes ser root"
    fi
}


echo '

# ALMACENAMIENTO DE VARIABLES SOBRE PARAMETROS DE RED
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

' >> auditoria_tecnica_$FEC_INI.txt

PROXY_GATEWAY=$(route -n | sed -n '3p' | awk '{print $2}') ; echo "PROXY/GATEWAY: $PROXY_GATEWAY" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# PROXY / GATEWAY CONFIGURADO EN EL EQUIPO

DOMINIO=$(cat /etc/resolv.conf | sed '2 d' | grep search | sed -n '1p' | awk '{print $2}') ; echo "DOMINIO: $DOMINIO" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# DOMINIO DE RED CONFIGURADO EN EL EQUIPO

IP_SERVIDOR_DNS=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}') ; echo "SERVIDOR DNS: $IP_SERVIDOR_DNS" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# SERVIDOR DNS CONFIGURADO EN EL EQUIPO

# CONEXION_INTERNET=(`if ping -c 1 8.8.8.8 &> /dev/null; then RESULTADO=Habilitado; else RESULTADO=Deshabilitado; fi ; echo $RESULTADO`) ; echo "CONEXION DE INTERNET: $CONEXION_INTERNET" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# ESTATUS DE LA CONEXIÓN A INTERNET

TEST_PING=$(ping 8.8.8.8 -c 5 | grep packet | awk '{print $6}' | cut -f1 -d%) ; echo "VALOR PING: $TEST_PING % de Perdida de paquetes" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# PORCENTAJE DE PERDIDA DE PAQUETES DE LA CONEXIÓN A INTERNET

TEST_LATENCIA_G=$(ping 8.8.8.8 -c 5 | grep packet | awk '{print $10}' | cut -f1 -d%) ; echo "VALOR LATENCIA GLOBAL: $TEST_LATENCIA_G" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# VALOR DE LATENCIA GLOBAL A LA CONEXIÓN A INTERNET

TEST_LATENCIA_P=$(ping 8.8.8.8 -c 1 | grep time= | awk '{print $7}' | sed 's/time=//') ; echo "VALOR LATENCIA PARCIAL: $TEST_LATENCIA_P" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# VALOR DE LATENCIA PARCIAL A LA CONEXIÓN A INTERNET

################################################################################

IP_INTERNA=$(hostname -I) ; echo "IP INTERNA: $IP_INTERNA" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# IP EXTERNA PRINCIPAL DEL EQUIPO

# IP_EXTERNA=$(curl -s ipecho.net/plain;echo) ; echo "IP EXTERNA: $IP_EXTERNA" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# IP EXTERNA PRINCIPAL DEL EQUIPO

IP_ETH0=$(ifconfig eth0 | grep inet | grep -v inet6 | cut -d ":" -f 2 | cut -d " " -f 1) ; echo "IP ETH0: $IP_ETH0" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# IP DE INTERFACE ETH0

MAC_ETH0=$(ifconfig eth0 | sed -n '1p' | awk '{print $5}') ; echo "MAC ETH0: $MAC_ETH0" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# MAC DE INTERFACE ETH0

IP_ETH1=$(ifconfig eth1 | grep inet | grep -v inet6 | cut -d ":" -f 2 | cut -d " " -f 1) ; echo "IP ETH1: $IP_ETH1" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# IP DE INTERFACE ETH0

MAC_ETH1=$(ifconfig eth1 | sed -n '1p' | awk '{print $5}') ; echo "MAC ETH1: $MAC_ETH1" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# MAC DE INTERFACE ETH1

echo '

# ALMACENAMIENTO DE VARIABLES SOBRE PARAMETROS DE CONEXION SSH
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

' >> auditoria_tecnica_$FEC_INI.txt


PUERTO_SSH=$(cat /etc/ssh/sshd_config | egrep '(Port)' | sed '/#/ d' | awk '{print $2}') ; echo "PUERTO SSH: $PUERTO_SSH" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# PUERTO SSH COMFIGURADO PARA EL EQUIPO EN EL PROTOCOLO SSH

# who>/tmp/who ; echo -e "Usuarios conectados al Host :"  && echo "" && echo "Usuarios Puertos      Fecha      Hora  Pantalla" ; echo "*************************************************************************" && cat /tmp/who >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# CHEQUEO DE USUARIO CONECTADOS VIA SSH AL EQUIPO - VERSION LARGA

USUARIOS_CONECTADOS=$(who | awk '{print $1}') ; echo "USUARIOS CONECTADOS: $USUARIOS_CONECTADOS" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# CHEQUEO DE USUARIO CONECTADOS VIA SSH AL EQUIPO - VERSION CORTA

# USER_ONLINE=$(who | awk '{print $1}' | wc -w) ; echo "USUARIOS EN LINEA: $USER_ONLINE" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# CANTIDAD DE USUARIO CONECTADOS VIA SSH - VERSION SIMPLE

# USER_ONLINE2=$(top -n 1 -b | grep "load average:" | awk '{print $6}') ; echo "USUARIOS EN LINEA: $USER_ONLINE2" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# CANTIDAD DE USUARIO CONECTADOS VIA SSH - VERSION COMPLEJA

echo '

# ALMACENAMIENTO DE VARIABLES SOBRE PARAMETROS DE DE CARPETAS DEL SISTEMA
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

' >> auditoria_tecnica_$FEC_INI.txt

NOMBRES_CARPETAS=$(ls -l /home | sed '1 d' | awk '{print $9}') ; echo "CARPETAS DE USUARIOS: $NOMBRES_CARPETAS" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# NOMBRES DE CARPETAS DE USUARIOS CREADOS

NUMERO_CARPETAS=$(ls -l /home | sed '1 d' | awk '{print $9}' | wc -w ) ; echo "N° CARPETAS DE USUARIO: $NUMERO_CARPETAS" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# NUMERO DE CARPETAS DE USUARIOS CREADAS

CARPETA_USUARIO1=$(ls -l /home | sed '1 d' | sort -k2 | sed q | awk '{print $9}') ; echo "CARPETA USUARIO +ARCHIVOS: $CARPETA_USUARIO1" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# USUARIO CON MAS CANTIDAD DE ARCHIVOS EN CARPETA HOME

DATA_USUARIO2=$(du -sh /home/* | sort -r | sed q | awk '{print $1}') ; echo "CARPETA USUARIO +DATA: $DATA_USUARIO2" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# USUARIO CON MAS CANTIDAD DE DATA (TAMAÑO) EN CARPETA HOME

DATA_ROOT=$(du -sh /root | awk '{print $1}') ; echo "TAMAÑO CARPETA /root: $DATA_ROOT" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# TAMAÑO DE LA CARPETA DEL SUPERUSUARIO ROOT

DATA_CARPETA1=$(du -sh /var | awk '{print $1}') ; echo "TAMAÑO CARPETA /var: $DATA_CARPETA1" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# TAMAÑO DE UNA CARPETA PREDEFINIDA. EJEMPLO: /VAR

echo '

# ALMACENAMIENTO DE VARIABLES SOBRE PARAMETROS DE CARGA / PROCESOS / TIEMPOS
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

' >> auditoria_tecnica_$FEC_INI.txt

CARGA_1MIN=$(top -n 1 -b | grep "load average:" | awk '{print $12}' | sed 's/,//2') ; echo "CARGA PROMEDIO 1M: $CARGA_1MIN" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# COMPROBAR CARGA DEL SISTEMA EN 1 MIN

CARGA_5MIN=$(top -n 1 -b | grep "load average:" | awk '{print $13}' | sed 's/,//2') ; echo "CARGA PROMEDIO 5M: $CARGA_5MIN" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# COMPROBAR CARGA DEL SISTEMA EN 5 MIN

CARGA_15MIN=$(top -n 1 -b | grep "load average:" | awk '{print $14}' | sed 's/,//2') ; echo "CARGA PROMEDIO 15M: $CARGA_15MIN" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# COMPROBAR CARGA DEL SISTEMA EN 15 MIN

#CARGA_1MIN=$(uptime | awk '{print $10}' | sed 's/,//2') ; echo $CARGA_1MIN ; echo "CARGA PROMEDIO 1M: $CARGA_1MIN" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# COMPROBAR CARGA DEL SISTEMA EN 1 MIN

#CARGA_5MIN=$(uptime | awk '{print $11}' | sed 's/,//2') ; echo $CARGA_5MIN ; echo "CARGA PROMEDIO 5M: $CARGA_5MIN" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# COMPROBAR CARGA DEL SISTEMA EN 5 MIN

#CARGA_15MIN=$(uptime | awk '{print $12}' | sed 's/,//2') ; echo $CARGA_15MIN ; echo "CARGA PROMEDIO 15M: $CARGA_15MIN" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# COMPROBAR CARGA DEL SISTEMA EN 15 MIN

PROC_ZOMBIE=$(top -n 1 -b | grep "zombie" | awk '{print $10}') ; echo "PROCESOS ZOMBIE: $PROC_ZOMBIE" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# COMPROBAR CANTIDAD DE PROCESOS ZOMBIES

TIEMPO_ENCENDIDO=$(uptime | awk '{print $3,$4}' | cut -f1 -d,) ; echo "TIEMPO DE ENCENDIDO: $TIEMPO_ENCENDIDO" >> auditoria_tecnica_$FEC_INI.txt ; echo "" >> auditoria_tecnica_$FEC_INI.txt
# COMPROBAR TIEMPO DE ENCENDIDO DEL SISTEMA
################################################################################
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
echo "instalando dependencias para la instalacion de $Webmin"
apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python apt-transport-https

echo '#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      #+++++++++++++++++++++++Agregando repositorios+++++++++++++++++++++++++#'
echo "deb http://download.webmin.com/download/repository sarge contrib " | sudo tee /etc/apt/sources.list.d/webmin.list
echo '#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      #+++++++++++++++++++++++Agregando llaves GPG +++++++++++++++++++++++++++#'

wget -o http://www.webmin.com/jcameron-key.asc | apt-key add jcameron-key.asc | apt-get update | apt-get -y install webmin

echo '#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      #+++++++Iniciando  y Verificando Servicio Webmin +++++++++++++++++++++++#'

systemctl start webmin | systemctl status webmin
echo '#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      #+++++++Agregando e Iniciando reglas al Firewall +++++++++++++++++++++++++++++++++++#'

      firewall-cmd --permanent --add-port=10000/tcp | firewall-cmd --reload | systemctl restart firewalld

echo '#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      #++++++++++++Agregando repositorios para Rundder +++++++++++++++++++++++#'


wget --quiet -O- "https://www.rudder-project.org/apt-repos/rudder_apt_key.pub" | sudo apt-key add -

echo "deb http://www.rudder-project.org/apt-4.1/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/rudder.list | apt-get update

echo '#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
      #+++++++++++++instalando Rundder+++++++++++++++++++++++++++++++++++++++++#'

       apt-get install -y rudder-agent






     esac
 done < /dev/tty
