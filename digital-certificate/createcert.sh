#!/bin/bash
#
# Software: createcert.sh
# Description: Create private key
# Requiriment: openssl (apt-get install openssl)
#
# Gabriel Richter <gabrielrih@gmail.com>
#
# Criation Date:	2015-10-20
# Last Modification:	2015-10-20
#

uso="USAGE: $0 [option] [arg1] [arg2] [arg3]

option:
	[-c | --criar]		Criar certificado digital com chave publica e privada.
	[-a | --assinar]	Assinar um documento a partir de um certificado digital.
	[-v | --verificar]	Verificar assinatura de um arquivo.
	[-h | --help]	Mostra essa ajuda.

arg1:
	Com a opcao [criar] esse parametro sera o nome do arquivo que sera criado.
	Com a opcao [assinar] esse parametro sera o certificado utilizado. OBS: Com extensao .pem
	Com a opcao [verificar] esse parametro sera o arquivo contendo a chave publica para verificar assinatura.

arg2:
	Com a opcao [assinar] nome do arquivo de saida (contera a assinatura).
	Com a opcao [verificar] nome do arquivo assinado.

arg3:
	Com a opcao [assinar] nome do arquivo a ser assinado.
	Com a opcao [verificar] nome do arquivo original.


Exemplos de uso:
	$0 --criar certificado
	$0 --assinar certificado.pem arquivo.sig arquivo.txt
	$0 --verificar certificao.pub arquivo.sig arquivo.txt
"

case $1 in

	# Criar certificado digital
	-c | --criar)

			# Se não recebeu dois parâmetros cai fora
			if [ $# != 2 ]
			then
				echo "$uso"
				echo ""
				echo "ERRO: Faltam parametros obrigatorios!"
				exit 1
			fi

			certificado=$2.pem
			arqchavepub=$2.pub
			tamanho=1024

			# Criar um certificado digital
			openssl genrsa -out $certificado $tamanho

			echo "$(date +%R:%S) Criando certificado digital...........................[OK]"

			# Extrai a chave pública do arquivo
			openssl rsa -pubout -in $certificado -out $arqchavepub

			echo "$(date +%R:%S) Exportando chave publica.........................[OK]"

	;;

	# Assinar um documento
	-a | --assinar)

			# Se não recebeu 4 parâmetros cai fora
			if [ $# != 4 ]
			then
				echo "$uso"
				echo ""
				echo "ERRO: Faltam parametros obrigatorios!"
				exit 1
			fi

			# Atribui parâmetros
 			certificado=$2
			arquivooriginal=$4
			arquivoassinado=$3

			# Verifica se os arquivos informados existem
			if [ ! -f $certificado ]
			then
				echo "$(date +%R:%S) Arquivo $certificado nao existe!"
				exit 1
			fi

			if [ ! -f $arquivooriginal ]
			then
				echo "$(date +%R:%S) Arquivo $arquivooriginal nao existe!"
				echo "$(date +%R:%S) Nao foi possivel criar assinatura."
				exit 1
			fi

			# Assinar arquivo
			openssl sha1 -sign $certificado -out $arquivoassinado $arquivooriginal

			echo "$(date +%R:%S) Assinando $arquivooriginal.........................[OK]"
	;;

	# Verificar assinatura
	-v | --verificar)

			# Se não recebeu 4 parâmetros cai fora
			if [ $# != 4 ]
			then
				echo "$uso"
				exit 1
			fi

			# Atribui parâmetros
			chavepublica=$2
			arquivoassinado=$3
			arquivooriginal=$4

			# Verificar existência de arquivos
			if [ ! -f $chavepublica ]
			then
				echo "$(date +%R:%S) Arquivo $chavepublica nao existe!"
                                echo "$(date +%R:%S) Nao foi possivel verificar assinatura."
				exit 1
			fi

                        if [ ! -f $arquivoassinado ]
                        then
                                echo "$(date +%R:%S) Arquivo $arquivoassinado nao existe!"
                                echo "$(date +%R:%S) Nao foi possivel verificar assinatura."
                                exit 1
                        fi

                        if [ ! -f $arquivooriginal ]
                        then
                                echo "$(date +%R:%S) Arquivo $arquivooriginal nao existe!"
                                echo "$(date +%R:%S) Nao foi possivel verificar assinatura."
                                exit 1
                        fi

                        # Verificar assinatura de arquivo
                        openssl sha1 -verify $chavepublica -signature $arquivoassinado $arquivooriginal

	;;

	-h | --help )
			echo "$uso"
			exit 0
	;;
	# Mostrar ajuda
	*)
			echo "$uso"

			if [ ! -f $1 ]
	                then
                	        echo ""
        	                echo "ERRO: Parametro $1 não existe!"
	                fi

			exit 1
	;;

esac

exit 0
