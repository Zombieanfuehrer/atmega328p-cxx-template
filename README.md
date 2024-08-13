# atmega328p-cxx-template
This project template uses Conan and CMake to provide a preconfigured project environment

[Build Status](https://github.com/Zombieanfuehrer/atmega328p-cxx-template/actions/workflows/build.yml/badge.svg)
![License](https://img.shields.io/github/license/Zombieanfuehrer/atmega328p-cxx-template)
![Conan](https://img.shields.io/badge/conan-2-blue)
![CMake](https://img.shields.io/badge/cmake-3.20.0-blue)
![GitHub issues](https://img.shields.io/github/issues/Zombieanfuehrer/atmega328p-cxx-template)
![GitHub stars](https://img.shields.io/github/stars/Zombieanfuehrer/atmega328p-cxx-template)

## Projektbeschreibung

Bei diesem Projekt handelt es sich um ein GitHub-Template für die AVR-ATmega Mikrocontroller Familie.

Es nutzt CMake als Buildtool und bindet Conan als Package- und Dependency-Management-Tool ein.

## Voraussetzungen

Für den Build sind folgende Voraussetzungen erforderlich:
- Installierte `avr-gcc` Toolchain
- Installierte Version von Python inklusive `venv` und `pip`
- Eine Version von Conan >= 2

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