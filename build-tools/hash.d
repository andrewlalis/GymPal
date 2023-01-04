/** 
 * Helper for hashing the content of source files to determine if we need to
 * re-compile certain sources.
 */
module hash;

import std.stdio;
import std.file;
import std.string;
import std.digest.md;
import std.base64;

const HASH_FILE = "bin/hash.txt";

/** 
 * Determines if the content of the source file at the given path matches
 * the hash we have for it (if possible).
 * Params:
 *   sourcePath = The path to the source file.
 * Returns: True if we have a hash for the source file, and it matches the
 * current hash of the file contents. False if we don't have a hash or it
 * doesn't match.
 */
bool contentMatchesHash(string sourcePath) {
    if (!exists(sourcePath) || !isFile(sourcePath)) return false;
    string[string] hashes = readHashes();
    if (sourcePath !in hashes) return false;
    ubyte[16] rawHash = md5Of(readText(sourcePath));
    ubyte[] savedHash = Base64.decode(hashes[sourcePath]);
    return rawHash == savedHash;
}

/** 
 * Saves the hash of the given source path to the hash file.
 * Params:
 *   sourcePath = The source path of the file to save.
 */
void saveHash(string sourcePath) {
    if (!exists(sourcePath) || !isFile(sourcePath)) return;
    ubyte[16] rawHash = md5Of(readText(sourcePath));
    string hash = Base64.encode(rawHash);
    string[string] hashes = readHashes();
    hashes[sourcePath] = hash;
    saveHashes(hashes);
}

private string[string] readHashes() {
    string[string] hashes;
    if (!exists(HASH_FILE)) return hashes;
    auto file = File(HASH_FILE, "r");
    foreach (string line; lines(file)) {
        string[] parts = split(line, ":");
        string sourcePath = parts[0].strip;
        string hashBase64 = parts[1].strip;
        hashes[sourcePath] = hashBase64;
    }
    return hashes;
}

private void saveHashes(string[string] hashes) {
    auto file = File(HASH_FILE, "w");
    foreach (string sourcePath, string hash; hashes) {
        file.writefln!"%s:%s"(sourcePath, hash);
    }
}