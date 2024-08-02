import os
from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout


class Atmega328TemplateRecipe(ConanFile):
    name = "atmega328_template"
    version = "1.0.0"

    # Optional metadata
    license = "MIT"
    author = "David A. Haufe"
    url = "https://github.com/Zombieanfuehrer/atmega328p-cxx-template"
    description = "Just a simple conan + cmake project to support the atmega328p"
    topics = ("avr")

    # Binary configuration
    settings = "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False], "platform": ["avr", "linux"]}
    default_options = {"shared": False, "fPIC": False, "platform": "avr"}

    # Sources are located in the same place as this recipe, copy them to the recipe
    exports_sources = "CMakeLists.txt", "*.cmake", "app/*", "src/*", "public/*", "private/*","style/*", "docs/Doxyfile", "configure/*"

    def requirements(self):
        self.build_requires("cmake/[>=3.28.0]")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.presets_prefix = "conan-generated-" + str(self.options.platform)
        tc.generate()

    def build(self):
        cmake = CMake(self)
        build_type = str(self.settings.build_type)
        arch = str(self.settings.arch)

        # build folder name not working
        build_folder_name = f"build/{build_type}-{arch}"
        self.output.info(f"Build folder: {build_folder_name}")

        cmake.configure()
        
        cmake.build(target="ATmega328__T_LIB")
        cmake.build(target="ATmega328__T_")

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        pass