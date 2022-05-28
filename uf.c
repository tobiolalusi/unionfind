#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <getopt.h>

#include "uf_utils.h"

extern void unionfind(uint64_t set_size, char* instruction_string, char* solution_string);

int main(int argc, char** argv) {
    { // program argument parsing
        const char* prog_name = argv[0];
        
        if (argc == 1) {
            print_usage(prog_name);
            return EXIT_FAILURE;
        }

        int opt;

        while (1) {
            int option_index = 0;
            static struct option options[] = {
                { "help",   0,  0,  'h' },
                { "test",   0,  0,  't' },
                { 0,        0,  0,  0   }
            };

            opt = getopt_long(argc, argv, "+th", options, &option_index);

            if (opt == -1) break;

            switch (opt) {
            case 'h':
                print_help(prog_name);
                return EXIT_SUCCESS;
            case 't':
                printf("executing tests...\n");
                return EXIT_SUCCESS;
            }
        }
    }

    uint64_t set_size = atol(argv[1]);
    char* instruction_string = argv[2];

    char* solution_string = (char*) malloc(131080);

    unionfind(set_size, instruction_string, solution_string);

    fprintf(stdout, "%s\n", solution_string);
    
    free(solution_string);

    return EXIT_SUCCESS;
}

