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

import util;
import hash;

const string SOURCE_DIR = "src";
const string BUILD_DIR = "bin";

const string[] COMPILER_FLAGS = [
    "-Wall",
    "-Os",
    "-g",
    "-DF_CPU=16000000UL",
    "-mmcu=atmega328p"
];

const string[] AVRDUDE_FLAGS = [
    "-c arduino",
    "-p m328p",
    "-P /dev/ttyUSB0",
    "-b 57600",
    "-u"
];

alias BuildCommand = int function(string[]);

int main(string[] args) {
    string command;
    if (args.length < 2) {
        command = "build";
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
    writeln("--------------------------------------------");
    writeln("Usage: ./build.d <command> [args...]");
    writeln("");
    writeln("The following commands are available:");
    writeln("  build [-f]    Compiles source code. Use -f to force rebuild.");
    writeln("                By default, sources are hashed, and only built if changes are detected.");
    writeln("                This is also the default command if none is specified.");
    writeln("  flash         Flashes code onto a connected AVR device via AVRDude.");
    writeln("  clean         Removes all build files.");
    writeln("  help          Shows this help information.");
    return 0;
}

int clean(string[] args) {
    if (!exists(BUILD_DIR)) return 0;
    rmdirRecurse(BUILD_DIR);
    return 0;
}

int buildCommand(string[] args) {
    import std.algorithm : canFind;
    return build(canFind(args, "-f"));
}

int flashCommand(string[] args) {
    string hexFilePath = buildPath(BUILD_DIR, "gympal.hex");
    if (!exists(hexFilePath)) {
        writeln("Hex file doesn't exist yet; building it now.");
        int result = buildCommand(args);
        if (result != 0) return result;
    }
    string flags = join(AVRDUDE_FLAGS, " ");
    string cmd = format!"avrdude %s -U flash:w:%s:i"(flags, hexFilePath);
    writeln(cmd);
    return run(cmd);
}

int build(bool force = false) {
    import std.datetime.stopwatch;
    if (!exists(BUILD_DIR)) mkdir(BUILD_DIR);
    string[] sources = findFiles(SOURCE_DIR, ".c");
    string[] objects;
    objects.reserve(sources.length);
    StopWatch sw = StopWatch(AutoStart.yes);
    foreach (source; sources) {
        objects ~= compileSourceToObject(source, force);
    }
    string elfFile = linkObjects(objects);
    string hexFile = copyToHex(elfFile);
    sw.stop();
    ulong durationMillis = sw.peek().total!"msecs";
    writefln!"Built %s in %d ms."(hexFile, durationMillis);
    runOrQuit("avr-size " ~ hexFile);
    return 0;
}

bool shouldCompileSource(string sourcePath) {
    return !contentMatchesHash(sourcePath);
}

string compileSourceToObject(string sourcePath, bool force = false) {
    string flags = join(COMPILER_FLAGS, " ");
    string name = baseName(sourcePath);
    name = name[0 .. name.lastIndexOf('.')];
    string objectPath = buildPath("bin", name ~ ".o");

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
    saveHash(sourcePath);
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
