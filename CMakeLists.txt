cmake_minimum_required(VERSION 3.16)

project(Mental_krisis_app VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Sql)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appMental_krisis_app
    main.cpp
)

qt_add_qml_module(appMental_krisis_app
    URI Mental_krisis_app
    VERSION 1.0
    QML_FILES Main.qml
)

# Для Android
if(ANDROID)
    find_library(log-lib log)
    target_link_libraries(appMental_krisis_app
        PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Sql
        ${log-lib}
    )

    # Разрешения для Android
    set_target_properties(appMental_krisis_app PROPERTIES
        QT_ANDROID_APP_PERMISSIONS "android.permission.INTERNET;android.permission.WRITE_EXTERNAL_STORAGE;android.permission.READ_EXTERNAL_STORAGE"
    )
else()
    # Для десктопа
    find_package(PostgreSQL)
    if(PostgreSQL_FOUND)
        target_link_libraries(appMental_krisis_app
            PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Sql
            PostgreSQL::PostgreSQL
        )
        message(STATUS "PostgreSQL found")
    else()
        target_link_libraries(appMental_krisis_app
            PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Sql
        )
        message(WARNING "PostgreSQL not found, using SQLite only")
    endif()
endif()

set_target_properties(appMental_krisis_app PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    WIN32_EXECUTABLE TRUE
)
