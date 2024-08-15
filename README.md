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
# Alternativ kann auch vurl genutzt werden 
cd /opt/ && curl -O https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/avr8-gnu-toolchain-3.7.0.1796-linux.any.x86_64.tar.gz
# Archiv mit tar entpacken
tar -C ./ -xf ./avr8-gnu-toolchain-3.7.0.1796-linux.any.x86_64.tar.gz
# Besitzer Rechte entsprechend setzten
chown -R root:root /opt/avr8-gnu-toolchain-linux_x86_64
```

- __CMake__ min. Version 3.20
```sh
# Installation von CMake
sudo apt-get update
sudo apt-get install -y cmake
```
- __Python3__ inklusive venv und pip
```sh
# Installation von Python3, venv und pip
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip
```
- __Doxygen__ optinal mit Graphviz
```sh
# Installation von Doxygen und Graphviz
sudo apt-get update
sudo apt-get install -y doxygen graphviz
```
- __Conan__ >= Version 2.0
```sh
# Installation von Conan
sudo apt-get update
pip install conan
```

## Installation

1. Installieren Sie die `avr-gcc` Toolchain.
2. Installieren Sie Python und die benötigten Pakete:
    ```sh
    sudo apt-get install python3 python3-venv python3-pip
    ```
3. Installieren Sie Conan:
    ```sh
    pip install conan
    ```

## Build-Anleitung

1. Klonen Sie das Repository:
    ```sh
    git clone https://github.com/Zombieanfuehrer/atmega328p-cxx-template.git
    cd atmega328p-cxx-template
    ```
2. Erstellen Sie ein virtuelles Python-Umfeld und aktivieren Sie es:
    ```sh
    python3 -m venv venv
    source venv/bin/activate
    ```
3. Installieren Sie die Conan-Abhängigkeiten:
    ```sh
    conan install . --profile myprofile --build=missing
    ```
4. Konfigurieren und bauen Sie das Projekt mit CMake:
    ```sh
    cmake -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -S . -B build
    cmake --build build
    ```

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert. Weitere Informationen finden Sie in der [LICENSE](LICENSE)-Datei.