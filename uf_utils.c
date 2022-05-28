#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <getopt.h>

const char* usage_msg = "Usage: %s SET_SIZE INSTRUCTION\n";

const char* help_msg =
    "Führt UnionFind für INSTRUCTION aus und gibt einen ASCII String mit den\n"
    "Resultaten der Operationen aus.\n\n"
    "SET_SIZE:    Anzahl der Datenpunkte D_i\n"
    "INSTRUCTION: ASCII String, der eine Sequenz an Union/Find Anweisungen\n"
    "             als 'U' und 'F' kodiert) enthält\n";


void print_usage(const char* prog_name) {
   fprintf(stderr, usage_msg, prog_name); 
}

void print_help(const char* prog_name) {
    print_usage(prog_name);
    fprintf(stderr, "\n%s", help_msg);
}

char* putint(uint64_t value, char* string) {
    sprintf(string, "%ld", value);
    while (*string != '\0') string++;
    return string;
}

