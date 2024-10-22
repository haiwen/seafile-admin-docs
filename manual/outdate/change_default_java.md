
When you have both Java 6 and Java 7 installed, the default Java may not be Java 7.

Do this by typing `java -version`, and check the output.

- If the output is like **"java version "1.7.0_xx"**, then the default Java is Java 7, which is good.
- If the output is like **"java version "1.6.0_xx"**, then the default Java is Java 6, we need to configure default Java to Java 7.

If the default Java is Java 6, then do

On Debian/Ubuntu:
```
sudo update-alternatives --config java
```

On CentOS/RHEL:
```
sudo alternatives --config java
```

The above command will ask you to choose one of the installed Java versions as default. You should choose Java 7 here.

After that, re-run `java -version` to make sure the change has taken effect.

[Reference link](http://unix.stackexchange.com/questions/35185/installing-openjdk-7-jdk-does-not-update-java-which-is-still-version-1-6)
