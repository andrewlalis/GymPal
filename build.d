#!/usr/bin/env rdmd
/**
 * This module is responsible for building the project.
 */
module build;

import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.path;
import std.digest.md;
import std.base64;

const string MCU_ID = "atmega328p";
const ulong CPU_FREQ = 16_000_000;
const string BOOTLOADER = "arduino";
const ulong AVRDUDE_BAUDRATE = 57_600;

const string SOURCE_DIR = "src";
const string BUILD_DIR = "bin";

const string[] COMPILER_FLAGS = [
    "-Wall",
    "-Os"
];

int main(string[] args) {
    if (args.length < 2) {
        return build();
    }
    string command = args[1].strip.toLower;
    if (command == "flash") {
        build().quitIfNonZero();
        return flashToMCU(buildPath("bin", "gympal.hex"));
    }
    if (command == "build") return build(true);
    if (command == "clean") return clean();

    writefln!"Unknown command: \"%s\"."(command);
    return 0;
}

int clean() {
    rmdirRecurse(BUILD_DIR);
    return 0;
}

int build(bool force = false) {
    if (!exists(BUILD_DIR)) mkdir(BUILD_DIR);
    string[] sources = findFiles(SOURCE_DIR, ".c");
    string[] objects;
    objects.reserve(sources.length);
    foreach (source; sources) {
        objects ~= compileSourceToObject(source, force);
    }
    string elfFile = linkObjects(objects);
    string hexFile = copyToHex(elfFile);
    writefln!"Built %s"(hexFile);
    runOrQuit("avr-size " ~ hexFile);
    return 0;
}

//-------- Utility functions below here -------

int run(string shellCommand) {
    import std.process : Pid, spawnShell, wait;
    Pid pid = spawnShell(shellCommand);
    return wait(pid);
}

void runOrQuit(string shellCommand, int[] successExitCodes = [0]) {
    import core.stdc.stdlib : exit;
    import std.algorithm : canFind;
    int result = run(shellCommand);
    if (!canFind(successExitCodes, result)) exit(result);
}

void quitIfNonZero(int n) {
    import core.stdc.stdlib : exit;
    if (n != 0) exit(n);
}

bool shouldCompileSource(string sourcePath) {
    string name = baseName(sourcePath);
    name = name[0 .. name.lastIndexOf('.')];
    string hashPath = buildPath("bin", "hash", name ~ ".md5");
    string objectPath = buildPath("bin", name ~ ".o");
    if (!exists(hashPath) || !exists(objectPath)) return true;
    ubyte[] storedHash = Base64.decode(readText(hashPath).strip());
    ubyte[16] currentHash = md5Of(readText(sourcePath));
    return storedHash != currentHash;
}

string compileSourceToObject(string sourcePath, bool force = false) {
    string flags = join(COMPILER_FLAGS, " ");
    string name = baseName(sourcePath);
    name = name[0 .. name.lastIndexOf('.')];
    string objectPath = buildPath("bin", name ~ ".o");
    string hashPath = buildPath("bin", "hash", name ~ ".md5");

    if (!force && !shouldCompileSource(sourcePath)) {
        writefln!"Not compiling %s because no changes detected."(sourcePath);
        return objectPath;
    }

    string cmd = format!"avr-gcc %s -DF_CPU=%dUL -mmcu=%s -c -o %s %s"(
        flags,
        CPU_FREQ,
        MCU_ID,
        objectPath,
        sourcePath
    );
    writeln(cmd);
    runOrQuit(cmd);

    ubyte[16] hash = md5Of(readText(sourcePath));
    string hashDir = buildPath("bin", "hash");
    if (!exists(hashDir)) mkdir(hashDir);
    std.file.write(hashPath, Base64.encode(hash));

    return objectPath;
}

string linkObjects(string[] objectPaths) {
    string objectsArg = join(objectPaths, " ");
    string flags = join(COMPILER_FLAGS, " ");
    string elfFile = buildPath(BUILD_DIR, "gympal.elf");
    string cmd = format!"avr-gcc %s -o %s %s"(
        flags,
        elfFile,
        objectsArg
    );
    writeln(cmd);
    runOrQuit(cmd);
    return elfFile;
}

string copyToHex(string elfFile) {
    string hexFile = buildPath(BUILD_DIR, "gympal.hex");
    string cmd = format!"avr-objcopy -O ihex -R .eeprom %s %s"(
        elfFile,
        hexFile
    );
    writeln(cmd);
    runOrQuit(cmd);
    return hexFile;
}

int flashToMCU(string hexFile) {
    string cmd = format!"avrdude -c %s -p %s -P /dev/ttyUSB0 -b %d flash:w:%s:i"(
        BOOTLOADER,
        MCU_ID,
        AVRDUDE_BAUDRATE,
        hexFile
    );
    writeln(cmd);
    return run(cmd);
}

string[] findFiles(string path, string suffix = null) {
    import std.array;
    import std.algorithm;
    auto app = appender!(string[]);
    foreach (DirEntry entry; dirEntries(path, SpanMode.breadth, false)) {
        if (entry.isFile && (suffix is null || entry.name.endsWith(suffix))) {
            app ~= entry.name;
        }
    }
    return app[];
}
