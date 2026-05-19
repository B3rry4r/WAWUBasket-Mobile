allprojects {
    repositories {
        google()
        mavenCentral()
        // Mapbox SDK is served from a private Maven repo. The password is
        // a SECRET download token (sk.* with DOWNLOADS:READ scope) — NOT
        // the public pk.* runtime token. Supply it via the
        // MAPBOX_DOWNLOADS_TOKEN gradle property
        // (~/.gradle/gradle.properties locally) or the same-named
        // environment variable (CI).
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication { create<BasicAuthentication>("basic") }
            credentials {
                username = "mapbox"
                password = (project.findProperty("MAPBOX_DOWNLOADS_TOKEN")
                    ?: System.getenv("MAPBOX_DOWNLOADS_TOKEN")
                    ?: "") as String
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
