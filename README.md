# atmega328p-cxx-template
This project template uses Conan and CMake to provide a preconfigured project environment

![Build Status](https://github.com/Zombieanfuehrer/atmega328p-cxx-template/actions/workflows/build.yml/badge.svg)
![License](https://img.shields.io/github/license/Zombieanfuehrer/atmega328p-cxx-template)
![Conan](https://img.shields.io/badge/conan-2-blue)
![CMake](https://img.shields.io/badge/cmake-3.20.0-blue)
![GitHub issues](https://img.shields.io/github/issues/Zombieanfuehrer/atmega328p-cxx-template)
![GitHub stars](https://img.shields.io/github/stars/Zombieanfuehrer/atmega328p-cxx-template)

## Projektbeschreibung

Bei diesem Projekt handelt es sich um ein GitHub-Template für die AVR-ATmega Mikrocontroller Familie.
Dieses Basis Projekt implentiert DevOps Grundlagen und untersützt eine einfache Integration von Libraries in andere Projekte durch Conan.
Als Buildtool wird CMake eingesetzt welches eine einfache Build-Konfiguration  über Conan, in Form von CMake Presets unterstützt.
Dieses Projekt soll Programmier Anfängern, aber auch fortgeschrittenen eine grundlegende Basis bieten um moderne Software-Entwicklung unter C/C++ zu betreiben.

## Voraussetzungen

Für die Nutzung dieses Tempalte sind folgende Vorrausetzungen zu beachten:
- Linux, WSL oder entsprechender Container.
- Installierte __avr-gcc toolchain__ [download avr-gcc](https://www.microchip.com/en-us/tools-resources/develop/microchip-studio/gcc-compilers "avr-gcc toolchain downloads from microchip.com")

```sh
# Beispiel Installation 8-Bit Toolchain z.b. ATmega328p

# Download with wget
cd /opt/ && wget https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/avr8-gnu-toolchain-3.7.0.1796-linux.any.x86_64.tar.gz
# Alternativ kann auch curl genutzt werden 
cd /opt/ && curl -O https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/avr8-gnu-toolchain-3.7.0.1796-linux.any.x86_64.tar.gz
# Archiv mit tar entpacken
tar -C ./ -xf ./avr8-gnu-toolchain-3.7.0.1796-linux.any.x86_64.tar.gz
# Besitzer Rechte entsprechend setzten
chown -R root:root /opt/avr8-gnu-toolchain-linux_x86_64
```

- __CMake__ min. Version 3.20
```sh
# Installation von CMake
sudo apt-get install -y cmake
```
- __Python3__ inklusive venv und pip
```sh
# Installation von Python3, venv und pip
sudo apt-get install -y python3 python3-venv python3-pip
```
- __Doxygen__ optinal mit Graphviz
```sh
# Installation von Doxygen und Graphviz
sudo apt-get install -y doxygen graphviz
```
- __Conan__ >= Version 2.0
```sh
# Conan wird automatisch über das CMake Projekt hinzugefügt, über die ./requirements.txt
# Soll es dennoch manuell auch außerhalb dieses Projekts verwendet werden wird empfolen conan über ein virtuelles python enviroment zu installieren
python3 -m venv <name_of_virtual_env> <target_path>
source  <name_of_virtual_env>/bin/activate
pip install conan
# Alternativ direkt installation von Conan
pip install conan
```
- __Conan profiles__  Background [conan introduction to profiles](https://docs.conan.io/2/reference/config_files/profiles.html "conan 2 profile documentation")
Nach der Installation von conan benötigen wir für den Cross-Compile-Prozess über conan -> cmake -> avr-gcc toolchain entsprechende conan profile um das enviroment zu setzen und zu übergeben.
Um dieses conan feature nutzten zu können müssen wir ein default profile erzeugen:
```sh
# Create default conan profile with default name
conan profile detect
```
> __Hinweis:__ In der Regel befindet sich das angelegte Profile unter: *~/.conan2/profiles/default*

Um nun die spezifischen Conan Profile für den ATmega328p zu nutzten können diese aus [diesem repo](https://github.com/Zombieanfuehrer/conan-profiles-linux "conan 2 Zombieanfuehrer/conan-profiles-linux")
heruntergeladen und in den Ordner */.conan2/profiles/* kopiert werden.
__avr-mega328p__: Ist das Profil um einen Release-Build zu erzeugen.
__avr-mega328p_g__: Ist das Profil um einen Debug-Build zu erzeugen.

## Build-Anleitung

Der einfachste Weg das Projekt zu bauen und daüber aufzusetzten um auf dieser Basis eigene Projekte zu entwickeln ist der Build über conan install.

```sh
# conan install im Projektverzeichnis ausführen oder in referenz zum conanfile.py
conan install . --build=missing -pr:h=avr-mega328p_g
# shell enviroment mit entsprechenden, von conan definierten Varaiblen, setzten
. build/Debug/generators/conanbuild.sh
# cmake preset setzten, definition aus conanfile.py.
# um das build enviroment und compiler / linker flags an cmake zu übergeben
cmake --preset conan-generated-avr-debug
# build prozess über cmake starten (build/Debug legt das zielverzeichnis für die binaries und Artefacte fest)
cmake --build build/Debug
```
Bei einem Release Build ist entsprechend das conan profil zu ändern, sowie die preset und verzeichnisnamen.
Anschließend kann das Projekt über eine IDE der Wahl wie z.b. VSCode bearbeitet werden.
Über ein CMake Plugin können die weiteren Targets in der IDE ausgeführt werden, dies geht aber ebenso über die Shell.

Alternativ kann das Projekt auch direkt über CMake konfiguriert werden, allerdings hebelt dies den Gedanken Conan als Build-Interface zu nutzten aus.

```sh
# Build Verzeichnis anlegen und in dieses wechseln
mkdir build
cd build
# Cmake configure ausführen ./CMakeLists.txt
cmake ..
# CMake preset laden
cmake --preset conan-generated-avr-debug
# build prozess über cmake starten (build/Debug legt das zielverzeichnis für die binaries und Artefacte fest)
cmake --build build/Debug
```

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert. Weitere Informationen finden Sie in der [LICENSE](LICENSE)-Datei.