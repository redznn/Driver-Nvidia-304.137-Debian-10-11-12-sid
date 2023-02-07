#!/usr/bin/env bash
#===========================================#
#script pra instala o driver nvidia 304.137 
#feito por Flydiscohuebr
#===========================================#

#testes
#Verificando se e ROOT!
#==========================#
[[ "$UID" -ne "0" ]] && { echo -e "Necessita de root para executar o programa. \nexecute o comando logado como usuario root usando o comando su - \nou usando o comando sudo ex: sudo ./instalador.sh" ; exit 1 ;}
#==========================#

#verificando se tem interwebs
#=====================================================#
if ! wget -q --spider www.google.com; then
    echo "Não tem internet..."
    echo "Verifique se o cabo de rede esta conectado."
    exit 1
fi
#=====================================================#

echo '
-----------------------------------------------------------------------
        Instalador não oficial do Driver NVidia 304-137
-----------------------------------------------------------------------
'

echo '
Devido a esse script ter sido baseado especialmente para o Debian GNU/Linux
os repositorios contrib e non-free precisam ser ativados principalmente se
você instalou utilizando os cds e dvds sem os firmwares (non-free)nao livres.

Como esse script pode ser usado em outras distros baseadas no Debian em geral como
por ex: (MX Linux/AntiX, Q4OS, SparkyLinux, BunsenLabs e etc.) esses repositorios ja podem
estar ativados por padrão.

Deseja que os repositorios "contrib" e "non-free" 
sejam adicionados automaticamente?

OBS: Caso esteja em duvida veja o arquivo em /etc/apt/sources.list
com o comando cat /etc/apt/sources.list
é verifique se esse arquivo existe e esta com esses repositorios ativado
(Se você acabou de instalar o Debian por meio dos cds/dvds livres provavelmente somente o main vai estar ativado)

Se estiver com duvidas esses links vão ser uteis
https://wiki.debian.org/pt_BR/SourcesList#Exemplo_sources.list
https://linuxdicasesuporte.blogspot.com/2020/12/habilitar-os-repositorios-contrib-non.html

Responda S para que os repositorios sejam colocados automaticamente 
e N se esses repositorios ja estiverem ativados
e aperte ctrl+c para sair
'

read -p "[S/N?] " resp1
resp1=${resp1^^}
if [[ "$resp1" = "S" ]]; then
sudo sed -i 's/main/main contrib non-free/' /etc/apt/sources.list
echo "contrib e non-free adicionados com sucesso"
fi
echo "continuando"

echo '
-----------------------------------------------------------------------
        Instalador não oficial do Driver NVidia 304-137
        Suportando Debian 10/11/12/testing/sid e derivados
        Testado no kernel 6.0
        By: Flydiscohuebr

        Problemas Durante a Instalação? Chame no telegram
        @Flydiscohuebr
        Ou deixe no comentario do video :)
        https://www.youtube.com/@flydiscohuebr
-----------------------------------------------------------------------
'

#removendo pacotes inuteis que vai atrapalhar no downgrade do xorg
#especificamente MX Linux/AntiX e seus derivados/refisefuqui?
echo "removendo pacotes conflitantes"
sudo apt remove \
virtualbox-guest-x11 \
xserver-xorg-video-cirrus \
xserver-xorg-video-mach64 \
xserver-xorg-video-mga \
xserver-xorg-video-neomagic \
xserver-xorg-video-r128 \
xserver-xorg-video-savage \
xserver-xorg-video-siliconmotion \
xserver-xorg-video-sisusb \
xserver-xorg-video-tdfx \
xserver-xorg-video-trident

sudo dpkg --add-architecture i386 #habilitando o multiarch

sudo apt update && sudo apt upgrade -y || { echo "falha ao atualizar pacotes. Tente novamente" ; exit 1; } #atualizando o sistema antes de continuar

#instalando o nvidia-xconfig
sudo apt install nvidia-xconfig --no-install-recommends --no-install-suggests -y
#verificando se o nvidia-xconfig foi Instalado com sucesso
[[ $(type -P nvidia-xconfig) ]] || { echo "Falha ao instalar o nvidia-xconfig. Tente novamente" ; exit 1 ;} 

#fazendo downgrade do xorg pra versao 1.19
#pacotes são do debian 9 stretch 
#foram baixados pelo site https://packages.debian.org/stretch/x11/
cd $PWD/xorg
sudo apt install ./*.deb || { echo "O downgrade do Xorg falhou. Tente novamente" ; exit 1; }
sudo apt-mark hold xserver-xorg-core
cd ../

#detectando a verção e instalando o pacote nvidia-kernel-common compativel
if [[ $(cat /etc/debian_version) = "bookworm/sid" ]] || [[ $(cat /etc/debian_version) = "bookworm" ]]; then
    echo "Debian 12(bookworm)/testing/sid detectado"
    cd $PWD/utils
    sudo apt install ./nvidia-kernel-common_20151021+13_amd64.deb
    sudo apt install ./xserver-xorg-input-libinput_1.1.0-1_amd64.deb
    cd ../
    sudo apt-mark hold xserver-xorg-input-libinput
fi

#instalação do driver
#com patches aplicados para funcionar com kernels mais recentes
#https://github.com/flydiscohuebr/NVIDIA-Linux-304.137-patches
cd $PWD/driver
sudo apt install ./*.deb || { echo "A instalação do driver falhou. Desfazendo alterações" ; sudo apt remove \
libgl1-nvidia-legacy-304xx-glx \
libnvidia-legacy-304xx-cfg1 \
libnvidia-legacy-304xx-cfg1:i386 \
libnvidia-legacy-304xx-glcore \
libnvidia-legacy-304xx-ml1 \
nvidia-legacy-304xx-alternative \
nvidia-legacy-304xx-driver \
nvidia-legacy-304xx-driver-bin \
nvidia-legacy-304xx-driver-libs \
nvidia-legacy-304xx-driver-libs:i386 \
nvidia-legacy-304xx-kernel-dkms \
nvidia-legacy-304xx-kernel-support \
nvidia-legacy-304xx-vdpau-driver \
nvidia-settings-legacy-304xx \
xserver-xorg-video-nvidia-legacy-304xx -y ; echo "Tente a instalação novamente" ; exit 1; }

#impedindo pacotes de serem atualizados
sudo apt-mark hold \
libgl1-nvidia-legacy-304xx-glx \
libnvidia-legacy-304xx-cfg1 \
libnvidia-legacy-304xx-cfg1:i386 \
libnvidia-legacy-304xx-glcore \
libnvidia-legacy-304xx-ml1 \
nvidia-legacy-304xx-alternative \
nvidia-legacy-304xx-driver \
nvidia-legacy-304xx-driver-bin \
nvidia-legacy-304xx-driver-libs \
nvidia-legacy-304xx-driver-libs:i386 \
nvidia-legacy-304xx-kernel-dkms \
nvidia-legacy-304xx-kernel-support \
nvidia-legacy-304xx-vdpau-driver \
nvidia-settings-legacy-304xx \
xserver-xorg-video-nvidia-legacy-304xx 

sudo nvidia-xconfig #criando arquivo xorg.conf

echo '
Instalação concluida com sucesso
reinicie o computador agora
qualquer problema ou duvidas futuras
Telegram: @Flydiscohuebr
ou escreva um comentario no video que vc baixou isso :)
'
