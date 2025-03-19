# Security Questions

## How is the connection between client and server encrypted?

Seafile uses HTTP(S) to syncing files between client and server (Since version 4.1.0).

## Encrypted Library

Seafile provides a feature called encrypted library to protect your privacy. The file encryption/decryption is performed on client-side when using the desktop client for file synchronization. The password of an encrypted library is not stored on the server. Even the system admin of the server can't view the file contents.

There are a few limitation about this feature:

1. File metadata is NOT encrypted. The metadata includes: the complete list of directory and file names, every files size, the history of editors, when, and what byte ranges were altered.
2. The client side encryption does currently NOT work while using the web browser and the cloud file explorer of the desktop client. When you are browsing encrypted libraries via the web browser or the cloud file explorer, you need to input the password and the server is going to use the password to decrypt the "file key" for the library (see description below) and cache the password in memory for one hour. The plain text password is never stored or cached on the server.
3. If you create an encrypted library on the web interface, the library password and encryption keys will pass through the server. If you want end-to-end protection, you should create encrypted libraries from desktop client only.
4. For encryption protocol version 4, each library use its own salt to derive key/iv pairs. However, all files within a library shares the same salt. Likewise, all the files within a library are encrypted with the same key/iv pair. With encryption protocol version 2, all libraries use the same salt, but separate key/iv pairs.
5. Encrypted library doesn't ensure file integrity. For example, the server admin can still partially change the contents of files in an encrypted library. The client is not able to detect such changes to contents.

The client side encryption works on iOS client since version 2.1.6. The Android client support client side encryption since version 2.1.0. But since version 3.0.0, the iOS and Android clients drop support for client side encryptioin. You need to send the password to the server to encrypt/decrypt files.

## How does an encrypted library work?

When you create an encrypted library, you'll need to provide a password for it. All the data in that library will be encrypted with the password before uploading it to the server (see limitations above).

### Encryption/Decryption procedure

There are currently two supported encryption protocol versions for encrypted libraries, version 2 and versioin 4. The two versions shares the same basic procedure so we first describe the procedure.

1. Generate a 32-byte long cryptographically strong random number. This will be used as the file encryption key ("file key").
2. Encrypt the file key with the user provided password. We first use a secure hash algorithm to derive a key/iv pair from the password, then use AES 256/CBC to encrypt the file key. The result is called the "encrypted file key". This encrypted file key will be sent to and stored on the server. When you need to access the data, you can decrypt the file key from the encrypted file key.
3. A "magic token" is derived from the password and library id, with the same secure hash algorithm. This token is stored with the library and will be use to check passwords before decrypting data later.
4. All file data is encrypted by the file key with AES 256/CBC. We use PBKDF2-SHA256 with 1000 iterations to derive key/iv pair from the file key. After encryption, the data is uploaded to the server.

The only difference between version 2 and version 4 is on the usage of salt for the secure hash algorithm. In version 2, all libaries share the same fixed salt. In version 4, each library will use a separate and randomly generated salt.

### Secure hash algorithms for password verification

A secure hash algorithm is used to derive key/iv pair for encrypting the file key. So it's critical to choose a relatively costly algorithm to prevent brute-force guessing for the password.

Before version 12, a fixed secure hash algorithm (PBKDF2-SHA256 with 1000 iterations) is used, which is far from secure for today's standard.

Since Seafile server version 12, we allow the admin to choose proper secure hash algorithms. Currently two hash algorithms are supported.

* PBKDF2: The only available parameter is the number of iterations. You need to increase the the number of iterations over time, as GPUs are more and more used for such calculation. The default number of iterations is 1000. As of 2023, the recommended iterations is 600,000.
* Argon2id: Secure hash algorithm that has high cost even for GPUs. There are 3 parameters that can be set: time cost, memory cost, and parallelism degree. The parameters are seperated by commas, e.g. "2,102400,8", which the default parameters used in Seafile. Learn more about this algorithm on https://github.com/P-H-C/phc-winner-argon2 .

### Client-side encryption and decryption

The above encryption procedure can be executed on the desktop and the mobile client. The Seahub browser client uses a different encryption procedure that happens at the server. Because of this your password will be transferred to the server.

When you sync an encrypted library to the desktop, the client needs to verify your password. When you create the library, a "magic token" is derived from the password and library id. This token is stored with the library on the server side. The client use this token to check whether your password is correct before you sync the library. The magic token is generated by the secure hash algorithm chosen when the library was created.

For maximum security, the plain-text password won't be saved on the client side, too. The client only saves the key/iv pair derived from the "file key", which is used to decrypt the data. So if you forget the password, you won't be able to recover it or access your data on the server.

## Why fileserver delivers every content to everybody knowing the content URL of an unshared private file?

When a file download link is clicked, a random URL is generated for user to access the file from fileserver. This url can only be access once. After that, all access will be denied to the url. So even if someone else happens to know about the url, he can't access it anymore.

This was changed in Seafile server version 12. Instead of a random URL, a URL like 'https://yourserver.com/seafhttp/repos/{library id}/file_path' is used for downloading the file. Authorization will be done by checking cookies or API tokens on the server side. This makes the URL more cache-friendly while still being secure.

## How does Seafile store user login password?

User login passwords are stored in hash form only. Note that user login password is different from the passwords used in encrypted libraries. In the database, its format is

```
PBKDF2SHA256$iterations$salt$hash
```

The record is divided into 4 parts by the $ sign.

- The first part is the used hash algorithm. Currently we use PBKDF2 with SHA256. It can be changed to an even stronger algorithm if needed.
- The second part is the number of iterations of the hash algorithm
- The third part is the random salt used to generate the hash
- The fourth part is the final hash generated from the password

To calculate the hash:

- First, generate a 32-byte long cryptographically strong random number, use it as the salt.
- Calculate the hash with `PBKDF2(password, salt, iterations)`. The number of iterations is currently 10000.
