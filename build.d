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
    "-Os",
    "-g",
    "-DF_CPU=16000000UL",
    "-mmcu=atmega328p"
];

alias BuildCommand = int function(string[]);

int main(string[] args) {
    string command;
    if (args.length < 2) {
        command = "help";
    } else {
        command = args[1].strip.toLower;
    }

    BuildCommand[string] commandMap = [
        "build": &buildCommand,
        "flash": &flashCommand,
        "clean": &clean,
        "help": &helpCommand
    ];

    if (command !in commandMap) {
        command = "help";
    }

    BuildCommand func = commandMap[command];
    string[] commandArgs = [];
    if (args.length > 2) commandArgs = args[2 .. $];
    return func(commandArgs);
}

int helpCommand(string[] args) {
    writeln("build.d - A simple build script for C files.");
    writeln("The following commands are available:");
    writeln("build [-f] - Compiles source code. Use -f to force rebuild.");
    writeln("  By default, sources are hashed, and only built if changes are detected.");
    writeln("flash [buildArgs] - Flashes code onto a connected AVR device via AVRDude.");
    writeln("clean - Removes all build files.");
    writeln("help - Shows this help information.");
    return 0;
}

int clean(string[] args) {
    rmdirRecurse(BUILD_DIR);
    return 0;
}

int buildCommand(string[] args) {
    import std.algorithm : canFind;
    return build(canFind(args, "-f"));
}

int flashCommand(string[] args) {
    int result = buildCommand(args);
    if (result != 0) return result;
    return flashToMCU(buildPath("bin", "gympal.hex"));
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

    string cmd = format!"avr-gcc %s -c -o %s %s"(
        flags,
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
    string cmd = format!"avr-objcopy -j .data -j .text -O ihex %s %s"(
        elfFile,
        hexFile
    );
    writeln(cmd);
    runOrQuit(cmd);
    return hexFile;
}

int flashToMCU(string hexFile) {
    string cmd = format!"avrdude -c %s -p m328p -P /dev/ttyUSB0 -b %d -u -U flash:w:%s:i"(
        BOOTLOADER,
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
