#!/bin/bash

#****
# auto_kernel.sh to program, który pomaga częściowo zautomatyzować tworzenie
# własnej wersji kernela. Wykonując cały program stworzymy i zainstalujemy
# nowy kernel w systemie w taki sposób, że przy następnym uruchomieniu 
# komputera będzie już on dostępny do wyboru z listy istniejących kerneli.
# Program przechodzi przez następujące etapy:
# 1. Instalacja narzędzi wymaganych przy kompilacji jądra
# 2. Pobranie i rozpakowanie kodu jądra w wybranej wersji z linku (użytkownik
# może zmienić domyślny link na swój w zmiennej LINK_DO_KERNELA)
# 3. Utworzenie pliku konfiguracyjnego .config zawierającego ustawienia nowego
# kernela:
#   a. tworzony jest plik domyślny za pomocą polecenia make defconfig
#   b. usuwane są moduły inne, niż te, które ma załadowane użytkownik przy
#   obecnie działającym jądrze 
#   c. plik .config jest oddawany do modyfikacji użytkownikowi
# Uwaga: po stworzeniu pliku .config, jeśli użytkownik chce zostawić kompilację
# na potem, może wyjść w tym momencie z programu (pojawi się pytanie,
# czy kontynuować program). Gdy klient będzie chciał już dokonać kompilacji,
# wystarczy włączyć program ponownie znajdując się w tej samej lokalizacji
# jak poprzednio i odpowiedzieć "n" w opcji nr 3. Opcje 1 i 2 wykonują się
# tylko, jeśli nie zostały wcześniej wykonane w danej lokalizacji, a opcja 3
# zmienia plik .config, dlatego gdy mamy już gotowy ten plik, wystarczy ją
# pominąć, a program przejdzie w stanie takim samym, jak gdy został wyłączony,
# do dalszych kroków.
# 4. Kompilacja kernela - produkuje plik bzImage (skompilowane jądro)
# 5. Kompilacja modułów - kompiluje moduły
# 6. Instalacja modułów - zapisuje moduły do katalogu
# /lib/modules/$WERSJA_KERNELA
# 7. Instalacja końcowa - przenosi plik bzImage, initrd i System.map
# do katalogu /boot zmieniając ich nazwy na odpowiednio 
# vmlinuz-$WERSJA_KERNELA, initrd.img-$WERSJA_KERNELA i
# System.map-$WERSJA_KERNELA
# 8. Aktualizacja bootloadera (grub2)

#zmienne możliwe do modyfikacji wedle potrzeby
FOLDER_GLOWNY="Zabawa-z-kernelem"
KERNEL_SRC_FOLDER="kernel_src"
LINK_DO_KERNELA="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.88.tar.xz"
NOWA_NAZWA_KERNELA="Moj-nowy-kernel1"
ARCHITEKTURA="x86_64"
USTAWIENIA_BOOTLOADERA="/etc/default/grub"

#zmienne pomocnicze
WERSJA_KERNELA=$( printf $LINK_DO_KERNELA | sed 's|.*/||' | sed 's\.tar.xz\\' )
ZMIEN_CONFIG=""
KOMPILUJ=""


printf "\nPobierzmy najpierw narzędzia !\nPobieram...\n"

#narzedzia potrzebne do kompilacji kernela
sudo apt-get install build-essential ncurses-dev xz-utils libssl-dev bc bison flex libelf-dev qt5-default xutils-dev

printf "\nZaczynamy zabawę z: $WERSJA_KERNELA !\n"

mkdir -p $FOLDER_GLOWNY
cd $FOLDER_GLOWNY

#curl - biblioteka do transferu danych z/do serwera z uzyciem wspieranych protokolow, np. pobierania z danego linku pliku
sudo apt-get install curl

mkdir -p $KERNEL_SRC_FOLDER
cd $KERNEL_SRC_FOLDER

#pobieranie kernela (jesli nie ma w folderze jego pliku)
if ! [ -e  "$WERSJA_KERNELA.tar.xz" ]
then
printf "\nPobieram wybrany kernel do ./$FOLDER_GLOWNY/$KERNEL_SRC_FOLDER\n"
curl -O $LINK_DO_KERNELA
fi

#rozpakowanie kernela
if ! [ -d "$WERSJA_KERNELA" ]
then
printf "\nRozpakowuję kernel\n"
tar xf "$WERSJA_KERNELA.tar.xz"
fi

#link symboliczny do ladnieszej nazwy linux
ln -s ./$WERSJA_KERNELA ./linux
cd ./linux

#modyfikacje pliku .conf
printf "\nCzy chcesz stworzyć nowy plik konfiguracyjny (.config)? (T/n)\n"
read ZMIEN_CONFIG

if [ $ZMIEN_CONFIG = "T" ]
then
printf "\nGeneruję domyślną konfigurację do pliku .conf dla arch=$ARCHITEKTURA\n"
make ARCH=$ARCHITEKTURA defconfig
#printf "\nWyłączam większość niepotrzebnych modułów i ładuję tylko te, które są załadowane w aktualnie włączonym kernelu\n"
#make localmodconfig
fi

printf "\nCzy chcesz zmodyfikować plik konfiguracyjny (.config)? (T/n)\n"
read ZMIEN_CONFIG
while [ $ZMIEN_CONFIG = "T" ]
do
printf "\nProszę wprowadzić ręcznie pozostałe ustawienia\n"
make xconfig
printf "\nCzy chcesz zmodyfikować plik konfiguracyjny (.config)? (T/n)\n"
read ZMIEN_CONFIG
done

printf "\nCzy chcesz teraz skompilować kernel i moduły? (T/n) (Odpowiedź 'n' wyłączy program. Aby wrócić do obecnego stanu tworzenia kernela wystarczy go włączyć ponownie z tego samego katalogu, w jakim został uruchomiony teraz)\n"
read KOMPILUJ
if [ $KOMPILUJ = 'n' ]
then
exit 0
fi

#zmiana nazwy kernela na wybrana przez użytkownika
printf "\nZmieniam EXTRAVERSION w Makefile na nową nazwę jądra: $NOWA_NAZWA_KERNELA\n"
sed -i "/EXTRAVERSION =/c\EXTRAVERSION = $NOWA_NAZWA_KERNELA" Makefile
printf "\nOd teraz w uname -a powinno się pojawiać $NOWA_NAZWA_KERNELA :>\n"

#kompilacja jądra
printf "\nZaczynamy kompilację!\nBuduję zależności\nCzyszczę śmieci\nKompiluję kernel!\n"
makedepend
make clean
time make -j4 bzImage

#kompilacja i instalacja modułów - skopiowanie modułów do /lib/modules
printf "\nCzas skompilować moduły !\n"
time make -j4 modules
sudo make -j4 modules_install

#instalacja całości - skopiowanie pliku jądra, initrd i System.map do /boot
sudo make install

#aktualizacja bootloadera i włączanie pokazywania okna wyboru kerneli przy uruchamianiu
sudo sed -i '/GRUB_TIMEOUT_STYLE=/c\#GRUB_TIMEOUT_STYLE=' $USTAWIENIA_BOOTLOADERA
sudo sed -i '/GRUB_TIMEOUT=/c\GRUB_TIMEOUT=-1' $USTAWIENIA_BOOTLOADERA

sudo update-grub





