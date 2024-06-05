from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout


class Atmega328TemplateRecipe(ConanFile):
    name = "Atmega328Template"
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
    exports_sources = "CMakeLists.txt", "*.cmake", "app/*", "src/*"
    generators = "CMakeDeps"

    def requirements(self):
        if (self.options.platform == 'linux'):
            self.requires("gtest/1.14.0")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.presets_prefix = "conan-generated" + str(self.options.platform)
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build(target="ATmega328__T_LIB")
        cmake.build(target="ATmega328__T_")

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["Atmega328Template"]
