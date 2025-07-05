// android/build.gradle.kts (Project-level)

plugins {
    // These might already be here, or you might need to add them based on your project
    // Example: id("com.android.application") version "8.11.0" apply false
    // Example: id("org.jetbrains.kotlin.android") version "1.9.0" apply false

    // THIS IS THE CRUCIAL LINE FOR THE GOOGLE SERVICES PLUGIN
    id("com.google.gms.google-services") version "4.4.1" apply false // Use the latest version
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}