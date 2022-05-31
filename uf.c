#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <getopt.h>

#include "uf_utils.h"

extern void unionfind(uint64_t set_size, char* instruction_string, char* solution_string);

void run_tests(void);

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
                run_tests();
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

struct test_param {
    uint64_t ss; // set_size
    char* is; // instruction_stringr
    char* ess; // expected_solution_string
} test_params[] = {
    { .ss = 0, .is = "", .ess = "" },
    { .ss = 3, .is = "F0F1F2", .ess = "F0L0F1L0F2L0" },
    { .ss = 2, .is = "U0&1F0F1", .ess = "U0L0F0L0F0L1" },
    { .ss = 5, .is = "U0&1U1&2U3&4U4&2F4F4", .ess = "U0L0U0L1U3L0U0L2F0L2F0L1" },
    { .ss = 9999, .is = "F1337", .ess = "F1337L0" },
    { .ss = 2, .is = "F1U0&0U0&1U0&1U0&0", .ess = "F1L0U0L0U0L0U0L1U0L0" },
};

size_t NUM_TESTS = 6;

void run_tests() {
    size_t i;
    struct test_param tp;
    size_t passed = 0;
    int i_pass;

    char* sol = (char*) malloc(4096);

    for (i = 0; i < NUM_TESTS; i++) {
        tp = test_params[i];
        unionfind(tp.ss, tp.is, sol);
        i_pass = strncmp(sol, tp.ess, strlen(tp.ess)) == 0;
        passed += i_pass;
        printf("%s %ld \"%s\" :: \"%s\"\n", i_pass ? "✅" : "❌", tp.ss, tp.is, sol);
        if (!i_pass) printf("   expected: \"%s\"\n", tp.ess);
    }

    free(sol);
 
    printf("---\n");
    if (passed == NUM_TESTS) printf("All tests passed 🔥🔥🔥\n");
    else printf("%ld tests failed 💀\n", NUM_TESTS - passed);
}

