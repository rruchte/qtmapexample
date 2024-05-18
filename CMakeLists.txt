cmake_minimum_required(VERSION 3.28)
project(qtmap)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

find_package(Qt6 REQUIRED COMPONENTS
        Core
        Gui
        Widgets
        Location
        QuickWidgets)

add_executable(qtmap
        main.cpp
        mainwindow.h
        mainwindow.cpp
        qtmap.qrc)

target_link_libraries(qtmap
        PRIVATE
        Qt::Core
        Qt::Gui
        Qt::Widgets
        Qt::QuickWidgets
        Qt::Location
)

