cmake_minimum_required(VERSION 3.16)

project(Mental_krisis_app VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Sql)

qt_standard_project_setup(REQUIRES 6.8)

# Явно добавляем файлы
qt_add_executable(appMental_krisis_app
    main.cpp
    Main.qml
)

# Создаем QML модуль
qt_add_qml_module(appMental_krisis_app
    URI Mental_krisis_app
    VERSION 1.0
    QML_FILES Main.qml
)

# Ищем PostgreSQL
find_package(PostgreSQL)
if(PostgreSQL_FOUND)
    message(STATUS "PostgreSQL found")
    target_link_libraries(appMental_krisis_app
        PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Sql
        PostgreSQL::PostgreSQL
    )
else()
    message(WARNING "PostgreSQL not found")
    target_link_libraries(appMental_krisis_app
        PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Sql
    )
endif()

set_target_properties(appMental_krisis_app PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    WIN32_EXECUTABLE TRUE
)

# Копируем QML файл в директорию сборки
add_custom_command(TARGET appMental_krisis_app POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/Main.qml"
        "${CMAKE_CURRENT_BINARY_DIR}/Main.qml"
    COMMENT "Copying Main.qml to build directory"
)
