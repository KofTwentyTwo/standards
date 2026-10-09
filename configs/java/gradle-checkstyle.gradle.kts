// KofTwentyTwo Checkstyle enforcement for Gradle (K22-CODE-JV-02).
// Add to build.gradle.kts. `gradle check` (CI) and every local build fail on a violation.
plugins {
   java
   checkstyle
}

checkstyle {
   toolVersion = "14.3.0"
   configFile = rootProject.file("checkstyle/checkstyle.xml")
   isIgnoreFailures = false
   maxWarnings = 0
}

tasks.withType<Checkstyle>().configureEach {
   reports {
      xml.required.set(true)
      html.required.set(false)
   }
}
